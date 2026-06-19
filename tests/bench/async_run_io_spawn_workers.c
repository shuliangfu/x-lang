/**
 * tests/bench/async_run_io_spawn_workers.c — A4 v5 spawn 并行 IO + SHUX_ASYNC_WORKERS=2
 *
 * 双 pipe + 双 task submit（round-robin 至 worker 0/1）+ drain_until_idle + poll。
 *
 * 编译：cc -std=c11 -pthread -o async_run_io_spawn_workers \
 *   tests/bench/async_run_io_spawn_workers.c std/io/io.o std/async/scheduler.o
 * 运行：SHUX_ASYNC_YIELD=1 SHUX_ASYNC_WORKERS=2 ./async_run_io_spawn_workers
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define SHUX_ASYNC_SUSPENDED ((int32_t)0x41535700)
#define SHUX_IO_ASYNC_NOT_READY ((int32_t)-2)

extern int shux_io_submit_read_async(uint8_t *ptr, size_t len, size_t handle);
extern int32_t shux_io_complete_read_async_slot(int slot);
extern unsigned shux_io_poll_async_completions(unsigned timeout_ms);
extern int shux_async_cps_suspend_io(int32_t *phase, int32_t next_phase);
extern int shux_async_task_submit(int32_t (*fn)(void));
extern int32_t shux_async_run_drain_until_idle(void);
extern void shux_async_queue_reset(void);
extern void shux_async_run_seed_push_i32(int32_t v);
extern int shux_async_run_seed_valid(void);
extern int32_t shux_async_run_seed_take_i32(void);
extern uint32_t shux_async_worker_count(void);
extern uint32_t shux_async_io_waiters_pending(void);

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
        /* fd 由 main 预设；勿用全局 seed FIFO（并行 worker 时 seed 非线程安全）。 */
        ctx->step = 1;
        ctx->phase = 0;
        ctx->slot = shux_io_submit_read_async(ctx->buf, sizeof(ctx->buf),
            (size_t)(unsigned)ctx->read_fd);
        if (ctx->slot < 0)
            return -1;
        if (shux_async_cps_suspend_io(&ctx->phase, 1))
            return SHUX_ASYNC_SUSPENDED;
    }
    n = shux_io_complete_read_async_slot(ctx->slot);
    if (n == SHUX_IO_ASYNC_NOT_READY) {
#if defined(__linux__)
        (void)shux_io_poll_async_completions(500);
#endif
        n = shux_io_complete_read_async_slot(ctx->slot);
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
 * 入口：SHUX_ASYNC_WORKERS=2 + spawn 并行 IO drain。
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

    setenv("SHUX_ASYNC_YIELD", "1", 1);
    setenv("SHUX_ASYNC_WORKERS", "2", 1);
    unsetenv("SHUX_ASYNC_IO_WAIT");

    if (shux_async_worker_count() != 2) {
        fprintf(stderr, "async_run_io_spawn_workers: worker_count=%u want 2\n",
            (unsigned)shux_async_worker_count());
        return 3;
    }

    memset(&g_ctx_a, 0, sizeof(g_ctx_a));
    memset(&g_ctx_b, 0, sizeof(g_ctx_b));
    g_ctx_a.read_fd = fds_a[0];
    g_ctx_b.read_fd = fds_b[0];

    shux_async_queue_reset();
    if (shux_async_task_submit(io_spawn_read_a) != 0) {
        fprintf(stderr, "async_run_io_spawn_workers: submit a failed\n");
        return 4;
    }
    if (shux_async_task_submit(io_spawn_read_b) != 0) {
        fprintf(stderr, "async_run_io_spawn_workers: submit b failed\n");
        return 5;
    }

    total = shux_async_run_drain_until_idle();
    if (total != 5) {
        fprintf(stderr, "async_run_io_spawn_workers: total=%d want 5\n", (int)total);
        return 6;
    }
    if (shux_async_io_waiters_pending() != 0) {
        fprintf(stderr, "async_run_io_spawn_workers: io waiters=%u\n",
            (unsigned)shux_async_io_waiters_pending());
        return 7;
    }

    (void)close(fds_a[0]);
    (void)close(fds_b[0]);
    return 0;
}
