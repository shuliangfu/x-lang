/* seeds/pthin_lex_skip.from_x.c — G-02f-281 P2 parser thin P1 lex/skip
 * Logic source: src/asm/pthin_lex_skip.x
 * Hybrid: XLANG_PTHIN_LEX_SKIP_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Body: seeds/parser_asm/parser_asm_lex_skip_slice.inc
 * Hybrid P1b/P1c/P1d/P1e (XLANG_PTHIN_LEX_SKIP_BODIES_FROM_X): portable kind/copy/skip
 * bodies, the count walk, ASI advance_past_*, parse_peek_function_name, and
 * first_token_kind come from pthin_lex_skip.x; this TU keeps by-value
 * trampolines plus g_gp_pending_* / register_pending C. P1d/P1e C trampolines
 * live in helpers.inc (original twins). Cold: no BODIES define, full .inc.
 * Do not reuse XLANG_PTHIN_LEX_SKIP_FROM_X for P1b/P1c/P1d/P1e bodies.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser_asm_stretch_audit_gate.h"
#include "token.h"

struct parser_asm_token {
  int32_t kind;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t *ident;
  int32_t ident_len;
};

struct parser_asm_lexer {
  size_t pos;
  int32_t line;
  int32_t col;
};

struct parser_asm_lexer_result {
  struct parser_asm_lexer next_lex;
  struct parser_asm_token tok;
  size_t token_start;
};

struct parser_asm_slice_u8 {
  uint8_t *data;
  size_t length;
};

/* Align with mega for glue ABI. */
struct lexer_Lexer {
  size_t pos;
  int32_t line;
  int32_t col;
};

struct xlang_slice_uint8_t {
  uint8_t *data;
  size_t length;
};

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *data);
extern struct parser_asm_lexer_result lexer_next_buf(struct parser_asm_lexer lex, uint8_t *data, int32_t len);

/* PLATFORM: SHARED — 7.2.1 P1b/P1c Route C + B-minus (2026-09-13).
 * pthin_lex_skip.x TOKEN_* are pin copies of this enum.
 * token.h remains the authority; fire if the pin drifts. */
_Static_assert((int)TOKEN_EOF == 0, "lex_skip.x TOKEN_EOF pin");
_Static_assert((int)TOKEN_FUNCTION == 1, "lex_skip.x TOKEN_FUNCTION pin");
_Static_assert((int)TOKEN_LET == 2, "lex_skip.x TOKEN_LET pin");
_Static_assert((int)TOKEN_PANIC == 12, "lex_skip.x TOKEN_PANIC pin");
_Static_assert((int)TOKEN_DEFER == 13, "lex_skip.x TOKEN_DEFER pin");
_Static_assert((int)TOKEN_SELF == 51, "lex_skip.x TOKEN_SELF pin");
_Static_assert((int)TOKEN_SPAWN == 58, "lex_skip.x TOKEN_SPAWN pin");
_Static_assert((int)TOKEN_IDENT == 59, "lex_skip.x TOKEN_IDENT pin");
_Static_assert((int)TOKEN_LPAREN == 82, "lex_skip.x TOKEN_LPAREN pin");
_Static_assert((int)TOKEN_RPAREN == 83, "lex_skip.x TOKEN_RPAREN pin");
_Static_assert((int)TOKEN_LBRACE == 84, "lex_skip.x TOKEN_LBRACE pin");
_Static_assert((int)TOKEN_RBRACE == 85, "lex_skip.x TOKEN_RBRACE pin");
_Static_assert((int)TOKEN_COMMA == 90, "lex_skip.x TOKEN_COMMA pin");
_Static_assert((int)TOKEN_COLON == 91, "lex_skip.x TOKEN_COLON pin");
_Static_assert((int)TOKEN_SEMICOLON == 95, "lex_skip.x TOKEN_SEMICOLON pin");
_Static_assert((int)TOKEN_STAR == 98, "lex_skip.x TOKEN_STAR pin");
_Static_assert((int)TOKEN_PLUS_EQ == 106, "lex_skip.x TOKEN_PLUS_EQ pin");
_Static_assert((int)TOKEN_RSHIFT_EQ == 115, "lex_skip.x TOKEN_RSHIFT_EQ pin");
_Static_assert((int)TOKEN_LT == 120, "lex_skip.x TOKEN_LT pin");
_Static_assert((int)TOKEN_GT == 121, "lex_skip.x TOKEN_GT pin");
_Static_assert((int)TOKEN_EXPORT == 131, "lex_skip.x TOKEN_EXPORT pin");

#ifdef XLANG_PTHIN_LEX_SKIP_BODIES_FROM_X
/* .x product bodies (same C names for Route C; pointer ABI for skip walks). */
extern void parser_asm_copy_slice_to_name64_buf_c(uint8_t *source, int32_t source_len, size_t start, int32_t nlen,
                                                  uint8_t *out);
extern void parser_asm_copy_slice_to_name64_at_end_buf_c(uint8_t *source, int32_t source_len, size_t end_pos, int32_t nlen,
                                                         uint8_t *out);
extern void parser_asm_copy_slice_to_param32_buf_c(uint8_t *source, int32_t source_len, size_t start, int32_t nlen,
                                                   uint8_t *out);
extern void parser_asm_copy_slice_to_param32_at_end_buf_c(uint8_t *source, int32_t source_len, size_t end_pos, int32_t nlen,
                                                          uint8_t *out);
extern int32_t parser_asm_skip_balanced_parens_into_c(void *lex_inout, void *source);
extern int32_t parser_asm_skip_balanced_braces_into_c(void *lex_inout, void *source);
extern int32_t parser_asm_skip_generic_angle_list_into_c(void *lex_inout, void *source);

void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r) {
  if (!out)
    return;
  out->pos = r.next_lex.pos;
  out->line = r.next_lex.line;
  out->col = r.next_lex.col;
}

void parser_asm_copy_slice_to_name64_slice_c(struct parser_asm_slice_u8 *source, size_t start, int32_t nlen,
                                             uint8_t *out) {
  if (!source)
    return;
  parser_asm_copy_slice_to_name64_buf_c(source->data, (int32_t)source->length, start, nlen, out);
}

void parser_asm_copy_slice_to_name64_at_end_slice_c(struct parser_asm_slice_u8 *source, size_t end_pos, int32_t nlen,
                                                    uint8_t *out) {
  if (!source || !out || nlen <= 0)
    return;
  parser_asm_copy_slice_to_name64_slice_c(source, end_pos - (size_t)nlen, nlen, out);
}

void parser_asm_copy_slice_to_param32_slice_c(struct parser_asm_slice_u8 *source, size_t start, int32_t nlen,
                                              uint8_t *out) {
  if (!out)
    return;
  parser_asm_copy_slice_to_param32_buf_c(source ? source->data : (uint8_t *)0,
                                        source ? (int32_t)source->length : 0, start, nlen, out);
}

void parser_asm_copy_slice_to_param32_at_end_slice_c(struct parser_asm_slice_u8 *source, size_t end_pos, int32_t nlen,
                                                     uint8_t *out) {
  if (!out)
    return;
  parser_asm_copy_slice_to_param32_slice_c(source, end_pos - (size_t)nlen, nlen, out);
}

void parser_asm_skip_balanced_parens_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                  struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer cur;
  if (!out || !source)
    return;
  cur = lex;
  (void)parser_asm_skip_balanced_parens_into_c(&cur, source);
  *out = cur;
}

struct parser_asm_lexer parser_asm_skip_balanced_parens_buf_c(struct parser_asm_lexer lex, uint8_t *data, int32_t len) {
  struct parser_asm_slice_u8 sl;
  struct parser_asm_lexer out;
  sl.data = data;
  sl.length = len >= 0 ? (size_t)len : 0;
  parser_asm_skip_balanced_parens_into_slice_c(&out, lex, &sl);
  return out;
}

void parser_asm_skip_balanced_parens_into_buf_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex, uint8_t *data,
                                                int32_t len) {
  struct parser_asm_lexer rlex;
  if (!out)
    return;
  rlex = parser_asm_skip_balanced_parens_buf_c(lex, data, len);
  out->pos = rlex.pos;
  out->line = rlex.line;
  out->col = rlex.col;
}

struct parser_asm_lexer parser_asm_skip_balanced_parens_slice_c(struct parser_asm_lexer lex,
                                                                struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer out;
  parser_asm_skip_balanced_parens_into_slice_c(&out, lex, source);
  return out;
}

void parser_asm_skip_balanced_braces_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                  struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer cur;
  if (!out || !source)
    return;
  cur = lex;
  (void)parser_asm_skip_balanced_braces_into_c(&cur, source);
  *out = cur;
}

struct parser_asm_lexer parser_asm_skip_balanced_braces_buf_c(struct parser_asm_lexer lex, uint8_t *data, int32_t len) {
  struct parser_asm_slice_u8 sl;
  struct parser_asm_lexer out;
  sl.data = data;
  sl.length = len >= 0 ? (size_t)len : 0;
  parser_asm_skip_balanced_braces_into_slice_c(&out, lex, &sl);
  return out;
}

void parser_asm_skip_balanced_braces_into_buf_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex, uint8_t *data,
                                                int32_t len) {
  struct parser_asm_lexer rlex;
  if (!out)
    return;
  rlex = parser_asm_skip_balanced_braces_buf_c(lex, data, len);
  out->pos = rlex.pos;
  out->line = rlex.line;
  out->col = rlex.col;
}

struct parser_asm_lexer parser_asm_skip_balanced_braces_slice_c(struct parser_asm_lexer lex,
                                                                struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer out;
  parser_asm_skip_balanced_braces_into_slice_c(&out, lex, source);
  return out;
}

void parser_asm_skip_generic_angle_list_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                     struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer cur;
  if (!out || !source)
    return;
  cur = lex;
  (void)parser_asm_skip_generic_angle_list_into_c(&cur, source);
  *out = cur;
}
#endif /* XLANG_PTHIN_LEX_SKIP_BODIES_FROM_X */

#include "parser_asm_lex_skip_slice.inc"

int labi_pthin_lex_skip_slice_marker(void) {
  return 1;
}
