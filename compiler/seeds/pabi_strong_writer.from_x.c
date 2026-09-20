/* wave645: STRONG platform_macho_write_macho_o_to_buf to override the
 * all-weak G05_X_O_WEAK=1 pabi thin output and the weak experimental
 * bridge stub. cc -r (ld -r) resolves weak-vs-strong correctly: strong
 * wins, no duplicate error. Body matches the .x authority (delegates
 * to pipeline_macho_write_o_to_buf_c).
 * PLATFORM: SHARED (compiled everywhere; harmless on ELF where strong
 * symbols are the default anyway). */
#include <stdint.h>
extern int32_t pipeline_macho_write_o_to_buf_c(void *elf_ctx, void *out_buf);
int32_t platform_macho_write_macho_o_to_buf(void *elf_ctx, void *out_buf) {
  if (!elf_ctx || !out_buf) return -1;
  return pipeline_macho_write_o_to_buf_c(elf_ctx, out_buf);
}
