/**
 * tests/std-context/context_smoke_ok.c — STD-071 C context 烟测入口
 */
#include <stdint.h>

extern int32_t ctx_smoke_c(void);

int main(void) {
  return (int)ctx_smoke_c();
}
