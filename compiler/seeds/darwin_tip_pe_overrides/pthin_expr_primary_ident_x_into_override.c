/**
 * PLATFORM: MACOS|DARWIN arm64 tip PE only —
 * tip_l4_tip_pe_println_method_call_p001 (follow-on after semi twin).
 *
 * Residual: tip parser_asm_primary_ident_x_into_c elides peeks (kind stays 0)
 * → early return 0 → primary fallthrough out_ok=0 → dig_id/hello P001.
 * Cap peeks kind/ident_len/token_start/line/col + expr_alloc. Soft Cap /
 * Prefer / Cap aside / Win banned.
 *
 * Tip-local host-cc twin from src/asm/pthin_expr_primary.x.
 */
#include <stddef.h>
#include <stdint.h>

enum {
  TOKEN_SELF = 51,
  TOKEN_IDENT = 59,
  TOKEN_LBRACE = 84,
  EXPR_VAR_LIT = 3
};

extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_ident_len_c(void *lex_inout, void *source);
extern size_t parser_asm_lex_peek_token_start_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_tok_line_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_tok_col_c(void *lex_inout, void *source);
extern uint8_t *parser_asm_lex_source_data_c(void *source);
extern int32_t parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern size_t parser_asm_lex_pos_c(void *lex_inout);
extern int32_t parser_asm_lex_line_c(void *lex_inout);
extern int32_t parser_asm_lex_col_c(void *lex_inout);
extern void parser_asm_lex_set_pos_c(void *lex_inout, size_t pos);
extern void parser_asm_lex_set_line_c(void *lex_inout, int32_t line);
extern void parser_asm_lex_set_col_c(void *lex_inout, int32_t col);

extern int32_t ast_ast_arena_expr_alloc(void *arena);
extern void pipeline_expr_set_kind(void *arena, int32_t er, int32_t kind);
extern void pipeline_expr_set_line_col(void *arena, int32_t er, int32_t line,
                                      int32_t col);
extern void pipeline_expr_set_common_zeros_c(void *arena, int32_t er);
extern void pipeline_expr_set_var_name(void *arena, int32_t er, uint8_t *data,
                                      int32_t vlen);

extern int32_t parser_asm_ident_pre_dispatch_ptr_c(void *arena, void *lex_inout,
                                                  void *source, int32_t *out_ok,
                                                  int32_t *out_expr_ref);
extern int32_t parser_asm_lbrace_looks_like_block_ptr_c(void *lex_inout,
                                                       void *source);
extern int32_t parser_asm_empty_ident_braces_prefer_block_ptr_c(void *lex_inout,
                                                               void *source);
extern void parser_finish_struct_lit_ptr_into_c(void *arena, int32_t head_ref,
                                               void *lex_inout, void *source,
                                               int32_t *out_ok,
                                               int32_t *out_expr_ref);
extern int32_t parser_asm_primary_suffix_loop_x_into_c(
    void *arena, void *source, void *lex_inout, int32_t *out_ok,
    int32_t *out_expr_ref, int32_t *mc_arg_buf, int32_t *arg_buf,
    int32_t *parsed_refs, int32_t *pending_refs, uint8_t *mangled,
    uint8_t *name_buf);

int32_t parser_asm_primary_ident_x_into_c(
    void *arena, void *lex_inout, void *source, int32_t *out_ok,
    int32_t *out_expr_ref, int32_t *mc_arg_buf, int32_t *arg_buf,
    int32_t *parsed_refs, int32_t *pending_refs, uint8_t *mangled,
    uint8_t *name_buf) {
  int32_t kind;
  int32_t vlen;
  int32_t name_was_self;
  int32_t ref;
  size_t ts;
  int32_t tl;
  int32_t tc;
  size_t pos0;
  int32_t line0;
  int32_t col0;
  uint8_t *data;
  int32_t ok2;
  (void)mangled;
  (void)name_buf;
  if (!arena || !lex_inout || !source || !out_ok || !out_expr_ref)
    return 0;
  out_ok[0] = 0;
  out_expr_ref[0] = 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_IDENT && kind != TOKEN_SELF)
    return 0;
  ok2 = 0;
  ref = 0;
  if (parser_asm_ident_pre_dispatch_ptr_c(arena, lex_inout, source, &ok2,
                                          &ref) != 0) {
    out_ok[0] = ok2;
    out_expr_ref[0] = ref;
    return 1;
  }
  name_was_self = 0;
  vlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
  if (kind == TOKEN_SELF) {
    name_was_self = 1;
    vlen = 4;
  }
  ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
  tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
  tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
  data = parser_asm_lex_source_data_c(source);
  ref = ast_ast_arena_expr_alloc(arena);
  if (ref == 0) {
    out_ok[0] = 0;
    return 1;
  }
  pipeline_expr_set_kind(arena, ref, EXPR_VAR_LIT);
  pipeline_expr_set_line_col(arena, ref, tl, tc);
  pipeline_expr_set_common_zeros_c(arena, ref);
  pipeline_expr_set_var_name(arena, ref, data + ts, vlen);
  out_ok[0] = 1;
  out_expr_ref[0] = ref;
  parser_asm_lex_step_kind_c(lex_inout, source);
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind == TOKEN_LBRACE && name_was_self == 0) {
    pos0 = parser_asm_lex_pos_c(lex_inout);
    line0 = parser_asm_lex_line_c(lex_inout);
    col0 = parser_asm_lex_col_c(lex_inout);
    parser_asm_lex_step_kind_c(lex_inout, source);
    if (parser_asm_lbrace_looks_like_block_ptr_c(lex_inout, source) != 0) {
      parser_asm_lex_set_pos_c(lex_inout, pos0);
      parser_asm_lex_set_line_c(lex_inout, line0);
      parser_asm_lex_set_col_c(lex_inout, col0);
      return 1;
    }
    if (parser_asm_empty_ident_braces_prefer_block_ptr_c(lex_inout, source) ==
        1) {
      parser_asm_lex_set_pos_c(lex_inout, pos0);
      parser_asm_lex_set_line_c(lex_inout, line0);
      parser_asm_lex_set_col_c(lex_inout, col0);
      return 1;
    }
    ok2 = 0;
    ref = 0;
    parser_finish_struct_lit_ptr_into_c(arena, out_expr_ref[0], lex_inout,
                                       source, &ok2, &ref);
    if (ok2 == 0) {
      out_ok[0] = 0;
      return 1;
    }
    out_expr_ref[0] = ref;
  }
  parser_asm_primary_suffix_loop_x_into_c(arena, source, lex_inout, out_ok,
                                         out_expr_ref, mc_arg_buf, arg_buf,
                                         parsed_refs, pending_refs, mangled,
                                         name_buf);
  return 1;
}
