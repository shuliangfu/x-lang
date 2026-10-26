/* 10.22: Class BX omit-rest drops product_keep; restore live stretch helpers.
 * Layout matches seeds/pthin_stretch.from_x.c. PLATFORM: LINUX. */
#include <stddef.h>
#include <stdint.h>
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

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *source);
extern void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out,
                                                 struct parser_asm_lexer_result r);
/* Forward: defined later in product_keep.inc / provided by stretch lite. */
int32_t parser_asm_stretch_skip_type_suffix_c(void *lex_inout, void *source);
static int32_t parser_asm_stretch_classify_toplevel_c(int32_t kind, int32_t next_kind,
                                                       int32_t third_kind) {
  (void)kind; (void)next_kind; (void)third_kind;
  return 0;
}

#include "parser_asm_stretch_suite_product_keep.inc"
