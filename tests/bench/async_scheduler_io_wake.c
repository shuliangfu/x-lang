/**
 * tests/bench/async_scheduler_io_wake.c — IO-A5 IO 等待队列 + completion 唤醒烟测
 *
 * SHU_ASYNC_YIELD=1 + SHU_ASYNC_IO_WAIT=1：suspend 任务进 IO 等待队列；
 * shu_async_io_wake_all 后 drain 完成。
 *
 * 编译：cc -std=c11 -o async_scheduler_io_wake tests/bench/async_scheduler_io_wake.c std/async/scheduler.o
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define SHU_ASYNC_SUSPENDED ((int32_t)0x41535700)

extern int shu_async_task_submit(int32_t (*fn)(void));
extern int32_t shu_async_scheduler_drain(void);
extern void shu_async_queue_reset(void);
extern void shu_async_io_wake_all(void);
extern uint32_t shu_async_io_waiters_pending(void);

static int g_step;

/**
 * 首次 SUSPENDED（进 IO 等待队列），二次返回 42。
 */
static int32_t io_task(void) {
    if (g_step == 0) {
        g_step = 1;
        return SHU_ASYNC_SUSPENDED;
    }
    return 42;
}

/**
 * 入口：验证 IO 等待 + wake + drain 路径。
 */
int main(void) {
    int32_t r;

    setenv("SHU_ASYNC_YIELD", "1", 1);
    setenv("SHU_ASYNC_IO_WAIT", "1", 1);

    shu_async_queue_reset();
    g_step = 0;

    if (shu_async_task_submit(io_task) != 0) {
        fprintf(stderr, "async_scheduler_io_wake: submit failed\n");
        return 1;
    }
    r = shu_async_scheduler_drain();
    if (r != 0) {
        fprintf(stderr, "async_scheduler_io_wake: first drain got %d want 0 (io wait)\n", (int)r);
        return 2;
    }
    if (shu_async_io_waiters_pending() != 1) {
        fprintf(stderr, "async_scheduler_io_wake: waiters=%u want 1\n",
            (unsigned)shu_async_io_waiters_pending());
        return 3;
    }

    shu_async_io_wake_all();
    if (shu_async_io_waiters_pending() != 0) {
        fprintf(stderr, "async_scheduler_io_wake: waiters not empty after wake\n");
        return 4;
    }

    r = shu_async_scheduler_drain();
    if (r != 42) {
        fprintf(stderr, "async_scheduler_io_wake: second drain got %d want 42\n", (int)r);
        return 5;
    }
    return 0;
}
