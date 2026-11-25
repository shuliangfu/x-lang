/* Host-gcc twin of typool lexer_try_keyword_b (lexer.x).
 * typool first-wins T 0x140018010 (fromsrc_s93) matches "import" correctly
 * (lexer_match_keyword returns 1) but then builds Token kind=53
 * (TOKEN_IMPORT) at local slot -0x710 and copies out.kind from a
 * different slot -0x550 (stays 0). Writer RIP typool 0x140019868
 * (mov eax,(rbx) with eax from -0x550). Caller return RIP typool
 * lexer_try_keyword (thin fallthrough) then typool
 * lexer_emit_ident_or_keyword at typool 0x14000156b. Live GDB on
 * fromsrc_s93_noaslr check examples/hello.x (repo cwd):
 * B_ENTER n=9 start=157 nlen=6; IMP_NLEN6 nlen_slot=6;
 * MATCH_IMP r9="import"; MATCH_IMP_RET eax=1; WRONG_STORE
 * writing_eax=0 slot710.kind=53 slot550.kind=0; EMIT_RET kind=59
 * (IDENT) line=3 col=13. Same dual-slot class as typool
 * lexer_try_keyword (const). Host-gcc twin writes through out via a
 * small-frame helper and falls through to typool lexer_try_keyword_c
 * for the rest of the keyword chain. typool lexer_try_keyword /
 * typool lexer_try_keyword_c/d / typool lexer_match_keyword /
 * typool tip / typool skip_function / typool diag_io_fputc are not
 * in this thin. docs-only .x, do not idx8. Do not JMP typool rec T
 * 0x140087de4. */
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

extern int32_t lexer_match_keyword(void *data, uint64_t start, int32_t len,
                                   const uint8_t *keyword);
extern void lexer_try_keyword_c(XlangToken *out, void *data, uint64_t start,
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

void lexer_try_keyword_b(XlangToken *out, void *data, uint64_t start, uint64_t len,
                         int32_t line0, int32_t col0) {
  int32_t nlen;
  uint8_t *bytes;

  nlen = (int32_t)len;
  if (nlen == 6 && lexer_match_keyword(data, start, 6, (const uint8_t *)"struct") != 0) {
    lexer_write_simple_token(out, 19, line0, col0);
    return;
  }
  if (nlen == 4 && lexer_match_keyword(data, start, 4, (const uint8_t *)"type") != 0) {
    lexer_write_simple_token(out, 20, line0, col0);
    return;
  }
  if (nlen == 6 && lexer_match_keyword(data, start, 6, (const uint8_t *)"packed") != 0) {
    lexer_write_simple_token(out, 21, line0, col0);
    return;
  }
  if (nlen == 3 && lexer_match_keyword(data, start, 3, (const uint8_t *)"soa") != 0) {
    lexer_write_simple_token(out, 22, line0, col0);
    return;
  }
  if (nlen == 5 && lexer_match_keyword(data, start, 5, (const uint8_t *)"align") != 0) {
    lexer_write_simple_token(out, 46, line0, col0);
    return;
  }
  if (nlen == 4 && lexer_match_keyword(data, start, 4, (const uint8_t *)"enum") != 0) {
    lexer_write_simple_token(out, 47, line0, col0);
    return;
  }
  if (nlen == 4 && lexer_match_keyword(data, start, 4, (const uint8_t *)"goto") != 0) {
    lexer_write_simple_token(out, 48, line0, col0);
    return;
  }
  if (nlen == 5 && lexer_match_keyword(data, start, 5, (const uint8_t *)"trait") != 0) {
    lexer_write_simple_token(out, 49, line0, col0);
    return;
  }
  if (nlen == 4 && lexer_match_keyword(data, start, 4, (const uint8_t *)"impl") != 0) {
    lexer_write_simple_token(out, 50, line0, col0);
    return;
  }
  if (nlen == 4 && lexer_match_keyword(data, start, 4, (const uint8_t *)"self") != 0) {
    lexer_write_simple_token(out, 51, line0, col0);
    return;
  }
  if (nlen == 1 && data != 0) {
    bytes = *(uint8_t **)data;
    if (bytes != 0 && bytes[start] == 95) {
      lexer_write_simple_token(out, 52, line0, col0);
      return;
    }
  }
  if (nlen == 6 && lexer_match_keyword(data, start, 6, (const uint8_t *)"import") != 0) {
    lexer_write_simple_token(out, 53, line0, col0);
    return;
  }
  if (nlen == 6 && lexer_match_keyword(data, start, 6, (const uint8_t *)"extern") != 0) {
    lexer_write_simple_token(out, 54, line0, col0);
    return;
  }
  if (nlen == 5 && lexer_match_keyword(data, start, 5, (const uint8_t *)"async") != 0) {
    lexer_write_simple_token(out, 55, line0, col0);
    return;
  }
  if (nlen == 5 && lexer_match_keyword(data, start, 5, (const uint8_t *)"await") != 0) {
    lexer_write_simple_token(out, 56, line0, col0);
    return;
  }
  if (nlen == 3 && lexer_match_keyword(data, start, 3, (const uint8_t *)"run") != 0) {
    lexer_write_simple_token(out, 57, line0, col0);
    return;
  }
  lexer_try_keyword_c(out, data, start, len, line0, col0);
}
