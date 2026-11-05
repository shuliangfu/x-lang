/**
 * PLATFORM: MACOS|DARWIN arm64 tip PE only — tip_l4_tip_pe_cg002_prologue_arch.
 *
 * Tip PE selfhost-emitted arm64_enc_addsub_sp_imm_chunks drops if-body
 * stores (left=0 / chunk=4080) and critically omits loop-tail
 * `left = left - chunk`. Cap keeps the stores. While never shrinks →
 * append fails → addsub -1 → backend_enc_prologue_arch / arch_arm64_enc_enc_prologue
 * -1 → CG002 → tip_after.o 0B / no `_main`. Soft Cap Prefer / Cap aside /
 * Win banned.
 *
 * Tip-local host-cc twin Cap-aligned with src/asm/backend_arm64_enc_c.x.
 */
#include <stddef.h>
#include <stdint.h>

extern int32_t pipeline_elf_ctx_append_bytes(void *elf, uint8_t *bytes, int32_t n);

static int32_t tip_arm64_enc_u32_le(void *elf, uint32_t word) {
  uint8_t b[4];
  b[0] = (uint8_t)(word & 0xffu);
  b[1] = (uint8_t)((word >> 8) & 0xffu);
  b[2] = (uint8_t)((word >> 16) & 0xffu);
  b[3] = (uint8_t)((word >> 24) & 0xffu);
  return pipeline_elf_ctx_append_bytes(elf, b, 4);
}

int32_t arm64_enc_addsub_sp_imm_chunks(void *elf_ctx, int32_t imm, int32_t is_sub) {
  int32_t base;
  int32_t left;
  int32_t chunk;

  if (elf_ctx == NULL)
    return -1;
  /* ADD sp,sp,#0 base 0x910003FF; SUB 0xD10003FF — same as .x (0-N) form. */
  base = (int32_t)0x910003ff;
  if (is_sub != 0)
    base = (int32_t)0xd10003ff;
  left = imm;
  if (left < 0)
    left = 0;
  /* AAPCS64: SP 16-byte aligned; 4080 = largest 12-bit multiple of 16. */
  while (left > 0) {
    chunk = left;
    if (chunk > 4080)
      chunk = 4080;
    if (tip_arm64_enc_u32_le(elf_ctx, (uint32_t)(base | (chunk << 10))) != 0)
      return -1;
    /* w2060 Darwin: probe after each large sub sp chunk (STR XZR,[SP]). */
    if (is_sub != 0) {
      if (chunk >= 256) {
        if (tip_arm64_enc_u32_le(elf_ctx, (uint32_t)0xf90003ff) != 0)
          return -1;
      }
    }
    left = left - chunk;
  }
  return 0;
}
