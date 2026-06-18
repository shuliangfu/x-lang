/**
 * tests/std-ffi/struct_callback_ok.c — STD-151 结构体/回调 C 烟测入口
 */
#include <stdint.h>

extern int32_t ffi_struct_callback_smoke_c(void);

int main(void) {
  return (int)ffi_struct_callback_smoke_c();
}
