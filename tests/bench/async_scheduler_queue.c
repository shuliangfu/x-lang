/**
 * tests/bench/async_scheduler_queue.c — A4 就绪队列烟测
 *
 * 验证 shux_async_task_submit + shux_async_scheduler_drain：
 *   1) 单任务一次 suspend 后 resume 完成；
 *   2) 双任务穿插（先 suspend 的任务让出，immediate 任务先完成）。
 *
 * 编译：cc -o async_scheduler_queue tests/bench/async_scheduler_queue.c std/async/scheduler.o
 */
#include <stdint.h>
#include <stdio.h>

/** 与 scheduler.c SHUX_ASYNC_SUSPENDED 一致。 */
#define SHUX_ASYNC_SUSPENDED ((int32_t)0x41535700)

extern int shux_async_task_submit(int32_t (*fn)(void));
extern int32_t shux_async_scheduler_drain(void);

/** 单步 suspend 任务的状态。 */
static int g_step_a;

/**
 * 首次调用返回 SUSPENDED，二次返回 77。
 */
static int32_t task_suspend_once(void) {
    if (g_step_a == 0) {
        g_step_a = 1;
        return SHUX_ASYNC_SUSPENDED;
    }
    return 77;
}

/**
 * 无 suspend，立即返回 88。
 */
static int32_t task_immediate(void) {
    return 88;
}

/**
 * 入口：跑两组 drain 场景，失败时非零退出。
 */
int main(void) {
    int32_t r;

    /* 单任务：suspend 一次后 drain 内二次 poll 完成 */
    g_step_a = 0;
    if (shux_async_task_submit(task_suspend_once) != 0) {
        fprintf(stderr, "async_scheduler_queue: submit single failed\n");
        return 1;
    }
    r = shux_async_scheduler_drain();
    if (r != 77) {
        fprintf(stderr, "async_scheduler_queue: single drain got %d want 77\n", (int)r);
        return 2;
    }

    /* 双任务：A suspend → B 完成 → A resume */
    g_step_a = 0;
    if (shux_async_task_submit(task_suspend_once) != 0) {
        fprintf(stderr, "async_scheduler_queue: submit A failed\n");
        return 3;
    }
    if (shux_async_task_submit(task_immediate) != 0) {
        fprintf(stderr, "async_scheduler_queue: submit B failed\n");
        return 4;
    }
    r = shux_async_scheduler_drain();
    if (r != 77) {
        fprintf(stderr, "async_scheduler_queue: two-task drain got %d want 77\n", (int)r);
        return 5;
    }

    return 0;
}
