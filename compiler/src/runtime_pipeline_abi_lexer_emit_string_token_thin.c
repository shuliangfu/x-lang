/* Host-gcc twin of typool lexer_emit_string_token (lexer.x).
 * typool lexer_next_body_into (fromsrc_s94 first-wins T 0x14002fc58) inlines
 * the STRING finish after the close-quote scan. It never calls
 * lexer_begin_number_span at the opening quote (bag has no such symbol),
 * so out.token_start stays 0. The inlined finish then builds slen from
 * wrong huge-frame slots: at CLOSE_ENTER, surviving open locals are
 * start@-0xd70=165 line@-0xd78=3 col@-0xd80=20 lex.pos=172, but the
 * finish reads start from -0x58(=0) and writes ident_len from -0x60
 * (end_pos-0 = 172). Writer RIP typool 0x14003133c
 * (`mov %eax,0x28(%rbx)` ident_len store); park then writes token_start=0
 * (typool 0x14003145a). Live GDB on fromsrc_s94_noaslr check
 * examples/hello.x (repo cwd): STR_OPEN start=165; STR_SLEN slot60=172
 * parked=0; three re-emits of kind=130 ident_len=172; then kind=0 with
 * smashed out_pos; SIGSEGV rip outside image / rbp=ASCII ort("std from
 * import("std.fmt"). Host-gcc twin takes the surviving start/line/col as
 * args (DIG close-quote redirect), keeps Token+write in one small frame,
 * sets next_lex to end_pos+1 and parks content start. typool tip /
 * skip_function / append_i32 / fputc / try_keyword_c / typool rec /
 * typool body_into wholesale are not in this thin. DIG unofficial image
 * must redirect the inlined close finish (typool 0x140031281) to this
 * thin then jmp body epilogue. docs-only .x, do not idx8. Do not JMP
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

void lexer_emit_string_token(void *out, XlangLexer *lex, uint64_t content_start,
                             int32_t line0, int32_t col0) {
  XlangLexer next;
  XlangToken tok;
  uint64_t end_pos;
  int32_t end_line;
  int32_t end_col;
  int32_t slen;

  if (out == 0 || lex == 0) {
    return;
  }
  end_pos = lex->pos;
  end_line = lex->line;
  end_col = lex->col;
  slen = (int32_t)(end_pos - content_start);
  next.pos = end_pos + 1;
  next.line = end_line;
  next.col = end_col + 1;
  tok.kind = 130;
  tok.line = line0;
  tok.col = col0;
  tok.int_val = 0;
  tok.float_val = 0.0;
  tok.ident = 0;
  tok.ident_len = slen;
  lexer_write_next_lex_into(out, &next);
  lexer_write_tok_into(out, &tok);
  lexer_park_token_start(out, content_start);
}
