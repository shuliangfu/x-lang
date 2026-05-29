/* loop_i32.c — 与 tests/bench/loop_i32.su 等价的 C 参照 */
#include <stdio.h>

int main(void) {
  int n = 1000000000;
  int s = 0;
  for (int i = 0; i < n; i++)
    s++;
  printf("%d\n", s);
  return 0;
}
