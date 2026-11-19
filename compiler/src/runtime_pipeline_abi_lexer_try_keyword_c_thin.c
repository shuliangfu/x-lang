/* Host-gcc twin of typool lexer_try_keyword_c (lexer.x).
 * typool first-wins T 0x14001cbf8 (fromsrc_s105_noaslr) is entered for
 * the word "export" (start=804, nlen=6, bytes e x p o r t) from host-cc
 * lexer_try_keyword_b (return RIP 0x140003eb2) but does not write
 * TOKEN_EXPORT=131 through out. Live GDB on fromsrc_s105_noaslr check
 * examples/hello.x (repo cwd), core/fmt/mod.x export:
 * C_EXPORT_ENTER out=0x103f7e00 kind=272573224 (0x103f2328) rdx=0x103f8920
 * start=804 len=6 ret=0x140003eb2; C_EXPORT_RET kind=272573224 line=0
 * col=272604000 ident_len=6; typool lexer_try_keyword_d first-wins
 * 0x14001ed98 not reached (d_hit=0); typool leftover T 0x1402b3218 not
 * entered. out.kind is unchanged entry stack-pointer garbage, so the
 * emit thin takes the kind!=0 path and parser_parse_into_buf misses
 * TOKEN_EXPORT, firing parse skip / XP008. Same class as typool
 * lexer_try_keyword / typool lexer_try_keyword_b (keyword match does
 * not write through out). Host-gcc twin writes through out via a
 * small-frame helper and falls through to typool lexer_try_keyword_d
 * for the rest of the keyword chain. typool lexer_try_keyword_d /
 * typool lexer_match_keyword / typool write_tok / typool
 * parser_diagnostic_parse_skip / typool diag_io_fputc are not in this
 * thin. docs-only .x, do not idx8. Do not JMP typool rec T 0x140087de4. */
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
extern void lexer_try_keyword_d(XlangToken *out, void *data, uint64_t start,
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

void lexer_try_keyword_c(XlangToken *out, void *data, uint64_t start, uint64_t len,
                         int32_t line0, int32_t col0) {
  int32_t nlen;

  nlen = (int32_t)len;
  if (nlen == 5 && lexer_match_keyword(data, start, 5, (const uint8_t *)"spawn") != 0) {
    lexer_write_simple_token(out, 58, line0, col0);
    return;
  }
  if (nlen == 6 && lexer_match_keyword(data, start, 6, (const uint8_t *)"export") != 0) {
    lexer_write_simple_token(out, 131, line0, col0);
    return;
  }
  if (nlen == 3 && lexer_match_keyword(data, start, 3, (const uint8_t *)"i32") != 0) {
    lexer_write_simple_token(out, 60, line0, col0);
    return;
  }
  if (nlen == 4 && lexer_match_keyword(data, start, 4, (const uint8_t *)"bool") != 0) {
    lexer_write_simple_token(out, 61, line0, col0);
    return;
  }
  if (nlen == 2 && lexer_match_keyword(data, start, 2, (const uint8_t *)"u8") != 0) {
    lexer_write_simple_token(out, 62, line0, col0);
    return;
  }
  if (nlen == 3 && lexer_match_keyword(data, start, 3, (const uint8_t *)"u32") != 0) {
    lexer_write_simple_token(out, 63, line0, col0);
    return;
  }
  if (nlen == 3 && lexer_match_keyword(data, start, 3, (const uint8_t *)"u64") != 0) {
    lexer_write_simple_token(out, 64, line0, col0);
    return;
  }
  if (nlen == 3 && lexer_match_keyword(data, start, 3, (const uint8_t *)"i64") != 0) {
    lexer_write_simple_token(out, 65, line0, col0);
    return;
  }
  if (nlen == 5 && lexer_match_keyword(data, start, 5, (const uint8_t *)"usize") != 0) {
    lexer_write_simple_token(out, 66, line0, col0);
    return;
  }
  if (nlen == 5 && lexer_match_keyword(data, start, 5, (const uint8_t *)"isize") != 0) {
    lexer_write_simple_token(out, 67, line0, col0);
    return;
  }
  if (nlen == 4 && lexer_match_keyword(data, start, 4, (const uint8_t *)"true") != 0) {
    lexer_write_simple_token(out, 75, line0, col0);
    return;
  }
  if (nlen == 5 && lexer_match_keyword(data, start, 5, (const uint8_t *)"false") != 0) {
    lexer_write_simple_token(out, 76, line0, col0);
    return;
  }
  if (nlen == 4 && lexer_match_keyword(data, start, 4, (const uint8_t *)"null") != 0) {
    lexer_write_simple_token(out, 132, line0, col0);
    return;
  }
  if (nlen == 3 && lexer_match_keyword(data, start, 3, (const uint8_t *)"f32") != 0) {
    lexer_write_simple_token(out, 77, line0, col0);
    return;
  }
  if (nlen == 3 && lexer_match_keyword(data, start, 3, (const uint8_t *)"f64") != 0) {
    lexer_write_simple_token(out, 78, line0, col0);
    return;
  }
  if (nlen == 4 && lexer_match_keyword(data, start, 4, (const uint8_t *)"void") != 0) {
    lexer_write_simple_token(out, 79, line0, col0);
    return;
  }
  lexer_try_keyword_d(out, data, start, len, line0, col0);
}
