/**
 * tests/std-elf/parse_phdr_smoke_ok.c — STD-064 C ELF64 Phdr 烟测入口
 */
#include <stdint.h>

extern int32_t elf64_phdr_smoke_c(void);

int main(void) {
  return (int)elf64_phdr_smoke_c();
}
