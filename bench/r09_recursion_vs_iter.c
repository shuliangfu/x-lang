/* r09_recursion_vs_iter.c — fib(35) recursive vs iterative (matches r09_recursion_vs_iter.x / .zig)
 * Tests: recursive function call overhead vs tight iterative loop.
 * Recursive: fib(n) = fib(n-1) + fib(n-2), fib(0)=0, fib(1)=1.
 * Iterative: loop accumulating a, b = b, a+b.
 * Returns rec ^ iter (should be 0, verifying both produce fib(35)=9227465).
 * Anti-fold: __asm__ on n prevents compile-time fib(35) evaluation;
 * __asm__ on result prevents DCE of the return value. */
#include <stdint.h>

static int32_t fib_rec(int32_t n) {
  if (n < 2) return n;
  return fib_rec(n - 1) + fib_rec(n - 2);
}

static int32_t fib_iter(int32_t n) {
  if (n < 2) return n;
  int32_t a = 0;
  int32_t b = 1;
  int32_t i = 2;
  while (i <= n) {
    int32_t c = a + b;
    a = b;
    b = c;
    i = i + 1;
  }
  return b;
}

int main(void) {
  int32_t n = 35;
  /* B-CMP: make n opaque so the compiler cannot evaluate fib(35) at compile time
   * or unroll the iterative loop. */
  __asm__ volatile("" : "+r"(n) : : "memory");
  int32_t rec = fib_rec(n);
  int32_t iter = fib_iter(n);
  int32_t result = rec ^ iter;
  __asm__ volatile("" : "+r"(result) : : "memory");
  return (int)result;
}
