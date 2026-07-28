/* seeds/asm_backend_compat_stubs_surface.from_x.c
 * G-02f-15 asm_backend_compat_stubs R2 DIRECT surface - isomorphic with src/asm/asm_backend_compat_stubs.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/asm_backend_compat_stubs.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (3 #[no_mangle] + 1 doc_anchor)
 * Mode: DIRECT - 3 #[no_mangle] functions (xlang_format_u32_to_buf pure compute +
 *   xlang_elf_ctx_append_u32_le + xlang_arm64_mov_imm32_to_w0_c via pipeline_elf_ctx_append_bytes extern bridge)
 * Cap residual: pipeline_elf_ctx_append_bytes (extern bridge, not #[no_mangle])
 * doc_anchor asm_backend_compat_stubs_x_doc_anchor (no ast_; no module prefix on doc_anchor).
 * Note: xlang_ prefix not trigger ast_ (confirmed wave545+).
 * Logic: 3 DIRECT functions. seed 全守卫 #ifndef XLANG_ASM_BACKEND_COMPAT_STUBS_FROM_X.
 * Regen: ./xlang-c -E ... asm_backend_compat_stubs.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n);

int32_t asm_backend_compat_stubs_x_doc_anchor(void) { return 0; }

/* xlang_format_u32_to_buf: pure compute, no extern bridge */
int32_t xlang_format_u32_to_buf(uint8_t *buf, int32_t off, int32_t max, uint32_t u) {
  if (buf == 0) { return 0 - 1; }
  if (max < 1) { return 0 - 1; }
  uint8_t tmp[10];
  int32_t num_digits = 0;
  uint32_t v = u;
  while (v > 0) {
    if (num_digits >= 10) { break; }
    tmp[num_digits] = (uint8_t)(48 + (v % 10u));
    num_digits = num_digits + 1;
    v = v / 10u;
  }
  if (num_digits == 0) {
    buf[off] = 48;
    return 1;
  }
  if (num_digits > max) { return 0 - 1; }
  int32_t idx = 0;
  while (idx < num_digits) {
    buf[off + idx] = tmp[num_digits - 1 - idx];
    idx = idx + 1;
  }
  return num_digits;
}

/* xlang_elf_ctx_append_u32_le: thin+rest via pipeline_elf_ctx_append_bytes */
int32_t xlang_elf_ctx_append_u32_le(uint8_t *elf_ctx, uint32_t word) {
  if (elf_ctx == 0) { return 0 - 1; }
  uint8_t bytes[4];
  bytes[0] = (uint8_t)(word & 255u);
  bytes[1] = (uint8_t)((word >> 8) & 255u);
  bytes[2] = (uint8_t)((word >> 16) & 255u);
  bytes[3] = (uint8_t)((word >> 24) & 255u);
  return pipeline_elf_ctx_append_bytes(elf_ctx, bytes, 4);
}

/* xlang_arm64_mov_imm32_to_w0_c: thin+rest via xlang_elf_ctx_append_u32_le */
int32_t xlang_arm64_mov_imm32_to_w0_c(uint8_t *elf_ctx, int32_t imm32) {
  uint32_t u = (uint32_t)imm32;
  uint32_t lo = u & 65535u;
  uint32_t hi = (u >> 16) & 65535u;
  if (xlang_elf_ctx_append_u32_le(elf_ctx, 1384120320u | (lo << 5)) != 0) {
    return 0 - 1;
  }
  if (hi != 0) {
    if (xlang_elf_ctx_append_u32_le(elf_ctx, 1920991232u | (hi << 5)) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}
