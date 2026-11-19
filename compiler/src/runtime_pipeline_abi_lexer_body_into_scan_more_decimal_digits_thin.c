/* Host-gcc twin of typool lexer_next_body_into's inlined decimal
 * "scan more digits / _ separators" loop (lexer.x 3689-3696). typool
 * leftover body (fromsrc_s110_noaslr first face 0x140032b18) typool-wrongs
 * lexer_take_byte's data[l.pos] store as mov %rax,-0x30(%rbp) at typool
 * 0x14003752c, overwriting the data fat pointer with the next digit byte.
 * Live GDB on fromsrc_s110_noaslr check examples/hello.x (repo cwd),
 * core/fmt/mod.x `let digits: u8[10] = ...` (the integer 10 at pos 0x497):
 * first digit '1' is fine (data still 0x103f1330, ival=1), then the '0'
 * store smashes data to 0x30 and the next `l.pos < data.length` load
 * at typool 0x1400373e8 (add 8; mov (%rax),%rax) SIGSEGVs with rax=0x38.
 * Single-digit `0` (n=1..9) never takes this store and already worked.
 * DIG unofficial image redirects typool's decimal more-digits loop head
 * to this thin, then jmps typool's post-loop L008 / float / emit path.
 * typool rec / typool fputc / typool lexer_next_body_into wholesale /
 * typool hex / typool bin / typool oct loops are not in this thin.
 * docs-only .x, do not idx8. Do not JMP typool rec T 0x140087de4. */
#include <stdint.h>

typedef struct XlangLexer {
  uint64_t pos;
  int32_t line;
  int32_t col;
} XlangLexer;

typedef struct XlangSliceU8 {
  uint8_t *ptr;
  uint64_t len;
} XlangSliceU8;

extern int32_t lexer_is_digit(uint8_t c);
extern void lexer_advance_one(XlangLexer *lex, uint8_t c);

void lexer_body_into_scan_more_decimal_digits(XlangLexer *lex,
                                              XlangSliceU8 *data,
                                              int64_t *ival) {
  uint8_t ch;
  uint8_t nxt;

  if (lex == 0 || data == 0 || ival == 0 || data->ptr == 0) {
    return;
  }
  while (lex->pos < data->len) {
    ch = data->ptr[lex->pos];
    if (lexer_is_digit(ch) != 0) {
      lexer_advance_one(lex, ch);
      *ival = *ival * 10 + (int64_t)(ch - 48);
      continue;
    }
    if (ch == 95 && (lex->pos + 1) < data->len) {
      nxt = data->ptr[lex->pos + 1];
      if (lexer_is_digit(nxt) != 0) {
        lexer_advance_one(lex, 95);
        continue;
      }
    }
    break;
  }
}
