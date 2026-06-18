/**
 * tests/std-compress/brotli_smoke_ok.c — STD-125 C 烟测
 */
#include <stdint.h>
#include <stdio.h>

extern int32_t compress_brotli_available_c(void);
extern int32_t compress_brotli_smoke_c(void);

int main(void) {
  if (compress_brotli_available_c() == 0) {
    return 0;
  }
  return compress_brotli_smoke_c();
}
