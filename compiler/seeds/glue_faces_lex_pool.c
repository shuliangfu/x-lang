/* 10.22: Class CB thin_glue can leave these UNDEF; restore portable C faces.
 * Layout matches seeds/pthin_glue.from_x.c lexer_result. PLATFORM: LINUX. */
#include <stddef.h>
#include <stdint.h>

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

struct parser_asm_onefunc_result;

extern void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out,
                                                 struct parser_asm_lexer_result r);

void parser_lex_from_next_into_glue(struct parser_asm_lexer *out, struct parser_asm_lexer_result r) {
  parser_asm_lex_from_result_val_into(out, r);
}

uint8_t *parser_asm_onefunc_result_pool_ptr_c(struct parser_asm_onefunc_result *res) {
  return (uint8_t *)res;
}
