/**
 * tests/std-simd/autovec_strategy_ok.c — STD-153 策略 C 烟测入口
 */
#include <stdint.h>

extern int32_t simd_autovec_smoke_c(void);

int main(void) {
  return (int)simd_autovec_smoke_c();
}
