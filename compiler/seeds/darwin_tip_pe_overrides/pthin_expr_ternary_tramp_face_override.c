/**
 * PLATFORM: MACOS|DARWIN arm64 tip PE only —
 * tip_l4_tip_pe_println_method_call_p001.
 *
 * Tip PE selfhost BODIES_FROM_X hollows the ternary/assign parse stack:
 *   1) pthin_expr_ternary_tramp_face drops bls to x_into (memcpy-only)
 *   2) parser_asm_parse_{ternary,assign}_x_into_c drop peeks/logor/wrap
 *   3) {ternary,assign}_wrap_into_c drop ast_ast_arena_expr_alloc
 * → ok=0 → onefunc fail → false P001 on any non-empty fn body
 * (product hello fmt.println / return 0 / field / if). Cap aside keeps
 * the full sequence. Soft Cap Prefer / Cap aside / Win banned.
 *
 * Tip-local host-cc twins of tramp face + macOS slice wrappers +
 * x_into bodies + wrap bodies (src/asm/pthin_expr_ternary{,_tramp}.x).
 * g05_relink_env prepends this .o and demotes hollow tip archive Ts.
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

enum {
  TOKEN_COLON = 91,
  TOKEN_ASSIGN = 117,
  TOKEN_QUESTION = 127,
  EXPR_TERNARY = 27,
  EXPR_ASSIGN = 28
};

extern int32_t parser_asm_parse_ternary_x_into_c(void *arena, void *lex_inout,
                                                void *source, int32_t *out_ok,
                                                int32_t *out_expr_ref);
extern int32_t parser_asm_parse_assign_x_into_c(void *arena, void *lex_inout,
                                               void *source, int32_t *out_ok,
                                               int32_t *out_expr_ref);

extern int32_t parser_parse_logor_ptr_into_c(void *arena, void *lex_inout,
                                            void *source, int32_t *out_ok,
                                            int32_t *out_expr_ref);
extern int32_t parser_parse_expr_ptr_into_c(void *arena, void *lex_inout,
                                           void *source, int32_t *out_ok,
                                           int32_t *out_expr_ref);
extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_tok_line_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_tok_col_c(void *lex_inout, void *source);
extern int32_t parser_asm_is_compound_assign_token_c(int32_t kind);
extern int32_t compound_assign_token_to_expr_kind_from_glue(int32_t kind);
extern int32_t pipeline_expr_ref_is_assign_lvalue(void *arena, int32_t expr_ref);

extern int32_t ast_ast_arena_expr_alloc(void *arena);
extern void pipeline_expr_set_common_zeros_c(void *arena, int32_t er);
extern void pipeline_expr_set_kind(void *arena, int32_t er, int32_t kind);
extern void pipeline_expr_set_line_col(void *arena, int32_t er, int32_t line,
                                      int32_t col);
extern void pipeline_expr_set_if_c(void *arena, int32_t er, int32_t cond,
                                   int32_t then_ref, int32_t else_ref);
extern void pipeline_expr_set_binop_operands_c(void *arena, int32_t er,
                                              int32_t left, int32_t right);

typedef struct {
  size_t pos;
  int32_t line;
  int32_t col;
} PthinTernaryLex;

int32_t parser_asm_ternary_wrap_into_c(void *arena, int32_t *out_ok,
                                       int32_t *out_expr_ref, int32_t cond_ref,
                                       int32_t then_ref, int32_t else_ref) {
  int32_t tern_ref;
  if (!arena || !out_ok || !out_expr_ref)
    return 0;
  tern_ref = ast_ast_arena_expr_alloc(arena);
  if (tern_ref == 0) {
    out_ok[0] = 0;
    return 0;
  }
  pipeline_expr_set_common_zeros_c(arena, tern_ref);
  pipeline_expr_set_kind(arena, tern_ref, EXPR_TERNARY);
  pipeline_expr_set_if_c(arena, tern_ref, cond_ref, then_ref, else_ref);
  pipeline_expr_set_line_col(arena, tern_ref, 0, 0);
  out_expr_ref[0] = tern_ref;
  return tern_ref;
}

int32_t parser_asm_assign_wrap_into_c(void *arena, int32_t *out_ok,
                                      int32_t *out_expr_ref, int32_t kind,
                                      int32_t left_ref, int32_t right_ref,
                                      int32_t line, int32_t col) {
  int32_t bin_ref;
  if (!arena || !out_ok || !out_expr_ref)
    return 0;
  bin_ref = ast_ast_arena_expr_alloc(arena);
  if (bin_ref == 0) {
    out_ok[0] = 0;
    return 0;
  }
  pipeline_expr_set_common_zeros_c(arena, bin_ref);
  pipeline_expr_set_kind(arena, bin_ref, kind);
  pipeline_expr_set_binop_operands_c(arena, bin_ref, left_ref, right_ref);
  pipeline_expr_set_line_col(arena, bin_ref, line, col);
  out_expr_ref[0] = bin_ref;
  return bin_ref;
}

int32_t parser_asm_parse_ternary_x_into_c(void *arena, void *lex_inout,
                                         void *source, int32_t *out_ok,
                                         int32_t *out_expr_ref) {
  int32_t kind;
  int32_t cond_ref;
  int32_t then_ref;
  int32_t else_ref;
  int32_t wr;
  int32_t rc;
  if (!arena || !lex_inout || !source || !out_ok || !out_expr_ref)
    return 0;
  out_ok[0] = 0;
  out_expr_ref[0] = 0;
  rc = parser_parse_logor_ptr_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
  if (rc == 0)
    return 0;
  if (out_ok[0] == 0)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_QUESTION)
    return 1;
  cond_ref = out_expr_ref[0];
  parser_asm_lex_step_kind_c(lex_inout, source);
  rc = parser_parse_expr_ptr_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
  if (rc == 0) {
    out_ok[0] = 0;
    return 0;
  }
  if (out_ok[0] == 0)
    return 0;
  then_ref = out_expr_ref[0];
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_COLON) {
    out_ok[0] = 0;
    return 0;
  }
  parser_asm_lex_step_kind_c(lex_inout, source);
  rc = parser_asm_parse_ternary_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
  if (rc == 0)
    return 0;
  if (out_ok[0] == 0)
    return 0;
  else_ref = out_expr_ref[0];
  wr = parser_asm_ternary_wrap_into_c(arena, out_ok, out_expr_ref, cond_ref, then_ref,
                                     else_ref);
  if (wr == 0) {
    out_ok[0] = 0;
    return 0;
  }
  return 1;
}

int32_t parser_asm_parse_assign_x_into_c(void *arena, void *lex_inout, void *source,
                                        int32_t *out_ok, int32_t *out_expr_ref) {
  int32_t kind;
  int32_t left_ref;
  int32_t right_ref;
  int32_t assign_kind;
  int32_t assign_line;
  int32_t assign_col;
  int32_t wr;
  int32_t rc;
  int32_t lv;
  if (!arena || !lex_inout || !source || !out_ok || !out_expr_ref)
    return 0;
  out_ok[0] = 0;
  out_expr_ref[0] = 0;
  rc = parser_asm_parse_ternary_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
  if (rc == 0)
    return 0;
  if (out_ok[0] == 0)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_ASSIGN && parser_asm_is_compound_assign_token_c(kind) == 0)
    return 1;
  lv = pipeline_expr_ref_is_assign_lvalue(arena, out_expr_ref[0]);
  if (lv == 0)
    return 1;
  left_ref = out_expr_ref[0];
  assign_kind = EXPR_ASSIGN;
  if (kind != TOKEN_ASSIGN)
    assign_kind = compound_assign_token_to_expr_kind_from_glue(kind);
  assign_line = parser_asm_lex_peek_tok_line_c(lex_inout, source);
  assign_col = parser_asm_lex_peek_tok_col_c(lex_inout, source);
  parser_asm_lex_step_kind_c(lex_inout, source);
  rc = parser_asm_parse_ternary_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
  if (rc == 0) {
    out_ok[0] = 0;
    return 0;
  }
  if (out_ok[0] == 0)
    return 0;
  right_ref = out_expr_ref[0];
  wr = parser_asm_assign_wrap_into_c(arena, out_ok, out_expr_ref, assign_kind, left_ref,
                                    right_ref, assign_line, assign_col);
  if (wr == 0) {
    out_ok[0] = 0;
    return 0;
  }
  return 1;
}

void pthin_expr_ternary_tramp_face(void *arena, void *lex, void *source, void *out,
                                  int32_t which) {
  int32_t *op;
  uint8_t cur[16];
  int32_t ok;
  int32_t refv;
  int32_t rc;

  if (out == NULL)
    return;
  op = (int32_t *)out;
  if (source == NULL || lex == NULL) {
    op[0] = 0;
    return;
  }
  memcpy(cur, lex, 16);
  ok = 0;
  refv = 0;
  {
    int32_t pk = parser_asm_lex_peek_kind_c(cur, source);
  }
  if (which == 0)
    rc = parser_asm_parse_ternary_x_into_c(arena, cur, source, &ok, &refv);
  else
    rc = parser_asm_parse_assign_x_into_c(arena, cur, source, &ok, &refv);
  if (rc == 0 || ok == 0) {
    op[0] = 0;
    return;
  }
  op[0] = 1;
  op[1] = refv;
  memcpy((uint8_t *)out + 8, cur, 16);
}

void parser_asm_parse_ternary_into_slice_c(void *arena, PthinTernaryLex lex,
                                          void *source, void *out) {
  pthin_expr_ternary_tramp_face(arena, &lex, source, out, 0);
}

void parser_asm_parse_assign_into_slice_c(void *arena, PthinTernaryLex lex,
                                         void *source, void *out) {
  pthin_expr_ternary_tramp_face(arena, &lex, source, out, 1);
}
