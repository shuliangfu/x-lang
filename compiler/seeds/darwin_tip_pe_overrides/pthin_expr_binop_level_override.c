/**
 * PLATFORM: MACOS|DARWIN arm64 tip PE only —
 * tip_l4_tip_pe_println_method_call_p001 (follow-on).
 *
 * After ternary/assign face+x_into twins, tip still P001: product hello /
 * ret0 never reach unary. Cap aside OK. lldb: assign→ternary→logor_ptr→
 * call_logor→logor_into→glue→logor_slice→binop_tramp_level→
 * parser_asm_parse_binop_level_x_into_c then exit P001; unary never hit.
 *
 * Tip PE selfhost BODIES_FROM_X hollows binop_level_x_into (no cast_ptr /
 * peek / recursive lower / wrap) and binop_wrap_into (drops
 * ast_ast_arena_expr_alloc). Cap keeps full sequence from
 * src/asm/pthin_expr_binop.x. Soft Cap Prefer / Cap aside / Win banned.
 *
 * Tip-local host-cc twins of wrap + level x_into. g05_relink_env prepends
 * this .o and demotes hollow tip archive Ts to __hollow_dead.
 */
#include <stddef.h>
#include <stdint.h>

enum {
  BINOP_LEVEL_TERM = 0,
  BINOP_LEVEL_ADDSUB = 1,
  BINOP_LEVEL_SHIFT = 2,
  BINOP_LEVEL_REL = 3,
  BINOP_LEVEL_EQ = 4,
  BINOP_LEVEL_BITAND = 5,
  BINOP_LEVEL_BITXOR = 6,
  BINOP_LEVEL_BITOR = 7,
  BINOP_LEVEL_LOGAND = 8,
  BINOP_LEVEL_LOGOR = 9,
  EXPR_ADD = 4,
  EXPR_SUB = 5,
  EXPR_MUL = 6,
  EXPR_DIV = 7,
  EXPR_MOD = 8,
  EXPR_SHL = 9,
  EXPR_SHR = 10,
  EXPR_BITAND = 11,
  EXPR_BITOR = 12,
  EXPR_BITXOR = 13,
  EXPR_EQ = 14,
  EXPR_NE = 15,
  EXPR_LT = 16,
  EXPR_LE = 17,
  EXPR_GT = 18,
  EXPR_GE = 19,
  EXPR_LOGAND = 20,
  EXPR_LOGOR = 21
};

extern int32_t parser_parse_cast_ptr_into_c(void *arena, void *lex_inout,
                                            void *source, int32_t *out_ok,
                                            int32_t *out_expr_ref);
extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_binop_token_to_expr_kind_c(int32_t kind);
extern int32_t parser_asm_binop_kind_matches_level_c(int32_t mapped,
                                                    int32_t level);

extern int32_t ast_ast_arena_expr_alloc(void *arena);
extern void pipeline_expr_set_common_zeros_c(void *arena, int32_t er);
extern void pipeline_expr_set_kind(void *arena, int32_t er, int32_t kind);
extern void pipeline_expr_set_line_col(void *arena, int32_t er, int32_t line,
                                      int32_t col);
extern void pipeline_expr_set_binop_operands_c(void *arena, int32_t er,
                                              int32_t left, int32_t right);

int32_t parser_asm_binop_wrap_into_c(void *arena, int32_t *out_ok,
                                     int32_t *out_expr_ref, int32_t kind,
                                     int32_t left_ref, int32_t right_ref) {
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
  pipeline_expr_set_line_col(arena, bin_ref, 0, 0);
  out_expr_ref[0] = bin_ref;
  return bin_ref;
}

int32_t parser_asm_parse_binop_level_x_into_c(void *arena, void *lex_inout,
                                             void *source, int32_t *out_ok,
                                             int32_t *out_expr_ref,
                                             int32_t level) {
  int32_t kind;
  int32_t mapped;
  int32_t left_ref;
  int32_t right_ref;
  int32_t wr;
  int32_t rc;
  if (!arena || !lex_inout || !source || !out_ok || !out_expr_ref)
    return 0;
  if (level < 0 || level > BINOP_LEVEL_LOGOR)
    return 0;
  out_ok[0] = 0;
  out_expr_ref[0] = 0;
  if (level == BINOP_LEVEL_TERM)
    rc = parser_parse_cast_ptr_into_c(arena, lex_inout, source, out_ok,
                                      out_expr_ref);
  else
    rc = parser_asm_parse_binop_level_x_into_c(arena, lex_inout, source, out_ok,
                                               out_expr_ref, level - 1);
  if (rc == 0)
    return 0;
  if (out_ok[0] == 0)
    return 0;
  for (;;) {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    mapped = parser_asm_binop_token_to_expr_kind_c(kind);
    if (parser_asm_binop_kind_matches_level_c(mapped, level) == 0)
      return 1;
    left_ref = out_expr_ref[0];
    parser_asm_lex_step_kind_c(lex_inout, source);
    if (level == BINOP_LEVEL_TERM)
      rc = parser_parse_cast_ptr_into_c(arena, lex_inout, source, out_ok,
                                        out_expr_ref);
    else
      rc = parser_asm_parse_binop_level_x_into_c(
          arena, lex_inout, source, out_ok, out_expr_ref, level - 1);
    if (rc == 0)
      return 0;
    if (out_ok[0] == 0)
      return 0;
    right_ref = out_expr_ref[0];
    wr = parser_asm_binop_wrap_into_c(arena, out_ok, out_expr_ref, mapped,
                                      left_ref, right_ref);
    if (wr == 0) {
      out_ok[0] = 0;
      return 0;
    }
  }
}
