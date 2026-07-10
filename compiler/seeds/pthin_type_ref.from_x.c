/* seeds/pthin_type_ref.from_x.c — G-02f-280 P2 parser thin P3 type_ref
 * Logic source: src/asm/pthin_type_ref.x
 * Hybrid: SHUX_PTHIN_TYPE_REF_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Body: seeds/parser_asm/parser_asm_type_ref_slice.inc
 * Types must match parser_asm_thin_c.from_x.c (layout-locked).
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

/* Helpers from thin mega rest. */
extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *data);
extern void parser_lex_from_lexer_result_ptr_into(struct parser_asm_lexer *out,
                                                 struct parser_asm_lexer_result *r);
extern void parser_asm_copy_slice_to_name64_slice_c(struct parser_asm_slice_u8 *source, size_t start,
                                                   int32_t nlen, uint8_t *out);
extern void parser_asm_copy_slice_to_name64_at_end_slice_c(struct parser_asm_slice_u8 *source,
                                                          size_t end_pos, int32_t nlen, uint8_t *out);
extern int32_t parser_asm_is_pointee_type_token_c(int32_t kind);

/* mega rest 中为 static；本 TU 自备等价实现（layout 一致）。 */
static void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out,
                                               struct parser_asm_lexer_result r) {
  if (!out)
    return;
  out->pos = r.next_lex.pos;
  out->line = r.next_lex.line;
  out->col = r.next_lex.col;
}

#include "parser_asm_type_ref_slice.inc"

int labi_pthin_type_ref_slice_marker(void) {
  return 1;
}
