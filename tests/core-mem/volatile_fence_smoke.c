/**
 * tests/core-mem/volatile_fence_smoke.c — CORE-017 C 烟测入口
 */
#include <stdint.h>

extern int32_t mem_volatile_fence_smoke_c(void);

int main(void) {
  return (int)mem_volatile_fence_smoke_c();
}
