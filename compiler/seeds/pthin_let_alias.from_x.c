/* seeds/pthin_let_alias.from_x.c — G-02f-279 P2 parser thin P2 let/alias
 * Logic source: src/asm/pthin_let_alias.x
 * Hybrid: XLANG_PTHIN_LET_ALIAS_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Bodies: seeds/parser_asm/{body_let,top_level_let,type_alias}_slice.inc
 * Types must match parser_asm_thin_c.from_x.c (layout-locked).
 *
 * Hybrid P2b (XLANG_PTHIN_LET_ALIAS_BODIES_FROM_X): dest-buffer
 * parse_one_top_level_let / parse_one_type_alias come from
 * pthin_let_alias.x. C trampoline holds the name pack.
 * Hybrid P2c (XLANG_PTHIN_LET_ALIAS_COND_FROM_X): dest-buffer
 * parse_cond_expr (INT+as probe). Separate define so a missing
 * parse_cond_expr_x keeps the C cond twin without dropping P2b.
 * body_let_bracket stays C. Cold: no define, full .inc.
 * Do not reuse XLANG_PTHIN_LET_ALIAS_FROM_X for P2b/P2c bodies.
 * PLATFORM: SHARED — do not assemble parser.x.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser_asm_stretch_audit_gate.h"
#include "token.h"
#include "ast.h"

_Static_assert((int)TOKEN_IDENT == 59, "let_alias.x TOKEN_IDENT pin");
_Static_assert((int)TOKEN_INT == 80, "let_alias.x TOKEN_INT pin");
_Static_assert((int)TOKEN_COLON == 91, "let_alias.x TOKEN_COLON pin");
_Static_assert((int)TOKEN_SEMICOLON == 95, "let_alias.x TOKEN_SEMICOLON pin");
_Static_assert((int)TOKEN_ASSIGN == 117, "let_alias.x TOKEN_ASSIGN pin");
_Static_assert((int)TOKEN_AS == 128, "let_alias.x TOKEN_AS pin");

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

/* Shared helpers (defined in thin mega rest / other slices). */
extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *data);
extern void parser_lex_from_lexer_result_ptr_into(struct parser_asm_lexer *out,
                                                 struct parser_asm_lexer_result *r);
extern void parser_lex_from_next_into_glue(struct parser_asm_lexer *out,
                                           struct parser_asm_lexer_result r);
extern void parser_asm_copy_slice_to_name64_slice_c(struct parser_asm_slice_u8 *source,
                                                   size_t token_start, int32_t name_len,
                                                   uint8_t *name_buf);

#include "parser_asm_body_let_slice.inc"
#include "parser_asm_top_level_let_slice.inc"
#include "parser_asm_type_alias_slice.inc"

/* Audit helper for hybrid smoke / nm. */
int labi_pthin_let_alias_slice_marker(void) {
  return 3; /* body_let + top_level_let + type_alias */
}
