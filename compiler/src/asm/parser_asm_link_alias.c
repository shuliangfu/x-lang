/**
 * parser_asm_link_alias.c — pipeline / runtime 链接别名：pipeline 期望 parser_* 前缀，
 * asm 编 parser.sx bootstrap .o 可能导出裸名 parse_into_buf 等，由此转发。
 */
#include <stddef.h>
#include <stdint.h>

/** 与 parser_gen / pipeline_gen []u8 切片 ABI 一致。 */
struct shux_slice_uint8_t {
  uint8_t *data;
  size_t length;
};

struct ASTModule;
struct ast_ASTArena;

/** 与 parser.sx ParseIntoResult 布局一致。 */
struct parser_ParseIntoResult {
  int32_t ok;
  int32_t main_idx;
};

extern int32_t parser_asm_copy_module_import_path64_c(struct ASTModule *module, int32_t i, uint8_t *out);
extern int32_t parser_parse_one_function_ok_for_pipeline_glue(void *arena, struct shux_slice_uint8_t *source);
extern int32_t parser_diag_token_after_collect_imports_glue(struct shux_slice_uint8_t *source, void *module);

#ifndef PARSER_ASM_LINK_ALIAS_SKIP_SU_SYMBOLS
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

#ifndef PARSER_ASM_LINK_ALIAS_SKIP_SU_SYMBOLS
/**
 * pipeline 期望 parser_copy_module_import_path64；委托 thin C copy+len。
 */
int32_t parser_copy_module_import_path64(struct ASTModule *module, int32_t i, uint8_t out[64]) {
  return parser_asm_copy_module_import_path64_c(module, i, out);
}
#endif

#ifndef PARSER_ASM_LINK_ALIAS_SKIP_SU_SYMBOLS
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
