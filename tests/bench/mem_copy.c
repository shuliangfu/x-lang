/* mem_copy.c — 与 tests/bench/mem_copy.su 对齐（while 两遍扫描 × rounds，无 I/O） */
#include <stdint.h>

int main(void) {
  enum { n = 4096, rounds = 8192 };
  uint8_t buf[n];
  int32_t r;
  int32_t i;
  int32_t j;
  int32_t sum = 0;
  r = 0;
  while (r < rounds) {
    i = 0;
    while (i < n) {
      buf[i] = (uint8_t)i;
      i = i + 1;
    }
    j = 0;
    while (j < n) {
      sum += (int32_t)buf[j];
      j = j + 1;
    }
    r = r + 1;
  }
  return (int)sum;
}
