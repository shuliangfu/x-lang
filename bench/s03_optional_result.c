/* s03_optional_result.c — Optional/Result hot-path overhead
 * Compares "direct return" vs "optional with ok-flag" function call overhead.
 * N=100000000 calls. compute(x) = x * 42 + 7.
 * Direct:   int32_t compute_direct(int32_t x) { return x*42 + 7; }
 * Optional: int32_t compute_optional(int32_t x, int32_t *ok) { if (x > 1000000) { *ok=0; return 0; } *ok=1; return x*42+7; }
 * Anti-fold: __asm__ volatile in bench loop bodies; bench returns sum. */
#include <stdint.h>
#include <stdio.h>
#include <time.h>

enum { N = 100000000 };

static int32_t compute_direct(int32_t x) {
  return x * 42 + 7;
}

static int32_t compute_optional(int32_t x, int32_t *ok) {
  if (x > 1000000) {
    *ok = 0;
    return 0;
  }
  *ok = 1;
  return x * 42 + 7;
}

static int32_t bench_direct(void) {
  int32_t sum = 0;
  int32_t i = 0;
  while (i < N) {
    sum += compute_direct(i);
    i = i + 1;
    __asm__ volatile("" : "+r"(sum) : : "memory");
  }
  return sum;
}

static int32_t bench_optional(void) {
  int32_t sum = 0;
  int32_t i = 0;
  while (i < N) {
    int32_t ok;
    int32_t v = compute_optional(i, &ok);
    if (ok) {
      sum += v;
    }
    i = i + 1;
    __asm__ volatile("" : "+r"(sum) : : "memory");
  }
  return sum;
}

int main(void) {
  clock_t t1 = clock();
  int32_t s1 = bench_direct();
  clock_t t2 = clock();
  int32_t s2 = bench_optional();
  clock_t t3 = clock();

  double ms1 = (double)(t2 - t1) / CLOCKS_PER_SEC * 1000.0;
  double ms2 = (double)(t3 - t2) / CLOCKS_PER_SEC * 1000.0;
  printf("direct:    %8.2f ms  sum=%d\n", ms1, (int)s1);
  printf("optional:  %8.2f ms  sum=%d\n", ms2, (int)s2);
  return 0;
}
