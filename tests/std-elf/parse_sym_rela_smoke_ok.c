/**
 * tests/std-elf/parse_sym_rela_smoke_ok.c — STD-103 C ELF64 symtab/rela 烟测入口
 */
#include <stdint.h>

extern int32_t elf64_sym_rela_smoke_c(void);

int main(void) {
  return (int)elf64_sym_rela_smoke_c();
}
