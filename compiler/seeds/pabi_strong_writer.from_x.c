/* Not a build input. pipeline_abi_inject_modlet_thin compiles
 * src/pabi_strong_writer.x with ./xlang_asm. Do not cc this file.
 * Body kept so the old strong-T contract stays readable:
 * null elf_ctx or out_buf returns -1, else pipeline_macho_write_o_to_buf_c.
 * PLATFORM: SHARED. */
#include <stdint.h>
extern int32_t pipeline_macho_write_o_to_buf_c(void *elf_ctx, void *out_buf);
int32_t platform_macho_write_macho_o_to_buf(void *elf_ctx, void *out_buf) {
  if (!elf_ctx || !out_buf) return -1;
  return pipeline_macho_write_o_to_buf_c(elf_ctx, out_buf);
}
