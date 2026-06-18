/**
 * tests/std-sort/key_cmp_ok.c — STD-150 key 比较器 C 烟测入口
 */
#include <stdint.h>

extern int32_t sort_key_cmp_smoke_c(void);

int main(void) {
  return (int)sort_key_cmp_smoke_c();
}
