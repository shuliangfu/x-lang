/**
 * parser_asm_parse_expr_link.c — parser_asm_thin 与 parser_sx.o 的 parse_expr_into 链接桥。
 *
 * thin_c 切片期望裸名 parse_expr_into（parser_asm_lexer / parser_asm_slice_u8）；
 * parser_gen.c 导出 parser_parse_expr_into（lexer_Lexer / shux_slice_uint8_t）。
 * 布局与 parser.sx ParseExprResult 一致，此处做字段拷贝转发。
 */
#include <stdint.h>
#include <stddef.h>

/** 与 parser_asm / lexer.sx Lexer 布局一致。 */
struct parser_asm_lexer {
  size_t pos;
  int32_t line;
  int32_t col;
};

struct parser_asm_slice_u8 {
  uint8_t *data;
  size_t length;
};

/** 与 parser_asm_body_let_slice.c 中 parser_asm_parse_expr_result 一致。 */
struct parser_asm_parse_expr_result {
  int32_t ok;
  int32_t expr_ref;
  struct parser_asm_lexer next_lex;
};

struct shux_slice_uint8_t {
  uint8_t *data;
  size_t length;
};

struct lexer_Lexer {
  size_t pos;
  int32_t line;
  int32_t col;
};

struct parser_ParseExprResult {
  int32_t ok;
  int32_t expr_ref;
  struct lexer_Lexer next_lex;
};

struct ast_ASTArena;

extern void parser_parse_expr_into(struct ast_ASTArena *arena, struct lexer_Lexer lex,
                                   struct shux_slice_uint8_t *source, struct parser_ParseExprResult *out);

/**
 * asm thin 切片入口：转发至 parser_sx.o 的 parser_parse_expr_into。
 */
void parse_expr_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                     struct parser_asm_parse_expr_result *out) {
  struct lexer_Lexer mega_lex;
  struct shux_slice_uint8_t mega_src;
  struct parser_ParseExprResult mega_out;
  if (!source || !out) {
    return;
  }
  mega_lex.pos = lex.pos;
  mega_lex.line = lex.line;
  mega_lex.col = lex.col;
  mega_src.data = source->data;
  mega_src.length = source->length;
  parser_parse_expr_into((struct ast_ASTArena *)arena, mega_lex, &mega_src, &mega_out);
  out->ok = mega_out.ok;
  out->expr_ref = mega_out.expr_ref;
  out->next_lex.pos = mega_out.next_lex.pos;
  out->next_lex.line = mega_out.next_lex.line;
  out->next_lex.col = mega_out.next_lex.col;
}
