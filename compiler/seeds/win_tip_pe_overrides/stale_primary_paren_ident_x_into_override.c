/**
 * PLATFORM: WINDOWS tip PE only — knife 11.55.
 *
 * Tip-peel left __stale_prim_parser_asm_primary_{paren,ident}_x_into_c
 * as 8-byte jmp→suffix_loop (no LPAREN/IDENT consume). Soft Cap keeps
 * live parser_asm_primary_*_x_into_c and trampolines stale parse_primary
 * +0 onto them; tip has no live copies (14 missing). Soft Cap mix banned.
 *
 * Strong tip-local C twins (host-gcc) for paren + minimal ident, then
 * PE-inject + JMP the weak stubs. Calls tip PE symbols only.
 */
#include <stdint.h>

enum { TOKEN_IDENT = 59, TOKEN_SELF = 60, TOKEN_LPAREN = 82, TOKEN_RPAREN = 83, TOKEN_LBRACE = 84 };
enum { EXPR_VAR_LIT = 3 };

extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern void parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_ident_len_c(void *lex_inout, void *source);
extern size_t parser_asm_lex_peek_token_start_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_tok_line_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_tok_col_c(void *lex_inout, void *source);
extern uint8_t *parser_asm_lex_source_data_c(void *source);
extern int32_t ast_ast_arena_expr_alloc(void *arena);
extern void pipeline_expr_set_kind(void *arena, int32_t ref, int32_t kind);
extern void pipeline_expr_set_common_zeros_c(void *arena, int32_t ref);
extern void pipeline_expr_set_line_col(void *arena, int32_t ref, int32_t line, int32_t col);
extern void pipeline_expr_set_var_name(void *arena, int32_t ref, uint8_t *data, int32_t vlen);
extern int32_t parser_parse_expr_ptr_into_c(void *arena, void *lex_inout, void *source, int32_t *out_ok,
                                           int32_t *out_expr_ref);
extern int32_t parser_asm_ident_pre_dispatch_ptr_c(void *arena, void *lex_inout, void *source, int32_t *out_ok,
                                                    int32_t *out_expr_ref);
extern void __stale_prim_parser_asm_primary_suffix_loop_x_into_c(
    void *arena, void *source, void *lex_inout, int32_t *out_ok, int32_t *out_expr_ref, int32_t *mc_arg_buf,
    int32_t *arg_buf, int32_t *parsed_refs, int32_t *pending_refs, void *mangled, void *name_buf);

int32_t __stale_prim_parser_asm_primary_paren_x_into_c(void *arena, void *lex_inout, void *source,
                                                       int32_t *out_ok, int32_t *out_expr_ref,
                                                       int32_t *mc_arg_buf, int32_t *arg_buf,
                                                       int32_t *parsed_refs, int32_t *pending_refs,
                                                       void *mangled, void *name_buf) {
  int32_t kind;
  int32_t eok;
  int32_t eref;
  if (!arena || !lex_inout || !source || !out_ok || !out_expr_ref)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_LPAREN)
    return 0;
  parser_asm_lex_step_kind_c(lex_inout, source);
  eok = 0;
  eref = 0;
  if (parser_parse_expr_ptr_into_c(arena, lex_inout, source, &eok, &eref) == 0 || eok == 0) {
    *out_ok = 0;
    return 1;
  }
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_RPAREN) {
    *out_ok = 0;
    return 1;
  }
  parser_asm_lex_step_kind_c(lex_inout, source);
  *out_ok = 1;
  *out_expr_ref = eref;
  __stale_prim_parser_asm_primary_suffix_loop_x_into_c(arena, source, lex_inout, out_ok, out_expr_ref,
                                                       mc_arg_buf, arg_buf, parsed_refs, pending_refs,
                                                       mangled, name_buf);
  return 1;
}

/* Minimal IDENT/SELF → EXPR_VAR_LIT + suffix_loop. Skips struct-lit `{`
 * restore path (leave LBRACE for stmt parsers); still runs ident_pre_dispatch. */
int32_t __stale_prim_parser_asm_primary_ident_x_into_c(void *arena, void *lex_inout, void *source,
                                                       int32_t *out_ok, int32_t *out_expr_ref,
                                                       int32_t *mc_arg_buf, int32_t *arg_buf,
                                                       int32_t *parsed_refs, int32_t *pending_refs,
                                                       void *mangled, void *name_buf) {
  int32_t kind;
  int32_t vlen;
  int32_t ref;
  int32_t tl;
  int32_t tc;
  int32_t ok2;
  int32_t pref;
  size_t ts;
  uint8_t *data;
  if (!arena || !lex_inout || !source || !out_ok || !out_expr_ref)
    return 0;
  *out_ok = 0;
  *out_expr_ref = 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_IDENT && kind != TOKEN_SELF)
    return 0;
  ok2 = 0;
  pref = 0;
  if (parser_asm_ident_pre_dispatch_ptr_c(arena, lex_inout, source, &ok2, &pref) != 0) {
    *out_ok = ok2;
    *out_expr_ref = pref;
    return 1;
  }
  vlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
  if (kind == TOKEN_SELF)
    vlen = 4;
  ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
  tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
  tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
  data = parser_asm_lex_source_data_c(source);
  ref = ast_ast_arena_expr_alloc(arena);
  if (ref == 0) {
    *out_ok = 0;
    return 1;
  }
  pipeline_expr_set_kind(arena, ref, EXPR_VAR_LIT);
  pipeline_expr_set_line_col(arena, ref, tl, tc);
  pipeline_expr_set_common_zeros_c(arena, ref);
  pipeline_expr_set_var_name(arena, ref, data + ts, vlen);
  *out_ok = 1;
  *out_expr_ref = ref;
  parser_asm_lex_step_kind_c(lex_inout, source);
  /* If next is LBRACE, leave it — stmt/block parsers own prefer-block. */
  __stale_prim_parser_asm_primary_suffix_loop_x_into_c(arena, source, lex_inout, out_ok, out_expr_ref,
                                                       mc_arg_buf, arg_buf, parsed_refs, pending_refs,
                                                       mangled, name_buf);
  return 1;
}
