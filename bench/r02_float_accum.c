/* r02_float_accum.c — FP accumulation benchmark (matches r02_float_accum.x / .zig)
 * Tests: double-precision FP accumulation and multiply-add throughput.
 * Anti-fold: __asm__ volatile makes the loop counter opaque to the optimizer,
 * preventing gcc/clang -O2 from folding the arithmetic series into a closed form. */
#include <stdint.h>

int main(void) {
  int32_t n = 100000000;
  double sum = 0.0;
  int32_t i = 0;
  while (i < n) {
    sum += (double)i * 0.5;
    i = i + 1;
    /* B-CMP: "+r"(i) makes i opaque after the asm, so the compiler cannot
     * predict the i-sequence and fold sum into a closed-form expression. */
    __asm__ volatile("" : "+r"(i) : : "memory");
  }
  return (int)sum;
}
