/**
 * pipeline_sx.o（fat）经 -E-extern 声明 lexer_lexer_init；lexer_su.o 导出 lexer_init。
 * 链接期转发，避免为旧 pipeline 重编整份 pipeline_gen.c。
 */
#include <stddef.h>
#include <stdint.h>

struct lexer_Lexer {
  size_t pos;
  int32_t line;
  int32_t col;
};

extern struct lexer_Lexer lexer_init(void);

struct lexer_LexerResult {
  int32_t tok;
  int32_t int_val;
  double float_val;
  struct lexer_Lexer next_lex;
};

struct shux_slice_uint8_t;

extern void lexer_next_into(struct lexer_LexerResult *out, struct lexer_Lexer lex,
                            struct shux_slice_uint8_t *data);
extern struct lexer_LexerResult lexer_next_buf(struct lexer_Lexer lex,
                                               struct shux_slice_uint8_t *data);

struct lexer_Lexer lexer_lexer_init(void) {
  return lexer_init();
}

void lexer_lexer_next_into(struct lexer_LexerResult *out, struct lexer_Lexer lex,
                         struct shux_slice_uint8_t *data) {
  lexer_next_into(out, lex, data);
}

struct lexer_LexerResult lexer_lexer_next_buf(struct lexer_Lexer lex,
                                            struct shux_slice_uint8_t *data) {
  return lexer_next_buf(lex, data);
}
