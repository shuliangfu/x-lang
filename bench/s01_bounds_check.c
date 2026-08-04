/* s01_bounds_check.c — bounds check on/off overhead
 * Compares "with bounds check" vs "without bounds check" array access.
 * N=10000000 elements, R=10 rounds, pseudo-random index pattern.
 * Init: arr[i]=i, idx[i]=(i*1103515245+12345)%N (well-defined via uint32).
 * With check:    if (ii >= 0 && ii < N) { sum += arr[ii]; }
 * Without check: sum += arr[idx[i]];
 * Anti-fold: __asm__ volatile in bench loop bodies; bench returns sum. */
#include <stdint.h>
#include <stdio.h>
#include <time.h>

enum { N = 10000000, R = 10 };

static int32_t arr[N];
static int32_t idx[N];

static int32_t bench_with_check(void) {
  int32_t sum = 0;
  int32_t r = 0;
  while (r < R) {
    int32_t i = 0;
    while (i < N) {
      int32_t ii = idx[i];
      if (ii >= 0 && ii < N) {
        sum += arr[ii];
      }
      i = i + 1;
    }
    r = r + 1;
    /* B-CMP: make sum opaque per round to prevent DCE / folding. */
    __asm__ volatile("" : "+r"(sum) : : "memory");
  }
  return sum;
}

static int32_t bench_without_check(void) {
  int32_t sum = 0;
  int32_t r = 0;
  while (r < R) {
    int32_t i = 0;
    while (i < N) {
      sum += arr[idx[i]];
      i = i + 1;
    }
    r = r + 1;
    __asm__ volatile("" : "+r"(sum) : : "memory");
  }
  return sum;
}

int main(void) {
  int32_t i = 0;
  while (i < N) {
    arr[i] = i;
    idx[i] = (int32_t)(((uint32_t)i * 1103515245u + 12345u) % (uint32_t)N);
    i = i + 1;
  }
  /* B-CMP: memory barrier prevents the compiler from assuming arr/idx
   * contents are known at compile time during the bench loops. */
  __asm__ volatile("" : : : "memory");

  clock_t t1 = clock();
  int32_t s1 = bench_with_check();
  clock_t t2 = clock();
  int32_t s2 = bench_without_check();
  clock_t t3 = clock();

  double ms1 = (double)(t2 - t1) / CLOCKS_PER_SEC * 1000.0;
  double ms2 = (double)(t3 - t2) / CLOCKS_PER_SEC * 1000.0;
  printf("with_check:     %8.2f ms  sum=%d\n", ms1, (int)s1);
  printf("without_check:  %8.2f ms  sum=%d\n", ms2, (int)s2);
  return 0;
}
