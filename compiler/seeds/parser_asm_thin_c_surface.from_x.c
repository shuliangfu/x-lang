/* seeds/parser_asm_thin_c_surface.from_x.c
 * G-02f-88 parser_asm_thin_c R2 mixed surface - isomorphic with src/asm/parser_asm_thin_c.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/parser_asm_thin_c.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (11 #[no_mangle] + 1 doc_anchor)
 * Mode: mixed - 10 thin+rest forwards to _impl + 1 DIRECT pure compute
 * Cap residual: 10 _impl bridges (parser_asm_copy_token_bytes_to_buf64_impl + parser_asm_extern_parse_set_fail_c_impl
 *   + parser_asm_skip_trait_impl_block_raw_c_impl + parser_asm_skip_one_top_level_let_into_slice_c_impl
 *   + parser_asm_skip_one_top_level_const_into_slice_c_impl + parser_asm_cfg_skip_pending_top_level_into_slice_c_impl
 *   + parser_asm_try_skip_const_import_stmt_impl + parser_asm_collect_imports_consume_path_impl
 *   + parser_asm_write_try_skip_allow_result_impl + parser_asm_lex_from_lr_next_c_impl)
 * doc_anchor parser_asm_thin_c_x_doc_anchor (no ast_; no module prefix on doc_anchor).
 * Note: parser_asm_ prefix not trigger ast_ (confirmed wave545+).
 * Logic: 11 functions = 10 thin+rest + 1 DIRECT pure compute (parser_asm_is_fn_sig_scalar_type_token_c).
 * Regen: ./xlang-c -E ... parser_asm_thin_c.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern void parser_asm_copy_token_bytes_to_buf64_impl(uint8_t *src, int32_t n, uint8_t *dst);
extern void parser_asm_extern_parse_set_fail_c_impl(uint8_t *of, int32_t code);
extern void parser_asm_skip_trait_impl_block_raw_c_impl(uint8_t *out, uint8_t *start, int32_t a, int32_t b);
extern void parser_asm_skip_one_top_level_let_into_slice_c_impl(uint8_t *out, uint8_t *src, uint8_t *lex);
extern void parser_asm_skip_one_top_level_const_into_slice_c_impl(uint8_t *out, uint8_t *src, uint8_t *lex);
extern void parser_asm_cfg_skip_pending_top_level_into_slice_c_impl(uint8_t *lex, uint8_t *src, int32_t a);
extern int32_t parser_asm_try_skip_const_import_stmt_impl(uint8_t *lex, uint8_t *src);
extern int32_t parser_asm_collect_imports_consume_path_impl(uint8_t *out, uint8_t *src, int32_t a);
extern void parser_asm_write_try_skip_allow_result_impl(uint8_t *out, int32_t a, int32_t b);
extern void parser_asm_lex_from_lr_next_c_impl(uint8_t *lex, uint8_t *r);

int32_t parser_asm_thin_c_x_doc_anchor(void) { return 0; }

/* === 10 thin+rest forwards === */

void parser_asm_copy_token_bytes_to_buf64(uint8_t *src, int32_t n, uint8_t *dst) {
  parser_asm_copy_token_bytes_to_buf64_impl(src, n, dst);
}

void parser_asm_extern_parse_set_fail_c(uint8_t *of, int32_t code) {
  parser_asm_extern_parse_set_fail_c_impl(of, code);
}

void parser_asm_skip_trait_impl_block_raw_c(uint8_t *out, uint8_t *start, int32_t a, int32_t b) {
  parser_asm_skip_trait_impl_block_raw_c_impl(out, start, a, b);
}

void parser_asm_skip_one_top_level_let_into_slice_c(uint8_t *out, uint8_t *src, uint8_t *lex) {
  parser_asm_skip_one_top_level_let_into_slice_c_impl(out, src, lex);
}

void parser_asm_skip_one_top_level_const_into_slice_c(uint8_t *out, uint8_t *src, uint8_t *lex) {
  parser_asm_skip_one_top_level_const_into_slice_c_impl(out, src, lex);
}

void parser_asm_cfg_skip_pending_top_level_into_slice_c(uint8_t *lex, uint8_t *src, int32_t a) {
  parser_asm_cfg_skip_pending_top_level_into_slice_c_impl(lex, src, a);
}

int32_t parser_asm_try_skip_const_import_stmt(uint8_t *lex, uint8_t *src) {
  return parser_asm_try_skip_const_import_stmt_impl(lex, src);
}

int32_t parser_asm_collect_imports_consume_path(uint8_t *out, uint8_t *src, int32_t a) {
  return parser_asm_collect_imports_consume_path_impl(out, src, a);
}

void parser_asm_write_try_skip_allow_result(uint8_t *out, int32_t a, int32_t b) {
  parser_asm_write_try_skip_allow_result_impl(out, a, b);
}

void parser_asm_lex_from_lr_next_c(uint8_t *lex, uint8_t *r) {
  parser_asm_lex_from_lr_next_c_impl(lex, r);
}

/* === 1 DIRECT pure compute === */
/* TokenKind from token.h (cc-verified): IDENT=59 I32=60 BOOL=61 U8=62 U32=63 U64=64 I64=65 USIZE=66 VOID=79 */

int32_t parser_asm_is_fn_sig_scalar_type_token_c(int32_t tok) {
  if (tok == 60) { return 1; } /* I32 */
  if (tok == 65) { return 1; } /* I64 */
  if (tok == 61) { return 1; } /* BOOL */
  if (tok == 62) { return 1; } /* U8 */
  if (tok == 63) { return 1; } /* U32 */
  if (tok == 64) { return 1; } /* U64 */
  if (tok == 66) { return 1; } /* USIZE */
  if (tok == 79) { return 1; } /* VOID */
  if (tok == 59) { return 1; } /* IDENT */
  return 0;
}
