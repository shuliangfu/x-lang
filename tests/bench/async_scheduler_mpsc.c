/**
 * tests/bench/async_scheduler_mpsc.c — A4 MPSC 就绪队列烟测（双线程 submit + 主线程 drain）
 *
 * 两生产者线程各 submit 一次-suspend 任务，主线程 drain 至全部完成。
 * 编译：cc -std=c11 -pthread -o async_scheduler_mpsc tests/bench/async_scheduler_mpsc.c std/async/scheduler.o
 */
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>

/** 与 scheduler.c SHUX_ASYNC_SUSPENDED 一致。 */
#define SHUX_ASYNC_SUSPENDED ((int32_t)0x41535700)

extern int shux_async_task_submit(int32_t (*fn)(void));
extern int32_t shux_async_scheduler_drain(void);
extern void shux_async_queue_reset(void);

/** 任务 A：首次 SUSPENDED，二次返回 10。 */
static int g_step_a;

static int32_t task_a(void) {
    if (g_step_a == 0) {
        g_step_a = 1;
        return SHUX_ASYNC_SUSPENDED;
    }
    return 10;
}

/** 任务 B：无 suspend，立即返回 20。 */
static int32_t task_b(void) {
    return 20;
}

/** 生产者线程参数。 */
typedef struct {
    int32_t (*fn)(void);
    int expect_ok;
} submit_arg_t;

/**
 * 线程入口：向就绪队列 submit 一个任务。
 */
static void *submit_thread(void *arg) {
    submit_arg_t *a = (submit_arg_t *)arg;
    if (shux_async_task_submit(a->fn) != a->expect_ok) {
        return (void *)1;
    }
    return NULL;
}

/**
 * 入口：双线程 submit + 主线程 drain；失败非零退出。
 */
int main(void) {
    pthread_t t1;
    pthread_t t2;
    submit_arg_t a1 = { task_a, 0 };
    submit_arg_t a2 = { task_b, 0 };
    int32_t last;
    void *rc1;
    void *rc2;

    shux_async_queue_reset();
    g_step_a = 0;

    if (pthread_create(&t1, NULL, submit_thread, &a1) != 0) {
        fprintf(stderr, "async_scheduler_mpsc: pthread_create t1 failed\n");
        return 1;
    }
    if (pthread_create(&t2, NULL, submit_thread, &a2) != 0) {
        fprintf(stderr, "async_scheduler_mpsc: pthread_create t2 failed\n");
        return 2;
    }
    if (pthread_join(t1, &rc1) != 0 || rc1 != NULL) {
        fprintf(stderr, "async_scheduler_mpsc: t1 submit failed\n");
        return 3;
    }
    if (pthread_join(t2, &rc2) != 0 || rc2 != NULL) {
        fprintf(stderr, "async_scheduler_mpsc: t2 submit failed\n");
        return 4;
    }

    last = shux_async_scheduler_drain();
    if (last != 10) {
        fprintf(stderr, "async_scheduler_mpsc: drain last=%d want 10\n", (int)last);
        return 5;
    }
    return 0;
}
