/* Host-gcc twin of typool lexer_emit_int_token (lexer.x).
 * typool lexer_next_body_into inlines the decimal INT finish. It builds
 * Token at huge-frame -0xdd0 (kind=80 store typool 0x1400397a1 on
 * fromsrc_s107) but then copies fields from the wrong slot -0x310 into
 * write_tok_into staging (typool 0x140039861) and calls
 * lexer_write_tok_into at typool 0x140039904. Live GDB on
 * fromsrc_s107_noaslr check examples/hello.x (repo cwd), core/fmt/mod.x
 * `return 0;`: typool Lexer is correct (pos=849 line=22 col=46 ival=0),
 * but write_tok src is kind=6 line=0 col=7 ival=207. hello check then
 * RC=1 with garbled XP008 / parse skip at byte 847 and 810. typool
 * huge-frame start/line0/col0 slots also alias (start=-0x2c8=13093,
 * line=-0x2d0=1, col=-0x2d8=0); begin_number_span was not typool-emitted
 * as a symbol, and out.token_start is still the previous RETURN (841).
 * Host-gcc twin keeps Token+write in one small frame. The DIG unofficial
 * image redirects typool's inlined decimal finish (lea -0xdd0) to
 * lexer_emit_int_token_from_body_into, which recovers start by walking
 * digits/`_` back from lex.pos on typool's data fat, then calls this
 * twin and jmps the typool body-into epilogue. typool is_digit /
 * is_digit_sep / fputc / skip_function / typool rec / typool body_into
 * wholesale are not in this thin. docs-only .x, do not idx8. Do not JMP
 * typool rec T 0x140087de4. */
#include <stdint.h>
#include <string.h>

typedef struct XlangLexer {
  uint64_t pos;
  int32_t line;
  int32_t col;
} XlangLexer;

typedef struct XlangToken {
  int32_t kind;
  int32_t line;
  int32_t col;
  int32_t _pad0;
  int64_t int_val;
  double float_val;
  uint8_t *ident;
  int32_t ident_len;
  int32_t _pad1;
} XlangToken;

extern void lexer_write_next_lex_into(void *lexer_result_out, XlangLexer *lex);
extern void lexer_write_tok_into(void *lexer_result_out, XlangToken *tok);
extern void lexer_park_token_start(void *lexer_result_out, uint64_t pos);

void lexer_emit_int_token(void *out, XlangLexer *lex, uint64_t start,
                          int32_t line0, int32_t col0, int64_t ival) {
  XlangToken tok;

  if (out == 0 || lex == 0) {
    return;
  }
  tok.kind = 80;
  tok.line = line0;
  tok.col = col0;
  tok._pad0 = 0;
  tok.int_val = ival;
  tok.float_val = 0.0;
  tok.ident = 0;
  tok.ident_len = 0;
  tok._pad1 = 0;
  lexer_write_next_lex_into(out, lex);
  lexer_write_tok_into(out, &tok);
  lexer_park_token_start(out, start);
}

/* DIG hook: typool next_body_into inlined decimal emit. out=[rbp-0x10],
 * lex=[rbp-0x28], data_fat=[rbp-0x30] ({ptr,len}), ival=[rbp-0x2e0]. */
void lexer_emit_int_token_from_body_into(void *out, XlangLexer *lex,
                                         void *data_fat, int64_t ival) {
  uint8_t *p;
  uint64_t len;
  uint64_t pos;
  uint64_t start;
  int32_t line0;
  int32_t col0;

  if (out == 0 || lex == 0 || data_fat == 0) {
    return;
  }
  p = ((uint8_t **)data_fat)[0];
  len = ((uint64_t *)data_fat)[1];
  (void)len;
  pos = lex->pos;
  start = pos;
  if (p != 0) {
    while (start > 0) {
      uint8_t c = p[start - 1];
      if ((c >= (uint8_t)'0' && c <= (uint8_t)'9') || c == (uint8_t)'_') {
        start = start - 1;
      } else {
        break;
      }
    }
  }
  line0 = lex->line;
  col0 = lex->col - (int32_t)(pos - start);
  if (col0 < 1) {
    col0 = 1;
  }
  lexer_emit_int_token(out, lex, start, line0, col0, ival);
}
