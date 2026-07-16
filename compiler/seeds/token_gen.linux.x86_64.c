/* Auto: token.x -E; prove/cold seed. Layout portable (no arch asm). */
#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
enum TokenKind { TokenKind_TOKEN_EOF, TokenKind_TOKEN_FUNCTION, TokenKind_TOKEN_LET, TokenKind_TOKEN_CONST, TokenKind_TOKEN_IF, TokenKind_TOKEN_ELSE, TokenKind_TOKEN_WHILE, TokenKind_TOKEN_LOOP, TokenKind_TOKEN_FOR, TokenKind_TOKEN_BREAK, TokenKind_TOKEN_CONTINUE, TokenKind_TOKEN_RETURN, TokenKind_TOKEN_PANIC, TokenKind_TOKEN_DEFER, TokenKind_TOKEN_TRY, TokenKind_TOKEN_CATCH, TokenKind_TOKEN_REGION, TokenKind_TOKEN_WITH_ARENA, TokenKind_TOKEN_MATCH, TokenKind_TOKEN_STRUCT, TokenKind_TOKEN_TYPE, TokenKind_TOKEN_PACKED, TokenKind_TOKEN_SOA, TokenKind_TOKEN_ATTR_SOA, TokenKind_TOKEN_ATTR_CFG, TokenKind_TOKEN_ATTR_REPR_C, TokenKind_TOKEN_ATTR_REPR_COMPATIBLE, TokenKind_TOKEN_ATTR_ALLOC, TokenKind_TOKEN_ATTR_LINK_SECTION, TokenKind_TOKEN_ATTR_NAKED, TokenKind_TOKEN_ATTR_ENTRY, TokenKind_TOKEN_ATTR_USED, TokenKind_TOKEN_ATTR_NO_MANGLE, TokenKind_TOKEN_ATTR_LINK_NAME, TokenKind_TOKEN_ATTR_MAX_STACK, TokenKind_TOKEN_ATTR_INTERRUPT, TokenKind_TOKEN_ATTR_SEND, TokenKind_TOKEN_ATTR_SYNC, TokenKind_TOKEN_ATTR_GLOBAL_ALLOCATOR, TokenKind_TOKEN_ATTR_COLD, TokenKind_TOKEN_ATTR_INLINE_NEVER, TokenKind_TOKEN_ATTR_INLINE_ALWAYS, TokenKind_TOKEN_ATTR_EXPORT_NAME, TokenKind_TOKEN_ATTR_PANIC_HANDLER, TokenKind_TOKEN_ATTR_THREAD_LOCAL, TokenKind_TOKEN_ATTR_PERCPU, TokenKind_TOKEN_ALIGN, TokenKind_TOKEN_ENUM, TokenKind_TOKEN_GOTO, TokenKind_TOKEN_TRAIT, TokenKind_TOKEN_IMPL, TokenKind_TOKEN_SELF, TokenKind_TOKEN_UNDERSCORE, TokenKind_TOKEN_IMPORT, TokenKind_TOKEN_EXTERN, TokenKind_TOKEN_ASYNC, TokenKind_TOKEN_AWAIT, TokenKind_TOKEN_RUN, TokenKind_TOKEN_SPAWN, TokenKind_TOKEN_IDENT, TokenKind_TOKEN_I32, TokenKind_TOKEN_BOOL, TokenKind_TOKEN_U8, TokenKind_TOKEN_U32, TokenKind_TOKEN_U64, TokenKind_TOKEN_I64, TokenKind_TOKEN_USIZE, TokenKind_TOKEN_ISIZE, TokenKind_TOKEN_I32X4, TokenKind_TOKEN_I32X8, TokenKind_TOKEN_I32X16, TokenKind_TOKEN_U32X4, TokenKind_TOKEN_U32X8, TokenKind_TOKEN_U32X16, TokenKind_TOKEN_F32X4, TokenKind_TOKEN_TRUE, TokenKind_TOKEN_FALSE, TokenKind_TOKEN_F32, TokenKind_TOKEN_F64, TokenKind_TOKEN_VOID, TokenKind_TOKEN_INT, TokenKind_TOKEN_FLOAT, TokenKind_TOKEN_LPAREN, TokenKind_TOKEN_RPAREN, TokenKind_TOKEN_LBRACE, TokenKind_TOKEN_RBRACE, TokenKind_TOKEN_LBRACKET, TokenKind_TOKEN_RBRACKET, TokenKind_TOKEN_ARROW, TokenKind_TOKEN_FATARROW, TokenKind_TOKEN_COMMA, TokenKind_TOKEN_COLON, TokenKind_TOKEN_DOT, TokenKind_TOKEN_DOTDOT, TokenKind_TOKEN_ELLIPSIS, TokenKind_TOKEN_SEMICOLON, TokenKind_TOKEN_PLUS, TokenKind_TOKEN_MINUS, TokenKind_TOKEN_STAR, TokenKind_TOKEN_SLASH, TokenKind_TOKEN_PERCENT, TokenKind_TOKEN_AMP, TokenKind_TOKEN_PIPE, TokenKind_TOKEN_CARET, TokenKind_TOKEN_LSHIFT, TokenKind_TOKEN_RSHIFT, TokenKind_TOKEN_PLUS_EQ, TokenKind_TOKEN_MINUS_EQ, TokenKind_TOKEN_STAR_EQ, TokenKind_TOKEN_SLASH_EQ, TokenKind_TOKEN_PERCENT_EQ, TokenKind_TOKEN_AMP_EQ, TokenKind_TOKEN_PIPE_EQ, TokenKind_TOKEN_CARET_EQ, TokenKind_TOKEN_LSHIFT_EQ, TokenKind_TOKEN_RSHIFT_EQ, TokenKind_TOKEN_TILDE, TokenKind_TOKEN_ASSIGN, TokenKind_TOKEN_EQ, TokenKind_TOKEN_NE, TokenKind_TOKEN_LT, TokenKind_TOKEN_GT, TokenKind_TOKEN_LE, TokenKind_TOKEN_GE, TokenKind_TOKEN_AMPAMP, TokenKind_TOKEN_PIPEPIPE, TokenKind_TOKEN_BANG, TokenKind_TOKEN_QUESTION, TokenKind_TOKEN_AS, TokenKind_TOKEN_AT, TokenKind_TOKEN_STRING, TokenKind_TOKEN_EXPORT };
struct Token {
  int32_t kind;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t * ident;
  int32_t ident_len;
};

extern int token_is_eof(struct Token t);
int token_is_eof(struct Token t) {
  return ((t.kind) ==0);
}
