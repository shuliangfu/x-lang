/* generated (single-file with deps) */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
extern int getpid(void);
static inline void shux_crash_evidence_collect_inline(int has_msg, int msg_val) {
  const char *_ev = getenv("SHUX_CRASH_EVIDENCE");
  if (!_ev || _ev[0] != '1') return;
  int _pid = (int)getpid();
  fprintf(stderr, "shux: [SHUX_CRASH_EVIDENCE] panic=%d msg=%d frames=0 pid=%d\n", has_msg, msg_val, _pid);
  const char *_dir = getenv("SHUX_CRASH_EVIDENCE_DIR");
  if (_dir && _dir[0]) { char _p[1024]; snprintf(_p, sizeof _p, "%s/shux-crash-%d.txt", _dir, _pid);
    FILE *_f = fopen(_p, "w"); if (_f) { fprintf(_f, "panic_has_msg=%d\npanic_msg=%d\nframes=0\npid=%d\n", has_msg, msg_val, _pid); fclose(_f);
      fprintf(stderr, "shux: [SHUX_CRASH_EVIDENCE] bundle=%s\n", _p); } } }
static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));
static inline void shux_panic_(int has_msg, int msg_val) {
  shux_crash_evidence_collect_inline(has_msg, msg_val);
  if (has_msg) (void)fprintf(stderr, "%d\n", msg_val);
  abort();
}
enum token_TokenKind { token_TokenKind_TOKEN_EOF, token_TokenKind_TOKEN_FUNCTION, token_TokenKind_TOKEN_LET, token_TokenKind_TOKEN_CONST, token_TokenKind_TOKEN_IF, token_TokenKind_TOKEN_ELSE, token_TokenKind_TOKEN_WHILE, token_TokenKind_TOKEN_LOOP, token_TokenKind_TOKEN_FOR, token_TokenKind_TOKEN_BREAK, token_TokenKind_TOKEN_CONTINUE, token_TokenKind_TOKEN_RETURN, token_TokenKind_TOKEN_PANIC, token_TokenKind_TOKEN_DEFER, token_TokenKind_TOKEN_TRY, token_TokenKind_TOKEN_CATCH, token_TokenKind_TOKEN_REGION, token_TokenKind_TOKEN_WITH_ARENA, token_TokenKind_TOKEN_MATCH, token_TokenKind_TOKEN_STRUCT, token_TokenKind_TOKEN_TYPE, token_TokenKind_TOKEN_PACKED, token_TokenKind_TOKEN_SOA, token_TokenKind_TOKEN_ATTR_SOA, token_TokenKind_TOKEN_ATTR_CFG, token_TokenKind_TOKEN_ATTR_REPR_C, token_TokenKind_TOKEN_ATTR_REPR_COMPATIBLE, token_TokenKind_TOKEN_ATTR_ALLOC, token_TokenKind_TOKEN_ALIGN, token_TokenKind_TOKEN_ENUM, token_TokenKind_TOKEN_GOTO, token_TokenKind_TOKEN_TRAIT, token_TokenKind_TOKEN_IMPL, token_TokenKind_TOKEN_SELF, token_TokenKind_TOKEN_UNDERSCORE, token_TokenKind_TOKEN_IMPORT, token_TokenKind_TOKEN_EXTERN, token_TokenKind_TOKEN_ASYNC, token_TokenKind_TOKEN_AWAIT, token_TokenKind_TOKEN_RUN, token_TokenKind_TOKEN_SPAWN, token_TokenKind_TOKEN_IDENT, token_TokenKind_TOKEN_I32, token_TokenKind_TOKEN_BOOL, token_TokenKind_TOKEN_U8, token_TokenKind_TOKEN_U32, token_TokenKind_TOKEN_U64, token_TokenKind_TOKEN_I64, token_TokenKind_TOKEN_USIZE, token_TokenKind_TOKEN_ISIZE, token_TokenKind_TOKEN_I32X4, token_TokenKind_TOKEN_I32X8, token_TokenKind_TOKEN_I32X16, token_TokenKind_TOKEN_U32X4, token_TokenKind_TOKEN_U32X8, token_TokenKind_TOKEN_U32X16, token_TokenKind_TOKEN_F32X4, token_TokenKind_TOKEN_TRUE, token_TokenKind_TOKEN_FALSE, token_TokenKind_TOKEN_F32, token_TokenKind_TOKEN_F64, token_TokenKind_TOKEN_VOID, token_TokenKind_TOKEN_INT, token_TokenKind_TOKEN_FLOAT, token_TokenKind_TOKEN_LPAREN, token_TokenKind_TOKEN_RPAREN, token_TokenKind_TOKEN_LBRACE, token_TokenKind_TOKEN_RBRACE, token_TokenKind_TOKEN_LBRACKET, token_TokenKind_TOKEN_RBRACKET, token_TokenKind_TOKEN_ARROW, token_TokenKind_TOKEN_FATARROW, token_TokenKind_TOKEN_COMMA, token_TokenKind_TOKEN_COLON, token_TokenKind_TOKEN_DOT, token_TokenKind_TOKEN_DOTDOT, token_TokenKind_TOKEN_SEMICOLON, token_TokenKind_TOKEN_PLUS, token_TokenKind_TOKEN_MINUS, token_TokenKind_TOKEN_STAR, token_TokenKind_TOKEN_SLASH, token_TokenKind_TOKEN_PERCENT, token_TokenKind_TOKEN_AMP, token_TokenKind_TOKEN_PIPE, token_TokenKind_TOKEN_CARET, token_TokenKind_TOKEN_LSHIFT, token_TokenKind_TOKEN_RSHIFT, token_TokenKind_TOKEN_PLUS_EQ, token_TokenKind_TOKEN_MINUS_EQ, token_TokenKind_TOKEN_STAR_EQ, token_TokenKind_TOKEN_SLASH_EQ, token_TokenKind_TOKEN_PERCENT_EQ, token_TokenKind_TOKEN_AMP_EQ, token_TokenKind_TOKEN_PIPE_EQ, token_TokenKind_TOKEN_CARET_EQ, token_TokenKind_TOKEN_LSHIFT_EQ, token_TokenKind_TOKEN_RSHIFT_EQ, token_TokenKind_TOKEN_TILDE, token_TokenKind_TOKEN_ASSIGN, token_TokenKind_TOKEN_EQ, token_TokenKind_TOKEN_NE, token_TokenKind_TOKEN_LT, token_TokenKind_TOKEN_GT, token_TokenKind_TOKEN_LE, token_TokenKind_TOKEN_GE, token_TokenKind_TOKEN_AMPAMP, token_TokenKind_TOKEN_PIPEPIPE, token_TokenKind_TOKEN_BANG, token_TokenKind_TOKEN_QUESTION, token_TokenKind_TOKEN_AS, token_TokenKind_TOKEN_AT, token_TokenKind_TOKEN_STRING };
struct token_Token { enum token_TokenKind kind; int32_t line; int32_t col; int32_t int_val; double float_val; uint8_t * ident; int32_t ident_len; };
/* slim arena grow pool glue (C-04 codegen; linked from pipeline/runtime) */
extern struct ast_Expr pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Block pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Type pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Func pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);
extern void ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b);
extern void ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t);
extern void ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f);

struct shux_slice_uint8_t { uint8_t *data; size_t length; };
struct lexer_Lexer { size_t pos; int32_t line; int32_t col; };
struct lexer_LexerResult { struct lexer_Lexer next_lex; struct token_Token tok; size_t token_start; };
extern int32_t cfg_eval_expr_c(uint8_t * restrict start, int32_t len);
extern struct shux_slice_uint8_t lexer_parser_slice_from_buf(uint8_t * restrict data, int32_t len);
struct lexer_Lexer lexer_init();
struct lexer_Lexer lexer_advance_one(struct lexer_Lexer lex, uint8_t c);
int lexer_is_alpha(uint8_t c);
int lexer_is_hex_digit(uint8_t c);
int32_t lexer_hex_digit_value(uint8_t c);
int lexer_is_digit(uint8_t c);
int lexer_is_alnum_underscore(uint8_t c);
int lexer_match_keyword(struct shux_slice_uint8_t * data, size_t start, int32_t len, struct shux_slice_uint8_t * keyword);
int lexer_match_keyword_buf(uint8_t * restrict data, int32_t data_len, size_t start, int32_t len, struct shux_slice_uint8_t * keyword);
struct token_Token lexer_try_keyword(struct shux_slice_uint8_t * data, size_t start, size_t len, int32_t line0, int32_t col0);
struct token_Token lexer_try_keyword_buf(uint8_t * restrict data, int32_t data_len, size_t start, size_t len, int32_t line0, int32_t col0);
struct lexer_Lexer lexer_skip_repr_c_attr_if_present(struct lexer_Lexer lex, struct shux_slice_uint8_t * data);
struct lexer_Lexer lexer_skip_cfg_attr_if_present(struct lexer_Lexer lex, struct shux_slice_uint8_t * data);
int32_t lexer_try_cfg_attr_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer l, struct shux_slice_uint8_t * data);
int32_t lexer_try_repr_c_attr_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer l, struct shux_slice_uint8_t * data);
int32_t lexer_try_repr_compatible_attr_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer l, struct shux_slice_uint8_t * data);
int32_t lexer_try_soa_attr_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer l, struct shux_slice_uint8_t * data);
struct lexer_Lexer lexer_skip_whitespace_and_comments(struct lexer_Lexer lex, struct shux_slice_uint8_t * data);
struct lexer_Lexer lexer_skip_whitespace_and_comments_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_LexerResult lexer_next_slice(struct lexer_Lexer lex, struct shux_slice_uint8_t * data);
void lexer_apply_optional_exponent(struct lexer_Lexer l, struct shux_slice_uint8_t * data, double fval, struct lexer_Lexer * restrict out_l, double * restrict out_f);
void lexer_next_body_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer l, struct shux_slice_uint8_t * data);
void lexer_write_next_lex_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer l);
void lexer_write_tok_into(struct lexer_LexerResult * restrict out, struct token_Token t);
void lexer_next_impl(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * data);
void lexer_next_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * data);
void lexer_next_buf_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_LexerResult lexer_next_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_LexerResult lexer_next_body(struct lexer_Lexer l, struct shux_slice_uint8_t * data);
struct lexer_Lexer lexer_init() {
  return (struct lexer_Lexer){ .pos = 0, .line = 1, .col = 1 };
}
struct lexer_Lexer lexer_advance_one(struct lexer_Lexer lex, uint8_t c) {
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (c == 10) {   return (struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line + 1, .col = 1 };
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  return (struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 };
}
int lexer_is_alpha(uint8_t c) {
  (void)(({ int __tmp = 0; if (c >= 97 && c <= 122) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (c >= 65 && c <= 90) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return c == 95;
}
int lexer_is_hex_digit(uint8_t c) {
  (void)(({ int __tmp = 0; if (c >= 48 && c <= 57) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (c >= 97 && c <= 102) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (c >= 65 && c <= 70) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t lexer_hex_digit_value(uint8_t c) {
  (void)(({ int32_t __tmp = 0; if (c >= 48 && c <= 57) {   return ((int32_t)(c - 48));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c >= 97 && c <= 102) {   return ((int32_t)((c - 97) + 10));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c >= 65 && c <= 70) {   return ((int32_t)((c - 65) + 10));
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int lexer_is_digit(uint8_t c) {
  return c >= 48 && c <= 57;
}
int lexer_is_alnum_underscore(uint8_t c) {
  return lexer_is_alpha(c) || lexer_is_digit(c);
}
int lexer_match_keyword(struct shux_slice_uint8_t * data, size_t start, int32_t len, struct shux_slice_uint8_t * keyword) {
  int32_t i = 0;
  while (i < len) {
    (void)(({ int __tmp = 0; if ((start + i < 0 || (size_t)(start + i) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[start + i]) != (i < 0 || (size_t)(i) >= (keyword)->length ? (shux_panic_(1, 0), (keyword)->data[0]) : (keyword)->data[i])) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 1;
}
int lexer_match_keyword_buf(uint8_t * restrict data, int32_t data_len, size_t start, int32_t len, struct shux_slice_uint8_t * keyword) {
  int32_t i = 0;
  while (i < len) {
    (void)(({ int __tmp = 0; if (((int32_t)(start)) + i >= data_len) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int __tmp = 0; if ((data)[start + i] != (i < 0 || (size_t)(i) >= (keyword)->length ? (shux_panic_(1, 0), (keyword)->data[0]) : (keyword)->data[i])) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
  return 1;
}
struct token_Token lexer_try_keyword(struct shux_slice_uint8_t * data, size_t start, size_t len, int32_t line0, int32_t col0) {
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 8 && lexer_match_keyword(data, start, 8, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 102, 117, 110, 99, 116, 105, 111, 110 }, .length = 8 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_FUNCTION, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 3 && lexer_match_keyword(data, start, 3, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 108, 101, 116 }, .length = 3 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_LET, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword(data, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 99, 111, 110, 115, 116 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_CONST, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 2 && lexer_match_keyword(data, start, 2, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 105, 102 }, .length = 2 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_IF, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 4 && lexer_match_keyword(data, start, 4, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 101, 108, 115, 101 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_ELSE, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword(data, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 119, 104, 105, 108, 101 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_WHILE, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 4 && lexer_match_keyword(data, start, 4, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 108, 111, 111, 112 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_LOOP, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 3 && lexer_match_keyword(data, start, 3, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 102, 111, 114 }, .length = 3 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_FOR, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword(data, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 98, 114, 101, 97, 107 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_BREAK, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 8 && lexer_match_keyword(data, start, 8, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 99, 111, 110, 116, 105, 110, 117, 101 }, .length = 8 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_CONTINUE, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 6 && lexer_match_keyword(data, start, 6, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 114, 101, 116, 117, 114, 110 }, .length = 6 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_RETURN, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword(data, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 112, 97, 110, 105, 99 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_PANIC, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword(data, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 100, 101, 102, 101, 114 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_DEFER, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 6 && lexer_match_keyword(data, start, 6, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 114, 101, 103, 105, 111, 110 }, .length = 6 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_REGION, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  /** MEM-C1：with_arena 关键字（与 lexer.sx / token.h TOKEN_WITH_ARENA 一致）。 */
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 10 && lexer_match_keyword(data, start, 10, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 119, 105, 116, 104, 95, 97, 114, 101, 110, 97 }, .length = 10 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_WITH_ARENA, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword(data, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 109, 97, 116, 99, 104 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_MATCH, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 6 && lexer_match_keyword(data, start, 6, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 115, 116, 114, 117, 99, 116 }, .length = 6 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_STRUCT, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 4 && lexer_match_keyword(data, start, 4, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 116, 121, 112, 101 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_TYPE, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 6 && lexer_match_keyword(data, start, 6, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 112, 97, 99, 107, 101, 100 }, .length = 6 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_PACKED, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 3 && lexer_match_keyword(data, start, 3, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 115, 111, 97 }, .length = 3 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_SOA, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword(data, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 97, 108, 105, 103, 110 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_ALIGN, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 4 && lexer_match_keyword(data, start, 4, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 101, 110, 117, 109 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_ENUM, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 4 && lexer_match_keyword(data, start, 4, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 103, 111, 116, 111 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_GOTO, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword(data, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 116, 114, 97, 105, 116 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_TRAIT, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 4 && lexer_match_keyword(data, start, 4, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 105, 109, 112, 108 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_IMPL, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 4 && lexer_match_keyword(data, start, 4, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 115, 101, 108, 102 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_SELF, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 1 && (start < 0 || (size_t)(start) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[start]) == 95) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_UNDERSCORE, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 6 && lexer_match_keyword(data, start, 6, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 105, 109, 112, 111, 114, 116 }, .length = 6 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_IMPORT, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 6 && lexer_match_keyword(data, start, 6, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 101, 120, 116, 101, 114, 110 }, .length = 6 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_EXTERN, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword(data, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 97, 115, 121, 110, 99 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_ASYNC, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword(data, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 97, 119, 97, 105, 116 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_AWAIT, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 3 && lexer_match_keyword(data, start, 3, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 114, 117, 110 }, .length = 3 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_RUN, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword(data, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 115, 112, 97, 119, 110 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_SPAWN, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 3 && lexer_match_keyword(data, start, 3, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 105, 51, 50 }, .length = 3 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_I32, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 4 && lexer_match_keyword(data, start, 4, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 98, 111, 111, 108 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_BOOL, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 2 && lexer_match_keyword(data, start, 2, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 117, 56 }, .length = 2 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_U8, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 3 && lexer_match_keyword(data, start, 3, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 117, 51, 50 }, .length = 3 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_U32, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 3 && lexer_match_keyword(data, start, 3, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 117, 54, 52 }, .length = 3 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_U64, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 3 && lexer_match_keyword(data, start, 3, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 105, 54, 52 }, .length = 3 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_I64, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword(data, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 117, 115, 105, 122, 101 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_USIZE, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword(data, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 105, 115, 105, 122, 101 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_ISIZE, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 4 && lexer_match_keyword(data, start, 4, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 116, 114, 117, 101 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_TRUE, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword(data, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 102, 97, 108, 115, 101 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_FALSE, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 3 && lexer_match_keyword(data, start, 3, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 102, 51, 50 }, .length = 3 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_F32, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 3 && lexer_match_keyword(data, start, 3, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 102, 54, 52 }, .length = 3 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_F64, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 4 && lexer_match_keyword(data, start, 4, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 118, 111, 105, 100 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_VOID, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword(data, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 105, 51, 120, 52 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_I32X4, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword(data, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 105, 51, 120, 56 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_I32X8, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 6 && lexer_match_keyword(data, start, 6, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 105, 51, 120, 49, 54 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_I32X16, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword(data, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 117, 51, 120, 52 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_U32X4, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword(data, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 117, 51, 120, 56 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_U32X8, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 6 && lexer_match_keyword(data, start, 6, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 117, 51, 120, 49, 54 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_U32X16, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 2 && lexer_match_keyword(data, start, 2, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 97, 115 }, .length = 2 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_AS, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_IDENT, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = len };
  return t;
}
struct token_Token lexer_try_keyword_buf(uint8_t * restrict data, int32_t data_len, size_t start, size_t len, int32_t line0, int32_t col0) {
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 8 && lexer_match_keyword_buf(data, data_len, start, 8, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 102, 117, 110, 99, 116, 105, 111, 110 }, .length = 8 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_FUNCTION, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 3 && lexer_match_keyword_buf(data, data_len, start, 3, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 108, 101, 116 }, .length = 3 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_LET, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword_buf(data, data_len, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 99, 111, 110, 115, 116 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_CONST, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 2 && lexer_match_keyword_buf(data, data_len, start, 2, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 105, 102 }, .length = 2 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_IF, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 4 && lexer_match_keyword_buf(data, data_len, start, 4, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 101, 108, 115, 101 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_ELSE, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 6 && lexer_match_keyword_buf(data, data_len, start, 6, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 114, 101, 116, 117, 114, 110 }, .length = 6 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_RETURN, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 6 && lexer_match_keyword_buf(data, data_len, start, 6, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 115, 116, 114, 117, 99, 116 }, .length = 6 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_STRUCT, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 4 && lexer_match_keyword_buf(data, data_len, start, 4, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 116, 121, 112, 101 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_TYPE, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 4 && lexer_match_keyword_buf(data, data_len, start, 4, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 101, 110, 117, 109 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_ENUM, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword_buf(data, data_len, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 109, 97, 116, 99, 104 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_MATCH, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 4 && lexer_match_keyword_buf(data, data_len, start, 4, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 116, 114, 117, 101 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_TRUE, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword_buf(data, data_len, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 102, 97, 108, 115, 101 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_FALSE, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 3 && lexer_match_keyword_buf(data, data_len, start, 3, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 102, 54, 52 }, .length = 3 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_F64, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 4 && lexer_match_keyword_buf(data, data_len, start, 4, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 118, 111, 105, 100 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_VOID, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 3 && lexer_match_keyword_buf(data, data_len, start, 3, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 105, 51, 50 }, .length = 3 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_I32, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 4 && lexer_match_keyword_buf(data, data_len, start, 4, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 98, 111, 111, 108 }, .length = 4 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_BOOL, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 2 && lexer_match_keyword_buf(data, data_len, start, 2, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 117, 56 }, .length = 2 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_U8, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword_buf(data, data_len, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 117, 115, 105, 122, 101 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_USIZE, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword_buf(data, data_len, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 105, 115, 105, 122, 101 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_ISIZE, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 2 && lexer_match_keyword_buf(data, data_len, start, 2, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 97, 115 }, .length = 2 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_AS, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 6 && lexer_match_keyword_buf(data, data_len, start, 6, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 105, 109, 112, 111, 114, 116 }, .length = 6 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_IMPORT, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 6 && lexer_match_keyword_buf(data, data_len, start, 6, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 101, 120, 116, 101, 114, 110 }, .length = 6 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_EXTERN, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword_buf(data, data_len, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 97, 115, 121, 110, 99 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_ASYNC, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword_buf(data, data_len, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 97, 119, 97, 105, 116 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_AWAIT, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 3 && lexer_match_keyword_buf(data, data_len, start, 3, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 114, 117, 110 }, .length = 3 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_RUN, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 5 && lexer_match_keyword_buf(data, data_len, start, 5, &((struct shux_slice_uint8_t){ .data = (uint8_t[]){ 115, 112, 97, 119, 110 }, .length = 5 }))) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_SPAWN, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  (void)(({ struct token_Token __tmp = (struct token_Token){0}; if (len == 1 && start < ((size_t)(data_len)) && (data)[start] == 95) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_UNDERSCORE, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return t;
 } else (__tmp = (struct token_Token){0}) ; __tmp; }));
  struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_IDENT, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = len };
  return t;
}
struct lexer_Lexer lexer_skip_repr_c_attr_if_present(struct lexer_Lexer lex, struct shux_slice_uint8_t * data) {
  struct lexer_Lexer l = lex;
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((l).pos + 10 > (data)->length) {   return l;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) != 35 || ((l).pos + 1 < 0 || (size_t)((l).pos + 1) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 1]) != 91) {   return l;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((l).pos + 2 < 0 || (size_t)((l).pos + 2) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 2]) != 114 || ((l).pos + 3 < 0 || (size_t)((l).pos + 3) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 3]) != 101 || ((l).pos + 4 < 0 || (size_t)((l).pos + 4) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 4]) != 112 || ((l).pos + 5 < 0 || (size_t)((l).pos + 5) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 5]) != 114) {   return l;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((l).pos + 6 < 0 || (size_t)((l).pos + 6) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 6]) != 40 || ((l).pos + 7 < 0 || (size_t)((l).pos + 7) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 7]) != 67 || ((l).pos + 8 < 0 || (size_t)((l).pos + 8) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 8]) != 41 || ((l).pos + 9 < 0 || (size_t)((l).pos + 9) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 9]) != 93) {   return l;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  return (struct lexer_Lexer){ .pos = (l).pos + 10, .line = (l).line, .col = (l).col };
}
struct lexer_Lexer lexer_skip_cfg_attr_if_present(struct lexer_Lexer lex, struct shux_slice_uint8_t * data) {
  struct lexer_Lexer l = lex;
  size_t p = 0;
  int32_t depth = 0;
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((l).pos + 6 > (data)->length) {   return l;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) != 35 || ((l).pos + 1 < 0 || (size_t)((l).pos + 1) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 1]) != 91) {   return l;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((l).pos + 2 < 0 || (size_t)((l).pos + 2) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 2]) != 99 || ((l).pos + 3 < 0 || (size_t)((l).pos + 3) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 3]) != 102 || ((l).pos + 4 < 0 || (size_t)((l).pos + 4) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 4]) != 103) {   return l;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((l).pos + 5 < 0 || (size_t)((l).pos + 5) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 5]) != 40) {   return l;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (p = ((l).pos + 6));
  (depth = (1));
  while (p < (data)->length && depth > 0) {
    (void)(({ int32_t __tmp = 0; if ((p < 0 || (size_t)(p) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[p]) == 40) {   ++depth;
 } else (__tmp = ({ int32_t __tmp = 0; if ((p < 0 || (size_t)(p) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[p]) == 41) {   (depth = (depth - 1));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
    ++p;
  }
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (p >= (data)->length || (p < 0 || (size_t)(p) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[p]) != 93) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  ++p;
  return (struct lexer_Lexer){ .pos = p, .line = (l).line, .col = (l).col };
}
int32_t lexer_try_cfg_attr_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer l, struct shux_slice_uint8_t * data) {
  int32_t line0 = (l).line;
  int32_t col0 = (l).col;
  size_t p = 0;
  int32_t depth = 0;
  size_t expr_start = 0;
  (void)(({ int32_t __tmp = 0; if ((l).pos + 6 > (data)->length) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) != 35 || ((l).pos + 1 < 0 || (size_t)((l).pos + 1) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 1]) != 91) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((l).pos + 2 < 0 || (size_t)((l).pos + 2) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 2]) != 99 || ((l).pos + 3 < 0 || (size_t)((l).pos + 3) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 3]) != 102 || ((l).pos + 4 < 0 || (size_t)((l).pos + 4) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 4]) != 103) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((l).pos + 5 < 0 || (size_t)((l).pos + 5) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 5]) != 40) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (p = ((l).pos + 6));
  (depth = (1));
  (expr_start = (p));
  while (p < (data)->length && depth > 0) {
    (void)(({ int32_t __tmp = 0; if ((p < 0 || (size_t)(p) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[p]) == 40) {   ++depth;
 } else (__tmp = ({ int32_t __tmp = 0; if ((p < 0 || (size_t)(p) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[p]) == 41) {   (depth = (depth - 1));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
    ++p;
  }
  (void)(({ int32_t __tmp = 0; if (p >= (data)->length || (p < 0 || (size_t)(p) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[p]) != 93) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t expr_len = (((int32_t)(p)) - ((int32_t)(expr_start))) - 1;
  (void)(({ int32_t __tmp = 0; if (expr_len <= 0 || expr_len > 127) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t tmp[128] = { 0 };
  int32_t ti = 0;
  while (ti < expr_len) {
    ((ti < 0 || (ti) >= 128 ? (shux_panic_(1, 0), 0) : ((tmp)[ti] = (expr_start + ((size_t)(ti)) < 0 || (size_t)(expr_start + ((size_t)(ti))) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[expr_start + ((size_t)(ti))]), 0)));
    ++ti;
  }
  int32_t enabled = cfg_eval_expr_c((&((tmp)[0])), expr_len);
  ++p;
  struct lexer_Lexer l2 = (struct lexer_Lexer){ .pos = p, .line = (l).line, .col = (l).col };
  struct token_Token tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_ATTR_CFG, .line = line0, .col = col0, .int_val = enabled, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  (void)(lexer_write_next_lex_into(out, l2));
  (void)(lexer_write_tok_into(out, tok));
  ((out)->token_start = (((size_t)(0))));
  return 1;
}
int32_t lexer_try_repr_c_attr_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer l, struct shux_slice_uint8_t * data) {
  (void)(({ int32_t __tmp = 0; if ((l).pos + 10 > (data)->length) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) != 35 || ((l).pos + 1 < 0 || (size_t)((l).pos + 1) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 1]) != 91) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((l).pos + 2 < 0 || (size_t)((l).pos + 2) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 2]) != 114 || ((l).pos + 3 < 0 || (size_t)((l).pos + 3) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 3]) != 101 || ((l).pos + 4 < 0 || (size_t)((l).pos + 4) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 4]) != 112 || ((l).pos + 5 < 0 || (size_t)((l).pos + 5) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 5]) != 114) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((l).pos + 6 < 0 || (size_t)((l).pos + 6) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 6]) != 40 || ((l).pos + 7 < 0 || (size_t)((l).pos + 7) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 7]) != 67 || ((l).pos + 8 < 0 || (size_t)((l).pos + 8) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 8]) != 41 || ((l).pos + 9 < 0 || (size_t)((l).pos + 9) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 9]) != 93) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t line0 = (l).line;
  int32_t col0 = (l).col;
  size_t np = (l).pos + 10;
  struct lexer_Lexer l2 = (struct lexer_Lexer){ .pos = np, .line = line0, .col = col0 };
  struct token_Token tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_ATTR_REPR_C, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  (void)(lexer_write_next_lex_into(out, l2));
  (void)(lexer_write_tok_into(out, tok));
  ((out)->token_start = (((size_t)(0))));
  return 1;
}
/** MOD-02：`#[repr(compatible)]` → TOKEN_ATTR_REPR_COMPATIBLE。 */
int32_t lexer_try_repr_compatible_attr_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer l, struct shux_slice_uint8_t * data) {
  (void)(({ int32_t __tmp = 0; if ((l).pos + 19 > (data)->length) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) != 35 || ((l).pos + 1 < 0 || (size_t)((l).pos + 1) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 1]) != 91) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((l).pos + 2 < 0 || (size_t)((l).pos + 2) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 2]) != 114 || ((l).pos + 3 < 0 || (size_t)((l).pos + 3) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 3]) != 101 || ((l).pos + 4 < 0 || (size_t)((l).pos + 4) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 4]) != 112 || ((l).pos + 5 < 0 || (size_t)((l).pos + 5) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 5]) != 114) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((l).pos + 6 < 0 || (size_t)((l).pos + 6) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 6]) != 40) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((l).pos + 7 < 0 || (size_t)((l).pos + 7) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 7]) != 99 || ((l).pos + 8 < 0 || (size_t)((l).pos + 8) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 8]) != 111 || ((l).pos + 9 < 0 || (size_t)((l).pos + 9) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 9]) != 109 || ((l).pos + 10 < 0 || (size_t)((l).pos + 10) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 10]) != 112 || ((l).pos + 11 < 0 || (size_t)((l).pos + 11) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 11]) != 97 || ((l).pos + 12 < 0 || (size_t)((l).pos + 12) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 12]) != 116 || ((l).pos + 13 < 0 || (size_t)((l).pos + 13) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 13]) != 105 || ((l).pos + 14 < 0 || (size_t)((l).pos + 14) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 14]) != 98 || ((l).pos + 15 < 0 || (size_t)((l).pos + 15) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 15]) != 108 || ((l).pos + 16 < 0 || (size_t)((l).pos + 16) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 16]) != 101) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((l).pos + 17 < 0 || (size_t)((l).pos + 17) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 17]) != 41 || ((l).pos + 18 < 0 || (size_t)((l).pos + 18) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 18]) != 93) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t line0 = (l).line;
  int32_t col0 = (l).col;
  size_t np = (l).pos + 19;
  struct lexer_Lexer l2 = (struct lexer_Lexer){ .pos = np, .line = line0, .col = col0 };
  struct token_Token tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_ATTR_REPR_COMPATIBLE, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  (void)(lexer_write_next_lex_into(out, l2));
  (void)(lexer_write_tok_into(out, tok));
  ((out)->token_start = (((size_t)(0))));
  return 1;
}
int32_t lexer_try_soa_attr_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer l, struct shux_slice_uint8_t * data) {
  (void)(({ int32_t __tmp = 0; if ((l).pos + 6 > (data)->length) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) != 35 || ((l).pos + 1 < 0 || (size_t)((l).pos + 1) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 1]) != 91) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((l).pos + 2 < 0 || (size_t)((l).pos + 2) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 2]) != 115 || ((l).pos + 3 < 0 || (size_t)((l).pos + 3) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 3]) != 111 || ((l).pos + 4 < 0 || (size_t)((l).pos + 4) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 4]) != 97 || ((l).pos + 5 < 0 || (size_t)((l).pos + 5) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 5]) != 93) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t line0 = (l).line;
  int32_t col0 = (l).col;
  struct lexer_Lexer l2 = l;
  (l2 = (lexer_advance_one(l2, 35)));
  (l2 = (lexer_advance_one(l2, 91)));
  (l2 = (lexer_advance_one(l2, 115)));
  (l2 = (lexer_advance_one(l2, 111)));
  (l2 = (lexer_advance_one(l2, 97)));
  (l2 = (lexer_advance_one(l2, 93)));
  struct token_Token tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_ATTR_SOA, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  (void)(lexer_write_next_lex_into(out, l2));
  (void)(lexer_write_tok_into(out, tok));
  ((out)->token_start = (((size_t)(0))));
  return 1;
}
struct lexer_Lexer lexer_skip_whitespace_and_comments(struct lexer_Lexer lex, struct shux_slice_uint8_t * data) {
  struct lexer_Lexer l = lex;
  while ((l).pos < (data)->length) {
    uint8_t c = ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]);
    (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (c == 32 || c == 9 || c == 10 || c == 13) {   (l = (lexer_advance_one(l, c)));
 } else (__tmp = ({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (c == 47 && (l).pos + 1 < (data)->length && ((l).pos + 1 < 0 || (size_t)((l).pos + 1) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 1]) == 47) {   while ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) != 10) {
    (l = (lexer_advance_one(l, ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))));
  }
 } else (__tmp = ({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (c == 47 && (l).pos + 1 < (data)->length && ((l).pos + 1 < 0 || (size_t)((l).pos + 1) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 1]) == 42) {   (l = (lexer_advance_one(l, 47)));
  (l = (lexer_advance_one(l, 42)));
  while ((l).pos + 1 < (data)->length) {
    (void)(({ int32_t __tmp = 0; if (((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 42 && ((l).pos + 1 < 0 || (size_t)((l).pos + 1) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 1]) == 47) {   (l = (lexer_advance_one(l, 42)));
  (l = (lexer_advance_one(l, 47)));
  break;
 } else (__tmp = 0) ; __tmp; }));
    (l = (lexer_advance_one(l, ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))));
  }
 } else (__tmp = ({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (c == 35) {   __tmp = ({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((l).pos + 1 < (data)->length && ((l).pos + 1 < 0 || (size_t)((l).pos + 1) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 1]) == 91) {   return l;
 } else {   while ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) != 10) {
    (l = (lexer_advance_one(l, ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))));
  }
 } ; __tmp; });
 } else {   return l;
 } ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; }));
  }
  return l;
}
struct lexer_Lexer lexer_skip_whitespace_and_comments_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t source = lexer_parser_slice_from_buf(data, len);
  return lexer_skip_whitespace_and_comments(lex, &(source));
}
struct lexer_LexerResult lexer_next_slice(struct lexer_Lexer lex, struct shux_slice_uint8_t * data) {
  struct lexer_Lexer l = lexer_skip_whitespace_and_comments(lex, data);
  return ({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if ((l).pos >= (data)->length) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = (l).line, .col = (l).col, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  __tmp = (struct lexer_LexerResult){ .next_lex = l, .tok = t, .token_start = ((size_t)(0)) };
 } else (__tmp = ({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 0) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = (l).line, .col = (l).col, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  __tmp = (struct lexer_LexerResult){ .next_lex = l, .tok = t, .token_start = ((size_t)(0)) };
 } else {   __tmp = lexer_next_body(l, data);
 } ; __tmp; })) ; __tmp; });
}
void lexer_apply_optional_exponent(struct lexer_Lexer l, struct shux_slice_uint8_t * data, double fval, struct lexer_Lexer * restrict out_l, double * restrict out_f) {
  struct lexer_Lexer lex = l;
  double cur = fval;
  (void)(({ int32_t __tmp = 0; if ((lex).pos < (data)->length && ((lex).pos < 0 || (size_t)((lex).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(lex).pos]) == 101 || ((lex).pos < 0 || (size_t)((lex).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(lex).pos]) == 69) {   (lex = (lexer_advance_one(lex, ((lex).pos < 0 || (size_t)((lex).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(lex).pos]))));
  int32_t exp_sign = 1;
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos < (data)->length && ((lex).pos < 0 || (size_t)((lex).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(lex).pos]) == 45) {   (exp_sign = ((-1)));
  (lex = (lexer_advance_one(lex, 45)));
 } else {   __tmp = ({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos < (data)->length && ((lex).pos < 0 || (size_t)((lex).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(lex).pos]) == 43) {   (lex = (lexer_advance_one(lex, 43)));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; });
 } ; __tmp; }));
  int32_t exp = 0;
  while ((lex).pos < (data)->length && lexer_is_digit(((lex).pos < 0 || (size_t)((lex).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(lex).pos]))) {
    uint8_t d = ((lex).pos < 0 || (size_t)((lex).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(lex).pos]);
    (lex = (lexer_advance_one(lex, d)));
    (exp = (exp * 10 + (d - 48)));
  }
  (exp = (exp * exp_sign));
  double scale = 1;
  int32_t e = 0;
  (void)(({ int32_t __tmp = 0; if (exp > 0) {   while (e < exp) {
    (scale = (scale * 10));
    ++e;
  }
 } else {   while (e > exp) {
    (scale = (scale * 0.1));
    (e = (e - 1));
  }
 } ; __tmp; }));
  (cur = (fval * scale));
 } else (__tmp = 0) ; __tmp; }));
  ((out_l)[0] = (lex));
  ((out_f)[0] = (cur));
}
void lexer_next_body_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer l, struct shux_slice_uint8_t * data) {
  uint8_t c = ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]);
  (void)(({ int32_t __tmp = 0; if (lexer_try_cfg_attr_into(out, l, data) != 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (lexer_try_repr_c_attr_into(out, l, data) != 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (lexer_try_repr_compatible_attr_into(out, l, data) != 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (lexer_try_soa_attr_into(out, l, data) != 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 34) {   int32_t line0 = (l).line;
  int32_t col0 = (l).col;
  size_t start = (l).pos + 1;
  (l = (lexer_advance_one(l, 34)));
  while ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) != 34) {
    (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 92 && (l).pos + 1 < (data)->length) {   (l = (lexer_advance_one(l, ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))));
  (l = (lexer_advance_one(l, ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))));
 } else {   (l = (lexer_advance_one(l, ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))));
 } ; __tmp; }));
  }
  (void)(({ int32_t __tmp = 0; if ((l).pos >= (data)->length) {   struct token_Token tok_eof = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok_eof));
  ((out)->token_start = (start));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t slen = ((int32_t)((l).pos - start));
  (l = (lexer_advance_one(l, 34)));
  struct token_Token tok_str = (struct token_Token){ .kind = token_TokenKind_TOKEN_STRING, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = slen };
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok_str));
  ((out)->token_start = (start));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (lexer_is_alpha(c)) {   size_t start = (l).pos;
  int32_t line0 = (l).line;
  int32_t col0 = (l).col;
  (l = (lexer_advance_one(l, c)));
  while ((l).pos < (data)->length && lexer_is_alnum_underscore(((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))) {
    (l = (lexer_advance_one(l, ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))));
  }
  size_t len = (l).pos - start;
  struct token_Token tok = lexer_try_keyword(data, start, len, line0, col0);
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  ((out)->token_start = (start));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (lexer_is_digit(c)) {   size_t start = (l).pos;
  int32_t line0 = (l).line;
  int32_t col0 = (l).col;
  int32_t ival = 0;
  (l = (lexer_advance_one(l, c)));
  (void)(({ int32_t __tmp = 0; if (c == 48 && (l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 120 || ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 88) {   (l = (lexer_advance_one(l, ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))));
  uint32_t hval = ((uint32_t)(0));
  while ((l).pos < (data)->length && lexer_is_hex_digit(((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))) {
    uint8_t hd = ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]);
    (hval = (hval * 16 + ((uint32_t)(lexer_hex_digit_value(hd)))));
    (l = (lexer_advance_one(l, hd)));
  }
  struct token_Token tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_INT, .line = line0, .col = col0, .int_val = ((int32_t)(hval)), .float_val = 0.0, .ident = 0, .ident_len = 0 };
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  ((out)->token_start = (start));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (ival = (ival * 10 + (c - 48)));
  while ((l).pos < (data)->length && lexer_is_digit(((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))) {
    uint8_t d = ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]);
    (l = (lexer_advance_one(l, d)));
    (ival = (ival * 10 + (d - 48)));
  }
  (void)(({ int32_t __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 46 && (l).pos + 1 < (data)->length && lexer_is_digit(((l).pos + 1 < 0 || (size_t)((l).pos + 1) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 1]))) {   (l = (lexer_advance_one(l, 46)));
  double fval = ((double)(ival));
  double frac = 0.1;
  while ((l).pos < (data)->length && lexer_is_digit(((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))) {
    uint8_t d = ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]);
    (l = (lexer_advance_one(l, d)));
    (fval = (fval + frac * (d - 48)));
    (frac = (frac * 0.1));
  }
  (void)(lexer_apply_optional_exponent(l, data, fval, (&(l)), (&(fval))));
  struct token_Token tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_FLOAT, .line = line0, .col = col0, .int_val = 0, .float_val = fval, .ident = 0, .ident_len = 0 };
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 101 || ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 69) {   (l = (lexer_advance_one(l, ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))));
  int32_t exp_sign = 1;
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 45) {   (exp_sign = ((-1)));
  (l = (lexer_advance_one(l, 45)));
 } else {   __tmp = ({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 43) {   (l = (lexer_advance_one(l, 43)));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; });
 } ; __tmp; }));
  int32_t exp = 0;
  while ((l).pos < (data)->length && lexer_is_digit(((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))) {
    uint8_t d = ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]);
    (l = (lexer_advance_one(l, d)));
    (exp = (exp * 10 + (d - 48)));
  }
  (exp = (exp * exp_sign));
  double scale = 1;
  int32_t e = 0;
  (void)(({ int32_t __tmp = 0; if (exp > 0) {   while (e < exp) {
    (scale = (scale * 10));
    ++e;
  }
 } else {   while (e > exp) {
    (scale = (scale * 0.1));
    (e = (e - 1));
  }
 } ; __tmp; }));
  double fval = ((double)(ival)) * scale;
  struct token_Token tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_FLOAT, .line = line0, .col = col0, .int_val = 0, .float_val = fval, .ident = 0, .ident_len = 0 };
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct token_Token tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_INT, .line = line0, .col = col0, .int_val = ival, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  ((out)->token_start = (start));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 46 && (l).pos + 1 < (data)->length && lexer_is_digit(((l).pos + 1 < 0 || (size_t)((l).pos + 1) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 1]))) {   int32_t line0 = (l).line;
  int32_t col0 = (l).col;
  (l = (lexer_advance_one(l, 46)));
  double fval = 0.0;
  double frac = 0.1;
  while ((l).pos < (data)->length && lexer_is_digit(((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))) {
    uint8_t d = ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]);
    (l = (lexer_advance_one(l, d)));
    (fval = (fval + frac * (d - 48)));
    (frac = (frac * 0.1));
  }
  (void)(lexer_apply_optional_exponent(l, data, fval, (&(l)), (&(fval))));
  struct token_Token tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_FLOAT, .line = line0, .col = col0, .int_val = 0, .float_val = fval, .ident = 0, .ident_len = 0 };
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t line0 = (l).line;
  int32_t col0 = (l).col;
  (l = (lexer_advance_one(l, c)));
  struct token_Token tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  (void)(({ int32_t __tmp = 0; if (c == 40) {   ((tok).kind = (token_TokenKind_TOKEN_LPAREN));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 41) {   ((tok).kind = (token_TokenKind_TOKEN_RPAREN));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 123) {   ((tok).kind = (token_TokenKind_TOKEN_LBRACE));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 125) {   ((tok).kind = (token_TokenKind_TOKEN_RBRACE));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 91) {   ((tok).kind = (token_TokenKind_TOKEN_LBRACKET));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 93) {   ((tok).kind = (token_TokenKind_TOKEN_RBRACKET));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 44) {   ((tok).kind = (token_TokenKind_TOKEN_COMMA));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 58) {   ((tok).kind = (token_TokenKind_TOKEN_COLON));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 46) {   ((tok).kind = (token_TokenKind_TOKEN_DOT));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 59) {   ((tok).kind = (token_TokenKind_TOKEN_SEMICOLON));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 43) {   (void)(({ enum token_TokenKind __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_PLUS_EQ));
 } else {   ((tok).kind = (token_TokenKind_TOKEN_PLUS));
 } ; __tmp; }));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 45) {   (void)(({ int32_t __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 62) {   (l = (lexer_advance_one(l, 62)));
  ((tok).kind = (token_TokenKind_TOKEN_ARROW));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_MINUS_EQ));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  ((tok).kind = (token_TokenKind_TOKEN_MINUS));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 42) {   (void)(({ enum token_TokenKind __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_STAR_EQ));
 } else {   ((tok).kind = (token_TokenKind_TOKEN_STAR));
 } ; __tmp; }));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 47) {   (void)(({ enum token_TokenKind __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_SLASH_EQ));
 } else {   ((tok).kind = (token_TokenKind_TOKEN_SLASH));
 } ; __tmp; }));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 37) {   (void)(({ enum token_TokenKind __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_PERCENT_EQ));
 } else {   ((tok).kind = (token_TokenKind_TOKEN_PERCENT));
 } ; __tmp; }));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 94) {   (void)(({ enum token_TokenKind __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_CARET_EQ));
 } else {   ((tok).kind = (token_TokenKind_TOKEN_CARET));
 } ; __tmp; }));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 126) {   ((tok).kind = (token_TokenKind_TOKEN_TILDE));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 38) {   (void)(({ int32_t __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 38) {   (l = (lexer_advance_one(l, 38)));
  ((tok).kind = (token_TokenKind_TOKEN_AMPAMP));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_AMP_EQ));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  ((tok).kind = (token_TokenKind_TOKEN_AMP));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 124) {   (void)(({ int32_t __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 124) {   (l = (lexer_advance_one(l, 124)));
  ((tok).kind = (token_TokenKind_TOKEN_PIPEPIPE));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_PIPE_EQ));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  ((tok).kind = (token_TokenKind_TOKEN_PIPE));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 60) {   (void)(({ int32_t __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_LE));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 60) {   (l = (lexer_advance_one(l, 60)));
  (void)(({ enum token_TokenKind __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_LSHIFT_EQ));
 } else {   ((tok).kind = (token_TokenKind_TOKEN_LSHIFT));
 } ; __tmp; }));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  ((tok).kind = (token_TokenKind_TOKEN_LT));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 62) {   (void)(({ int32_t __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_GE));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 62) {   (l = (lexer_advance_one(l, 62)));
  (void)(({ enum token_TokenKind __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_RSHIFT_EQ));
 } else {   ((tok).kind = (token_TokenKind_TOKEN_RSHIFT));
 } ; __tmp; }));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  ((tok).kind = (token_TokenKind_TOKEN_GT));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 33) {   (void)(({ int32_t __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_NE));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  ((tok).kind = (token_TokenKind_TOKEN_BANG));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 63) {   ((tok).kind = (token_TokenKind_TOKEN_QUESTION));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 64) {   ((tok).kind = (token_TokenKind_TOKEN_AT));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (c == 61) {   (void)(({ int32_t __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 62) {   (l = (lexer_advance_one(l, 62)));
  ((tok).kind = (token_TokenKind_TOKEN_FATARROW));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_EQ));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  ((tok).kind = (token_TokenKind_TOKEN_ASSIGN));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, tok));
}
void lexer_write_next_lex_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer l) {
  (((out)->next_lex).pos = ((l).pos));
  (((out)->next_lex).line = ((l).line));
  (((out)->next_lex).col = ((l).col));
  ((out)->token_start = (((size_t)(0))));
}
void lexer_write_tok_into(struct lexer_LexerResult * restrict out, struct token_Token t) {
  (((out)->tok).kind = ((t).kind));
  (((out)->tok).line = ((t).line));
  (((out)->tok).col = ((t).col));
  (((out)->tok).int_val = ((t).int_val));
  (((out)->tok).float_val = ((t).float_val));
  (((out)->tok).ident = ((t).ident));
  (((out)->tok).ident_len = ((t).ident_len));
}
void lexer_next_impl(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * data) {
  struct lexer_Lexer l = lexer_skip_whitespace_and_comments(lex, data);
  (void)(({ int32_t __tmp = 0; if ((l).pos >= (data)->length) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = (l).line, .col = (l).col, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, t));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 0) {   struct token_Token t = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = (l).line, .col = (l).col, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  (void)(lexer_write_next_lex_into(out, l));
  (void)(lexer_write_tok_into(out, t));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(lexer_next_body_into(out, l, data));
}
void lexer_next_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * data) {
  (void)(lexer_next_impl(out, lex, data));
}
void lexer_next_buf_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t source = lexer_parser_slice_from_buf(data, len);
  (void)(lexer_next_into(out, lex, &(source)));
}
struct lexer_LexerResult lexer_next_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t source = lexer_parser_slice_from_buf(data, len);
  return lexer_next_slice(lex, &(source));
}
struct lexer_LexerResult lexer_next_body(struct lexer_Lexer l, struct shux_slice_uint8_t * data) {
  uint8_t c = ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]);
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (lexer_is_alpha(c)) {   size_t start = (l).pos;
  int32_t line0 = (l).line;
  int32_t col0 = (l).col;
  (l = (lexer_advance_one(l, c)));
  while ((l).pos < (data)->length && lexer_is_alnum_underscore(((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))) {
    (l = (lexer_advance_one(l, ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))));
  }
  size_t len = (l).pos - start;
  struct token_Token tok = lexer_try_keyword(data, start, len, line0, col0);
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = start };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (lexer_is_digit(c)) {   size_t start = (l).pos;
  int32_t line0 = (l).line;
  int32_t col0 = (l).col;
  int32_t ival = 0;
  (l = (lexer_advance_one(l, c)));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 48 && (l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 120 || ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 88) {   (l = (lexer_advance_one(l, ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))));
  uint32_t hval = ((uint32_t)(0));
  while ((l).pos < (data)->length && lexer_is_hex_digit(((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))) {
    uint8_t hd = ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]);
    (hval = (hval * 16 + ((uint32_t)(lexer_hex_digit_value(hd)))));
    (l = (lexer_advance_one(l, hd)));
  }
  struct token_Token tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_INT, .line = line0, .col = col0, .int_val = ((int32_t)(hval)), .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = start };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (ival = (ival * 10 + (c - 48)));
  while ((l).pos < (data)->length && lexer_is_digit(((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))) {
    uint8_t d = ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]);
    (l = (lexer_advance_one(l, d)));
    (ival = (ival * 10 + (d - 48)));
  }
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 46 && (l).pos + 1 < (data)->length && lexer_is_digit(((l).pos + 1 < 0 || (size_t)((l).pos + 1) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 1]))) {   (l = (lexer_advance_one(l, 46)));
  double fval = ((double)(ival));
  double frac = 0.1;
  while ((l).pos < (data)->length && lexer_is_digit(((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))) {
    uint8_t d = ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]);
    (l = (lexer_advance_one(l, d)));
    (fval = (fval + frac * (d - 48)));
    (frac = (frac * 0.1));
  }
  (void)(lexer_apply_optional_exponent(l, data, fval, (&(l)), (&(fval))));
  struct token_Token tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_FLOAT, .line = line0, .col = col0, .int_val = 0, .float_val = fval, .ident = 0, .ident_len = 0 };
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 101 || ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 69) {   (l = (lexer_advance_one(l, ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))));
  int32_t exp_sign = 1;
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 45) {   (exp_sign = ((-1)));
  (l = (lexer_advance_one(l, 45)));
 } else {   __tmp = ({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 43) {   (l = (lexer_advance_one(l, 43)));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; });
 } ; __tmp; }));
  int32_t exp = 0;
  while ((l).pos < (data)->length && lexer_is_digit(((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))) {
    uint8_t d = ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]);
    (l = (lexer_advance_one(l, d)));
    (exp = (exp * 10 + (d - 48)));
  }
  (exp = (exp * exp_sign));
  double scale = 1;
  int32_t e = 0;
  (void)(({ int32_t __tmp = 0; if (exp > 0) {   while (e < exp) {
    (scale = (scale * 10));
    ++e;
  }
 } else {   while (e > exp) {
    (scale = (scale * 0.1));
    (e = (e - 1));
  }
 } ; __tmp; }));
  double fval = ((double)(ival)) * scale;
  struct token_Token tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_FLOAT, .line = line0, .col = col0, .int_val = 0, .float_val = fval, .ident = 0, .ident_len = 0 };
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  struct token_Token tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_INT, .line = line0, .col = col0, .int_val = ival, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = start };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 46 && (l).pos + 1 < (data)->length && lexer_is_digit(((l).pos + 1 < 0 || (size_t)((l).pos + 1) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos + 1]))) {   int32_t line0 = (l).line;
  int32_t col0 = (l).col;
  (l = (lexer_advance_one(l, 46)));
  double fval = 0.0;
  double frac = 0.1;
  while ((l).pos < (data)->length && lexer_is_digit(((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]))) {
    uint8_t d = ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]);
    (l = (lexer_advance_one(l, d)));
    (fval = (fval + frac * (d - 48)));
    (frac = (frac * 0.1));
  }
  (void)(lexer_apply_optional_exponent(l, data, fval, (&(l)), (&(fval))));
  struct token_Token tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_FLOAT, .line = line0, .col = col0, .int_val = 0, .float_val = fval, .ident = 0, .ident_len = 0 };
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  int32_t line0 = (l).line;
  int32_t col0 = (l).col;
  (l = (lexer_advance_one(l, c)));
  struct token_Token tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = line0, .col = col0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 };
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 40) {   ((tok).kind = (token_TokenKind_TOKEN_LPAREN));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 41) {   ((tok).kind = (token_TokenKind_TOKEN_RPAREN));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 123) {   ((tok).kind = (token_TokenKind_TOKEN_LBRACE));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 125) {   ((tok).kind = (token_TokenKind_TOKEN_RBRACE));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 91) {   ((tok).kind = (token_TokenKind_TOKEN_LBRACKET));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 93) {   ((tok).kind = (token_TokenKind_TOKEN_RBRACKET));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 44) {   ((tok).kind = (token_TokenKind_TOKEN_COMMA));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 58) {   ((tok).kind = (token_TokenKind_TOKEN_COLON));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 46) {   ((tok).kind = (token_TokenKind_TOKEN_DOT));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 59) {   ((tok).kind = (token_TokenKind_TOKEN_SEMICOLON));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 43) {   (void)(({ enum token_TokenKind __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_PLUS_EQ));
 } else {   ((tok).kind = (token_TokenKind_TOKEN_PLUS));
 } ; __tmp; }));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 45) {   (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 62) {   (l = (lexer_advance_one(l, 62)));
  ((tok).kind = (token_TokenKind_TOKEN_ARROW));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_MINUS_EQ));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  ((tok).kind = (token_TokenKind_TOKEN_MINUS));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 42) {   (void)(({ enum token_TokenKind __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_STAR_EQ));
 } else {   ((tok).kind = (token_TokenKind_TOKEN_STAR));
 } ; __tmp; }));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 47) {   (void)(({ enum token_TokenKind __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_SLASH_EQ));
 } else {   ((tok).kind = (token_TokenKind_TOKEN_SLASH));
 } ; __tmp; }));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 37) {   (void)(({ enum token_TokenKind __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_PERCENT_EQ));
 } else {   ((tok).kind = (token_TokenKind_TOKEN_PERCENT));
 } ; __tmp; }));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 94) {   (void)(({ enum token_TokenKind __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_CARET_EQ));
 } else {   ((tok).kind = (token_TokenKind_TOKEN_CARET));
 } ; __tmp; }));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 126) {   ((tok).kind = (token_TokenKind_TOKEN_TILDE));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 38) {   (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 38) {   (l = (lexer_advance_one(l, 38)));
  ((tok).kind = (token_TokenKind_TOKEN_AMPAMP));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_AMP_EQ));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  ((tok).kind = (token_TokenKind_TOKEN_AMP));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 124) {   (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 124) {   (l = (lexer_advance_one(l, 124)));
  ((tok).kind = (token_TokenKind_TOKEN_PIPEPIPE));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_PIPE_EQ));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  ((tok).kind = (token_TokenKind_TOKEN_PIPE));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 60) {   (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_LE));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 60) {   (l = (lexer_advance_one(l, 60)));
  (void)(({ enum token_TokenKind __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_LSHIFT_EQ));
 } else {   ((tok).kind = (token_TokenKind_TOKEN_LSHIFT));
 } ; __tmp; }));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  ((tok).kind = (token_TokenKind_TOKEN_LT));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 62) {   (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_GE));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 62) {   (l = (lexer_advance_one(l, 62)));
  (void)(({ enum token_TokenKind __tmp = 0; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_RSHIFT_EQ));
 } else {   ((tok).kind = (token_TokenKind_TOKEN_RSHIFT));
 } ; __tmp; }));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  ((tok).kind = (token_TokenKind_TOKEN_GT));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 33) {   (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_NE));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  ((tok).kind = (token_TokenKind_TOKEN_BANG));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 63) {   ((tok).kind = (token_TokenKind_TOKEN_QUESTION));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 64) {   ((tok).kind = (token_TokenKind_TOKEN_AT));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (c == 61) {   (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 62) {   (l = (lexer_advance_one(l, 62)));
  ((tok).kind = (token_TokenKind_TOKEN_FATARROW));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if ((l).pos < (data)->length && ((l).pos < 0 || (size_t)((l).pos) >= (data)->length ? (shux_panic_(1, 0), (data)->data[0]) : (data)->data[(l).pos]) == 61) {   (l = (lexer_advance_one(l, 61)));
  ((tok).kind = (token_TokenKind_TOKEN_EQ));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  ((tok).kind = (token_TokenKind_TOKEN_ASSIGN));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  return (struct lexer_LexerResult){ .next_lex = l, .tok = tok, .token_start = ((size_t)(0)) };
}
