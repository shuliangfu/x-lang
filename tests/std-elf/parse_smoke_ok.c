/**
 * tests/std-elf/parse_smoke_ok.c — STD-058 C ELF64 解析烟测入口
 */
#include <stdint.h>

extern int32_t elf64_parse_smoke_c(void);

int main(void) {
  return (int)elf64_parse_smoke_c();
}
