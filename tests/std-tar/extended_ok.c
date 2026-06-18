/**
 * tests/std-tar/extended_ok.c — STD-152 长路径/Pax C 烟测入口
 */
#include <stdint.h>

extern int32_t tar_extended_smoke_c(void);

int main(void) {
  return (int)tar_extended_smoke_c();
}
