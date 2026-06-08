/**
 * tests/bench/async_scheduler_io_read_e2e.c — IO-A5 scheduler + read async 端到端烟测
 *
 * 模拟 codegen 路径：submit_read_async → suspend_io → IO 等待队列 → wake → complete。
 * 父进程写 pipe；子任务 drain/wake/drain 读回 3 字节。
 *
 * 编译：cc -std=c11 -o async_scheduler_io_read_e2e tests/bench/async_scheduler_io_read_e2e.c \
 *       std/io/io.o std/async/scheduler.o
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
extern int32_t shu_io_complete_read_async(void);
extern int shu_async_cps_suspend_io(int32_t *phase, int32_t next_phase);
extern int shu_async_task_submit(int32_t (*fn)(void));
extern int32_t shu_async_scheduler_drain(void);
extern int32_t shu_async_run_drain_until_idle(void);
extern void shu_async_queue_reset(void);
extern void shu_async_io_wake_all(void);
extern uint32_t shu_async_io_waiters_pending(void);
extern unsigned shu_io_poll_async_completions(unsigned timeout_ms);

static int g_read_fd;
static uint8_t g_buf[16];
static int32_t g_phase;
static int g_step;
static int32_t g_result;

/**
 * 协程体：submit → suspend_io；resume 后 complete 并写入 g_result。
 */
static int32_t io_read_task(void) {
    int32_t n;
    if (g_step == 0) {
        g_step = 1;
        g_phase = 0;
        if (shu_io_submit_read_async(g_buf, sizeof(g_buf), (size_t)(unsigned)g_read_fd) < 0)
            return -1;
        if (shu_async_cps_suspend_io(&g_phase, 1))
            return SHU_ASYNC_SUSPENDED;
    }
    n = shu_io_complete_read_async();
    if (n == SHU_IO_ASYNC_NOT_READY) {
        if (shu_async_cps_suspend_io(&g_phase, 1))
            return SHU_ASYNC_SUSPENDED;
        n = shu_io_complete_read_async();
    }
    g_result = n;
    return n;
}

/**
 * 入口：pipe 喂数据 + scheduler IO 等待/wake 全路径。
 */
int main(void) {
    int fds[2];
    int32_t r;

    if (pipe(fds) != 0) {
        fprintf(stderr, "async_scheduler_io_read_e2e: pipe failed\n");
        return 1;
    }
    if (write(fds[1], "xyz", 3) != 3) {
        fprintf(stderr, "async_scheduler_io_read_e2e: write failed\n");
        return 2;
    }
    (void)close(fds[1]);

    setenv("SHU_ASYNC_YIELD", "1", 1);
    unsetenv("SHU_ASYNC_IO_WAIT");

    g_read_fd = fds[0];
    g_step = 0;
    g_phase = 0;
    g_result = -99;
    memset(g_buf, 0, sizeof(g_buf));

    shu_async_queue_reset();
    if (shu_async_task_submit(io_read_task) != 0) {
        fprintf(stderr, "async_scheduler_io_read_e2e: submit failed\n");
        return 3;
    }

    r = shu_async_scheduler_drain();
    if (r != 0) {
        fprintf(stderr, "async_scheduler_io_read_e2e: first drain got %d want 0\n", (int)r);
        return 4;
    }
    if (shu_async_io_waiters_pending() != 1) {
        fprintf(stderr, "async_scheduler_io_read_e2e: waiters=%u want 1\n",
            (unsigned)shu_async_io_waiters_pending());
        return 5;
    }

    (void)shu_io_poll_async_completions(500);
    r = shu_async_run_drain_until_idle();
    if (r != 3) {
        fprintf(stderr, "async_scheduler_io_read_e2e: second drain got %d want 3\n", (int)r);
        return 6;
    }
    if (g_result != 3 || g_buf[0] != 'x' || g_buf[1] != 'y' || g_buf[2] != 'z') {
        fprintf(stderr, "async_scheduler_io_read_e2e: payload mismatch\n");
        return 7;
    }

    (void)close(fds[0]);
    return 0;
}
