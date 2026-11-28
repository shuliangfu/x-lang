/* Host-gcc twin of typool lexer_next_impl EOF Token emit (lexer.x).
 * typool first-wins lexer_next_impl (fromsrc_s99 0x14003e154) EOF arm
 * builds Token at local -0xe0 (kind=0 store typool 0x14003e268) but then
 * copies fields from the wrong slot -0x70 (lea typool 0x14003e330) into
 * write_tok_into staging and calls lexer_write_tok_into at typool
 * 0x14003e3c1. Non-debuggee DIG kindprobe that rewrites parse_skip
 * byte_pos to load r.tok.kind at 0x8f0(%rbp) printed 549710384 /
 * 0x20c3a030 (pointer garbage). After main is collected, strict
 * unexpected-toplevel fires P001 parse skip at byte 232. The NUL-byte
 * EOF arm at typool 0x14003e546 already reads -0xe0 correctly.
 * Host-gcc twin takes LexerResult* out (next_lex already updated by
 * typool skip_ws) and writes TOKEN_EOF from out.next_lex line/col in
 * one small frame. DIG unofficial image must redirect the pos>=len EOF
 * arm (typool 0x14003e256) to this thin then jmp impl epilogue.
 * Do not replace typool lexer_next_impl wholesale (host/typool skip_ws
 * ABI diverge; a full thin hung on hello). typool tip / body_into /
 * skip_function / append_i32 / fputc / try_keyword_c / typool rec are
 * not in this thin. docs-only .x, do not idx8. Do not JMP typool rec
 * T 0x140087de4. s280: Windows g05 links this thin and
 * win_patch_lexer_next_impl_eof_arm wires only the typool pos>=len arm. */
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

void lexer_emit_eof_token(void *out) {
  XlangLexer lex;
  XlangToken tok;

  if (out == 0) {
    return;
  }
  memcpy(&lex, out, sizeof(lex));
  tok.kind = 0;
  tok.line = lex.line;
  tok.col = lex.col;
  tok._pad0 = 0;
  tok.int_val = 0;
  tok.float_val = 0.0;
  tok.ident = 0;
  tok.ident_len = 0;
  tok._pad1 = 0;
  lexer_write_next_lex_into(out, &lex);
  lexer_write_tok_into(out, &tok);
}
