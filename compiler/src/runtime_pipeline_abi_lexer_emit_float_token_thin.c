/* Host-gcc twin of typool lexer_emit_float_token (lexer.x).
 * typool lexer_next_body_into inlines the FLOAT finish. It builds Token
 * at huge-frame -0xdd0 (kind=81 store typool 0x1400391ba on
 * fromsrc_s119) but then copies fields from the wrong slot -0x970 into
 * write_tok_into staging (typool lea 0x14003927c) and calls
 * lexer_write_tok_into at typool 0x14003931f. Live GDB on
 * fromsrc_s119_noaslr check examples/hello.x (repo cwd), core/fmt/mod.x
 * `if (x == 0.0)` at byte 8340: constructed tok at -0xdd0 is kind=81,
 * but write_tok src kind is a pointer (272449840). peek_kind then
 * returns that pointer instead of TOKEN_FLOAT=81, so
 * parser_asm_primary_literal_x_into_c early-returns 0 and
 * fmt_f64_is_inf parse-skips at byte 8240. typool huge-frame fval
 * slot also aliases. Host-gcc twin keeps Token+write in one small
 * frame and re-parses data[start, end) with typool lexer_parse_float_span
 * (scale by (10 as f64); do not idx8). The DIG unofficial image
 * redirects typool inlined FLOAT finish (lea -0xdd0 + mov $0x51 +
 * lea -0x970) to lexer_emit_float_token_from_body_into, which recovers
 * start by walking digits/`_`/`.`/`e`/`E` and exponent sign back from
 * lex.pos on typool data fat, then calls this twin and jmps the typool
 * body-into epilogue. typool leftover if_stmt_x / literal / peek_kind /
 * buf_into / body_into / fputc / rec wholesale are not in this thin.
 * docs-only .x, do not idx8. Do not JMP typool rec T 0x140087de4. */
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

static int is_digit_b(uint8_t c) {
  return (c >= 48 && c <= 57) ? 1 : 0;
}

/* typool lexer_parse_float_span: data[start, end), scale with 10.0. */
static double lexer_parse_float_span_host(const uint8_t *data, uint64_t start,
                                          uint64_t end) {
  uint64_t i = start;
  double fval = 0.0;
  int32_t places;
  int32_t pi;
  int32_t exp_sign;
  int32_t exp;
  int32_t e;
  double scale;

  if (data == 0 || start >= end) {
    return 0.0;
  }
  while (i < end && (is_digit_b(data[i]) != 0 || data[i] == 95)) {
    if (is_digit_b(data[i]) != 0) {
      fval = fval * 10.0 + (double)(data[i] - 48);
    }
    i = i + 1;
  }
  if (i < end && data[i] == 46) {
    i = i + 1;
    places = 0;
    while (i < end && (is_digit_b(data[i]) != 0 || data[i] == 95)) {
      if (is_digit_b(data[i]) != 0) {
        fval = fval * 10.0 + (double)(data[i] - 48);
        places = places + 1;
      }
      i = i + 1;
    }
    pi = 0;
    while (pi < places) {
      fval = fval / 10.0;
      pi = pi + 1;
    }
  }
  if (i < end && (data[i] == 101 || data[i] == 69)) {
    i = i + 1;
    exp_sign = 1;
    if (i < end && data[i] == 45) {
      exp_sign = -1;
      i = i + 1;
    } else {
      if (i < end && data[i] == 43) {
        i = i + 1;
      }
    }
    exp = 0;
    while (i < end && (is_digit_b(data[i]) != 0 || data[i] == 95)) {
      if (is_digit_b(data[i]) != 0) {
        exp = exp * 10 + (data[i] - 48);
      }
      i = i + 1;
    }
    exp = exp * exp_sign;
    scale = 1.0;
    e = 0;
    if (exp > 0) {
      while (e < exp) {
        scale = scale * 10.0;
        e = e + 1;
      }
    } else {
      while (e > exp) {
        scale = scale / 10.0;
        e = e - 1;
      }
    }
    fval = fval * scale;
  }
  return fval;
}

void lexer_emit_float_token(void *out, XlangLexer *lex, const uint8_t *data,
                            uint64_t start) {
  XlangToken tok;
  uint64_t end_pos;
  int32_t line0;
  int32_t col0;
  double fval;

  if (out == 0 || lex == 0) {
    return;
  }
  end_pos = lex->pos;
  if (end_pos < start) {
    start = end_pos;
  }
  line0 = lex->line;
  col0 = lex->col - (int32_t)(end_pos - start);
  if (col0 < 1) {
    col0 = 1;
  }
  fval = lexer_parse_float_span_host(data, start, end_pos);
  tok.kind = 81;
  tok.line = line0;
  tok.col = col0;
  tok._pad0 = 0;
  tok.int_val = 0;
  tok.float_val = fval;
  tok.ident = 0;
  tok.ident_len = 0;
  tok._pad1 = 0;
  lexer_write_next_lex_into(out, lex);
  lexer_write_tok_into(out, &tok);
  lexer_park_token_start(out, start);
}

/* DIG hook: typool next_body_into inlined float emit. out=[rbp-0x10],
 * lex=[rbp-0x28], data_fat=[rbp-0x30] ({ptr,len}). */
void lexer_emit_float_token_from_body_into(void *out, XlangLexer *lex,
                                           void *data_fat) {
  uint8_t *p;
  uint64_t len;
  uint64_t pos;
  uint64_t start;
  uint8_t c;
  uint8_t prev;

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
      c = p[start - 1];
      if ((c >= 48 && c <= 57) || c == 95 || c == 46 || c == 101 || c == 69) {
        start = start - 1;
      } else if ((c == 43 || c == 45) && start >= 2) {
        prev = p[start - 2];
        if (prev == 101 || prev == 69) {
          start = start - 1;
        } else {
          break;
        }
      } else {
        break;
      }
    }
  }
  lexer_emit_float_token(out, lex, p, start);
}
