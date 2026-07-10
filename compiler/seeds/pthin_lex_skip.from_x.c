/* seeds/pthin_lex_skip.from_x.c — G-02f-281 P2 parser thin P1 lex/skip
 * Logic source: src/asm/pthin_lex_skip.x
 * Hybrid: SHUX_PTHIN_LEX_SKIP_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Body: seeds/parser_asm/parser_asm_lex_skip_slice.inc
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
  int32_t int_val;
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

struct shux_slice_uint8_t {
  uint8_t *data;
  size_t length;
};

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *data);
extern struct parser_asm_lexer_result lexer_next_buf(struct parser_asm_lexer lex, uint8_t *data, int32_t len);

#include "parser_asm_lex_skip_slice.inc"

int labi_pthin_lex_skip_slice_marker(void) {
  return 1;
}
