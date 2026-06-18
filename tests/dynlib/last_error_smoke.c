/**
 * tests/dynlib/last_error_smoke.c — STD-096 dynlib_last_error_smoke_c 入口
 */
#include <stdint.h>

extern int32_t dynlib_last_error_smoke_c(void);

int main(void) {
  return (int)dynlib_last_error_smoke_c();
}
