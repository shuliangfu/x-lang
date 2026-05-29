/* mem_copy.c — 与 tests/bench/mem_copy.su 等价的 C 参照（fill + sum 两遍扫描） */
#include <stdint.h>
#include <stdio.h>

int main(void) {
  enum { n = 4096 };
  uint8_t buf[n];
  int i;
  int j;
  int sum = 0;
  for (i = 0; i < n; i++)
    buf[i] = (uint8_t)i;
  for (j = 0; j < n; j++)
    sum += (int)buf[j];
  printf("%d\n", sum);
  return 0;
}
