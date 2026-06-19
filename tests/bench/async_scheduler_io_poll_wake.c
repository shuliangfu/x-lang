/**
 * tests/bench/async_scheduler_io_poll_wake.c — IO-A5 v3 poll CQE → completion 唤醒烟测
 *
 * submit + suspend 后调用 shux_io_poll_async_completions（Linux io_uring 路径）或
 * macOS 回退 wake_all，再 drain 完成 read async。
 *
 * 编译：cc -std=c11 -o async_scheduler_io_poll_wake \
 *   tests/bench/async_scheduler_io_poll_wake.c std/io/io.o std/async/scheduler.o
 */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#define SHUX_ASYNC_SUSPENDED ((int32_t)0x41535700)
#define SHUX_IO_ASYNC_NOT_READY ((int32_t)-2)

extern int shux_io_submit_read_async(uint8_t *ptr, size_t len, size_t handle);
extern int32_t shux_io_complete_read_async_slot(int slot);
extern unsigned shux_io_poll_async_completions(unsigned timeout_ms);
extern int shux_async_cps_suspend_io(int32_t *phase, int32_t next_phase);
extern int shux_async_task_submit(int32_t (*fn)(void));
extern int32_t shux_async_scheduler_drain(void);
extern void shux_async_queue_reset(void);
extern void shux_async_io_wake_all(void);
extern uint32_t shux_async_io_waiters_pending(void);

static int g_read_fd;
static uint8_t g_buf[16];
static int32_t g_phase;
static int g_step;
static int g_slot;
static int32_t g_result;

/**
 * 协程体：submit(slot) → suspend_io；resume 后 complete_slot。
 */
static int32_t io_read_task(void) {
    int32_t n;
    if (g_step == 0) {
        g_step = 1;
        g_phase = 0;
        g_slot = shux_io_submit_read_async(g_buf, sizeof(g_buf), (size_t)(unsigned)g_read_fd);
        if (g_slot < 0)
            return -1;
        if (shux_async_cps_suspend_io(&g_phase, 1))
            return SHUX_ASYNC_SUSPENDED;
    }
    n = shux_io_complete_read_async_slot(g_slot);
    if (n == SHUX_IO_ASYNC_NOT_READY)
        n = shux_io_complete_read_async_slot(g_slot);
    g_result = n;
    return n;
}

/**
 * 入口：pipe 喂数 + poll/wake + drain（Linux 优先 poll 路径）。
 */
int main(void) {
    int fds[2];
    int32_t r;
    unsigned polled;

    if (pipe(fds) != 0) {
        fprintf(stderr, "async_scheduler_io_poll_wake: pipe failed\n");
        return 1;
    }
    if (write(fds[1], "abc", 3) != 3) {
        fprintf(stderr, "async_scheduler_io_poll_wake: write failed\n");
        return 2;
    }
    (void)close(fds[1]);

    setenv("SHUX_ASYNC_YIELD", "1", 1);
    unsetenv("SHUX_ASYNC_IO_WAIT");

    g_read_fd = fds[0];
    g_step = 0;
    g_phase = 0;
    g_result = -99;
    memset(g_buf, 0, sizeof(g_buf));

    shux_async_queue_reset();
    if (shux_async_task_submit(io_read_task) != 0) {
        fprintf(stderr, "async_scheduler_io_poll_wake: submit failed\n");
        return 3;
    }

    r = shux_async_scheduler_drain();
    if (r != 0) {
        fprintf(stderr, "async_scheduler_io_poll_wake: first drain got %d want 0\n", (int)r);
        return 4;
    }
    if (shux_async_io_waiters_pending() != 1) {
        fprintf(stderr, "async_scheduler_io_poll_wake: waiters=%u want 1\n",
            (unsigned)shux_async_io_waiters_pending());
        return 5;
    }

    polled = shux_io_poll_async_completions(500);
#if defined(__linux__)
    if (polled == 0) {
        fprintf(stderr, "async_scheduler_io_poll_wake: poll got 0 on Linux\n");
        return 6;
    }
#else
    if (polled == 0)
        shux_async_io_wake_all();
#endif

    r = shux_async_scheduler_drain();
    if (r != 3) {
        fprintf(stderr, "async_scheduler_io_poll_wake: second drain got %d want 3\n", (int)r);
        return 7;
    }
    if (g_result != 3 || memcmp(g_buf, "abc", 3) != 0) {
        fprintf(stderr, "async_scheduler_io_poll_wake: payload mismatch\n");
        return 8;
    }

    (void)close(fds[0]);
    return 0;
}
