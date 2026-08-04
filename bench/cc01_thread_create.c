/**
 * cc01_thread_create.c — 并发基准：线程创建/加入（C -O2 -pthread 对照）
 *
 * 顺序 create+join N=10000 个线程，每线程做 WORK=64 步 base+i 累加。
 * 顺序而非一次性 spawn：避免 1e4 线程同时存活触及栈/资源上限，
 * 同时仍精确测量 pthread_create + pthread_join 的单次开销。
 *
 * 编译：cc -O2 -pthread bench/cc01_thread_create.c -o /tmp/test_cc01
 */
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>

enum { N_THREADS = 10000, WORK = 64 };

/** worker：对 base 起 WORK 步累加 sum += base+i，返回 sum。 */
static void *worker(void *arg) {
    int32_t base = (int32_t)(intptr_t)arg;
    int32_t sum = 0;
    int32_t i = 0;
    while (i < WORK) {
        sum += base + i;
        i = i + 1;
    }
    /* 防止 gcc/clang -O2 把 worker 内的累加折叠成闭式。 */
    __asm__ volatile("" : "+r"(sum) : : "memory");
    return (void *)(intptr_t)sum;
}

int main(void) {
    int64_t total = 0;
    int32_t t = 0;
    while (t < N_THREADS) {
        pthread_t th;
        if (pthread_create(&th, NULL, worker, (void *)(intptr_t)t) != 0) {
            fprintf(stderr, "cc01: pthread_create %d failed\n", (int)t);
            return 1;
        }
        void *ret = NULL;
        if (pthread_join(th, &ret) != 0) {
            fprintf(stderr, "cc01: pthread_join %d failed\n", (int)t);
            return 2;
        }
        total += (int64_t)(intptr_t)ret;
        t = t + 1;
    }
    /* 防止 total 被折叠：强制落盘寄存器并作为返回值。 */
    __asm__ volatile("" : "+r"(total) : : "memory");
    return (int)(total & 255);
}
