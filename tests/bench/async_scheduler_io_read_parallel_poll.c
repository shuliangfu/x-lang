/**
 * tests/bench/async_scheduler_io_read_parallel_poll.c — IO-A5 v4 双协程并行 + poll 唤醒
 *
 * 两路 pipe 各 submit 一个 read async；Linux 上 shu_io_poll_async_completions 唤醒；
 * macOS 回退 wake_all。与 multi_e2e 相同语义，验证 poll 路径。
 *
 * 编译：cc -std=c11 -o async_scheduler_io_read_parallel_poll \
 *   tests/bench/async_scheduler_io_read_parallel_poll.c std/io/io.o std/async/scheduler.o
 */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#define SHU_ASYNC_SUSPENDED ((int32_t)0x41535700)
#define SHU_IO_ASYNC_NOT_READY ((int32_t)-2)

extern int shu_io_submit_read_async(uint8_t *ptr, size_t len, size_t handle);
extern int32_t shu_io_complete_read_async_slot(int slot);
extern unsigned shu_io_poll_async_completions(unsigned timeout_ms);
extern int shu_async_cps_suspend_io(int32_t *phase, int32_t next_phase);
extern int shu_async_task_submit(int32_t (*fn)(void));
extern int32_t shu_async_scheduler_drain(void);
extern void shu_async_queue_reset(void);
extern void shu_async_io_wake_all(void);
extern uint32_t shu_async_io_waiters_pending(void);

/** 单协程 read async 上下文。 */
typedef struct {
    int read_fd;
    uint8_t buf[16];
    int32_t phase;
    int step;
    int slot;
    int32_t result;
    int expect_len;
    const char *expect;
} io_read_ctx_t;

static io_read_ctx_t g_task_a;
static io_read_ctx_t g_task_b;

/**
 * 单任务协程体：submit(slot) → suspend_io；resume 后 complete_slot。
 */
static int32_t io_read_task_impl(io_read_ctx_t *ctx) {
    int32_t n;
    if (!ctx)
        return -1;
    if (ctx->step == 0) {
        ctx->step = 1;
        ctx->phase = 0;
        ctx->slot = shu_io_submit_read_async(ctx->buf, sizeof(ctx->buf),
            (size_t)(unsigned)ctx->read_fd);
        if (ctx->slot < 0)
            return -1;
        if (shu_async_cps_suspend_io(&ctx->phase, 1))
            return SHU_ASYNC_SUSPENDED;
    }
    n = shu_io_complete_read_async_slot(ctx->slot);
    if (n == SHU_IO_ASYNC_NOT_READY)
        n = shu_io_complete_read_async_slot(ctx->slot);
    ctx->result = n;
    return n;
}

/** 任务 A 入口。 */
static int32_t io_read_task_a(void) {
    return io_read_task_impl(&g_task_a);
}

/** 任务 B 入口。 */
static int32_t io_read_task_b(void) {
    return io_read_task_impl(&g_task_b);
}

/**
 * 校验单任务读回字节数与内容。
 */
static int check_task(const io_read_ctx_t *ctx, const char *label) {
    if (!ctx || !label)
        return 1;
    if (ctx->result != ctx->expect_len) {
        fprintf(stderr, "async_scheduler_io_read_parallel_poll: %s len=%d want %d\n",
            label, (int)ctx->result, ctx->expect_len);
        return 2;
    }
    if (memcmp(ctx->buf, ctx->expect, (size_t)ctx->expect_len) != 0) {
        fprintf(stderr, "async_scheduler_io_read_parallel_poll: %s payload mismatch\n", label);
        return 3;
    }
    return 0;
}

/**
 * 入口：双 pipe + 双 task submit + poll/wake + drain。
 */
int main(void) {
    int fds_a[2];
    int fds_b[2];
    int32_t r;
    int chk;
    unsigned polled;

    if (pipe(fds_a) != 0 || pipe(fds_b) != 0) {
        fprintf(stderr, "async_scheduler_io_read_parallel_poll: pipe failed\n");
        return 1;
    }
    if (write(fds_a[1], "ab", 2) != 2 || write(fds_b[1], "xyz", 3) != 3) {
        fprintf(stderr, "async_scheduler_io_read_parallel_poll: write failed\n");
        return 2;
    }
    (void)close(fds_a[1]);
    (void)close(fds_b[1]);

    setenv("SHU_ASYNC_YIELD", "1", 1);
    unsetenv("SHU_ASYNC_IO_WAIT");

    memset(&g_task_a, 0, sizeof(g_task_a));
    memset(&g_task_b, 0, sizeof(g_task_b));
    g_task_a.read_fd = fds_a[0];
    g_task_a.expect = "ab";
    g_task_a.expect_len = 2;
    g_task_a.result = -99;
    g_task_b.read_fd = fds_b[0];
    g_task_b.expect = "xyz";
    g_task_b.expect_len = 3;
    g_task_b.result = -99;

    shu_async_queue_reset();
    if (shu_async_task_submit(io_read_task_a) != 0
        || shu_async_task_submit(io_read_task_b) != 0) {
        fprintf(stderr, "async_scheduler_io_read_parallel_poll: submit failed\n");
        return 3;
    }

    r = shu_async_scheduler_drain();
    if (r != 0) {
        fprintf(stderr, "async_scheduler_io_read_parallel_poll: first drain got %d want 0\n", (int)r);
        return 4;
    }
    if (shu_async_io_waiters_pending() != 2) {
        fprintf(stderr, "async_scheduler_io_read_parallel_poll: waiters=%u want 2\n",
            (unsigned)shu_async_io_waiters_pending());
        return 5;
    }

    polled = shu_io_poll_async_completions(500);
#if defined(__linux__)
    if (polled == 0) {
        fprintf(stderr, "async_scheduler_io_read_parallel_poll: poll got 0 on Linux\n");
        return 6;
    }
#else
    if (polled == 0)
        shu_async_io_wake_all();
#endif

    (void)shu_async_scheduler_drain();

    chk = check_task(&g_task_a, "task_a");
    if (chk != 0)
        return 10 + chk;
    chk = check_task(&g_task_b, "task_b");
    if (chk != 0)
        return 20 + chk;

    (void)close(fds_a[0]);
    (void)close(fds_b[0]);
    return 0;
}
