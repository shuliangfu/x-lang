/**
 * tests/std-elf/parse_sections_smoke_ok.c — STD-063 C ELF64 深化烟测入口
 */
#include <stdint.h>

extern int32_t elf64_sections_deep_smoke_c(void);

int main(void) {
  return (int)elf64_sections_deep_smoke_c();
}
