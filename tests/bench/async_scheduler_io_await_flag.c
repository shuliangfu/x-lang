/**
 * tests/bench/async_scheduler_io_await_flag.c — IO-A5 shu_async_cps_suspend_io 烟测
 *
 * 仅 SHU_ASYNC_YIELD=1（无 SHU_ASYNC_IO_WAIT）：IO await suspend 仍进 IO 等待队列。
 *
 * 编译：cc -std=c11 -o async_scheduler_io_await_flag tests/bench/async_scheduler_io_await_flag.c std/async/scheduler.o
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define SHU_ASYNC_SUSPENDED ((int32_t)0x41535700)

extern int shu_async_cps_suspend_io(int32_t *phase, int32_t next_phase);
extern int shu_async_task_submit(int32_t (*fn)(void));
extern int32_t shu_async_scheduler_drain(void);
extern void shu_async_queue_reset(void);
extern void shu_async_io_wake_all(void);
extern uint32_t shu_async_io_waiters_pending(void);

static int32_t g_phase;
static int g_step;

/**
 * 首次经 suspend_io yield 进 IO 等待队列，resume 后返回 77。
 */
static int32_t io_await_task(void) {
    if (g_step == 0) {
        g_step = 1;
        g_phase = 0;
        if (shu_async_cps_suspend_io(&g_phase, 1))
            return SHU_ASYNC_SUSPENDED;
    }
    return 77;
}

/**
 * 入口：验证 suspend_io 标记路径（无需 SHU_ASYNC_IO_WAIT 环境变量）。
 */
int main(void) {
    int32_t r;

    setenv("SHU_ASYNC_YIELD", "1", 1);
    unsetenv("SHU_ASYNC_IO_WAIT");

    shu_async_queue_reset();
    g_step = 0;
    g_phase = 0;

    if (shu_async_task_submit(io_await_task) != 0) {
        fprintf(stderr, "async_scheduler_io_await_flag: submit failed\n");
        return 1;
    }
    r = shu_async_scheduler_drain();
    if (r != 0) {
        fprintf(stderr, "async_scheduler_io_await_flag: first drain got %d want 0\n", (int)r);
        return 2;
    }
    if (shu_async_io_waiters_pending() != 1) {
        fprintf(stderr, "async_scheduler_io_await_flag: waiters=%u want 1\n",
            (unsigned)shu_async_io_waiters_pending());
        return 3;
    }

    shu_async_io_wake_all();
    r = shu_async_scheduler_drain();
    if (r != 77) {
        fprintf(stderr, "async_scheduler_io_await_flag: second drain got %d want 77\n", (int)r);
        return 4;
    }
    return 0;
}
