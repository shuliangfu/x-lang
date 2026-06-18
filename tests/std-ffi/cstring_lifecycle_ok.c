/**
 * tests/std-ffi/cstring_lifecycle_ok.c — STD-055 C 烟测入口
 */
#include <stdint.h>

extern int32_t ffi_cstring_lifecycle_smoke_c(void);

int main(void) {
  return ffi_cstring_lifecycle_smoke_c();
}
