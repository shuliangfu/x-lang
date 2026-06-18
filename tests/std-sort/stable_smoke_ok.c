/**
 * tests/std-sort/stable_smoke_ok.c — STD-060 C 稳定排序烟测入口
 */
#include <stdint.h>

extern int32_t sort_stable_smoke_c(void);

int main(void) {
  return (int)sort_stable_smoke_c();
}
