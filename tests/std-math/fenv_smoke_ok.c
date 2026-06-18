/**
 * tests/std-math/fenv_smoke_ok.c — STD-059 C fenv 烟测入口
 */
#include <stdint.h>

extern int32_t math_fenv_smoke_c(void);

int main(void) {
  int32_t rc = math_fenv_smoke_c();
  if (rc == -9) return 0;
  return (int)rc;
}
