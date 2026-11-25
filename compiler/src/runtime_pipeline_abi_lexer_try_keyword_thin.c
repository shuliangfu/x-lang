/* Host-gcc twin of typool lexer_try_keyword (lexer.x).
 * typool first-wins T 0x1400157dc (fromsrc_s91) matches "const" correctly
 * (lexer_match_keyword returns 1) but then builds Token kind=3 at local
 * slot -0x710 and copies out.kind from a different slot -0x160 (stays 0).
 * Writer RIP typool 0x140015d82 (mov eax,(rbx) with eax from -0x160).
 * Caller return RIP typool lexer_next_body_into at typool 0x140030bd2.
 * Live GDB on fromsrc_s91 check examples/hello.x (repo cwd):
 * TRY_KW_ENTER n=1 start=145 nlen=5 line=3 col=1; CONST_NLEN5_BR n=1;
 * MATCH_ENTER kw=const; MATCH_RET eax=1; WRONG_STORE n=1 writing_eax=0
 * slot710.kind=3 slot160.kind=0. Parser therefore sees TOKEN_IDENT=59
 * instead of TOKEN_CONST=3 and takes strict unexpected-token {ok:-2}.
 * Same dual-slot class as the source comment on lexer_write_simple_token
 * (typool bag has no lexer_write_simple_token symbol; the helper was
 * inlined into the 0x1278-byte frame and recreated the bug). typool
 * lexer_match_keyword / typool lexer_next_body_into / typool
 * lexer_next_buf_into_tip / typool try_keyword_b/c/d / typool
 * diag_io_fputc / typool skip_function are not in this thin. Host-gcc
 * twin writes through out via a small-frame helper and falls through to
 * typool lexer_try_keyword_b for the rest of the keyword chain.
 * docs-only .x, do not idx8. Do not JMP typool rec T 0x140087de4. */
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

/* typool / host ABI: data is a pointer to the u8[] fat {ptr,len}. */
extern int32_t lexer_match_keyword(void *data, uint64_t start, int32_t len,
                                   const uint8_t *keyword);
extern void lexer_try_keyword_b(XlangToken *out, void *data, uint64_t start,
                                uint64_t len, int32_t line0, int32_t col0);

static void lexer_write_simple_token(XlangToken *out, int32_t kind, int32_t line0,
                                     int32_t col0) {
  if (out == 0) {
    return;
  }
  out->kind = kind;
  out->line = line0;
  out->col = col0;
  out->int_val = 0;
  out->float_val = 0.0;
  out->ident = 0;
  out->ident_len = 0;
}

void lexer_try_keyword(XlangToken *out, void *data, uint64_t start, uint64_t len,
                       int32_t line0, int32_t col0) {
  int32_t nlen;

  nlen = (int32_t)len;
  if (nlen == 8 && lexer_match_keyword(data, start, 8, (const uint8_t *)"function") != 0) {
    lexer_write_simple_token(out, 1, line0, col0);
    return;
  }
  if (nlen == 3 && lexer_match_keyword(data, start, 3, (const uint8_t *)"let") != 0) {
    lexer_write_simple_token(out, 2, line0, col0);
    return;
  }
  if (nlen == 5 && lexer_match_keyword(data, start, 5, (const uint8_t *)"const") != 0) {
    lexer_write_simple_token(out, 3, line0, col0);
    return;
  }
  if (nlen == 2 && lexer_match_keyword(data, start, 2, (const uint8_t *)"if") != 0) {
    lexer_write_simple_token(out, 4, line0, col0);
    return;
  }
  if (nlen == 4 && lexer_match_keyword(data, start, 4, (const uint8_t *)"else") != 0) {
    lexer_write_simple_token(out, 5, line0, col0);
    return;
  }
  if (nlen == 5 && lexer_match_keyword(data, start, 5, (const uint8_t *)"while") != 0) {
    lexer_write_simple_token(out, 6, line0, col0);
    return;
  }
  if (nlen == 4 && lexer_match_keyword(data, start, 4, (const uint8_t *)"loop") != 0) {
    lexer_write_simple_token(out, 7, line0, col0);
    return;
  }
  if (nlen == 3 && lexer_match_keyword(data, start, 3, (const uint8_t *)"for") != 0) {
    lexer_write_simple_token(out, 8, line0, col0);
    return;
  }
  if (nlen == 5 && lexer_match_keyword(data, start, 5, (const uint8_t *)"break") != 0) {
    lexer_write_simple_token(out, 9, line0, col0);
    return;
  }
  if (nlen == 8 && lexer_match_keyword(data, start, 8, (const uint8_t *)"continue") != 0) {
    lexer_write_simple_token(out, 10, line0, col0);
    return;
  }
  if (nlen == 6 && lexer_match_keyword(data, start, 6, (const uint8_t *)"return") != 0) {
    lexer_write_simple_token(out, 11, line0, col0);
    return;
  }
  if (nlen == 5 && lexer_match_keyword(data, start, 5, (const uint8_t *)"panic") != 0) {
    lexer_write_simple_token(out, 12, line0, col0);
    return;
  }
  if (nlen == 5 && lexer_match_keyword(data, start, 5, (const uint8_t *)"defer") != 0) {
    lexer_write_simple_token(out, 13, line0, col0);
    return;
  }
  if (nlen == 6 && lexer_match_keyword(data, start, 6, (const uint8_t *)"region") != 0) {
    lexer_write_simple_token(out, 16, line0, col0);
    return;
  }
  if (nlen == 10 && lexer_match_keyword(data, start, 10, (const uint8_t *)"with_arena") != 0) {
    lexer_write_simple_token(out, 17, line0, col0);
    return;
  }
  if (nlen == 5 && lexer_match_keyword(data, start, 5, (const uint8_t *)"match") != 0) {
    lexer_write_simple_token(out, 18, line0, col0);
    return;
  }
  lexer_try_keyword_b(out, data, start, len, line0, col0);
}
