/*
 * Host-gcc twin of parser_asm_primary_string_x_into_c
 * (pthin_expr_primary.x).
 * Root (s50 unofficial hello --check empty-log hang after the
 *   string_lit_append_byte fold): typool first-wins
 *   parser_asm_primary_string_x_into_c at 0x140476adc is live.
 * After the first TOKEN_STRING is stepped and decoded, language
 * concatenates adjacent string literals:
 *   while (1 == 1) {
 *     kind = parser_asm_lex_peek_kind_c(lex_inout, source);
 *     if (kind != TOKEN_STRING) break;
 *     ... decode + step ...
 *   }
 * typool compiled `if (kind != TOKEN_STRING) break` as:
 *   setne / je concat-body / jmp loop-head at +957 / 0x140476e99
 * gdb on unofficial s50 hello --check (100% CPU, empty log):
 *   typool lex_bridge_fill+805 was only the hot inner copy loop
 *   of peek_kind (loop-4 i advances 28..72 and exits; not the
 *   residual). Caller is primary_string+922. peek returns
 *   kind=83 (TOKEN_RPAREN) at lex.pos=228 (the ')' after
 *   "Hello World"), then typool takes the jmp back to the
 *   while head instead of leaving the loop. pos stays 228.
 * Class: typool miscompiled break-as-continue (same class as
 *   s47 parser_onefunc_param_name_dup_c and s49
 *   parser_asm_module_try_register_enum_name_c).
 * Do not fold typool parser_asm_lex_bridge_fill — it is hot but
 *   the copy loops increment correctly.
 * Fold allowlist: parser_asm_primary_string_x_into_c only.
 * Keep the uncommitted s50 JMP typool
 *   parser_asm_string_lit_append_byte_ptr_c T 0x14046f858
 *   -> 0x14a3e2a00.
 * Do not fold typool pend BSS, typool w1545_pend_rcx_emit, typool
 *   onefunc_sidecar_get, formal-ensure, or the sibling win stubs.
 * Do not idx8 the .x twin.
 * PLATFORM: WINDOWS — PE fold first-wins; keep proven hooks.
 */
#include <stdint.h>

#define TOKEN_STRING 130
#define EXPR_STRING_LIT 59

int32_t parser_asm_lex_peek_kind_c(uint8_t *lex, uint8_t *source);
int32_t parser_asm_lex_peek_tok_line_c(uint8_t *lex, uint8_t *source);
int32_t parser_asm_lex_peek_tok_col_c(uint8_t *lex, uint8_t *source);
uint64_t parser_asm_lex_peek_token_start_c(uint8_t *lex, uint8_t *source);
int32_t parser_asm_lex_peek_ident_len_c(uint8_t *lex, uint8_t *source);
int32_t parser_asm_lex_step_kind_c(uint8_t *lex, uint8_t *source);
int32_t ast_ast_arena_expr_alloc(uint8_t *arena);
void pipeline_expr_set_kind(uint8_t *arena, int32_t ref, int32_t kind);
void pipeline_expr_set_line_col(uint8_t *arena, int32_t ref, int32_t line,
                                int32_t col);
void pipeline_expr_set_common_zeros_c(uint8_t *arena, int32_t ref);
int32_t parser_asm_string_lit_decode_span_ptr_c(uint8_t *arena, int32_t head_ref,
                                               uint8_t *source, uint64_t q0,
                                               int32_t nlen, int32_t line,
                                               int32_t col);

int32_t parser_asm_primary_string_x_into_c(uint8_t *arena, uint8_t *lex_inout,
                                          uint8_t *source, int32_t *out_ok,
                                          int32_t *out_expr_ref) {
  int32_t kind;
  int32_t ref;
  int32_t tl;
  int32_t tc;
  uint64_t q0;
  int32_t nlen;

  if (arena == 0 || lex_inout == 0 || source == 0 || out_ok == 0 ||
      out_expr_ref == 0) {
    return 0;
  }
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_STRING) {
    return 0;
  }
  tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
  tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
  q0 = parser_asm_lex_peek_token_start_c(lex_inout, source);
  nlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
  parser_asm_lex_step_kind_c(lex_inout, source);
  ref = ast_ast_arena_expr_alloc(arena);
  if (ref == 0) {
    out_ok[0] = 0;
    return 1;
  }
  pipeline_expr_set_kind(arena, ref, EXPR_STRING_LIT);
  pipeline_expr_set_line_col(arena, ref, tl, tc);
  pipeline_expr_set_common_zeros_c(arena, ref);
  if (parser_asm_string_lit_decode_span_ptr_c(arena, ref, source, q0, nlen, tl,
                                              tc) != 0) {
    out_ok[0] = 0;
    return 1;
  }
  while (1) {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_STRING) {
      break;
    }
    q0 = parser_asm_lex_peek_token_start_c(lex_inout, source);
    nlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    if (parser_asm_string_lit_decode_span_ptr_c(arena, ref, source, q0, nlen, tl,
                                                tc) != 0) {
      out_ok[0] = 0;
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
  }
  out_ok[0] = 1;
  out_expr_ref[0] = ref;
  return 1;
}
