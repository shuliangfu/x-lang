/* loop_i32.c — 与 tests/bench/loop_i32.su 对齐（LCG 混合，无 I/O） */
#include <stdint.h>

int main(void) {
  int32_t n = 100000000;
  int32_t s = 0;
  int32_t i = 0;
  while (i < n) {
    int32_t t = i * 1103515245 + 12345;
    s = s ^ t;
    i = i + 1;
    /* B-CMP：阻止 gcc/clang -O3 整循环常量折叠，与 shu_asm 真跑 1e8 次对齐。 */
    __asm__ volatile("" : "+r"(i), "+r"(s) : : "memory");
  }
  return (int)s;
}
