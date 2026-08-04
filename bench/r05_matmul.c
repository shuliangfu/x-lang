/* r05_matmul.c — 64x64 integer matrix multiply (matches r05_matmul.x / .zig)
 * Tests: triple-nested loop, memory access patterns, integer MAC throughput.
 * Init: A[i][j]=i+j, B[i][j]=i*j. Compute C[i][j]=sum(A[i][k]*B[k][j]) ijk.
 * Anti-fold: returns C[0][0]+C[63][63] to prevent DCE; __asm__ on result. */
#include <stdint.h>

int main(void) {
  int32_t A[64][64];
  int32_t B[64][64];
  int32_t C[64][64];
  int32_t i = 0;
  while (i < 64) {
    int32_t j = 0;
    while (j < 64) {
      A[i][j] = i + j;
      B[i][j] = i * j;
      C[i][j] = 0;
      j = j + 1;
    }
    i = i + 1;
  }
  i = 0;
  while (i < 64) {
    int32_t j = 0;
    while (j < 64) {
      int32_t s = 0;
      int32_t k = 0;
      while (k < 64) {
        s += A[i][k] * B[k][j];
        k = k + 1;
      }
      C[i][j] = s;
      j = j + 1;
    }
    i = i + 1;
  }
  int32_t result = C[0][0] + C[63][63];
  /* B-CMP: prevent DCE of the matmul by making the result opaque. */
  __asm__ volatile("" : "+r"(result) : : "memory");
  return (int)result;
}
