/**
 * tests/std-hash/hasher_switch_ok.c — STD-056 C Hasher 切换烟测入口
 */
#include <stdint.h>

extern int32_t hash_hasher_switch_smoke_c(void);

int main(void) {
  return (int)hash_hasher_switch_smoke_c();
}
