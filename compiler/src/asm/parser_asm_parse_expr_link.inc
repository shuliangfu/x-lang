/**
 * parser_asm_parse_expr_link.c — parser_asm_thin 与 parser_x.o 的链接桥 + pipeline 别名。
 *
 * 1) parse_expr_into：thin 切片裸名 → parser_parse_expr_into（字段拷贝转发）
 * 2) parse_into* / parser_parse_into* 弱桩：seed 链无 bootstrap .o 时兜底
 * 3) parser_* 前缀别名（可选）：-DPARSER_ASM_LINK_ALIAS_SKIP_X_SYMBOLS 时省略
 *    （产品/G05 默认 SKIP：由 thin_glue / parser_x 提供强符号）
 *
 * G-02e-7：原 parser_asm_link_alias.c 并入本 TU。
 */
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

/** 与 parser_asm / lexer.x Lexer 布局一致。 */
struct parser_asm_lexer {
  size_t pos;
  int32_t line;
  int32_t col;
};

struct parser_asm_slice_u8 {
  uint8_t *data;
  size_t length;
};

/** 与 parser_asm_body_let_slice.inc 中 parser_asm_parse_expr_result 一致。 */
struct parser_asm_parse_expr_result {
  int32_t ok;
  int32_t expr_ref;
  struct parser_asm_lexer next_lex;
};

/** 与 parser_gen / pipeline_gen u8[] 切片 ABI 一致。 */
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

/** 与 parser.x ParseIntoResult 布局一致。 */
struct parser_ParseIntoResult {
  int32_t ok;
  int32_t main_idx;
};

struct ASTModule;
struct ast_ASTArena;

extern void parser_parse_expr_into(struct ast_ASTArena *arena, struct lexer_Lexer lex,
                                   struct shux_slice_uint8_t *source, struct parser_ParseExprResult *out);

extern int32_t parser_asm_copy_module_import_path64_c(struct ASTModule *module, int32_t i, uint8_t *out);
extern int32_t parser_parse_one_function_ok_for_pipeline_glue(void *arena, struct shux_slice_uint8_t *source);
extern int32_t parser_diag_token_after_collect_imports_glue(struct shux_slice_uint8_t *source, void *module);

static int parser_asm_parse_expr_debug_enabled(void) {
  const char *v = getenv("SHUX_PARSER_ASM_DEBUG");
  return v && *v && *v != '0';
}

static void parser_asm_parse_expr_debug_snippet_c(struct parser_asm_slice_u8 *source, size_t pos) {
  size_t start;
  size_t end;
  size_t i;
  if (!source || !source->data || source->length == 0) {
    fprintf(stderr, " snippet=<no-source>\n");
    return;
  }
  start = pos;
  if (start > source->length)
    start = source->length;
  if (start > 12)
    start -= 12;
  else
    start = 0;
  end = pos + 24;
  if (end > source->length)
    end = source->length;
  fprintf(stderr, " snippet=");
  for (i = start; i < end; i++) {
    unsigned char ch = source->data[i];
    if (ch == (unsigned char)'\n')
      fputs("\\n", stderr);
    else if (ch == (unsigned char)'\r')
      fputs("\\r", stderr);
    else if (ch == (unsigned char)'\t')
      fputs("\\t", stderr);
    else if (ch < 32 || ch > 126)
      fprintf(stderr, "\\x%02x", ch);
    else
      fputc((int)ch, stderr);
  }
  fputc('\n', stderr);
}

/**
 * asm thin 切片入口：转发至 parser_x.o 的 parser_parse_expr_into。
 */
void parse_expr_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                     struct parser_asm_parse_expr_result *out) {
  enum { PARSER_ASM_PARSE_EXPR_SAME_POS_WARN = 4096 };
  static size_t prev_in_pos = (size_t)-1;
  static int32_t same_in_pos_count = 0;
  static int32_t parse_expr_debug_calls = 0;
  int debug_enabled;
  struct lexer_Lexer mega_lex;
  struct shux_slice_uint8_t mega_src;
  struct parser_ParseExprResult mega_out;
  if (!source || !out) {
    return;
  }
  debug_enabled = parser_asm_parse_expr_debug_enabled();
  parse_expr_debug_calls++;
  if (lex.pos == prev_in_pos) {
    same_in_pos_count++;
  } else {
    prev_in_pos = lex.pos;
    same_in_pos_count = 0;
  }
  if (debug_enabled && (parse_expr_debug_calls <= 64 || (parse_expr_debug_calls % 4096) == 0
      || same_in_pos_count == PARSER_ASM_PARSE_EXPR_SAME_POS_WARN)) {
    fprintf(stderr, "parser_asm parse_expr enter call=%d in_pos=%zu line=%d col=%d len=%zu same=%d\n",
            parse_expr_debug_calls, lex.pos, lex.line, lex.col, source->length, same_in_pos_count);
    if (parse_expr_debug_calls <= 16)
      parser_asm_parse_expr_debug_snippet_c(source, lex.pos);
    fflush(stderr);
  }
  mega_lex.pos = lex.pos;
  mega_lex.line = lex.line;
  mega_lex.col = lex.col;
  mega_src.data = source->data;
  mega_src.length = source->length;
  parser_parse_expr_into((struct ast_ASTArena *)arena, mega_lex, &mega_src, &mega_out);
  if (debug_enabled && (parse_expr_debug_calls <= 64 || (parse_expr_debug_calls % 4096) == 0 || mega_out.next_lex.pos < lex.pos
      || mega_out.next_lex.pos == lex.pos || same_in_pos_count >= PARSER_ASM_PARSE_EXPR_SAME_POS_WARN)) {
    fprintf(stderr, "parser_asm parse_expr leave call=%d ok=%d in_pos=%zu out_pos=%zu expr=%d out_line=%d out_col=%d\n",
            parse_expr_debug_calls, mega_out.ok, lex.pos, mega_out.next_lex.pos, mega_out.expr_ref, mega_out.next_lex.line,
            mega_out.next_lex.col);
    fflush(stderr);
  }
  out->ok = mega_out.ok;
  out->expr_ref = mega_out.expr_ref;
  out->next_lex.pos = mega_out.next_lex.pos;
  out->next_lex.line = mega_out.next_lex.line;
  out->next_lex.col = mega_out.next_lex.col;
}

/* ---- G-02e-7：原 parser_asm_link_alias（pipeline / runtime 链接别名 + 弱 parse 桩）---- */

#ifndef PARSER_ASM_LINK_ALIAS_SKIP_X_SYMBOLS
/** runtime 期望 parser_diag_token_after_collect_imports；委托 thin_c glue。 */
int32_t parser_diag_token_after_collect_imports(struct shux_slice_uint8_t *source, void *module) {
  return parser_diag_token_after_collect_imports_glue(source, module);
}
#endif

/**
 * seed ./shux 链无 parser_parse_bootstrap.o 时提供弱裸名桩；experimental 链入真 bootstrap .o 后覆盖。
 */
__attribute__((weak)) struct parser_ParseIntoResult parse_into_buf(void *arena, void *module, uint8_t *data,
                                                                   int32_t len) {
  (void)arena;
  (void)module;
  (void)data;
  (void)len;
  struct parser_ParseIntoResult r;
  r.ok = 0;
  r.main_idx = -1;
  return r;
}

__attribute__((weak)) struct parser_ParseIntoResult parse_into(void *arena, void *module,
                                                                struct shux_slice_uint8_t *source) {
  (void)arena;
  (void)module;
  (void)source;
  struct parser_ParseIntoResult r;
  r.ok = 0;
  r.main_idx = -1;
  return r;
}

__attribute__((weak)) void parse_into_set_main_index(void *module, int32_t main_idx) {
  (void)module;
  (void)main_idx;
}

/** parser_parse_bootstrap.o 真 emit 时覆盖上述弱裸名桩。 */

#ifndef PARSER_ASM_LINK_ALIAS_SKIP_X_SYMBOLS
/**
 * pipeline 期望 parser_copy_module_import_path64；委托 thin C copy+len。
 */
int32_t parser_copy_module_import_path64(struct ASTModule *module, int32_t i, uint8_t out[64]) {
  return parser_asm_copy_module_import_path64_c(module, i, out);
}
#endif

#ifndef PARSER_ASM_LINK_ALIAS_SKIP_X_SYMBOLS
/**
 * pipeline 期望 (arena, source) 两参；委托 parse_one_function_ok_for_pipeline_glue。
 */
int32_t parser_parse_one_function_ok_for_pipeline(void *arena, struct shux_slice_uint8_t *source) {
  return parser_parse_one_function_ok_for_pipeline_glue(arena, source);
}
#endif

/** runtime 期望 parser_parse_into_buf；legacy .text / bootstrap .o 强符号覆盖弱默认。 */
__attribute__((weak)) struct parser_ParseIntoResult parser_parse_into_buf(void *arena, void *module, uint8_t *data,
                                                                          int32_t len) {
  return parse_into_buf(arena, module, data, len);
}

/** runtime 期望 parser_parse_into；legacy .text / bootstrap .o 强符号覆盖弱默认。 */
__attribute__((weak)) struct parser_ParseIntoResult parser_parse_into(void *arena, void *module,
                                                                       struct shux_slice_uint8_t *source) {
  return parse_into(arena, module, source);
}

/** runtime 期望 parser_parse_into_set_main_index；legacy .text / bootstrap .o 强符号覆盖弱默认。 */
__attribute__((weak)) void parser_parse_into_set_main_index(void *module, int32_t main_idx) {
  parse_into_set_main_index(module, main_idx);
}
