/**
 * tests/std-hash/xxhash64_smoke_ok.c — STD-105 C xxHash64 烟测入口
 */
#include <stdint.h>

extern int32_t hash_xxhash_smoke_c(void);

int main(void) {
  return (int)hash_xxhash_smoke_c();
}
