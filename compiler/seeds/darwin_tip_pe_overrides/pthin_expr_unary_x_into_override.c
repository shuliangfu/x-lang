/**
 * PLATFORM: MACOS|DARWIN arm64 tip PE only —
 * tip_l4_tip_pe_println_method_call_p001 (follow-on after binop twin).
 *
 * After face+binop twins, tip hello/ret0 past P001 → SIGSEGV: infinite
 * recursion in parser_asm_parse_unary_x_into_c (lldb stack of self-calls
 * → EXC_BAD_ACCESS in lexer_store_token). Cap aside OK.
 *
 * Tip PE BODIES_FROM_X hollows unary_x_into (drops peek / token_to_kind
 * gate / wrap; still bls step+self → always recurse). Cap keeps full
 * src/asm/pthin_expr_unary.x sequence. Soft Cap Prefer / Cap aside / Win
 * banned.
 *
 * Tip-local host-cc twins of unary_token_to / wrap_operand / unary_x_into.
 * g05_relink_env prepends this .o and demotes hollow tip archive Ts.
 */
#include <stddef.h>
#include <stdint.h>

enum {
  TOKEN_AWAIT = 56,
  TOKEN_RUN = 57,
  TOKEN_SPAWN = 58,
  TOKEN_MINUS = 97,
  TOKEN_STAR = 98,
  TOKEN_AMP = 101,
  TOKEN_TILDE = 116,
  TOKEN_BANG = 126,
  EXPR_NEG = 22,
  EXPR_BITNOT = 23,
  EXPR_LOGNOT = 24,
  EXPR_ADDR_OF = 51,
  EXPR_DEREF = 52,
  EXPR_AWAIT = 55,
  EXPR_RUN = 56,
  EXPR_SPAWN = 57
};

extern int32_t parser_parse_primary_ptr_into_c(void *arena, void *lex_inout,
                                               void *source, int32_t *out_ok,
                                               int32_t *out_expr_ref);
extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_tok_line_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_tok_col_c(void *lex_inout, void *source);

extern int32_t ast_ast_arena_expr_alloc(void *arena);
extern void pipeline_expr_set_common_zeros_c(void *arena, int32_t er);
extern void pipeline_expr_set_kind(void *arena, int32_t er, int32_t kind);
extern void pipeline_expr_set_line_col(void *arena, int32_t er, int32_t line,
                                      int32_t col);
extern void pipeline_expr_set_unary_operand_c(void *arena, int32_t er,
                                             int32_t operand_ref);

int32_t parser_asm_unary_token_to_expr_kind_c(int32_t kind) {
  if (kind == TOKEN_AWAIT)
    return EXPR_AWAIT;
  if (kind == TOKEN_RUN)
    return EXPR_RUN;
  if (kind == TOKEN_SPAWN)
    return EXPR_SPAWN;
  if (kind == TOKEN_MINUS)
    return EXPR_NEG;
  if (kind == TOKEN_TILDE)
    return EXPR_BITNOT;
  if (kind == TOKEN_BANG)
    return EXPR_LOGNOT;
  if (kind == TOKEN_AMP)
    return EXPR_ADDR_OF;
  if (kind == TOKEN_STAR)
    return EXPR_DEREF;
  return -1;
}

int32_t parser_asm_unary_wrap_operand_into_c(void *arena, int32_t *out_ok,
                                            int32_t *out_expr_ref, int32_t kind,
                                            int32_t operand_ref, int32_t line,
                                            int32_t col) {
  int32_t op_ref;
  if (!arena || !out_ok || !out_expr_ref || operand_ref == 0)
    return 0;
  op_ref = ast_ast_arena_expr_alloc(arena);
  if (op_ref == 0) {
    out_ok[0] = 0;
    return 0;
  }
  pipeline_expr_set_common_zeros_c(arena, op_ref);
  pipeline_expr_set_kind(arena, op_ref, kind);
  pipeline_expr_set_unary_operand_c(arena, op_ref, operand_ref);
  pipeline_expr_set_line_col(arena, op_ref, line, col);
  out_expr_ref[0] = op_ref;
  return op_ref;
}

int32_t parser_asm_parse_unary_x_into_c(void *arena, void *lex_inout,
                                       void *source, int32_t *out_ok,
                                       int32_t *out_expr_ref) {
  int32_t kind;
  int32_t expr_kind;
  int32_t tl;
  int32_t tc;
  int32_t wr;
  int32_t inner_ref;
  if (!arena || !lex_inout || !source || !out_ok || !out_expr_ref)
    return 0;
  out_ok[0] = 0;
  out_expr_ref[0] = 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  expr_kind = parser_asm_unary_token_to_expr_kind_c(kind);
  if (expr_kind >= 0) {
    tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    parser_asm_lex_step_kind_c(lex_inout, source);
    if (parser_asm_parse_unary_x_into_c(arena, lex_inout, source, out_ok,
                                        out_expr_ref) == 0)
      return 0;
    if (out_ok[0] == 0)
      return 0;
    inner_ref = out_expr_ref[0];
    wr = parser_asm_unary_wrap_operand_into_c(arena, out_ok, out_expr_ref,
                                             expr_kind, inner_ref, tl, tc);
    if (wr == 0) {
      out_ok[0] = 0;
      return 0;
    }
    return 1;
  }
  {
    int32_t pr = parser_parse_primary_ptr_into_c(arena, lex_inout, source, out_ok,
                                      out_expr_ref);
    if (pr == 0)
      return 0;
    if (out_ok[0] == 0)
      return 0;
    return 1;
  }
}
