/**
 * PLATFORM: WINDOWS tip PE only — knife 11.72.
 *
 * Tip Prefer peel left __stale_prim_parser_asm_primary_lbrace_x_into_c
 * as e9→primary_suffix_loop (no LBRACE consume / no struct-lit). Soft Cap
 * trampolines stale primary onto live; tip primary_x is full body but its
 * LBRACE arm calls the broken W stub. Tip already has live anon/fields
 * orphans + working ptr wrappers — only the lbrace dispatcher is missing.
 *
 * Host-gcc tip-local twin calls tip PE symbols only (bak nm VAs). No Soft
 * Cap body copy. No 11.67 wrap rollback. No pin raise.
 */
#include <stdint.h>

enum { TOKEN_LBRACE = 84 };

extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern void parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lbrace_looks_like_block_ptr_c(void *lex_inout, void *source);
extern void parser_asm_parse_anonymous_struct_lit_ptr_c(void *arena, void *lex_inout, void *source,
                                                       int32_t *out_ok, int32_t *out_expr_ref);
extern int32_t parser_parse_block_ptr_into_c(void *arena, void *lex_inout, void *source, int32_t unused,
                                            int32_t *out_ok, int32_t *out_block_ref);
/* tip W wrap_block is miswired; use tip-local primary wrap (t). */
extern int32_t parser_asm_wrap_block_ref_as_expr_primary_c(void *arena, int32_t block_ref, int32_t line);
extern void __stale_prim_parser_asm_primary_suffix_loop_x_into_c(
    void *arena, void *source, void *lex_inout, int32_t *out_ok, int32_t *out_expr_ref, int32_t *mc_arg_buf,
    int32_t *arg_buf, int32_t *parsed_refs, int32_t *pending_refs, void *mangled, void *name_buf);

/**
 * @return 1 handled (incl. fail via *out_ok=0); 0 not LBRACE.
 * ABI twin of parser_asm_primary_lbrace_x_into_c (pthin_expr_primary.x).
 */
int32_t __stale_prim_parser_asm_primary_lbrace_x_into_c(void *arena, void *lex_inout, void *source,
                                                       int32_t *out_ok, int32_t *out_expr_ref,
                                                       int32_t *mc_arg_buf, int32_t *arg_buf,
                                                       int32_t *parsed_refs, int32_t *pending_refs,
                                                       void *mangled, void *name_buf) {
  int32_t kind;
  int32_t bok;
  int32_t bref;
  int32_t wrap;
  int32_t eok;
  int32_t eref;

  if (!arena || !lex_inout || !source || !out_ok || !out_expr_ref)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_LBRACE)
    return 0;
  parser_asm_lex_step_kind_c(lex_inout, source);
  if (parser_asm_lbrace_looks_like_block_ptr_c(lex_inout, source) != 0) {
    bok = 0;
    bref = 0;
    if (parser_parse_block_ptr_into_c(arena, lex_inout, source, 0, &bok, &bref) == 0 || bok == 0) {
      *out_ok = 0;
      return 1;
    }
    wrap = parser_asm_wrap_block_ref_as_expr_primary_c(arena, bref, 0);
    if (wrap == 0) {
      *out_ok = 0;
      return 1;
    }
    *out_ok = 1;
    *out_expr_ref = wrap;
    __stale_prim_parser_asm_primary_suffix_loop_x_into_c(arena, source, lex_inout, out_ok, out_expr_ref,
                                                        mc_arg_buf, arg_buf, parsed_refs, pending_refs,
                                                        mangled, name_buf);
    return 1;
  }
  eok = 0;
  eref = 0;
  parser_asm_parse_anonymous_struct_lit_ptr_c(arena, lex_inout, source, &eok, &eref);
  if (eok == 0) {
    *out_ok = 0;
    return 1;
  }
  *out_ok = 1;
  *out_expr_ref = eref;
  __stale_prim_parser_asm_primary_suffix_loop_x_into_c(arena, source, lex_inout, out_ok, out_expr_ref,
                                                      mc_arg_buf, arg_buf, parsed_refs, pending_refs,
                                                      mangled, name_buf);
  return 1;
}
