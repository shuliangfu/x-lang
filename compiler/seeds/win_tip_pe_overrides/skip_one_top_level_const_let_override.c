/**
 * PLATFORM: WINDOWS tip PE only — knife 11.60.
 *
 * Tip (and Soft Cap Prefer dig) miswire:
 *   parser_asm_skip_one_top_level_{const,let}_into_c
 * as e9 → parser_asm_lex_step_kind_c (consumes one token only).
 * cfg_skip_pending_top_level then fails to skip inactive
 * `#[cfg(...)] const ...;` → parse skip @ std.io.backend (hello XP008).
 *
 * Tip-local C twin of compiler/src/asm/pthin_body_tl.x
 * skip_one_top_level_{const,let}_into_c. Calls tip PE lex_* only.
 * Soft Cap mix banned.
 */
#include <stdint.h>
#include <stddef.h>

enum {
  TOKEN_EOF = 0,
  TOKEN_LET = 2,
  TOKEN_CONST = 3,
  TOKEN_SEMICOLON = 95
};

extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern void parser_asm_lex_step_kind_c(void *lex_inout, void *source);

int32_t parser_asm_skip_one_top_level_let_into_c(void *lex_inout, void *source) {
  int32_t kind;
  if (!lex_inout || !source)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_LET)
    return 1;
  parser_asm_lex_step_kind_c(lex_inout, source);
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  while (kind != TOKEN_SEMICOLON && kind != TOKEN_EOF) {
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  }
  if (kind == TOKEN_SEMICOLON)
    parser_asm_lex_step_kind_c(lex_inout, source);
  return 1;
}

int32_t parser_asm_skip_one_top_level_const_into_c(void *lex_inout, void *source) {
  int32_t kind;
  if (!lex_inout || !source)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_CONST)
    return 1;
  parser_asm_lex_step_kind_c(lex_inout, source);
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  while (kind != TOKEN_SEMICOLON && kind != TOKEN_EOF) {
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  }
  if (kind == TOKEN_SEMICOLON)
    parser_asm_lex_step_kind_c(lex_inout, source);
  return 1;
}
