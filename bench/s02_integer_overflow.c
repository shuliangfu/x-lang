/* s02_integer_overflow.c — integer overflow check on/off overhead
 * Compares "with overflow check" vs "without overflow check" (wrapping) i32 mul.
 * N=100000000 iterations, a = i*7919, b = i*6151.
 * With check:    if (b != 0 && a > INT32_MAX / b) { overflow_count++; } else { sum += a*b; }
 * Without check: sum += a * b; (wrapping)
 * Anti-fold: __asm__ volatile in bench loop bodies; bench returns sum. */
#include <stdint.h>
#include <stdio.h>
#include <time.h>

enum { N = 100000000 };

static int32_t g_overflow_count;

static int32_t bench_with_check(void) {
  int32_t sum = 0;
  g_overflow_count = 0;
  int32_t i = 0;
  while (i < N) {
    int32_t a = i * 7919;
    int32_t b = i * 6151;
    if (b != 0 && a > INT32_MAX / b) {
      g_overflow_count++;
    } else {
      sum += a * b;
    }
    i = i + 1;
    __asm__ volatile("" : "+r"(sum) : : "memory");
  }
  return sum;
}

static int32_t bench_without_check(void) {
  int32_t sum = 0;
  int32_t i = 0;
  while (i < N) {
    int32_t a = i * 7919;
    int32_t b = i * 6151;
    sum += a * b;
    i = i + 1;
    __asm__ volatile("" : "+r"(sum) : : "memory");
  }
  return sum;
}

int main(void) {
  clock_t t1 = clock();
  int32_t s1 = bench_with_check();
  clock_t t2 = clock();
  int32_t s2 = bench_without_check();
  clock_t t3 = clock();

  double ms1 = (double)(t2 - t1) / CLOCKS_PER_SEC * 1000.0;
  double ms2 = (double)(t3 - t2) / CLOCKS_PER_SEC * 1000.0;
  printf("with_check:     %8.2f ms  sum=%d  overflow=%d\n", ms1, (int)s1, (int)g_overflow_count);
  printf("without_check:  %8.2f ms  sum=%d\n", ms2, (int)s2);
  return 0;
}
