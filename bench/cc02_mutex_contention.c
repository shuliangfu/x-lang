/**
 * cc02_mutex_contention.c — 并发基准：互斥锁争用（C -O2 -pthread 对照）
 *
 * M=4 线程各在共享互斥锁保护下对 counter 做 N_ITERS=10000000 次自增，
 * 终值 = M*N = 40000000。测量 pthread_mutex 在高争用下的吞吐。
 *
 * 编译：cc -O2 -pthread bench/cc02_mutex_contention.c -o /tmp/test_cc02
 */
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>

enum { N_THREADS = 4 };
#define N_ITERS 10000000LL

typedef struct {
    pthread_mutex_t *mtx;
    int64_t *counter;
    int64_t iters;
} worker_arg_t;

/** worker：在互斥锁保护下对 *counter 自增 iters 次。 */
static void *worker(void *arg) {
    worker_arg_t *a = (worker_arg_t *)arg;
    int64_t i = 0;
    while (i < a->iters) {
        pthread_mutex_lock(a->mtx);
        *a->counter += 1;
        pthread_mutex_unlock(a->mtx);
        i = i + 1;
    }
    return NULL;
}

int main(void) {
    pthread_mutex_t mtx;
    if (pthread_mutex_init(&mtx, NULL) != 0) {
        fprintf(stderr, "cc02: mutex_init failed\n");
        return 1;
    }
    int64_t counter = 0;
    pthread_t threads[N_THREADS];
    worker_arg_t args[N_THREADS];
    int32_t t = 0;
    while (t < N_THREADS) {
        args[t].mtx = &mtx;
        args[t].counter = &counter;
        args[t].iters = N_ITERS;
        if (pthread_create(&threads[t], NULL, worker, &args[t]) != 0) {
            fprintf(stderr, "cc02: pthread_create %d failed\n", (int)t);
            return 2;
        }
        t = t + 1;
    }
    t = 0;
    while (t < N_THREADS) {
        if (pthread_join(threads[t], NULL) != 0) {
            fprintf(stderr, "cc02: pthread_join %d failed\n", (int)t);
            return 3;
        }
        t = t + 1;
    }
    pthread_mutex_destroy(&mtx);
    /* 防止 counter 被折叠。 */
    __asm__ volatile("" : "+r"(counter) : : "memory");
    return (int)(counter & 255);
}
