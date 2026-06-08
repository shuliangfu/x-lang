/**
 * tests/bench/async_run_io_spawn_workers.c — A4 v5 spawn 并行 IO + SHU_ASYNC_WORKERS=2
 *
 * 双 pipe + 双 task submit（round-robin 至 worker 0/1）+ drain_until_idle + poll。
 *
 * 编译：cc -std=c11 -pthread -o async_run_io_spawn_workers \
 *   tests/bench/async_run_io_spawn_workers.c std/io/io.o std/async/scheduler.o
 * 运行：SHU_ASYNC_YIELD=1 SHU_ASYNC_WORKERS=2 ./async_run_io_spawn_workers
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define SHU_ASYNC_SUSPENDED ((int32_t)0x41535700)
#define SHU_IO_ASYNC_NOT_READY ((int32_t)-2)

extern int shu_io_submit_read_async(uint8_t *ptr, size_t len, size_t handle);
extern int32_t shu_io_complete_read_async_slot(int slot);
extern unsigned shu_io_poll_async_completions(unsigned timeout_ms);
extern int shu_async_cps_suspend_io(int32_t *phase, int32_t next_phase);
extern int shu_async_task_submit(int32_t (*fn)(void));
extern int32_t shu_async_run_drain_until_idle(void);
extern void shu_async_queue_reset(void);
extern void shu_async_run_seed_push_i32(int32_t v);
extern int shu_async_run_seed_valid(void);
extern int32_t shu_async_run_seed_take_i32(void);
extern uint32_t shu_async_worker_count(void);
extern uint32_t shu_async_io_waiters_pending(void);

/** 单协程 read async + seed 注入上下文。 */
typedef struct {
    int read_fd;
    uint8_t buf[16];
    int32_t phase;
    int step;
    int slot;
} io_spawn_ctx_t;

static io_spawn_ctx_t g_ctx_a;
static io_spawn_ctx_t g_ctx_b;

/**
 * 单任务：phase 0 从 seed 取 fd → submit → suspend_io；resume 后 complete。
 */
static int32_t io_spawn_read_task(io_spawn_ctx_t *ctx) {
    int32_t n;
    if (!ctx)
        return -1;
    if (ctx->step == 0) {
        if (shu_async_run_seed_valid())
            ctx->read_fd = shu_async_run_seed_take_i32();
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
    if (n == SHU_IO_ASYNC_NOT_READY) {
        (void)shu_io_poll_async_completions(500);
        n = shu_io_complete_read_async_slot(ctx->slot);
    }
    return n;
}

/** 任务 A 入口。 */
static int32_t io_spawn_read_a(void) {
    return io_spawn_read_task(&g_ctx_a);
}

/** 任务 B 入口。 */
static int32_t io_spawn_read_b(void) {
    return io_spawn_read_task(&g_ctx_b);
}

/**
 * 入口：SHU_ASYNC_WORKERS=2 + spawn 并行 IO drain。
 */
int main(void) {
    int fds_a[2];
    int fds_b[2];
    int32_t total;

    if (pipe(fds_a) != 0 || pipe(fds_b) != 0) {
        fprintf(stderr, "async_run_io_spawn_workers: pipe failed\n");
        return 1;
    }
    if (write(fds_a[1], "ab", 2) != 2 || write(fds_b[1], "xyz", 3) != 3) {
        fprintf(stderr, "async_run_io_spawn_workers: write failed\n");
        return 2;
    }
    (void)close(fds_a[1]);
    (void)close(fds_b[1]);

    setenv("SHU_ASYNC_YIELD", "1", 1);
    setenv("SHU_ASYNC_WORKERS", "2", 1);
    unsetenv("SHU_ASYNC_IO_WAIT");

    if (shu_async_worker_count() != 2) {
        fprintf(stderr, "async_run_io_spawn_workers: worker_count=%u want 2\n",
            (unsigned)shu_async_worker_count());
        return 3;
    }

    memset(&g_ctx_a, 0, sizeof(g_ctx_a));
    memset(&g_ctx_b, 0, sizeof(g_ctx_b));

    shu_async_queue_reset();
    shu_async_run_seed_push_i32(fds_a[0]);
    if (shu_async_task_submit(io_spawn_read_a) != 0) {
        fprintf(stderr, "async_run_io_spawn_workers: submit a failed\n");
        return 4;
    }
    shu_async_run_seed_push_i32(fds_b[0]);
    if (shu_async_task_submit(io_spawn_read_b) != 0) {
        fprintf(stderr, "async_run_io_spawn_workers: submit b failed\n");
        return 5;
    }

    total = shu_async_run_drain_until_idle();
    if (total != 5) {
        fprintf(stderr, "async_run_io_spawn_workers: total=%d want 5\n", (int)total);
        return 6;
    }
    if (shu_async_io_waiters_pending() != 0) {
        fprintf(stderr, "async_run_io_spawn_workers: io waiters=%u\n",
            (unsigned)shu_async_io_waiters_pending());
        return 7;
    }

    (void)close(fds_a[0]);
    (void)close(fds_b[0]);
    return 0;
}
