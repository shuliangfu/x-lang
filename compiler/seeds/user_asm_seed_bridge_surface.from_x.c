/* seeds/user_asm_seed_bridge_surface.from_x.c
 * G-02f-84 user_asm_seed_bridge R2 mixed surface - isomorphic with src/asm/user_asm_seed_bridge.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/user_asm_seed_bridge.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (7 #[no_mangle] + 1 doc_anchor)
 * Mode: mixed - 4 thin+rest forwards to _impl + 2 DIRECT env gates via link_abi_getenv + 1 DIRECT pure compute
 * Cap residual: 4 _impl bridges (seed_elf_ctx_set_macho_leading_underscore_impl + seed_asm_reject_empty_elf_text_impl
 *   + seed_platform_macho_write_macho_o_to_buf_impl + seed_platform_coff_write_coff_o_to_buf_impl)
 *   + link_abi_getenv (extern bridge, not #[no_mangle])
 * doc_anchor user_asm_seed_bridge_x_doc_anchor (no ast_; no module prefix on doc_anchor).
 * Note: seed_/seed_asm_/seed_platform_ prefix not trigger ast_ (confirmed wave545+).
 * Logic: 7 functions = 4 thin+rest + 2 DIRECT env gates + 1 DIRECT pure compute (seed_elf_ctx_code_len).
 *   seed 全守卫 #ifndef XLANG_USER_ASM_SEED_BRIDGE_FROM_X.
 * Regen: ./xlang-c -E ... user_asm_seed_bridge.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern uint8_t *link_abi_getenv(uint8_t *name);
extern void seed_elf_ctx_set_macho_leading_underscore_impl(uint8_t *elf_ctx, int32_t on);
extern int32_t seed_asm_reject_empty_elf_text_impl(uint8_t *module, uint8_t *elf_ctx);
extern int32_t seed_platform_macho_write_macho_o_to_buf_impl(uint8_t *elf_ctx, uint8_t *out_buf);
extern int32_t seed_platform_coff_write_coff_o_to_buf_impl(uint8_t *elf_ctx, uint8_t *out_buf);

int32_t user_asm_seed_bridge_x_doc_anchor(void) { return 0; }

/* === 4 thin+rest forwards === */

void seed_elf_ctx_set_macho_leading_underscore(uint8_t *elf_ctx, int32_t on) {
  seed_elf_ctx_set_macho_leading_underscore_impl(elf_ctx, on);
}

int32_t seed_asm_reject_empty_elf_text(uint8_t *module, uint8_t *elf_ctx) {
  return seed_asm_reject_empty_elf_text_impl(module, elf_ctx);
}

int32_t seed_platform_macho_write_macho_o_to_buf(uint8_t *elf_ctx, uint8_t *out_buf) {
  return seed_platform_macho_write_macho_o_to_buf_impl(elf_ctx, out_buf);
}

int32_t seed_platform_coff_write_coff_o_to_buf(uint8_t *elf_ctx, uint8_t *out_buf) {
  return seed_platform_coff_write_coff_o_to_buf_impl(elf_ctx, out_buf);
}

/* === 2 DIRECT env gates via link_abi_getenv extern bridge === */

int32_t seed_asm_debug_enabled(void) {
  uint8_t *e = link_abi_getenv((uint8_t *)"XLANG_ASM_DEBUG");
  if (e != 0) { return 1; }
  return 0;
}

int32_t seed_asm_emit_trace_enabled(void) {
  uint8_t *e = link_abi_getenv((uint8_t *)"XLANG_ASM_EMIT_TRACE");
  if (e != 0) { return 1; }
  return 0;
}

/* === 1 DIRECT pure compute === */

int32_t seed_elf_ctx_code_len(uint8_t *elf_ctx) {
  if (elf_ctx == 0) { return 0; }
  int32_t *p = (int32_t *)elf_ctx;
  return p[0];
}
