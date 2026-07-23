#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
void xlang_panic_(int has_msg, int msg_val);
enum token_TokenKind { token_TokenKind_TOKEN_EOF, token_TokenKind_TOKEN_FUNCTION, token_TokenKind_TOKEN_LET, token_TokenKind_TOKEN_CONST, token_TokenKind_TOKEN_IF, token_TokenKind_TOKEN_ELSE, token_TokenKind_TOKEN_WHILE, token_TokenKind_TOKEN_LOOP, token_TokenKind_TOKEN_FOR, token_TokenKind_TOKEN_BREAK, token_TokenKind_TOKEN_CONTINUE, token_TokenKind_TOKEN_RETURN, token_TokenKind_TOKEN_PANIC, token_TokenKind_TOKEN_DEFER, token_TokenKind_TOKEN_TRY, token_TokenKind_TOKEN_CATCH, token_TokenKind_TOKEN_REGION, token_TokenKind_TOKEN_WITH_ARENA, token_TokenKind_TOKEN_MATCH, token_TokenKind_TOKEN_STRUCT, token_TokenKind_TOKEN_TYPE, token_TokenKind_TOKEN_PACKED, token_TokenKind_TOKEN_SOA, token_TokenKind_TOKEN_ATTR_SOA, token_TokenKind_TOKEN_ATTR_CFG, token_TokenKind_TOKEN_ATTR_REPR_C, token_TokenKind_TOKEN_ATTR_REPR_COMPATIBLE, token_TokenKind_TOKEN_ATTR_ALLOC, token_TokenKind_TOKEN_ATTR_LINK_SECTION, token_TokenKind_TOKEN_ATTR_NAKED, token_TokenKind_TOKEN_ATTR_ENTRY, token_TokenKind_TOKEN_ATTR_USED, token_TokenKind_TOKEN_ATTR_NO_MANGLE, token_TokenKind_TOKEN_ATTR_LINK_NAME, token_TokenKind_TOKEN_ATTR_MAX_STACK, token_TokenKind_TOKEN_ATTR_INTERRUPT, token_TokenKind_TOKEN_ATTR_SEND, token_TokenKind_TOKEN_ATTR_SYNC, token_TokenKind_TOKEN_ATTR_GLOBAL_ALLOCATOR, token_TokenKind_TOKEN_ATTR_COLD, token_TokenKind_TOKEN_ATTR_INLINE_NEVER, token_TokenKind_TOKEN_ATTR_INLINE_ALWAYS, token_TokenKind_TOKEN_ATTR_EXPORT_NAME, token_TokenKind_TOKEN_ATTR_PANIC_HANDLER, token_TokenKind_TOKEN_ATTR_THREAD_LOCAL, token_TokenKind_TOKEN_ATTR_PERCPU, token_TokenKind_TOKEN_ALIGN, token_TokenKind_TOKEN_ENUM, token_TokenKind_TOKEN_GOTO, token_TokenKind_TOKEN_TRAIT, token_TokenKind_TOKEN_IMPL, token_TokenKind_TOKEN_SELF, token_TokenKind_TOKEN_UNDERSCORE, token_TokenKind_TOKEN_IMPORT, token_TokenKind_TOKEN_EXTERN, token_TokenKind_TOKEN_ASYNC, token_TokenKind_TOKEN_AWAIT, token_TokenKind_TOKEN_RUN, token_TokenKind_TOKEN_SPAWN, token_TokenKind_TOKEN_IDENT, token_TokenKind_TOKEN_I32, token_TokenKind_TOKEN_BOOL, token_TokenKind_TOKEN_U8, token_TokenKind_TOKEN_U32, token_TokenKind_TOKEN_U64, token_TokenKind_TOKEN_I64, token_TokenKind_TOKEN_USIZE, token_TokenKind_TOKEN_ISIZE, token_TokenKind_TOKEN_I32X4, token_TokenKind_TOKEN_I32X8, token_TokenKind_TOKEN_I32X16, token_TokenKind_TOKEN_U32X4, token_TokenKind_TOKEN_U32X8, token_TokenKind_TOKEN_U32X16, token_TokenKind_TOKEN_F32X4, token_TokenKind_TOKEN_TRUE, token_TokenKind_TOKEN_FALSE, token_TokenKind_TOKEN_F32, token_TokenKind_TOKEN_F64, token_TokenKind_TOKEN_VOID, token_TokenKind_TOKEN_INT, token_TokenKind_TOKEN_FLOAT, token_TokenKind_TOKEN_LPAREN, token_TokenKind_TOKEN_RPAREN, token_TokenKind_TOKEN_LBRACE, token_TokenKind_TOKEN_RBRACE, token_TokenKind_TOKEN_LBRACKET, token_TokenKind_TOKEN_RBRACKET, token_TokenKind_TOKEN_ARROW, token_TokenKind_TOKEN_FATARROW, token_TokenKind_TOKEN_COMMA, token_TokenKind_TOKEN_COLON, token_TokenKind_TOKEN_DOT, token_TokenKind_TOKEN_DOTDOT, token_TokenKind_TOKEN_ELLIPSIS, token_TokenKind_TOKEN_SEMICOLON, token_TokenKind_TOKEN_PLUS, token_TokenKind_TOKEN_MINUS, token_TokenKind_TOKEN_STAR, token_TokenKind_TOKEN_SLASH, token_TokenKind_TOKEN_PERCENT, token_TokenKind_TOKEN_AMP, token_TokenKind_TOKEN_PIPE, token_TokenKind_TOKEN_CARET, token_TokenKind_TOKEN_LSHIFT, token_TokenKind_TOKEN_RSHIFT, token_TokenKind_TOKEN_PLUS_EQ, token_TokenKind_TOKEN_MINUS_EQ, token_TokenKind_TOKEN_STAR_EQ, token_TokenKind_TOKEN_SLASH_EQ, token_TokenKind_TOKEN_PERCENT_EQ, token_TokenKind_TOKEN_AMP_EQ, token_TokenKind_TOKEN_PIPE_EQ, token_TokenKind_TOKEN_CARET_EQ, token_TokenKind_TOKEN_LSHIFT_EQ, token_TokenKind_TOKEN_RSHIFT_EQ, token_TokenKind_TOKEN_TILDE, token_TokenKind_TOKEN_ASSIGN, token_TokenKind_TOKEN_EQ, token_TokenKind_TOKEN_NE, token_TokenKind_TOKEN_LT, token_TokenKind_TOKEN_GT, token_TokenKind_TOKEN_LE, token_TokenKind_TOKEN_GE, token_TokenKind_TOKEN_AMPAMP, token_TokenKind_TOKEN_PIPEPIPE, token_TokenKind_TOKEN_BANG, token_TokenKind_TOKEN_QUESTION, token_TokenKind_TOKEN_AS, token_TokenKind_TOKEN_AT, token_TokenKind_TOKEN_STRING, token_TokenKind_TOKEN_EXPORT };
struct token_Token {
  int32_t kind;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t * ident;
  int32_t ident_len;
};

struct token_Token;
extern int token_is_eof(struct token_Token t);
int token_is_eof(struct token_Token t) {
  return ((t.kind) ==0);
}
extern int token_is_eof(struct token_Token t);
struct Lexer {
  size_t pos;
  int32_t line;
  int32_t col;
};

struct LexerResult {
  struct Lexer next_lex;
  struct token_Token tok;
  size_t token_start;
};

struct Token {
  int32_t kind;
  int32_t line;
  int32_t col;
  int32_t int_val;
  double float_val;
  int32_t ident;
  int32_t ident_len;
};

extern struct Lexer lexer_init(void);
extern struct Lexer advance_one(struct Lexer lex, uint8_t c);
extern int is_alpha(uint8_t c);
extern int is_hex_digit(uint8_t c);
extern int32_t hex_digit_value(uint8_t c);
extern int is_digit(uint8_t c);
extern int is_alnum_underscore(uint8_t c);
extern int match_keyword(struct xlang_slice_uint8_t data, size_t start, int32_t len, struct xlang_slice_uint8_t keyword);
extern int match_keyword_buf(uint8_t * data, int32_t data_len, size_t start, int32_t len, struct xlang_slice_uint8_t keyword);
extern struct token_Token try_keyword(struct xlang_slice_uint8_t data, size_t start, size_t len, int32_t line0, int32_t col0);
extern struct token_Token try_keyword_buf(uint8_t * data, int32_t data_len, size_t start, size_t len, int32_t line0, int32_t col0);
extern struct Lexer skip_repr_c_attr_if_present(struct Lexer lex, struct xlang_slice_uint8_t data);
extern struct Lexer skip_cfg_attr_if_present(struct Lexer lex, struct xlang_slice_uint8_t data);
extern int32_t lexer_try_cfg_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data);
extern int32_t lexer_try_repr_c_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data);
extern int32_t lexer_try_repr_compatible_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data);
extern int32_t lexer_try_soa_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data);
extern int32_t lexer_try_alloc_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data);
extern int32_t lexer_try_used_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data);
extern int32_t lexer_try_naked_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data);
extern int32_t lexer_try_entry_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data);
extern int32_t lexer_try_no_mangle_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data);
extern int32_t lexer_try_interrupt_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data);
extern int32_t lexer_try_send_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data);
extern int32_t lexer_try_sync_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data);
extern struct Lexer skip_whitespace_and_comments(struct Lexer lex, struct xlang_slice_uint8_t data);
extern struct Lexer skip_whitespace_and_comments_buf(struct Lexer lex, uint8_t * data, int32_t len);
/* wave269: L001 unclosed block comment hard diag */
extern void diag_report_with_code(const char *file, int32_t line, int32_t col,
                                  const char *kind, const char *code,
                                  const char *msg, const char *detail);
extern void lexer_unclosed_block_comment_reset(void);
extern int32_t lexer_unclosed_block_comment_pending(void);
extern void lexer_unclosed_string_reset(void);
extern int32_t lexer_unclosed_string_pending(void);
extern struct LexerResult lexer_next(struct Lexer lex, struct xlang_slice_uint8_t data);
extern void lexer_apply_optional_exponent(struct Lexer l, struct xlang_slice_uint8_t data, double fval, struct Lexer * out_l, double * out_f);
extern void lexer_next_body_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data);
extern void lexer_next_punct_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data, uint8_t c);
extern void write_next_lex_into(struct LexerResult * out, struct Lexer l);
extern void write_tok_into(struct LexerResult * out, struct token_Token t);
extern void lexer_next_impl(struct LexerResult * out, struct Lexer lex, struct xlang_slice_uint8_t data);
extern void lexer_next_into(struct LexerResult * out, struct Lexer lex, struct xlang_slice_uint8_t data);
extern void lexer_next_buf_into(struct LexerResult * out, struct Lexer lex, uint8_t * data, int32_t len);
extern struct LexerResult lexer_next_buf(struct Lexer lex, uint8_t * data, int32_t len);
extern int32_t main(void);
static uint8_t c;
static size_t start;
static int32_t line0;
static int32_t col0;
static size_t len;
static struct token_Token tok;
static size_t start;
static int32_t line0;
static int32_t col0;
static int64_t ival;
static uint64_t hval;
static uint8_t hd;
static uint8_t d;
static double fval;
static double frac;
static uint8_t d;
static int32_t exp_sign;
static int32_t exp;
static uint8_t d;
static double scale;
static int32_t e;
static double fval;
static size_t start;
static int32_t line0;
static int32_t col0;
static double fval;
static double frac;
static uint8_t d;
static size_t start;
static int32_t line0;
static int32_t col0;
static void init_globals(void) {
  c = (data)[(l.pos)];
  start = (l.pos);
  line0 = (l.line);
  col0 = (l.col);
  len = ((l.pos) - start);
  tok = try_keyword(data, start, len, line0, col0);
  start = (l.pos);
  line0 = (l.line);
  col0 = (l.col);
  ival = 0;
  hval = ((uint64_t)(0));
  hd = (data)[(l.pos)];
  d = (data)[(l.pos)];
  fval = ((double)(ival));
  frac = 0.0;
  d = (data)[(l.pos)];
  exp_sign = 1;
  exp = 0;
  d = (data)[(l.pos)];
  scale = 0.0;
  e = 0;
  fval = (((double)(ival)) * scale);
  start = (l.pos);
  line0 = (l.line);
  col0 = (l.col);
  fval = 0.0;
  frac = 0.0;
  d = (data)[(l.pos)];
  start = (l.pos);
  line0 = (l.line);
  col0 = (l.col);
}
extern int32_t cfg_eval_expr_c(uint8_t * start, int32_t len);
extern struct xlang_slice_uint8_t lexer_parser_slice_from_buf(uint8_t * data, int32_t len);
struct Lexer lexer_init(void) {
  return (struct Lexer){ .pos = 0, .line = 1, .col = 1 };
}
struct Lexer advance_one(struct Lexer lex, uint8_t c) {
  if ((c ==10)) {
    return (struct Lexer){ .pos = ((lex.pos) + 1), .line = ((lex.line) + 1), .col = 1 };
  }
  return (struct Lexer){ .pos = ((lex.pos) + 1), .line = (lex.line), .col = ((lex.col) + 1) };
}
int is_alpha(uint8_t c) {
  if (((c >=97) && (c <=122))) {
    return 1;
  }
  if (((c >=65) && (c <=90))) {
    return 1;
  }
  return (c ==95);
}
int is_hex_digit(uint8_t c) {
  if (((c >=48) && (c <=57))) {
    return 1;
  }
  if (((c >=97) && (c <=102))) {
    return 1;
  }
  if (((c >=65) && (c <=70))) {
    return 1;
  }
  return 0;
}
int32_t hex_digit_value(uint8_t c) {
  if (((c >=48) && (c <=57))) {
    return ((int32_t)((c - 48)));
  }
  if (((c >=97) && (c <=102))) {
    return ((int32_t)(((c - 97) + 10)));
  }
  if (((c >=65) && (c <=70))) {
    return ((int32_t)(((c - 65) + 10)));
  }
  return 0;
}
int is_digit(uint8_t c) {
  return ((c >=48) && (c <=57));
}
int is_alnum_underscore(uint8_t c) {
  return (is_alpha(c) || is_digit(c));
}
int match_keyword(struct xlang_slice_uint8_t data, size_t start, int32_t len, struct xlang_slice_uint8_t keyword) {
  int32_t i = 0;
  while ((i < len)) {
    if (((data).data[(start + i)] !=(keyword).data[i])) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
int match_keyword_buf(uint8_t * data, int32_t data_len, size_t start, int32_t len, struct xlang_slice_uint8_t keyword) {
  int32_t i = 0;
  while ((i < len)) {
    if (((((int32_t)(start)) + i) >=data_len)) {
      return 0;
    }
    if (((data)[(start + i)] !=(keyword).data[i])) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
struct token_Token try_keyword(struct xlang_slice_uint8_t data, size_t start, size_t len, int32_t line0, int32_t col0) {
  if (((len ==8) && match_keyword(data, start, 8, (uint8_t[]){102, 117, 110, 99, 116, 105, 111, 110 }))) {
    struct token_Token t = (struct Token){ .kind = 1, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==3) && match_keyword(data, start, 3, (uint8_t[]){108, 101, 116 }))) {
    struct token_Token t = (struct Token){ .kind = 2, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword(data, start, 5, (uint8_t[]){99, 111, 110, 115, 116 }))) {
    struct token_Token t = (struct Token){ .kind = 3, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==2) && match_keyword(data, start, 2, (uint8_t[]){105, 102 }))) {
    struct token_Token t = (struct Token){ .kind = 4, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==4) && match_keyword(data, start, 4, (uint8_t[]){101, 108, 115, 101 }))) {
    struct token_Token t = (struct Token){ .kind = 5, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword(data, start, 5, (uint8_t[]){119, 104, 105, 108, 101 }))) {
    struct token_Token t = (struct Token){ .kind = 6, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==4) && match_keyword(data, start, 4, (uint8_t[]){108, 111, 111, 112 }))) {
    struct token_Token t = (struct Token){ .kind = 7, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==3) && match_keyword(data, start, 3, (uint8_t[]){102, 111, 114 }))) {
    struct token_Token t = (struct Token){ .kind = 8, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword(data, start, 5, (uint8_t[]){98, 114, 101, 97, 107 }))) {
    struct token_Token t = (struct Token){ .kind = 9, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==8) && match_keyword(data, start, 8, (uint8_t[]){99, 111, 110, 116, 105, 110, 117, 101 }))) {
    struct token_Token t = (struct Token){ .kind = 10, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==6) && match_keyword(data, start, 6, (uint8_t[]){114, 101, 116, 117, 114, 110 }))) {
    struct token_Token t = (struct Token){ .kind = 11, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword(data, start, 5, (uint8_t[]){112, 97, 110, 105, 99 }))) {
    struct token_Token t = (struct Token){ .kind = 12, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword(data, start, 5, (uint8_t[]){100, 101, 102, 101, 114 }))) {
    struct token_Token t = (struct Token){ .kind = 13, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==6) && match_keyword(data, start, 6, (uint8_t[]){114, 101, 103, 105, 111, 110 }))) {
    struct token_Token t = (struct Token){ .kind = 16, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==10) && match_keyword(data, start, 10, (uint8_t[]){119, 105, 116, 104, 95, 97, 114, 101, 110, 97 }))) {
    struct token_Token t = (struct Token){ .kind = 17, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword(data, start, 5, (uint8_t[]){109, 97, 116, 99, 104 }))) {
    struct token_Token t = (struct Token){ .kind = 18, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==6) && match_keyword(data, start, 6, (uint8_t[]){115, 116, 114, 117, 99, 116 }))) {
    struct token_Token t = (struct Token){ .kind = 19, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==4) && match_keyword(data, start, 4, (uint8_t[]){116, 121, 112, 101 }))) {
    struct token_Token t = (struct Token){ .kind = 20, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==6) && match_keyword(data, start, 6, (uint8_t[]){112, 97, 99, 107, 101, 100 }))) {
    struct token_Token t = (struct Token){ .kind = 21, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==3) && match_keyword(data, start, 3, (uint8_t[]){115, 111, 97 }))) {
    struct token_Token t = (struct Token){ .kind = 22, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword(data, start, 5, (uint8_t[]){97, 108, 105, 103, 110 }))) {
    struct token_Token t = (struct Token){ .kind = 46, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==4) && match_keyword(data, start, 4, (uint8_t[]){101, 110, 117, 109 }))) {
    struct token_Token t = (struct Token){ .kind = 47, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==4) && match_keyword(data, start, 4, (uint8_t[]){103, 111, 116, 111 }))) {
    struct token_Token t = (struct Token){ .kind = 48, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword(data, start, 5, (uint8_t[]){116, 114, 97, 105, 116 }))) {
    struct token_Token t = (struct Token){ .kind = 49, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==4) && match_keyword(data, start, 4, (uint8_t[]){105, 109, 112, 108 }))) {
    struct token_Token t = (struct Token){ .kind = 50, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==4) && match_keyword(data, start, 4, (uint8_t[]){115, 101, 108, 102 }))) {
    struct token_Token t = (struct Token){ .kind = 51, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==1) && ((data).data[start] ==95))) {
    struct token_Token t = (struct Token){ .kind = 52, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==6) && match_keyword(data, start, 6, (uint8_t[]){105, 109, 112, 111, 114, 116 }))) {
    struct token_Token t = (struct Token){ .kind = 53, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==6) && match_keyword(data, start, 6, (uint8_t[]){101, 120, 116, 101, 114, 110 }))) {
    struct token_Token t = (struct Token){ .kind = 54, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword(data, start, 5, (uint8_t[]){97, 115, 121, 110, 99 }))) {
    struct token_Token t = (struct Token){ .kind = 55, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword(data, start, 5, (uint8_t[]){97, 119, 97, 105, 116 }))) {
    struct token_Token t = (struct Token){ .kind = 56, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==3) && match_keyword(data, start, 3, (uint8_t[]){114, 117, 110 }))) {
    struct token_Token t = (struct Token){ .kind = 57, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword(data, start, 5, (uint8_t[]){115, 112, 97, 119, 110 }))) {
    struct token_Token t = (struct Token){ .kind = 58, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==6) && match_keyword(data, start, 6, (uint8_t[]){101, 120, 112, 111, 114, 116 }))) {
    struct token_Token t = (struct Token){ .kind = 131, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==3) && match_keyword(data, start, 3, (uint8_t[]){105, 51, 50 }))) {
    struct token_Token t = (struct Token){ .kind = 60, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==4) && match_keyword(data, start, 4, (uint8_t[]){98, 111, 111, 108 }))) {
    struct token_Token t = (struct Token){ .kind = 61, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==2) && match_keyword(data, start, 2, (uint8_t[]){117, 56 }))) {
    struct token_Token t = (struct Token){ .kind = 62, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==3) && match_keyword(data, start, 3, (uint8_t[]){117, 51, 50 }))) {
    struct token_Token t = (struct Token){ .kind = 63, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==3) && match_keyword(data, start, 3, (uint8_t[]){117, 54, 52 }))) {
    struct token_Token t = (struct Token){ .kind = 64, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==3) && match_keyword(data, start, 3, (uint8_t[]){105, 54, 52 }))) {
    struct token_Token t = (struct Token){ .kind = 65, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword(data, start, 5, (uint8_t[]){117, 115, 105, 122, 101 }))) {
    struct token_Token t = (struct Token){ .kind = 66, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword(data, start, 5, (uint8_t[]){105, 115, 105, 122, 101 }))) {
    struct token_Token t = (struct Token){ .kind = 67, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==4) && match_keyword(data, start, 4, (uint8_t[]){116, 114, 117, 101 }))) {
    struct token_Token t = (struct Token){ .kind = 75, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword(data, start, 5, (uint8_t[]){102, 97, 108, 115, 101 }))) {
    struct token_Token t = (struct Token){ .kind = 76, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==3) && match_keyword(data, start, 3, (uint8_t[]){102, 51, 50 }))) {
    struct token_Token t = (struct Token){ .kind = 77, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==3) && match_keyword(data, start, 3, (uint8_t[]){102, 54, 52 }))) {
    struct token_Token t = (struct Token){ .kind = 78, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==4) && match_keyword(data, start, 4, (uint8_t[]){118, 111, 105, 100 }))) {
    struct token_Token t = (struct Token){ .kind = 79, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword(data, start, 5, (uint8_t[]){105, 51, 120, 52 }))) {
    struct token_Token t = (struct Token){ .kind = 68, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword(data, start, 5, (uint8_t[]){105, 51, 120, 56 }))) {
    struct token_Token t = (struct Token){ .kind = 69, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==6) && match_keyword(data, start, 6, (uint8_t[]){105, 51, 120, 49, 54 }))) {
    struct token_Token t = (struct Token){ .kind = 70, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword(data, start, 5, (uint8_t[]){117, 51, 120, 52 }))) {
    struct token_Token t = (struct Token){ .kind = 71, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword(data, start, 5, (uint8_t[]){117, 51, 120, 56 }))) {
    struct token_Token t = (struct Token){ .kind = 72, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==6) && match_keyword(data, start, 6, (uint8_t[]){117, 51, 120, 49, 54 }))) {
    struct token_Token t = (struct Token){ .kind = 73, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==2) && match_keyword(data, start, 2, (uint8_t[]){97, 115 }))) {
    struct token_Token t = (struct Token){ .kind = 128, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  struct token_Token t = (struct Token){ .kind = 59, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = len };
  return t;
}
struct token_Token try_keyword_buf(uint8_t * data, int32_t data_len, size_t start, size_t len, int32_t line0, int32_t col0) {
  if (((len ==8) && match_keyword_buf(data, data_len, start, 8, (uint8_t[]){102, 117, 110, 99, 116, 105, 111, 110 }))) {
    struct token_Token t = (struct Token){ .kind = 1, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==3) && match_keyword_buf(data, data_len, start, 3, (uint8_t[]){108, 101, 116 }))) {
    struct token_Token t = (struct Token){ .kind = 2, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword_buf(data, data_len, start, 5, (uint8_t[]){99, 111, 110, 115, 116 }))) {
    struct token_Token t = (struct Token){ .kind = 3, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==2) && match_keyword_buf(data, data_len, start, 2, (uint8_t[]){105, 102 }))) {
    struct token_Token t = (struct Token){ .kind = 4, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==4) && match_keyword_buf(data, data_len, start, 4, (uint8_t[]){101, 108, 115, 101 }))) {
    struct token_Token t = (struct Token){ .kind = 5, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==6) && match_keyword_buf(data, data_len, start, 6, (uint8_t[]){114, 101, 116, 117, 114, 110 }))) {
    struct token_Token t = (struct Token){ .kind = 11, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==6) && match_keyword_buf(data, data_len, start, 6, (uint8_t[]){115, 116, 114, 117, 99, 116 }))) {
    struct token_Token t = (struct Token){ .kind = 19, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==4) && match_keyword_buf(data, data_len, start, 4, (uint8_t[]){116, 121, 112, 101 }))) {
    struct token_Token t = (struct Token){ .kind = 20, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==4) && match_keyword_buf(data, data_len, start, 4, (uint8_t[]){101, 110, 117, 109 }))) {
    struct token_Token t = (struct Token){ .kind = 47, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword_buf(data, data_len, start, 5, (uint8_t[]){109, 97, 116, 99, 104 }))) {
    struct token_Token t = (struct Token){ .kind = 18, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==4) && match_keyword_buf(data, data_len, start, 4, (uint8_t[]){116, 114, 117, 101 }))) {
    struct token_Token t = (struct Token){ .kind = 75, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword_buf(data, data_len, start, 5, (uint8_t[]){102, 97, 108, 115, 101 }))) {
    struct token_Token t = (struct Token){ .kind = 76, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==3) && match_keyword_buf(data, data_len, start, 3, (uint8_t[]){102, 54, 52 }))) {
    struct token_Token t = (struct Token){ .kind = 78, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==4) && match_keyword_buf(data, data_len, start, 4, (uint8_t[]){118, 111, 105, 100 }))) {
    struct token_Token t = (struct Token){ .kind = 79, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==3) && match_keyword_buf(data, data_len, start, 3, (uint8_t[]){105, 51, 50 }))) {
    struct token_Token t = (struct Token){ .kind = 60, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==4) && match_keyword_buf(data, data_len, start, 4, (uint8_t[]){98, 111, 111, 108 }))) {
    struct token_Token t = (struct Token){ .kind = 61, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==2) && match_keyword_buf(data, data_len, start, 2, (uint8_t[]){117, 56 }))) {
    struct token_Token t = (struct Token){ .kind = 62, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword_buf(data, data_len, start, 5, (uint8_t[]){117, 115, 105, 122, 101 }))) {
    struct token_Token t = (struct Token){ .kind = 66, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword_buf(data, data_len, start, 5, (uint8_t[]){105, 115, 105, 122, 101 }))) {
    struct token_Token t = (struct Token){ .kind = 67, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==2) && match_keyword_buf(data, data_len, start, 2, (uint8_t[]){97, 115 }))) {
    struct token_Token t = (struct Token){ .kind = 128, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==6) && match_keyword_buf(data, data_len, start, 6, (uint8_t[]){105, 109, 112, 111, 114, 116 }))) {
    struct token_Token t = (struct Token){ .kind = 53, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==6) && match_keyword_buf(data, data_len, start, 6, (uint8_t[]){101, 120, 116, 101, 114, 110 }))) {
    struct token_Token t = (struct Token){ .kind = 54, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword_buf(data, data_len, start, 5, (uint8_t[]){97, 115, 121, 110, 99 }))) {
    struct token_Token t = (struct Token){ .kind = 55, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword_buf(data, data_len, start, 5, (uint8_t[]){97, 119, 97, 105, 116 }))) {
    struct token_Token t = (struct Token){ .kind = 56, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==3) && match_keyword_buf(data, data_len, start, 3, (uint8_t[]){114, 117, 110 }))) {
    struct token_Token t = (struct Token){ .kind = 57, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==5) && match_keyword_buf(data, data_len, start, 5, (uint8_t[]){115, 112, 97, 119, 110 }))) {
    struct token_Token t = (struct Token){ .kind = 58, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if (((len ==6) && match_keyword_buf(data, data_len, start, 6, (uint8_t[]){101, 120, 112, 111, 114, 116 }))) {
    struct token_Token t = (struct Token){ .kind = 131, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  if ((((len ==1) && (start < ((size_t)(data_len)))) && ((data)[start] ==95))) {
    struct token_Token t = (struct Token){ .kind = 52, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return t;
  }
  struct token_Token t = (struct Token){ .kind = 59, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = len };
  return t;
}
struct Lexer skip_repr_c_attr_if_present(struct Lexer lex, struct xlang_slice_uint8_t data) {
  struct Lexer l = lex;
  if ((((l.pos) + 10) > (data.length))) {
    return l;
  }
  if ((((data).data[(l.pos)] !=35) || ((data).data[((l.pos) + 1)] !=91))) {
    return l;
  }
  if ((((((data).data[((l.pos) + 2)] !=114) || ((data).data[((l.pos) + 3)] !=101)) || ((data).data[((l.pos) + 4)] !=112)) || ((data).data[((l.pos) + 5)] !=114))) {
    return l;
  }
  if ((((((data).data[((l.pos) + 6)] !=40) || ((data).data[((l.pos) + 7)] !=67)) || ((data).data[((l.pos) + 8)] !=41)) || ((data).data[((l.pos) + 9)] !=93))) {
    return l;
  }
  return (struct Lexer){ .pos = ((l.pos) + 10), .line = (l.line), .col = (l.col) };
}
struct Lexer skip_cfg_attr_if_present(struct Lexer lex, struct xlang_slice_uint8_t data) {
  struct Lexer l = lex;
  size_t p = 0;
  int32_t depth = 0;
  if ((((l.pos) + 6) > (data.length))) {
    return l;
  }
  if ((((data).data[(l.pos)] !=35) || ((data).data[((l.pos) + 1)] !=91))) {
    return l;
  }
  if (((((data).data[((l.pos) + 2)] !=99) || ((data).data[((l.pos) + 3)] !=102)) || ((data).data[((l.pos) + 4)] !=103))) {
    return l;
  }
  if (((data).data[((l.pos) + 5)] !=40)) {
    return l;
  }
  (void)((p = ((l.pos) + ((size_t)(6)))));
  (void)((depth = 1));
  while (((p < (data.length)) && (depth > 0))) {
    if (((data).data[p] ==40)) {
      (void)((depth = (depth + 1)));
    } else {
      if (((data).data[p] ==41)) {
        (void)((depth = (depth - 1)));
      }
    }
    (void)((p = (p + ((size_t)(1)))));
  }
  if (((p >=(data.length)) || ((data).data[p] !=93))) {
    return lex;
  }
  (void)((p = (p + ((size_t)(1)))));
  return (struct Lexer){ .pos = p, .line = (l.line), .col = (l.col) };
}
int32_t lexer_try_cfg_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data) {
  int32_t line0 = (l.line);
  int32_t col0 = (l.col);
  size_t p = 0;
  int32_t depth = 0;
  size_t expr_start = 0;
  if ((((l.pos) + 6) > (data.length))) {
    return 0;
  }
  if ((((data).data[(l.pos)] !=35) || ((data).data[((l.pos) + 1)] !=91))) {
    return 0;
  }
  if (((((data).data[((l.pos) + 2)] !=99) || ((data).data[((l.pos) + 3)] !=102)) || ((data).data[((l.pos) + 4)] !=103))) {
    return 0;
  }
  if (((data).data[((l.pos) + 5)] !=40)) {
    return 0;
  }
  (void)((p = ((l.pos) + ((size_t)(6)))));
  (void)((depth = 1));
  (void)((expr_start = p));
  while (((p < (data.length)) && (depth > 0))) {
    if (((data).data[p] ==40)) {
      (void)((depth = (depth + 1)));
    } else {
      if (((data).data[p] ==41)) {
        (void)((depth = (depth - 1)));
      }
    }
    (void)((p = (p + ((size_t)(1)))));
  }
  if (((p >=(data.length)) || ((data).data[p] !=93))) {
    return 0;
  }
  int32_t expr_len = ((((int32_t)(p)) - ((int32_t)(expr_start))) - 1);
  if (((expr_len <=0) || (expr_len > 127))) {
    return 0;
  }
  uint8_t tmp[128] = {};
  int32_t ti = 0;
  while ((ti < expr_len)) {
    (void)(((tmp)[ti] = (data).data[(expr_start + ((size_t)(ti)))]));
    (void)((ti = (ti + 1)));
  }
  int32_t enabled = 0;
  (void)((enabled = cfg_eval_expr_c(&((tmp)[0]), expr_len)));
  (void)((p = (p + ((size_t)(1)))));
  struct Lexer l2 = (struct Lexer){ .pos = p, .line = (l.line), .col = (l.col) };
  struct token_Token tok = (struct Token){ .kind = 24, .line = line0, .col = col0, .int_val = enabled, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  (void)(write_next_lex_into(out, l2));
  (void)(write_tok_into(out, tok));
  (void)(((out->token_start) = ((size_t)(0))));
  return 1;
}
int32_t lexer_try_repr_c_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data) {
  if ((((l.pos) + 10) > (data.length))) {
    return 0;
  }
  if ((((data).data[(l.pos)] !=35) || ((data).data[((l.pos) + 1)] !=91))) {
    return 0;
  }
  if ((((((data).data[((l.pos) + 2)] !=114) || ((data).data[((l.pos) + 3)] !=101)) || ((data).data[((l.pos) + 4)] !=112)) || ((data).data[((l.pos) + 5)] !=114))) {
    return 0;
  }
  if ((((((data).data[((l.pos) + 6)] !=40) || ((data).data[((l.pos) + 7)] !=67)) || ((data).data[((l.pos) + 8)] !=41)) || ((data).data[((l.pos) + 9)] !=93))) {
    return 0;
  }
  int32_t line0 = (l.line);
  int32_t col0 = (l.col);
  size_t np = ((l.pos) + ((size_t)(10)));
  struct Lexer l2 = (struct Lexer){ .pos = np, .line = line0, .col = col0 };
  struct token_Token tok = (struct Token){ .kind = 25, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  (void)(write_next_lex_into(out, l2));
  (void)(write_tok_into(out, tok));
  (void)(((out->token_start) = ((size_t)(0))));
  return 1;
}
int32_t lexer_try_repr_compatible_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data) {
  if ((((l.pos) + 19) > (data.length))) {
    return 0;
  }
  if ((((data).data[(l.pos)] !=35) || ((data).data[((l.pos) + 1)] !=91))) {
    return 0;
  }
  if ((((((data).data[((l.pos) + 2)] !=114) || ((data).data[((l.pos) + 3)] !=101)) || ((data).data[((l.pos) + 4)] !=112)) || ((data).data[((l.pos) + 5)] !=114))) {
    return 0;
  }
  if (((data).data[((l.pos) + 6)] !=40)) {
    return 0;
  }
  if ((((((((((((data).data[((l.pos) + 7)] !=99) || ((data).data[((l.pos) + 8)] !=111)) || ((data).data[((l.pos) + 9)] !=109)) || ((data).data[((l.pos) + 10)] !=112)) || ((data).data[((l.pos) + 11)] !=97)) || ((data).data[((l.pos) + 12)] !=116)) || ((data).data[((l.pos) + 13)] !=105)) || ((data).data[((l.pos) + 14)] !=98)) || ((data).data[((l.pos) + 15)] !=108)) || ((data).data[((l.pos) + 16)] !=101))) {
    return 0;
  }
  if ((((data).data[((l.pos) + 17)] !=41) || ((data).data[((l.pos) + 18)] !=93))) {
    return 0;
  }
  int32_t line0 = (l.line);
  int32_t col0 = (l.col);
  size_t np = ((l.pos) + ((size_t)(19)));
  struct Lexer l2 = (struct Lexer){ .pos = np, .line = line0, .col = col0 };
  struct token_Token tok = (struct Token){ .kind = 26, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  (void)(write_next_lex_into(out, l2));
  (void)(write_tok_into(out, tok));
  (void)(((out->token_start) = ((size_t)(0))));
  return 1;
}
int32_t lexer_try_soa_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data) {
  if ((((l.pos) + 6) > (data.length))) {
    return 0;
  }
  if ((((data).data[(l.pos)] !=35) || ((data).data[((l.pos) + 1)] !=91))) {
    return 0;
  }
  if ((((((data).data[((l.pos) + 2)] !=115) || ((data).data[((l.pos) + 3)] !=111)) || ((data).data[((l.pos) + 4)] !=97)) || ((data).data[((l.pos) + 5)] !=93))) {
    return 0;
  }
  int32_t line0 = (l.line);
  int32_t col0 = (l.col);
  struct Lexer l2 = l;
  (void)((l2 = advance_one(l2, 35)));
  (void)((l2 = advance_one(l2, 91)));
  (void)((l2 = advance_one(l2, 115)));
  (void)((l2 = advance_one(l2, 111)));
  (void)((l2 = advance_one(l2, 97)));
  (void)((l2 = advance_one(l2, 93)));
  struct token_Token tok = (struct Token){ .kind = 23, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  (void)(write_next_lex_into(out, l2));
  (void)(write_tok_into(out, tok));
  (void)(((out->token_start) = ((size_t)(0))));
  return 1;
}
int32_t lexer_try_alloc_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data) {
  if ((((l.pos) + 8) > (data.length))) {
    return 0;
  }
  if ((((data).data[(l.pos)] !=35) || ((data).data[((l.pos) + 1)] !=91))) {
    return 0;
  }
  if ((((((((data).data[((l.pos) + 2)] !=97) || ((data).data[((l.pos) + 3)] !=108)) || ((data).data[((l.pos) + 4)] !=108)) || ((data).data[((l.pos) + 5)] !=111)) || ((data).data[((l.pos) + 6)] !=99)) || ((data).data[((l.pos) + 7)] !=93))) {
    return 0;
  }
  int32_t line0 = (l.line);
  int32_t col0 = (l.col);
  struct Lexer l2 = l;
  (void)((l2 = advance_one(l2, 35)));
  (void)((l2 = advance_one(l2, 91)));
  (void)((l2 = advance_one(l2, 97)));
  (void)((l2 = advance_one(l2, 108)));
  (void)((l2 = advance_one(l2, 108)));
  (void)((l2 = advance_one(l2, 111)));
  (void)((l2 = advance_one(l2, 99)));
  (void)((l2 = advance_one(l2, 93)));
  struct token_Token tok = (struct Token){ .kind = 27, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  (void)(write_next_lex_into(out, l2));
  (void)(write_tok_into(out, tok));
  (void)(((out->token_start) = ((size_t)(0))));
  return 1;
}
int32_t lexer_try_used_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data) {
  if ((((l.pos) + 7) > (data.length))) {
    return 0;
  }
  if ((((data).data[(l.pos)] !=35) || ((data).data[((l.pos) + 1)] !=91))) {
    return 0;
  }
  if (((((((data).data[((l.pos) + 2)] !=117) || ((data).data[((l.pos) + 3)] !=115)) || ((data).data[((l.pos) + 4)] !=101)) || ((data).data[((l.pos) + 5)] !=100)) || ((data).data[((l.pos) + 6)] !=93))) {
    return 0;
  }
  int32_t line0 = (l.line);
  int32_t col0 = (l.col);
  struct Lexer l2 = l;
  (void)((l2 = advance_one(l2, 35)));
  (void)((l2 = advance_one(l2, 91)));
  (void)((l2 = advance_one(l2, 117)));
  (void)((l2 = advance_one(l2, 115)));
  (void)((l2 = advance_one(l2, 101)));
  (void)((l2 = advance_one(l2, 100)));
  (void)((l2 = advance_one(l2, 93)));
  struct token_Token tok = (struct Token){ .kind = 31, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  (void)(write_next_lex_into(out, l2));
  (void)(write_tok_into(out, tok));
  (void)(((out->token_start) = ((size_t)(0))));
  return 1;
}
int32_t lexer_try_naked_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data) {
  if ((((l.pos) + 8) > (data.length))) {
    return 0;
  }
  if ((((data).data[(l.pos)] !=35) || ((data).data[((l.pos) + 1)] !=91))) {
    return 0;
  }
  if ((((((((data).data[((l.pos) + 2)] !=110) || ((data).data[((l.pos) + 3)] !=97)) || ((data).data[((l.pos) + 4)] !=107)) || ((data).data[((l.pos) + 5)] !=101)) || ((data).data[((l.pos) + 6)] !=100)) || ((data).data[((l.pos) + 7)] !=93))) {
    return 0;
  }
  int32_t line0 = (l.line);
  int32_t col0 = (l.col);
  struct Lexer l2 = l;
  (void)((l2 = advance_one(l2, 35)));
  (void)((l2 = advance_one(l2, 91)));
  (void)((l2 = advance_one(l2, 110)));
  (void)((l2 = advance_one(l2, 97)));
  (void)((l2 = advance_one(l2, 107)));
  (void)((l2 = advance_one(l2, 101)));
  (void)((l2 = advance_one(l2, 100)));
  (void)((l2 = advance_one(l2, 93)));
  (void)(write_next_lex_into(out, l2));
  (void)(write_tok_into(out, (struct Token){ .kind = 29, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }));
  (void)(((out->token_start) = ((size_t)(0))));
  return 1;
}
int32_t lexer_try_entry_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data) {
  if ((((l.pos) + 8) > (data.length))) {
    return 0;
  }
  if ((((data).data[(l.pos)] !=35) || ((data).data[((l.pos) + 1)] !=91))) {
    return 0;
  }
  if ((((((((data).data[((l.pos) + 2)] !=101) || ((data).data[((l.pos) + 3)] !=110)) || ((data).data[((l.pos) + 4)] !=116)) || ((data).data[((l.pos) + 5)] !=114)) || ((data).data[((l.pos) + 6)] !=121)) || ((data).data[((l.pos) + 7)] !=93))) {
    return 0;
  }
  int32_t line0 = (l.line);
  int32_t col0 = (l.col);
  struct Lexer l2 = l;
  (void)((l2 = advance_one(l2, 35)));
  (void)((l2 = advance_one(l2, 91)));
  (void)((l2 = advance_one(l2, 101)));
  (void)((l2 = advance_one(l2, 110)));
  (void)((l2 = advance_one(l2, 116)));
  (void)((l2 = advance_one(l2, 114)));
  (void)((l2 = advance_one(l2, 101)));
  (void)((l2 = advance_one(l2, 93)));
  (void)(write_next_lex_into(out, l2));
  (void)(write_tok_into(out, (struct Token){ .kind = 30, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }));
  (void)(((out->token_start) = ((size_t)(0))));
  return 1;
}
int32_t lexer_try_no_mangle_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data) {
  if ((((l.pos) + 12) > (data.length))) {
    return 0;
  }
  if ((((data).data[(l.pos)] !=35) || ((data).data[((l.pos) + 1)] !=91))) {
    return 0;
  }
  if ((((((((((((data).data[((l.pos) + 2)] !=110) || ((data).data[((l.pos) + 3)] !=111)) || ((data).data[((l.pos) + 4)] !=95)) || ((data).data[((l.pos) + 5)] !=109)) || ((data).data[((l.pos) + 6)] !=97)) || ((data).data[((l.pos) + 7)] !=110)) || ((data).data[((l.pos) + 8)] !=103)) || ((data).data[((l.pos) + 9)] !=108)) || ((data).data[((l.pos) + 10)] !=101)) || ((data).data[((l.pos) + 11)] !=93))) {
    return 0;
  }
  int32_t line0 = (l.line);
  int32_t col0 = (l.col);
  struct Lexer l2 = l;
  (void)((l2 = advance_one(l2, 35)));
  (void)((l2 = advance_one(l2, 91)));
  (void)((l2 = advance_one(l2, 110)));
  (void)((l2 = advance_one(l2, 111)));
  (void)((l2 = advance_one(l2, 95)));
  (void)((l2 = advance_one(l2, 109)));
  (void)((l2 = advance_one(l2, 97)));
  (void)((l2 = advance_one(l2, 110)));
  (void)((l2 = advance_one(l2, 103)));
  (void)((l2 = advance_one(l2, 108)));
  (void)((l2 = advance_one(l2, 101)));
  (void)((l2 = advance_one(l2, 93)));
  (void)(write_next_lex_into(out, l2));
  (void)(write_tok_into(out, (struct Token){ .kind = 32, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }));
  (void)(((out->token_start) = ((size_t)(0))));
  return 1;
}
int32_t lexer_try_interrupt_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data) {
  if ((((l.pos) + 13) > (data.length))) {
    return 0;
  }
  if ((((data).data[(l.pos)] !=35) || ((data).data[((l.pos) + 1)] !=91))) {
    return 0;
  }
  if ((((((((((((data).data[((l.pos) + 2)] !=105) || ((data).data[((l.pos) + 3)] !=110)) || ((data).data[((l.pos) + 4)] !=116)) || ((data).data[((l.pos) + 5)] !=101)) || ((data).data[((l.pos) + 6)] !=114)) || ((data).data[((l.pos) + 7)] !=114)) || ((data).data[((l.pos) + 8)] !=117)) || ((data).data[((l.pos) + 9)] !=112)) || ((data).data[((l.pos) + 10)] !=116)) || ((data).data[((l.pos) + 11)] !=93))) {
    return 0;
  }
  int32_t line0 = (l.line);
  int32_t col0 = (l.col);
  struct Lexer l2 = l;
  (void)((l2 = advance_one(l2, 35)));
  (void)((l2 = advance_one(l2, 91)));
  (void)((l2 = advance_one(l2, 105)));
  (void)((l2 = advance_one(l2, 110)));
  (void)((l2 = advance_one(l2, 116)));
  (void)((l2 = advance_one(l2, 101)));
  (void)((l2 = advance_one(l2, 114)));
  (void)((l2 = advance_one(l2, 114)));
  (void)((l2 = advance_one(l2, 117)));
  (void)((l2 = advance_one(l2, 112)));
  (void)((l2 = advance_one(l2, 116)));
  (void)((l2 = advance_one(l2, 93)));
  (void)(write_next_lex_into(out, l2));
  (void)(write_tok_into(out, (struct Token){ .kind = 35, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }));
  (void)(((out->token_start) = ((size_t)(0))));
  return 1;
}
int32_t lexer_try_send_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data) {
  if ((((l.pos) + 8) > (data.length))) {
    return 0;
  }
  if ((((data).data[(l.pos)] !=35) || ((data).data[((l.pos) + 1)] !=91))) {
    return 0;
  }
  if (((((((data).data[((l.pos) + 2)] !=115) || ((data).data[((l.pos) + 3)] !=101)) || ((data).data[((l.pos) + 4)] !=110)) || ((data).data[((l.pos) + 5)] !=100)) || ((data).data[((l.pos) + 6)] !=93))) {
    return 0;
  }
  int32_t line0 = (l.line);
  int32_t col0 = (l.col);
  struct Lexer l2 = l;
  (void)((l2 = advance_one(l2, 35)));
  (void)((l2 = advance_one(l2, 91)));
  (void)((l2 = advance_one(l2, 115)));
  (void)((l2 = advance_one(l2, 101)));
  (void)((l2 = advance_one(l2, 110)));
  (void)((l2 = advance_one(l2, 100)));
  (void)((l2 = advance_one(l2, 93)));
  (void)(write_next_lex_into(out, l2));
  (void)(write_tok_into(out, (struct Token){ .kind = 36, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }));
  (void)(((out->token_start) = ((size_t)(0))));
  return 1;
}
int32_t lexer_try_sync_attr_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data) {
  if ((((l.pos) + 8) > (data.length))) {
    return 0;
  }
  if ((((data).data[(l.pos)] !=35) || ((data).data[((l.pos) + 1)] !=91))) {
    return 0;
  }
  if (((((((data).data[((l.pos) + 2)] !=115) || ((data).data[((l.pos) + 3)] !=121)) || ((data).data[((l.pos) + 4)] !=110)) || ((data).data[((l.pos) + 5)] !=99)) || ((data).data[((l.pos) + 6)] !=93))) {
    return 0;
  }
  int32_t line0 = (l.line);
  int32_t col0 = (l.col);
  struct Lexer l2 = l;
  (void)((l2 = advance_one(l2, 35)));
  (void)((l2 = advance_one(l2, 91)));
  (void)((l2 = advance_one(l2, 115)));
  (void)((l2 = advance_one(l2, 121)));
  (void)((l2 = advance_one(l2, 110)));
  (void)((l2 = advance_one(l2, 99)));
  (void)((l2 = advance_one(l2, 93)));
  (void)(write_next_lex_into(out, l2));
  (void)(write_tok_into(out, (struct Token){ .kind = 37, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }));
  (void)(((out->token_start) = ((size_t)(0))));
  return 1;
}
/* PLATFORM: SHARED — nested block comments; path-safe nest-open; lockstep with lexer.x.
 * wave269: EOF depth>0 → L001 unclosed block comment hard diag + sticky pending. */
static int lexer_block_comment_prev_is_path_like(uint8_t prev) {
  if (prev >= 65 && prev <= 90)
    return 1;
  if (prev >= 97 && prev <= 122)
    return 1;
  if (prev >= 48 && prev <= 57)
    return 1;
  if (prev == 95 || prev == 46 || prev == 125 || prev == 41 || prev == 93 || prev == 62
      || prev == 34 || prev == 39)
    return 1;
  return 0;
}
/* wave269 Cap residual: sticky unclosed block-comment state (≡ lexer.x). */
static int32_t g_lexer_unclosed_bc = 0;
static int32_t g_lexer_unclosed_line = 0;
static int32_t g_lexer_unclosed_col = 0;
static int32_t g_lexer_unclosed_reported = 0;
/* wave271 Cap residual: sticky unclosed string state (≡ lexer.x). */
static int32_t g_lexer_unclosed_str = 0;
static int32_t g_lexer_unclosed_str_line = 0;
static int32_t g_lexer_unclosed_str_col = 0;
static int32_t g_lexer_unclosed_str_reported = 0;
void lexer_unclosed_block_comment_reset(void) {
  g_lexer_unclosed_bc = 0;
  g_lexer_unclosed_line = 0;
  g_lexer_unclosed_col = 0;
  g_lexer_unclosed_reported = 0;
}
int32_t lexer_unclosed_block_comment_pending(void) {
  return g_lexer_unclosed_bc;
}
void lexer_unclosed_string_reset(void) {
  g_lexer_unclosed_str = 0;
  g_lexer_unclosed_str_line = 0;
  g_lexer_unclosed_str_col = 0;
  g_lexer_unclosed_str_reported = 0;
}
int32_t lexer_unclosed_string_pending(void) {
  return g_lexer_unclosed_str;
}
static void lexer_note_unclosed_block_comment(int32_t line, int32_t col) {
  if (g_lexer_unclosed_bc == 0) {
    g_lexer_unclosed_bc = 1;
    g_lexer_unclosed_line = line;
    g_lexer_unclosed_col = col;
  }
  if (g_lexer_unclosed_reported != 0)
    return;
  g_lexer_unclosed_reported = 1;
  {
    char kind[16];
    char code[8];
    char msg[32];
    kind[0] = 'l'; kind[1] = 'e'; kind[2] = 'x'; kind[3] = 'e'; kind[4] = 'r';
    kind[5] = ' '; kind[6] = 'e'; kind[7] = 'r'; kind[8] = 'r'; kind[9] = 'o';
    kind[10] = 'r'; kind[11] = 0;
    code[0] = 'L'; code[1] = '0'; code[2] = '0'; code[3] = '1'; code[4] = 0;
    msg[0] = 'u'; msg[1] = 'n'; msg[2] = 'c'; msg[3] = 'l'; msg[4] = 'o';
    msg[5] = 's'; msg[6] = 'e'; msg[7] = 'd'; msg[8] = ' '; msg[9] = 'b';
    msg[10] = 'l'; msg[11] = 'o'; msg[12] = 'c'; msg[13] = 'k'; msg[14] = ' ';
    msg[15] = 'c'; msg[16] = 'o'; msg[17] = 'm'; msg[18] = 'm'; msg[19] = 'e';
    msg[20] = 'n'; msg[21] = 't'; msg[22] = 0;
    diag_report_with_code(NULL, g_lexer_unclosed_line, g_lexer_unclosed_col,
                          kind, code, msg, NULL);
  }
}
static void lexer_note_unclosed_string(int32_t line, int32_t col) {
  if (g_lexer_unclosed_str == 0) {
    g_lexer_unclosed_str = 1;
    g_lexer_unclosed_str_line = line;
    g_lexer_unclosed_str_col = col;
  }
  if (g_lexer_unclosed_str_reported != 0)
    return;
  g_lexer_unclosed_str_reported = 1;
  {
    char kind[16];
    char code[8];
    char msg[32];
    kind[0] = 'l'; kind[1] = 'e'; kind[2] = 'x'; kind[3] = 'e'; kind[4] = 'r';
    kind[5] = ' '; kind[6] = 'e'; kind[7] = 'r'; kind[8] = 'r'; kind[9] = 'o';
    kind[10] = 'r'; kind[11] = 0;
    code[0] = 'L'; code[1] = '0'; code[2] = '0'; code[3] = '2'; code[4] = 0;
    msg[0] = 'u'; msg[1] = 'n'; msg[2] = 'c'; msg[3] = 'l'; msg[4] = 'o';
    msg[5] = 's'; msg[6] = 'e'; msg[7] = 'd'; msg[8] = ' '; msg[9] = 's';
    msg[10] = 't'; msg[11] = 'r'; msg[12] = 'i'; msg[13] = 'n'; msg[14] = 'g';
    msg[15] = ' '; msg[16] = 'l'; msg[17] = 'i'; msg[18] = 't'; msg[19] = 'e';
    msg[20] = 'r'; msg[21] = 'a'; msg[22] = 'l'; msg[23] = 0;
    diag_report_with_code(NULL, g_lexer_unclosed_str_line, g_lexer_unclosed_str_col,
                          kind, code, msg, NULL);
  }
}
struct Lexer skip_whitespace_and_comments(struct Lexer lex, struct xlang_slice_uint8_t data) {
  struct Lexer l = lex;
  int32_t depth = 0;
  while (((l.pos) < (data.length))) {
    uint8_t c = (data).data[(l.pos)];
    if (((((c ==32) || (c ==9)) || (c ==10)) || (c ==13))) {
      (void)((l = advance_one(l, c)));
    } else {
      if ((((c ==47) && (((l.pos) + 1) < (data.length))) && ((data).data[((l.pos) + 1)] ==47))) {
        while ((((l.pos) < (data.length)) && ((data).data[(l.pos)] !=10))) {
          (void)((l = advance_one(l, (data).data[(l.pos)])));
        }
      } else {
        if ((((c ==47) && (((l.pos) + 1) < (data.length))) && ((data).data[((l.pos) + 1)] ==42))) {
          int32_t open_line = l.line;
          int32_t open_col = l.col;
          (void)((l = advance_one(l, 47)));
          (void)((l = advance_one(l, 42)));
          depth = 1;
          while ((((l.pos) < (data.length)) && (depth > 0))) {
            if (((((l.pos) + 1) < (data.length)) && ((data).data[(l.pos)] ==47) && ((data).data[((l.pos) + 1)] ==42))) {
              int nest_ok = 1;
              if ((l.pos) > 0) {
                uint8_t prev = (data).data[((l.pos) - 1)];
                if (lexer_block_comment_prev_is_path_like(prev))
                  nest_ok = 0;
              }
              if (nest_ok && (((l.pos) + 2) < (data.length)) && ((data).data[((l.pos) + 2)] ==46))
                nest_ok = 0;
              if (nest_ok) {
                (void)((l = advance_one(l, 47)));
                (void)((l = advance_one(l, 42)));
                depth = depth + 1;
              } else {
                (void)((l = advance_one(l, (data).data[(l.pos)])));
              }
            } else if (((((l.pos) + 1) < (data.length)) && ((data).data[(l.pos)] ==42) && ((data).data[((l.pos) + 1)] ==47))) {
              (void)((l = advance_one(l, 42)));
              (void)((l = advance_one(l, 47)));
              depth = depth - 1;
            } else {
              (void)((l = advance_one(l, (data).data[(l.pos)])));
            }
          }
          if (depth > 0)
            lexer_note_unclosed_block_comment(open_line, open_col);
          depth = 0;
        } else {
          if ((c ==35)) {
            if (((((l.pos) + 1) < (data.length)) && ((data).data[((l.pos) + 1)] ==91))) {
              return l;
            } else {
              while ((((l.pos) < (data.length)) && ((data).data[(l.pos)] !=10))) {
                (void)((l = advance_one(l, (data).data[(l.pos)])));
              }
            }
          } else {
            return l;
          }
        }
      }
    }
  }
  return l;
}
struct Lexer skip_whitespace_and_comments_buf(struct Lexer lex, uint8_t * data, int32_t len) {
  return skip_whitespace_and_comments(lex, lexer_parser_slice_from_buf(data, len));
  return lex;
}
struct LexerResult lexer_next(struct Lexer lex, struct xlang_slice_uint8_t data) {
  struct Lexer l = skip_whitespace_and_comments(lex, data);
  if (((l.pos) >=(data.length))) {
    struct token_Token t = (struct Token){ .kind = 0, .line = (l.line), .col = (l.col), .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return (struct LexerResult){ .next_lex = l, .tok = t, .token_start = ((size_t)(0)) };
  }
  if (((data).data[(l.pos)] ==0)) {
    struct token_Token t = (struct Token){ .kind = 0, .line = (l.line), .col = (l.col), .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    return (struct LexerResult){ .next_lex = l, .tok = t, .token_start = ((size_t)(0)) };
  }
  struct LexerResult attr_out = (struct LexerResult){ .next_lex = l, .tok = (struct Token){ .kind = 0, .line = (l.line), .col = (l.col), .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = ((size_t)(0)) };
  if ((lexer_try_cfg_attr_into(&(attr_out), l, data) !=0)) {
    return attr_out;
  }
  if ((lexer_try_repr_c_attr_into(&(attr_out), l, data) !=0)) {
    return attr_out;
  }
  if ((lexer_try_repr_compatible_attr_into(&(attr_out), l, data) !=0)) {
    return attr_out;
  }
  if ((lexer_try_soa_attr_into(&(attr_out), l, data) !=0)) {
    return attr_out;
  }
  if ((lexer_try_alloc_attr_into(&(attr_out), l, data) !=0)) {
    return attr_out;
  }
  if ((lexer_try_used_attr_into(&(attr_out), l, data) !=0)) {
    return attr_out;
  }
  if ((lexer_try_naked_attr_into(&(attr_out), l, data) !=0)) {
    return attr_out;
  }
  if ((lexer_try_entry_attr_into(&(attr_out), l, data) !=0)) {
    return attr_out;
  }
  if ((lexer_try_no_mangle_attr_into(&(attr_out), l, data) !=0)) {
    return attr_out;
  }
  if ((lexer_try_interrupt_attr_into(&(attr_out), l, data) !=0)) {
    return attr_out;
  }
  if ((lexer_try_send_attr_into(&(attr_out), l, data) !=0)) {
    return attr_out;
  }
  if ((lexer_try_sync_attr_into(&(attr_out), l, data) !=0)) {
    return attr_out;
  }
  (void)(lexer_next_body_into(&(attr_out), l, data));
  return attr_out;
}
void lexer_apply_optional_exponent(struct Lexer l, struct xlang_slice_uint8_t data, double fval, struct Lexer * out_l, double * out_f) {
  struct Lexer lex = l;
  double cur = fval;
  if ((((lex.pos) < (data.length)) && (((data).data[(lex.pos)] ==101) || ((data).data[(lex.pos)] ==69)))) {
    int32_t exp_sign = 1;
    int32_t exp = 0;
    double scale = 0.0;
    int32_t e = 0;
    (void)((lex = advance_one(lex, (data).data[(lex.pos)])));
    if ((((lex.pos) < (data.length)) && ((data).data[(lex.pos)] ==45))) {
      (void)((exp_sign = -(1)));
      (void)((lex = advance_one(lex, 45)));
    } else {
      if ((((lex.pos) < (data.length)) && ((data).data[(lex.pos)] ==43))) {
        (void)((lex = advance_one(lex, 43)));
      }
    }
    while ((((lex.pos) < (data.length)) && is_digit((data).data[(lex.pos)]))) {
      uint8_t d = (data).data[(lex.pos)];
      (void)((lex = advance_one(lex, d)));
      (void)((exp = ((exp * 10) + (d - 48))));
    }
    (void)((exp = (exp * exp_sign)));
    if ((exp > 0)) {
      while ((e < exp)) {
        (void)((scale = (scale * 0.0)));
        (void)((e = (e + 1)));
      }
    } else {
      while ((e > exp)) {
        (void)((scale = (scale * 0.0)));
        (void)((e = (e - 1)));
      }
    }
    (void)((cur = (fval * scale)));
  }
  (void)(((out_l)[0] = lex));
  (void)(((out_f)[0] = cur));
}
void lexer_next_body_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data) {
  uint8_t c = (data).data[(l.pos)];
  if ((lexer_try_cfg_attr_into(out, l, data) !=0)) {
    return;
  }
  if ((lexer_try_repr_c_attr_into(out, l, data) !=0)) {
    return;
  }
  if ((lexer_try_repr_compatible_attr_into(out, l, data) !=0)) {
    return;
  }
  if ((lexer_try_soa_attr_into(out, l, data) !=0)) {
    return;
  }
  if ((lexer_try_alloc_attr_into(out, l, data) !=0)) {
    return;
  }
  if ((lexer_try_used_attr_into(out, l, data) !=0)) {
    return;
  }
  if ((lexer_try_naked_attr_into(out, l, data) !=0)) {
    return;
  }
  if ((lexer_try_entry_attr_into(out, l, data) !=0)) {
    return;
  }
  if ((lexer_try_no_mangle_attr_into(out, l, data) !=0)) {
    return;
  }
  if ((lexer_try_interrupt_attr_into(out, l, data) !=0)) {
    return;
  }
  if ((lexer_try_send_attr_into(out, l, data) !=0)) {
    return;
  }
  if ((lexer_try_sync_attr_into(out, l, data) !=0)) {
    return;
  }
  if ((c ==34)) {
    int32_t line0 = (l.line);
    int32_t col0 = (l.col);
    size_t start = ((l.pos) + ((size_t)(1)));
    (void)((l = advance_one(l, 34)));
    while ((((l.pos) < (data.length)) && ((data).data[(l.pos)] !=34))) {
      if ((((data).data[(l.pos)] ==92) && (((l.pos) + 1) < (data.length)))) {
        (void)((l = advance_one(l, (data).data[(l.pos)])));
        (void)((l = advance_one(l, (data).data[(l.pos)])));
      } else {
        (void)((l = advance_one(l, (data).data[(l.pos)])));
      }
    }
    if (((l.pos) >=(data.length))) {
      /* wave271: unclosed string at EOF → L002 hard diag + sticky pending. */
      lexer_note_unclosed_string(line0, col0);
      struct token_Token tok_eof = (struct Token){ .kind = 0, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
      (void)(write_next_lex_into(out, l));
      (void)(write_tok_into(out, tok_eof));
      (void)(((out->token_start) = start));
      return;
    }
    int32_t slen = ((int32_t)(((l.pos) - start)));
    (void)((l = advance_one(l, 34)));
    struct token_Token tok_str = (struct Token){ .kind = 130, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = slen };
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok_str));
    (void)(((out->token_start) = start));
    return;
  }
  if (is_alpha(c)) {
    size_t start = (l.pos);
    int32_t line0 = (l.line);
    int32_t col0 = (l.col);
    (void)((l = advance_one(l, c)));
    while ((((l.pos) < (data.length)) && is_alnum_underscore((data).data[(l.pos)]))) {
      (void)((l = advance_one(l, (data).data[(l.pos)])));
    }
    size_t len = ((l.pos) - start);
    struct token_Token tok = try_keyword(data, start, len, line0, col0);
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if (is_digit(c)) {
    size_t start = (l.pos);
    int32_t line0 = (l.line);
    int32_t col0 = (l.col);
    int64_t ival = 0;
    (void)((l = advance_one(l, c)));
    if ((((c ==48) && ((l.pos) < (data.length))) && (((data).data[(l.pos)] ==120) || ((data).data[(l.pos)] ==88)))) {
      uint64_t hval = ((uint64_t)(0));
      struct token_Token tok = (struct Token){ .kind = 80, .line = line0, .col = col0, .int_val = ((int64_t)(hval)), .float_val = 0.0, .ident = 0, .ident_len = 0 };
      (void)((l = advance_one(l, (data).data[(l.pos)])));
      while ((((l.pos) < (data.length)) && is_hex_digit((data).data[(l.pos)]))) {
        uint8_t hd = (data).data[(l.pos)];
        (void)((hval = ((hval * 16) + ((uint64_t)(hex_digit_value(hd))))));
        (void)((l = advance_one(l, hd)));
      }
      (void)(write_next_lex_into(out, l));
      (void)(write_tok_into(out, tok));
      (void)(((out->token_start) = start));
      return;
    }
    (void)((ival = ((ival * 10) + (c - 48))));
    while ((((l.pos) < (data.length)) && is_digit((data).data[(l.pos)]))) {
      uint8_t d = (data).data[(l.pos)];
      (void)((l = advance_one(l, d)));
      (void)((ival = ((ival * 10) + (d - 48))));
    }
    if ((((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==46)) && (((l.pos) + 1) < (data.length))) && is_digit((data).data[((l.pos) + 1)]))) {
      double fval = ((double)(ival));
      double frac = 0.0;
      struct token_Token tok = (struct Token){ .kind = 81, .line = line0, .col = col0, .int_val = 0, .float_val = fval, .ident = 0, .ident_len = 0 };
      (void)((l = advance_one(l, 46)));
      while ((((l.pos) < (data.length)) && is_digit((data).data[(l.pos)]))) {
        uint8_t d = (data).data[(l.pos)];
        (void)((l = advance_one(l, d)));
        (void)((fval = (fval + (frac * (d - 48)))));
        (void)((frac = (frac * 0.0)));
      }
      (void)(lexer_apply_optional_exponent(l, data, fval, &(l), &(fval)));
      (void)(write_next_lex_into(out, l));
      (void)(write_tok_into(out, tok));
      (void)(((out->token_start) = start));
      return;
    }
    if ((((l.pos) < (data.length)) && (((data).data[(l.pos)] ==101) || ((data).data[(l.pos)] ==69)))) {
      int32_t exp_sign = 1;
      int32_t exp = 0;
      double scale = 0.0;
      int32_t e = 0;
      double fval = (((double)(ival)) * scale);
      struct token_Token tok = (struct Token){ .kind = 81, .line = line0, .col = col0, .int_val = 0, .float_val = fval, .ident = 0, .ident_len = 0 };
      (void)((l = advance_one(l, (data).data[(l.pos)])));
      if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==45))) {
        (void)((exp_sign = -(1)));
        (void)((l = advance_one(l, 45)));
      } else {
        if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==43))) {
          (void)((l = advance_one(l, 43)));
        }
      }
      while ((((l.pos) < (data.length)) && is_digit((data).data[(l.pos)]))) {
        uint8_t d = (data).data[(l.pos)];
        (void)((l = advance_one(l, d)));
        (void)((exp = ((exp * 10) + (d - 48))));
      }
      (void)((exp = (exp * exp_sign)));
      if ((exp > 0)) {
        while ((e < exp)) {
          (void)((scale = (scale * 0.0)));
          (void)((e = (e + 1)));
        }
      } else {
        while ((e > exp)) {
          (void)((scale = (scale * 0.0)));
          (void)((e = (e - 1)));
        }
      }
      (void)(write_next_lex_into(out, l));
      (void)(write_tok_into(out, tok));
      (void)(((out->token_start) = start));
      return;
    }
    struct token_Token tok = (struct Token){ .kind = 80, .line = line0, .col = col0, .int_val = ival, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((((c ==46) && (((l.pos) + 1) < (data.length))) && is_digit((data).data[((l.pos) + 1)]))) {
    size_t start = (l.pos);
    int32_t line0 = (l.line);
    int32_t col0 = (l.col);
    (void)((l = advance_one(l, 46)));
    double fval = 0.0;
    double frac = 0.0;
    while ((((l.pos) < (data.length)) && is_digit((data).data[(l.pos)]))) {
      uint8_t d = (data).data[(l.pos)];
      (void)((l = advance_one(l, d)));
      (void)((fval = (fval + (frac * (d - 48)))));
      (void)((frac = (frac * 0.0)));
    }
    (void)(lexer_apply_optional_exponent(l, data, fval, &(l), &(fval)));
    struct token_Token tok = (struct Token){ .kind = 81, .line = line0, .col = col0, .int_val = 0, .float_val = fval, .ident = 0, .ident_len = 0 };
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  (void)(lexer_next_punct_into(out, l, data, c));
}
void lexer_next_punct_into(struct LexerResult * out, struct Lexer l, struct xlang_slice_uint8_t data, uint8_t c) {
  size_t start = (l.pos);
  int32_t line0 = (l.line);
  int32_t col0 = (l.col);
  (void)((l = advance_one(l, c)));
  struct token_Token tok = (struct Token){ .kind = 0, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  if ((c ==40)) {
    (void)(((tok.kind) = 82));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==41)) {
    (void)(((tok.kind) = 83));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==123)) {
    (void)(((tok.kind) = 84));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==125)) {
    (void)(((tok.kind) = 85));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==91)) {
    (void)(((tok.kind) = 86));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==93)) {
    (void)(((tok.kind) = 87));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==44)) {
    (void)(((tok.kind) = 90));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==58)) {
    (void)(((tok.kind) = 91));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==46)) {
    if ((((((l.pos) + 1) < (data.length)) && ((data).data[(l.pos)] ==46)) && ((data).data[((l.pos) + 1)] ==46))) {
      (void)((l = advance_one(l, 46)));
      (void)((l = advance_one(l, 46)));
      (void)(((tok.kind) = 94));
    } else {
      (void)(((tok.kind) = 92));
    }
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==59)) {
    (void)(((tok.kind) = 95));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==43)) {
    if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==61))) {
      (void)((l = advance_one(l, 61)));
      (void)(((tok.kind) = 106));
    } else {
      (void)(((tok.kind) = 96));
    }
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==45)) {
    if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==62))) {
      (void)((l = advance_one(l, 62)));
      (void)(((tok.kind) = 88));
      (void)(write_next_lex_into(out, l));
      (void)(write_tok_into(out, tok));
      (void)(((out->token_start) = start));
      return;
    }
    if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==61))) {
      (void)((l = advance_one(l, 61)));
      (void)(((tok.kind) = 107));
      (void)(write_next_lex_into(out, l));
      (void)(write_tok_into(out, tok));
      (void)(((out->token_start) = start));
      return;
    }
    (void)(((tok.kind) = 97));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==42)) {
    if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==61))) {
      (void)((l = advance_one(l, 61)));
      (void)(((tok.kind) = 108));
    } else {
      (void)(((tok.kind) = 98));
    }
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==47)) {
    if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==61))) {
      (void)((l = advance_one(l, 61)));
      (void)(((tok.kind) = 109));
    } else {
      (void)(((tok.kind) = 99));
    }
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==37)) {
    if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==61))) {
      (void)((l = advance_one(l, 61)));
      (void)(((tok.kind) = 110));
    } else {
      (void)(((tok.kind) = 100));
    }
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==94)) {
    if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==61))) {
      (void)((l = advance_one(l, 61)));
      (void)(((tok.kind) = 113));
    } else {
      (void)(((tok.kind) = 103));
    }
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==126)) {
    (void)(((tok.kind) = 116));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==38)) {
    if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==38))) {
      (void)((l = advance_one(l, 38)));
      (void)(((tok.kind) = 124));
      (void)(write_next_lex_into(out, l));
      (void)(write_tok_into(out, tok));
      (void)(((out->token_start) = start));
      return;
    }
    if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==61))) {
      (void)((l = advance_one(l, 61)));
      (void)(((tok.kind) = 111));
      (void)(write_next_lex_into(out, l));
      (void)(write_tok_into(out, tok));
      (void)(((out->token_start) = start));
      return;
    }
    (void)(((tok.kind) = 101));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==124)) {
    if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==124))) {
      (void)((l = advance_one(l, 124)));
      (void)(((tok.kind) = 125));
      (void)(write_next_lex_into(out, l));
      (void)(write_tok_into(out, tok));
      (void)(((out->token_start) = start));
      return;
    }
    if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==61))) {
      (void)((l = advance_one(l, 61)));
      (void)(((tok.kind) = 112));
      (void)(write_next_lex_into(out, l));
      (void)(write_tok_into(out, tok));
      (void)(((out->token_start) = start));
      return;
    }
    (void)(((tok.kind) = 102));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==60)) {
    if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==61))) {
      (void)((l = advance_one(l, 61)));
      (void)(((tok.kind) = 122));
      (void)(write_next_lex_into(out, l));
      (void)(write_tok_into(out, tok));
      (void)(((out->token_start) = start));
      return;
    }
    if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==60))) {
      (void)((l = advance_one(l, 60)));
      if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==61))) {
        (void)((l = advance_one(l, 61)));
        (void)(((tok.kind) = 114));
      } else {
        (void)(((tok.kind) = 104));
      }
      (void)(write_next_lex_into(out, l));
      (void)(write_tok_into(out, tok));
      (void)(((out->token_start) = start));
      return;
    }
    (void)(((tok.kind) = 120));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==62)) {
    if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==61))) {
      (void)((l = advance_one(l, 61)));
      (void)(((tok.kind) = 123));
      (void)(write_next_lex_into(out, l));
      (void)(write_tok_into(out, tok));
      (void)(((out->token_start) = start));
      return;
    }
    if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==62))) {
      (void)((l = advance_one(l, 62)));
      if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==61))) {
        (void)((l = advance_one(l, 61)));
        (void)(((tok.kind) = 115));
      } else {
        (void)(((tok.kind) = 105));
      }
      (void)(write_next_lex_into(out, l));
      (void)(write_tok_into(out, tok));
      (void)(((out->token_start) = start));
      return;
    }
    (void)(((tok.kind) = 121));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==33)) {
    if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==61))) {
      (void)((l = advance_one(l, 61)));
      (void)(((tok.kind) = 119));
      (void)(write_next_lex_into(out, l));
      (void)(write_tok_into(out, tok));
      (void)(((out->token_start) = start));
      return;
    }
    (void)(((tok.kind) = 126));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==63)) {
    (void)(((tok.kind) = 127));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==64)) {
    (void)(((tok.kind) = 129));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  if ((c ==61)) {
    if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==62))) {
      (void)((l = advance_one(l, 62)));
      (void)(((tok.kind) = 89));
      (void)(write_next_lex_into(out, l));
      (void)(write_tok_into(out, tok));
      (void)(((out->token_start) = start));
      return;
    }
    if ((((l.pos) < (data.length)) && ((data).data[(l.pos)] ==61))) {
      (void)((l = advance_one(l, 61)));
      (void)(((tok.kind) = 118));
      (void)(write_next_lex_into(out, l));
      (void)(write_tok_into(out, tok));
      (void)(((out->token_start) = start));
      return;
    }
    (void)(((tok.kind) = 117));
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, tok));
    (void)(((out->token_start) = start));
    return;
  }
  struct token_Token unk = (struct Token){ .kind = 0, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  (void)(write_next_lex_into(out, l));
  (void)(write_tok_into(out, unk));
  (void)(((out->token_start) = start));
}
void write_next_lex_into(struct LexerResult * out, struct Lexer l) {
  (void)((((out->next_lex).pos) = (l.pos)));
  (void)((((out->next_lex).line) = (l.line)));
  (void)((((out->next_lex).col) = (l.col)));
  (void)(((out->token_start) = ((size_t)(0))));
}
void write_tok_into(struct LexerResult * out, struct token_Token t) {
  (void)((((out->tok).kind) = (t.kind)));
  (void)((((out->tok).line) = (t.line)));
  (void)((((out->tok).col) = (t.col)));
  (void)((((out->tok).int_val) = (t.int_val)));
  (void)((((out->tok).float_val) = (t.float_val)));
  (void)((((out->tok).ident) = (t.ident)));
  (void)((((out->tok).ident_len) = (t.ident_len)));
}
void lexer_next_impl(struct LexerResult * out, struct Lexer lex, struct xlang_slice_uint8_t data) {
  struct Lexer l = skip_whitespace_and_comments(lex, data);
  if (((l.pos) >=(data.length))) {
    struct token_Token t = (struct Token){ .kind = 0, .line = (l.line), .col = (l.col), .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, t));
    return;
  }
  if (((data).data[(l.pos)] ==0)) {
    struct token_Token t = (struct Token){ .kind = 0, .line = (l.line), .col = (l.col), .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
    (void)(write_next_lex_into(out, l));
    (void)(write_tok_into(out, t));
    return;
  }
  (void)(lexer_next_body_into(out, l, data));
}
void lexer_next_into(struct LexerResult * out, struct Lexer lex, struct xlang_slice_uint8_t data) {
  (void)(lexer_next_impl(out, lex, data));
}
void lexer_next_buf_into(struct LexerResult * out, struct Lexer lex, uint8_t * data, int32_t len) {
  (void)(lexer_next_into(out, lex, lexer_parser_slice_from_buf(data, len)));
  (void)(0);
  return;
}
struct LexerResult lexer_next_buf(struct Lexer lex, uint8_t * data, int32_t len) {
  return lexer_next(lex, lexer_parser_slice_from_buf(data, len));
  return 0;
}
int32_t main(void) {
  init_globals();
  uint8_t src[32] = {108, 101, 116, 32, 120, 32, 61, 32, 49, 59, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  struct xlang_slice_uint8_t sl = (uint8_t[]){ };
  (void)((sl = lexer_parser_slice_from_buf(&((src)[0]), 11)));
  struct Lexer lex = lexer_init();
  struct LexerResult r = lexer_next(lex, sl);
  if ((((r.tok).kind) !=2)) {
    return 1;
  }
  (void)((lex = (r.next_lex)));
  (void)((r = lexer_next(lex, sl)));
  if ((((r.tok).kind) !=59)) {
    return 2;
  }
  (void)((lex = (r.next_lex)));
  (void)((r = lexer_next(lex, sl)));
  if ((((r.tok).kind) !=117)) {
    return 3;
  }
  (void)((lex = (r.next_lex)));
  (void)((r = lexer_next(lex, sl)));
  if ((((r.tok).kind) !=80)) {
    return 4;
  }
  (void)((lex = (r.next_lex)));
  (void)((r = lexer_next(lex, sl)));
  if ((((r.tok).kind) !=95)) {
    return 5;
  }
  (void)((lex = (r.next_lex)));
  (void)((r = lexer_next(lex, sl)));
  if ((((r.tok).kind) !=0)) {
    return 6;
  }
  return 0;
}
