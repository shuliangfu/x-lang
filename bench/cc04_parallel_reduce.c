/**
 * cc04_parallel_reduce.c — 并发基准：多线程分治规约（C -O2 -pthread 对照）
 *
 * M=4 线程各对分片 [start,end) 计算 sum of squares，元素值 = i & 0x3FF
 * （掩码将值限制在 [0,1023]，避免 4e7 规模下 i*i 累加溢出 i64），
 * 主线程合并 4 个分片和。N_TOTAL=40000000，每片 SLICE=10000000。
 *
 * 编译：cc -O2 -pthread bench/cc04_parallel_reduce.c -o /tmp/test_cc04
 */
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>

enum { N_THREADS = 4, SLICE = 10000000 };
#define N_TOTAL 40000000LL

typedef struct {
    int64_t start;
    int64_t end;
    int64_t result;
} reduce_arg_t;

/** worker：对 [start,end) 计算 sum of squares of (i & 0x3FF)。 */
static void *worker(void *arg) {
    reduce_arg_t *a = (reduce_arg_t *)arg;
    int64_t sum = 0;
    int64_t i = a->start;
    while (i < a->end) {
        int32_t v = (int32_t)(i & 0x3FF);
        sum += (int64_t)v * (int64_t)v;
        i = i + 1;
    }
    /* 防止分片和被折叠。 */
    __asm__ volatile("" : "+r"(sum) : : "memory");
    a->result = sum;
    return NULL;
}

int main(void) {
    pthread_t threads[N_THREADS];
    reduce_arg_t args[N_THREADS];
    int32_t t = 0;
    while (t < N_THREADS) {
        args[t].start = (int64_t)t * SLICE;
        args[t].end = args[t].start + SLICE;
        args[t].result = 0;
        if (pthread_create(&threads[t], NULL, worker, &args[t]) != 0) {
            fprintf(stderr, "cc04: pthread_create %d failed\n", (int)t);
            return 1;
        }
        t = t + 1;
    }
    int64_t total = 0;
    t = 0;
    while (t < N_THREADS) {
        if (pthread_join(threads[t], NULL) != 0) {
            fprintf(stderr, "cc04: pthread_join %d failed\n", (int)t);
            return 2;
        }
        total += args[t].result;
        t = t + 1;
    }
    /* 防止 total 被折叠。 */
    __asm__ volatile("" : "+r"(total) : : "memory");
    return (int)(total & 255);
}
