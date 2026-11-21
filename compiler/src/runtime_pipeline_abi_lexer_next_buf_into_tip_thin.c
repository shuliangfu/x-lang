/* Source-faithful lexer_next_buf_into_tip twin (lexer.x lexer_next_buf_into body).
 * s138 T001: PARSE_ONLY of std.fmt (22890 bytes) returned 0 but the published
 * module had num_funcs=0. alloc_slot never ran on that module. The first
 * function parse + skip + EOF happened at pos 175/185/233 — the length of
 * examples/hello.x, not std.fmt. typool lexer_next_buf_into_tip at
 * 0x140043ad4 loaded the parked entry source whenever the park was
 * non-null, dropping the caller buf. Source is:
 *   if (d == 0 && sp != 0) { d = sp; n = slen; }
 * typool compiled only `if (sp != 0)`. Hello parse parks (data, 233);
 * dep prerun then re-lexed hello, hit EOF at 233, and finished the fmt
 * module empty. The first-wins trampoline lexer_next_buf_into at
 * 0x140015da0 is kept; this thin is only the tip body it calls.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>
#include <string.h>

typedef struct {
  uint64_t pos;
  int32_t line;
  int32_t col;
} Lexer;

typedef struct {
  uint8_t *data;
  uint64_t length;
} SliceU8;

void lexer_src_data_store(uint8_t *out);
void lexer_src_len_store(uint8_t *out);
void lexer_next_impl(void *out, Lexer *lex, SliceU8 *sl);

void lexer_next_buf_into_tip(void *out, Lexer *lex, uint8_t *data, int32_t len) {
  int32_t n = len;
  uint8_t *d = data;
  uint8_t *sp = 0;
  uint64_t slen = 0;
  SliceU8 sl;
  Lexer lex_copy;
  lexer_src_data_store((uint8_t *)&sp);
  lexer_src_len_store((uint8_t *)&slen);
  if (d == 0 && sp != 0) {
    d = sp;
    n = (int32_t)slen;
  }
  if (n < 0) {
    n = 0;
  }
  sl.data = d;
  sl.length = (uint64_t)(uint32_t)n;
  if (lex) {
    lex_copy = *lex;
  } else {
    memset(&lex_copy, 0, sizeof(lex_copy));
  }
  lexer_next_impl(out, &lex_copy, &sl);
}
