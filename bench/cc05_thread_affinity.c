/**
 * cc05_thread_affinity.c — 线程亲和/绑核测方差（C -O2 -pthread 对照）
 *
 * 算法：创建 1 个线程，绑定到 CPU 0，做 N=100000000 次 LCG 累加，
 * 重复 R=5 轮，记录每轮 wall-clock 时间（秒），报告 median 和方差。
 * 这个 case 测的是"方差"而非绝对速度——绑核应降低时间方差。
 *
 * 绑核（PLATFORM 分支）：
 *   LINUX|UBUNTU — pthread_setaffinity_np 到 CPU 0（需 _GNU_SOURCE）
 *   MACOS|DARWIN — thread_policy_set THREAD_AFFINITY_POLICY tag=1
 *                  （macOS 仅提供 affinity hint，无法绑定特定 CPU）
 *   其他         — HAVE_AFFINITY=0，退化到不绑核但仍记录方差
 *
 * 返回：累加值 & 0xFF（exit code 仅低 8 位）
 *
 * 编译：cc -O2 -pthread bench/cc05_thread_affinity.c -o /tmp/test_cc05
 */
#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/* PLATFORM: LINUX|UBUNTU — pthread_setaffinity_np; MACOS|DARWIN — thread_policy_set */
#if defined(__linux__)
  #include <sched.h>
  #define HAVE_AFFINITY 1
#elif defined(__APPLE__)
  #include <mach/mach.h>
  #include <mach/thread_policy.h>
  #define HAVE_AFFINITY 1
#else
  #define HAVE_AFFINITY 0
#endif

enum { N = 100000000, ROUNDS = 5 };

typedef struct {
  int32_t result;
} worker_arg;

/** worker：N 步 LCG 累加（s ^= i*1103515245+12345），结果写入 arg->result。 */
static void *worker(void *arg) {
  worker_arg *a = (worker_arg *)arg;
  int32_t s = 0;
  int32_t i = 0;
  while (i < N) {
    int32_t t = i * 1103515245 + 12345;
    s = s ^ t;
    i = i + 1;
  }
  /* 防止 gcc/clang -O2 把累加折叠成闭式。 */
  __asm__ volatile("" : "+r"(s) : : "memory");
  a->result = s;
  return NULL;
}

/** pin_to_cpu0：将线程 th 绑定到 CPU 0（Linux）或设置 affinity hint（macOS）。 */
static int pin_to_cpu0(pthread_t th) {
#if defined(__linux__)
  /* PLATFORM: LINUX|UBUNTU — CPU 0 硬绑核。 */
  cpu_set_t set;
  CPU_ZERO(&set);
  CPU_SET(0, &set);
  return pthread_setaffinity_np(th, sizeof(set), &set);
#elif defined(__APPLE__)
  /* PLATFORM: MACOS|DARWIN — affinity tag=1（hint，非硬绑核）。 */
  mach_port_t mt = pthread_mach_thread_np(th);
  thread_affinity_policy_data_t policy = { 1 };
  return thread_policy_set(mt, THREAD_AFFINITY_POLICY,
                           (thread_policy_t)&policy, 1);
#else
  /* PLATFORM: OTHER — 无绑核 API。 */
  (void)th;
  return 0;
#endif
}

/** cmp_d：qsort 比较函数（double 升序）。 */
static int cmp_d(const void *a, const void *b) {
  double da = *(const double *)a;
  double db = *(const double *)b;
  return (da > db) - (da < db);
}

int main(void) {
  double samples[ROUNDS];
  int32_t sink = 0;
  int r = 0;
  while (r < ROUNDS) {
    worker_arg arg;
    arg.result = 0;
    pthread_t th;
    struct timespec t0, t1;
    /* 计时覆盖 create+pin+join 全程，方差反映绑核对工作负载稳定性的影响。 */
    clock_gettime(CLOCK_MONOTONIC, &t0);
    if (pthread_create(&th, NULL, worker, &arg) != 0) {
      fprintf(stderr, "cc05: pthread_create failed (round %d)\n", r);
      return 1;
    }
    if (pin_to_cpu0(th) != 0) {
      fprintf(stderr, "cc05: pin failed (round %d), continuing unpinned\n", r);
    }
    if (pthread_join(th, NULL) != 0) {
      fprintf(stderr, "cc05: pthread_join failed (round %d)\n", r);
      return 2;
    }
    clock_gettime(CLOCK_MONOTONIC, &t1);
    double secs = (double)(t1.tv_sec - t0.tv_sec)
                + (double)(t1.tv_nsec - t0.tv_nsec) / 1e9;
    samples[r] = secs;
    sink ^= arg.result;
    r = r + 1;
  }

  /* median：排序后取中位。 */
  qsort(samples, ROUNDS, sizeof(double), cmp_d);
  double median = samples[ROUNDS / 2];

  /* population variance：sum((x-mean)^2) / N。 */
  double mean = 0;
  for (int i = 0; i < ROUNDS; i++) mean += samples[i];
  mean /= (double)ROUNDS;
  double variance = 0;
  for (int i = 0; i < ROUNDS; i++) {
    double d = samples[i] - mean;
    variance += d * d;
  }
  variance /= (double)ROUNDS;

  fprintf(stderr,
          "cc05: rounds=%d N=%d pin=%d median=%.6fs variance=%.6e mean=%.6fs\n",
          ROUNDS, N, HAVE_AFFINITY, median, variance, mean);

  /* 防止 sink 被折叠：强制落盘寄存器并作为返回值。 */
  __asm__ volatile("" : "+r"(sink) : : "memory");
  return (int)(sink & 255);
}
