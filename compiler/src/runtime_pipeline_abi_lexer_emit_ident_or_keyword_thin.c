/* Host-gcc twin of typool lexer_emit_ident_or_keyword (lexer.x).
 * typool lexer_next_body_into (fromsrc_s92 first-wins T 0x14002f5d8) inlines
 * the ident/keyword finish: it builds Token kind=0 at local -0xdd0 but passes
 * &Token at -0x280 to try_keyword, then reads kind from -0x280. On a miss,
 * -0x280 keeps a stale previous keyword (CONST=3) or uninitialized garbage;
 * the kind!=0 path then call write_tok_into and re-emits that token.
 * Writer RIP typool 0x1400312d7 (call lexer_write_tok_into with src from the
 * stale -0x280 image). Typool-wrong lea of the try_keyword out slot is
 * typool 0x1400310f4 (lea -0x280); the unused inited slot store is typool
 * 0x140031084 (kind=0 at -0xdd0). Caller return continues to typool
 * lexer_park_token_start at typool 0x1400312e0.
 * Live GDB on fromsrc_s92_noaslr check examples/hello.x (repo cwd):
 * TK_CALL n=3 start=151 nlen=3 kind280=0 -> IDENT kind=59 (fmt ok);
 * TK_CALL n=6 start=151 nlen=3 kind280=3 (stale CONST) AFTER_TK still 3
 * -> TOK_INTO src_kind=3 src_col=1 (re-emit CONST for fmt);
 * TK_CALL n=9+ kind280=garbage -> TOK_INTO garbage -> P014 col=0.
 * Source already factors this finish into lexer_emit_ident_or_keyword; the
 * bag has no such symbol. Host-gcc twin keeps tok in one small frame.
 * typool lexer_next_body_into / typool try_keyword_b / typool tip /
 * typool skip_function / typool diag_io_fputc are not in this thin.
 * DIG unofficial image must redirect the inlined body_into finish to this
 * thin (skip typool 0x140031072..try_keyword, after write_next_lex call
 * this thin, then park). docs-only .x, do not idx8. Do not JMP typool
 * rec T 0x140087de4. */
#include <stdint.h>

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

extern void lexer_try_keyword(XlangToken *out, void *data, uint64_t start,
                              uint64_t len, int32_t line0, int32_t col0);
extern void lexer_write_tok_into(void *lexer_result_out, XlangToken *tok);

void lexer_emit_ident_or_keyword(void *out, void *data, uint64_t start,
                                 uint64_t span_len, int32_t line0,
                                 int32_t col0) {
  XlangToken tok;

  if (out == 0) {
    return;
  }
  tok.kind = 0;
  tok.line = line0;
  tok.col = col0;
  tok.int_val = 0;
  tok.float_val = 0.0;
  tok.ident = 0;
  tok.ident_len = 0;
  lexer_try_keyword(&tok, data, start, span_len, line0, col0);
  if (tok.kind == 0) {
    tok.kind = 59;
    tok.line = line0;
    tok.col = col0;
    tok.int_val = 0;
    tok.float_val = 0.0;
    tok.ident = 0;
    tok.ident_len = (int32_t)span_len;
    lexer_write_tok_into(out, &tok);
  } else {
    lexer_write_tok_into(out, &tok);
  }
}
