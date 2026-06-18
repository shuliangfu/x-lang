/**
 * STD-121：ELF write C 烟测入口。
 */
#include <stdint.h>

extern int32_t elf64_write_smoke_c(void);

int main(void) {
  return elf64_write_smoke_c() != 0 ? 1 : 0;
}
