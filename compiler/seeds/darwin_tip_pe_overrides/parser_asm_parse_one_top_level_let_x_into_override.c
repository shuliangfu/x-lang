/**
 * PLATFORM: MACOS|DARWIN arm64 tip PE only —
 * tip_l4_tip_pe_toplevel_let_const_p014.
 *
 * Tip PE selfhost-emitted parser_asm_parse_one_top_level_let_x_into_c
 * (pthin_let_alias.x via BODIES_FROM_X) drops every bl to
 * lex_peek_kind / peek_ident_len / peek_next_pos / peek_tok_line /
 * peek_tok_col. Locals stay 0 → kind!=IDENT always → false P014 on
 * valid `const x = 1;` / product hello `const fmt = import(...)`, then
 * diag_io SEGV. Cap aside keeps the peek sequence. Soft Cap Prefer /
 * Cap aside / Win banned.
 *
 * Tip-local host-cc twin of src/asm/pthin_let_alias.x x_into body.
 * g05_relink_env prepends this .o and weakens the hollow tip T in
 * parser_asm_thin_glue.o so the twin wins.
 */
#include <stddef.h>
#include <stdint.h>

enum {
  TOKEN_IDENT = 59,
  TOKEN_COLON = 91,
  TOKEN_SEMICOLON = 95,
  TOKEN_ASSIGN = 117
};

extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_ident_len_c(void *lex_inout, void *source);
extern size_t parser_asm_lex_peek_next_pos_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_tok_line_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_tok_col_c(void *lex_inout, void *source);

extern void parser_asm_let_alias_pack_reset_c(void *pack);
extern int32_t parser_asm_let_alias_pack_is_mut_src_c(void *source, size_t next_pos,
                                                     int32_t ident_len);
extern int32_t parser_asm_let_alias_pack_copy_name_src_c(void *pack, void *source,
                                                        size_t next_pos, int32_t ident_len,
                                                        int32_t line, int32_t col);
extern int32_t parser_asm_let_alias_pack_name_exists_c(void *pack, void *module);
extern int32_t parser_asm_let_alias_pack_commit_let_c(void *pack, void *module,
                                                     int32_t type_ref, int32_t init_ref,
                                                     int32_t is_const);

extern int32_t parser_asm_parse_type_ref_ptr_into_c(void *arena, void *lex_inout,
                                                   void *source);
extern int32_t parser_parse_expr_ptr_into_c(void *arena, void *lex_inout, void *source,
                                           int32_t *out_ok, int32_t *out_expr_ref);

extern void parser_report_keyword_binding_p014_c(int32_t line, int32_t col);
extern void parser_report_untyped_binding_p010_c(int32_t line, int32_t col, int32_t is_let);
extern void parser_report_duplicate_name_p012_c(int32_t line, int32_t col, int32_t kind);

int32_t parser_asm_parse_one_top_level_let_x_into_c(void *arena, void *module,
                                                   void *lex_inout, void *source,
                                                   int32_t is_const, void *pack) {
  int32_t kind;
  int32_t il;
  size_t np;
  int32_t line;
  int32_t col;
  int32_t type_ref;
  int32_t eok;
  int32_t eref;
  int32_t ic;
  int32_t is_let;

  if (!arena || !module || !lex_inout || !source || !pack)
    return 0;

  parser_asm_let_alias_pack_reset_c(pack);
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  il = parser_asm_lex_peek_ident_len_c(lex_inout, source);
  np = parser_asm_lex_peek_next_pos_c(lex_inout, source);
  /* wave385: optional IDENT "mut" after let (not const). */
  if (is_const == 0 && kind == TOKEN_IDENT &&
      parser_asm_let_alias_pack_is_mut_src_c(source, np, il) != 0) {
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  }
  line = parser_asm_lex_peek_tok_line_c(lex_inout, source);
  col = parser_asm_lex_peek_tok_col_c(lex_inout, source);
  if (kind != TOKEN_IDENT) {
    parser_report_keyword_binding_p014_c(line, col);
    return 0;
  }
  il = parser_asm_lex_peek_ident_len_c(lex_inout, source);
  if (il <= 0 || il > 255)
    return 0;
  np = parser_asm_lex_peek_next_pos_c(lex_inout, source);
  if (parser_asm_let_alias_pack_copy_name_src_c(pack, source, np, il, line, col) == 0)
    return 0;
  parser_asm_lex_step_kind_c(lex_inout, source);
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  type_ref = 0;
  if (kind == TOKEN_COLON) {
    parser_asm_lex_step_kind_c(lex_inout, source);
    type_ref = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
    if (type_ref == 0)
      return 0;
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  } else if (is_const != 0 && kind == TOKEN_ASSIGN) {
    /* const name = init — type inference; leave type_ref=0. */
  } else {
    line = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    col = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    is_let = (is_const == 0) ? 1 : 0;
    parser_report_untyped_binding_p010_c(line, col, is_let);
    return 0;
  }
  if (kind != TOKEN_ASSIGN)
    return 0;
  parser_asm_lex_step_kind_c(lex_inout, source);
  eok = 0;
  eref = 0;
  if (parser_parse_expr_ptr_into_c(arena, lex_inout, source, &eok, &eref) == 0)
    return 0;
  if (eok == 0)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_SEMICOLON)
    return 0;
  parser_asm_lex_step_kind_c(lex_inout, source);
  if (parser_asm_let_alias_pack_name_exists_c(pack, module) != 0) {
    parser_report_duplicate_name_p012_c(line, col, 2);
    return 0;
  }
  ic = (is_const != 0) ? 1 : 0;
  if (parser_asm_let_alias_pack_commit_let_c(pack, module, type_ref, eref, ic) == 0)
    return 0;
  return 1;
}
