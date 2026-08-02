/* s05_release_safe_vs_fast.c — mixed workload baseline for ReleaseSafe vs ReleaseFast
 * Tests: mixed array access + integer arithmetic + byte string scan.
 * C is a baseline reference (compiled with -O2; C has no ReleaseSafe concept).
 * Data: int arr[10000] init arr[i]=i; uint8_t str[10000] init str[i]=(i*31+17)&0xFF.
 * Loop: N=100000000 iterations: sum += arr[i%10000] * i; if (str[i%10000] > 127) str_count++.
 * Anti-fold: __asm__ volatile in loop body; returns sum + str_count. */
#include <stdint.h>

enum { N = 100000000, M = 10000 };

int main(void) {
  int32_t arr[M];
  uint8_t str_data[M];
  int32_t i = 0;
  while (i < M) {
    arr[i] = i;
    str_data[i] = (uint8_t)((i * 31 + 17) & 0xFF);
    i = i + 1;
  }
  /* B-CMP: memory barrier prevents the compiler from assuming arr/str_data
   * contents are known at compile time during the main loop. */
  __asm__ volatile("" : : : "memory");

  int32_t sum = 0;
  int32_t str_count = 0;
  i = 0;
  while (i < N) {
    int32_t j = i % M;
    sum += arr[j] * i;
    if (str_data[j] > 127) {
      str_count++;
    }
    i = i + 1;
    /* B-CMP: make sum and str_count opaque to prevent DCE / folding. */
    __asm__ volatile("" : "+r"(sum), "+r"(str_count) : : "memory");
  }

  int32_t result = sum + str_count;
  __asm__ volatile("" : "+r"(result) : : "memory");
  return (int)result;
}
