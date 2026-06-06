/**
 * tests/bench/async_scheduler_workers.c — A4 v2 per-worker 环 + 双 consumer drain 烟测
 *
 * SHU_ASYNC_WORKERS=2：两线程各 drain worker 0/1，验证隔离与并行消费。
 *
 * 编译：cc -std=c11 -pthread -o async_scheduler_workers \
 *   tests/bench/async_scheduler_workers.c std/async/scheduler.o
 */
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int shu_async_task_submit_to(uint32_t worker_id, int32_t (*fn)(void));
extern int32_t shu_async_worker_drain(uint32_t worker_id);
extern void shu_async_queue_reset(void);
extern uint32_t shu_async_worker_pending(uint32_t worker_id);

/** worker 0 任务：返回 11。 */
static int32_t task_w0(void) {
    return 11;
}

/** worker 1 任务：返回 22。 */
static int32_t task_w1(void) {
    return 22;
}

/** drain 线程参数。 */
typedef struct {
    uint32_t worker_id;
    int32_t expect;
    int32_t got;
} drain_arg_t;

/**
 * 线程入口：drain 指定 worker 就绪环。
 */
static void *drain_thread(void *arg) {
    drain_arg_t *a = (drain_arg_t *)arg;
    a->got = shu_async_worker_drain(a->worker_id);
    return NULL;
}

/**
 * 入口：双 worker submit + 双线程 parallel drain。
 */
int main(void) {
    pthread_t t0;
    pthread_t t1;
    drain_arg_t d0 = { 0, 11, -1 };
    drain_arg_t d1 = { 1, 22, -1 };

    setenv("SHU_ASYNC_WORKERS", "2", 1);
    shu_async_queue_reset();

    if (shu_async_task_submit_to(0, task_w0) != 0) {
        fprintf(stderr, "async_scheduler_workers: submit w0 failed\n");
        return 1;
    }
    if (shu_async_task_submit_to(1, task_w1) != 0) {
        fprintf(stderr, "async_scheduler_workers: submit w1 failed\n");
        return 2;
    }
    if (shu_async_worker_pending(0) != 1 || shu_async_worker_pending(1) != 1) {
        fprintf(stderr, "async_scheduler_workers: pending w0=%u w1=%u want 1/1\n",
            (unsigned)shu_async_worker_pending(0), (unsigned)shu_async_worker_pending(1));
        return 3;
    }

    if (pthread_create(&t0, NULL, drain_thread, &d0) != 0) {
        fprintf(stderr, "async_scheduler_workers: pthread_create t0 failed\n");
        return 4;
    }
    if (pthread_create(&t1, NULL, drain_thread, &d1) != 0) {
        fprintf(stderr, "async_scheduler_workers: pthread_create t1 failed\n");
        return 5;
    }
    if (pthread_join(t0, NULL) != 0 || pthread_join(t1, NULL) != 0) {
        fprintf(stderr, "async_scheduler_workers: join failed\n");
        return 6;
    }

    if (d0.got != 11) {
        fprintf(stderr, "async_scheduler_workers: worker0 got %d want 11\n", (int)d0.got);
        return 7;
    }
    if (d1.got != 22) {
        fprintf(stderr, "async_scheduler_workers: worker1 got %d want 22\n", (int)d1.got);
        return 8;
    }
    if (shu_async_worker_pending(0) != 0 || shu_async_worker_pending(1) != 0) {
        fprintf(stderr, "async_scheduler_workers: queues not empty after drain\n");
        return 9;
    }
    return 0;
}
