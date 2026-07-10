/* seeds/pthin_body_tl.from_x.c — G-02f-327 P2 parser thin body_tl
 * Logic source: src/asm/pthin_body_tl.x
 * Hybrid: SHUX_PTHIN_BODY_TL_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Body: seeds/parser_asm/parser_asm_body_tl_slice.inc (~971)
 * is_fn_sig_scalar + diag_first_ident + diag_skip_let_const_into + body_skip_into
 * + skip_one_top_level_{let,const} + cfg_skip_pending_top_level
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

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *data);
extern void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
extern struct parser_asm_lexer parser_asm_lexer_init_c(void);
extern void parser_lex_from_lexer_result_ptr_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result *r);
extern void parser_asm_skip_one_if_statement_into_slice_c(struct parser_asm_lexer_result *out,
                                                          struct parser_asm_lexer lex,
                                                          struct parser_asm_slice_u8 *source);
extern void parser_asm_skip_one_struct_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                     struct parser_asm_slice_u8 *source);
extern void parser_asm_skip_one_function_full_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                            struct parser_asm_slice_u8 *source);

#include "parser_asm_body_tl_slice.inc"

int labi_pthin_body_tl_slice_marker(void) {
  return 1;
}
