/* a03_trait_monomorphization.c — monomorphization vs dynamic dispatch
 * Compares "compile-time monomorphization (inline)" vs "runtime dynamic dispatch (fn ptr)".
 * N=100000000 iterations, alternating op_add and op_mul.
 * op_add(x, y) = x + y, op_mul(x, y) = x * y.
 * Monomorphization: static inline functions + if/else (compiler inlines).
 * Dynamic: function pointer array, indirect call per iteration.
 * Anti-fold: __asm__ volatile in bench loop bodies; bench returns sum. */
#include <stdint.h>
#include <stdio.h>
#include <time.h>

enum { N = 100000000 };

static inline int32_t op_add(int32_t x, int32_t y) { return x + y; }
static inline int32_t op_mul(int32_t x, int32_t y) { return x * y; }

static int32_t bench_monomorphization(void) {
  int32_t sum = 0;
  int32_t i = 0;
  while (i < N) {
    if (i % 2 == 0) {
      sum += op_add(sum, i);
    } else {
      sum += op_mul(sum, i);
    }
    i = i + 1;
    __asm__ volatile("" : "+r"(sum) : : "memory");
  }
  return sum;
}

static int32_t bench_dynamic(void) {
  int32_t (*ops[2])(int32_t, int32_t) = { op_add, op_mul };
  int32_t sum = 0;
  int32_t i = 0;
  while (i < N) {
    sum += ops[i & 1](sum, i);
    i = i + 1;
    __asm__ volatile("" : "+r"(sum) : : "memory");
  }
  return sum;
}

int main(void) {
  clock_t t1 = clock();
  int32_t s1 = bench_monomorphization();
  clock_t t2 = clock();
  int32_t s2 = bench_dynamic();
  clock_t t3 = clock();

  double ms1 = (double)(t2 - t1) / CLOCKS_PER_SEC * 1000.0;
  double ms2 = (double)(t3 - t2) / CLOCKS_PER_SEC * 1000.0;
  printf("monomorphization: %8.2f ms  sum=%d\n", ms1, (int)s1);
  printf("dynamic_dispatch: %8.2f ms  sum=%d\n", ms2, (int)s2);
  return 0;
}
