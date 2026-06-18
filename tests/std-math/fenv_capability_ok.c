/**
 * tests/std-math/fenv_capability_ok.c — STD-149 fenv 能力 C 烟测入口
 */
#include <stdint.h>

extern int32_t math_fenv_capability_smoke_c(void);

int main(void) {
  return (int)math_fenv_capability_smoke_c();
}
