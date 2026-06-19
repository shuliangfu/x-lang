/**
 * race_probe.c — SAFE-006 探测器：双线程无锁递增，仅 SHUX_RACE_PROBE=1 时以 TSAN 校验。
 *
 * 预期：-fsanitize=thread 编译运行时 ThreadSanitizer 报告 data race 并非零退出。
 */
#include <pthread.h>
#include <stdint.h>

/** 共享计数器（故意非原子、无锁）。 */
static volatile int32_t g_counter = 0;

/** 工作线程：对 g_counter 做无锁递增。 */
static void *race_worker(void *arg) {
  (void)arg;
  int32_t i = 0;
  while (i < 10000) {
    g_counter = g_counter + 1;
    i = i + 1;
  }
  return 0;
}

/** 入口：启动两线程制造数据竞争。 */
int main(void) {
  pthread_t t1;
  pthread_t t2;
  pthread_create(&t1, 0, race_worker, 0);
  pthread_create(&t2, 0, race_worker, 0);
  pthread_join(t1, 0);
  pthread_join(t2, 0);
  return 0;
}
