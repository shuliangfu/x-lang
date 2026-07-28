/* seeds/parser_asm_parse_expr_link_surface.from_x.c
 * G-02f-81 parser_asm_parse_expr_link R2 thin+rest surface - isomorphic with src/asm/parser_asm_parse_expr_link.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/parser_asm_parse_expr_link.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (1 #[no_mangle] + 1 doc_anchor)
 * Mode: thin+rest - 1 thin forward to link_abi_getenv extern bridge
 * Cap residual: link_abi_getenv (extern bridge, not #[no_mangle])
 * doc_anchor parser_asm_parse_expr_link_x_doc_anchor (no ast_; no module prefix on doc_anchor).
 * Note: parser_asm_ prefix not trigger ast_ (confirmed wave545+).
 * Logic: 1 thin+rest function. seed 全守卫 #ifndef XLANG_PARSER_ASM_PARSE_EXPR_LINK_FROM_X.
 * Regen: ./xlang-c -E ... parser_asm_parse_expr_link.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern uint8_t *link_abi_getenv(uint8_t *name);

int32_t parser_asm_parse_expr_link_x_doc_anchor(void) { return 0; }

/* parser_asm_parse_expr_debug_enabled: thin+rest via link_abi_getenv extern bridge.
 * Rules (≡ historical seed): null / empty / leading '0' → 0; any other non-empty → 1. */
int32_t parser_asm_parse_expr_debug_enabled(void) {
  uint8_t *v = link_abi_getenv((uint8_t *)"XLANG_PARSER_ASM_DEBUG");
  if (v == 0) { return 0; }
  if (v[0] == 0) { return 0; }
  /* Leading ASCII '0' (48) disables debug. */
  if (v[0] == 48) { return 0; }
  return 1;
}
