/**
 * tests/bench/async_scheduler_io_write_multi_e2e.c — 双协程并行 write async + scheduler IO wake
 *
 * 两路 pipe 各 submit 一个 write async（slot 池 v2），双任务 suspend_io 后进等待队列，
 * wake_all 后 complete_write_async_slot 写入 "ab" 与 "xyz"。
 *
 * 编译：cc -std=c11 -o async_scheduler_io_write_multi_e2e \
 *   tests/bench/async_scheduler_io_write_multi_e2e.c std/io/io.o std/async/scheduler.o
 */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#define SHU_ASYNC_SUSPENDED ((int32_t)0x41535700)
#define SHU_IO_ASYNC_NOT_READY ((int32_t)-2)

extern int shu_io_submit_write_async(const uint8_t *ptr, size_t len, size_t handle);
extern int32_t shu_io_complete_write_async_slot(int slot);
extern int shu_async_cps_suspend_io(int32_t *phase, int32_t next_phase);
extern int shu_async_task_submit(int32_t (*fn)(void));
extern int32_t shu_async_scheduler_drain(void);
extern int32_t shu_async_run_drain_until_idle(void);
extern void shu_async_queue_reset(void);
extern void shu_async_io_wake_all(void);
extern uint32_t shu_async_io_waiters_pending(void);
extern unsigned shu_io_poll_async_completions(unsigned timeout_ms);

/** 单协程 write async 上下文。 */
typedef struct {
    int write_fd;
    uint8_t payload[8];
    int payload_len;
    int32_t phase;
    int step;
    int slot;
    int32_t result;
    int read_fd;
} io_write_ctx_t;

static io_write_ctx_t g_task_a;
static io_write_ctx_t g_task_b;

/**
 * 单任务协程体：submit(slot) → suspend_io；resume 后 complete_slot。
 */
static int32_t io_write_task_impl(io_write_ctx_t *ctx) {
    int32_t n;
    if (!ctx)
        return -1;
    if (ctx->step == 0) {
        ctx->step = 1;
        ctx->phase = 0;
        ctx->slot = shu_io_submit_write_async(ctx->payload, (size_t)ctx->payload_len,
            (size_t)(unsigned)ctx->write_fd);
        if (ctx->slot < 0)
            return -1;
        if (shu_async_cps_suspend_io(&ctx->phase, 1))
            return SHU_ASYNC_SUSPENDED;
    }
    n = shu_io_complete_write_async_slot(ctx->slot);
    while (n == SHU_IO_ASYNC_NOT_READY) {
#if defined(__linux__)
        (void)shu_io_poll_async_completions(50);
#else
        shu_async_io_wake_all();
#endif
        n = shu_io_complete_write_async_slot(ctx->slot);
    }
    ctx->result = n;
    return n;
}

/** 任务 A 入口。 */
static int32_t io_write_task_a(void) {
    return io_write_task_impl(&g_task_a);
}

/** 任务 B 入口。 */
static int32_t io_write_task_b(void) {
    return io_write_task_impl(&g_task_b);
}

/**
 * 校验 pipe 读回内容与期望一致。
 */
static int check_writeback(const io_write_ctx_t *ctx, const char *label) {
    uint8_t buf[16];
    ssize_t nr;
    if (!ctx || !label)
        return 1;
    if (ctx->result != ctx->payload_len) {
        fprintf(stderr, "async_scheduler_io_write_multi_e2e: %s result=%d want %d\n",
            label, (int)ctx->result, ctx->payload_len);
        return 2;
    }
    memset(buf, 0, sizeof(buf));
    nr = read(ctx->read_fd, buf, sizeof(buf));
    if (nr != ctx->payload_len) {
        fprintf(stderr, "async_scheduler_io_write_multi_e2e: %s readback=%zd want %d\n",
            label, nr, ctx->payload_len);
        return 3;
    }
    if (memcmp(buf, ctx->payload, (size_t)ctx->payload_len) != 0) {
        fprintf(stderr, "async_scheduler_io_write_multi_e2e: %s payload mismatch\n", label);
        return 4;
    }
    return 0;
}

/**
 * 入口：双 pipe + 双 task submit/drain/wake/drain。
 */
int main(void) {
    int fds_a[2];
    int fds_b[2];
    int32_t r;
    int chk;

    if (pipe(fds_a) != 0 || pipe(fds_b) != 0) {
        fprintf(stderr, "async_scheduler_io_write_multi_e2e: pipe failed\n");
        return 1;
    }

    setenv("SHU_ASYNC_YIELD", "1", 1);
    unsetenv("SHU_ASYNC_IO_WAIT");

    memset(&g_task_a, 0, sizeof(g_task_a));
    memset(&g_task_b, 0, sizeof(g_task_b));
    g_task_a.write_fd = fds_a[1];
    g_task_a.read_fd = fds_a[0];
    g_task_a.payload[0] = 'a';
    g_task_a.payload[1] = 'b';
    g_task_a.payload_len = 2;
    g_task_b.write_fd = fds_b[1];
    g_task_b.read_fd = fds_b[0];
    g_task_b.payload[0] = 'x';
    g_task_b.payload[1] = 'y';
    g_task_b.payload[2] = 'z';
    g_task_b.payload_len = 3;

    shu_async_queue_reset();
    if (shu_async_task_submit(io_write_task_a) != 0
        || shu_async_task_submit(io_write_task_b) != 0) {
        fprintf(stderr, "async_scheduler_io_write_multi_e2e: submit failed\n");
        return 2;
    }

    r = shu_async_scheduler_drain();
    if (r != 0) {
        fprintf(stderr, "async_scheduler_io_write_multi_e2e: first drain got %d want 0\n", (int)r);
        return 3;
    }
    if (shu_async_io_waiters_pending() != 2) {
        fprintf(stderr, "async_scheduler_io_write_multi_e2e: waiters=%u want 2\n",
            (unsigned)shu_async_io_waiters_pending());
        return 4;
    }

    (void)shu_io_poll_async_completions(500);
    (void)shu_async_run_drain_until_idle();

    (void)close(fds_a[1]);
    (void)close(fds_b[1]);

    chk = check_writeback(&g_task_a, "task_a");
    if (chk != 0)
        return 10 + chk;
    chk = check_writeback(&g_task_b, "task_b");
    if (chk != 0)
        return 20 + chk;

    (void)close(fds_a[0]);
    (void)close(fds_b[0]);
    return 0;
}
