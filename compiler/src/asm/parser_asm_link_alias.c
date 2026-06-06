/**
 * parser_asm_link_alias.c — strict shu_asm 链接别名：build_asm/parser.o 导出单前缀符号，
 * pipeline/glue 仍引用 parser_* 前缀（与 fix_pipeline_extern_gen_c 一致）。
 */
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct shulang_slice_uint8_t;

extern int32_t copy_module_import_path64(struct ast_Module *module, int32_t i, uint8_t *out);
extern int32_t parse_one_function_ok_for_pipeline(struct ast_Module *module, struct ast_ASTArena *arena,
    struct shulang_slice_uint8_t *source, int32_t *out_main_idx);

/** glue/pipeline 期望 parser_copy_module_import_path64；实现委托 copy_module_import_path64。 */
int32_t parser_copy_module_import_path64(struct ast_Module *module, int32_t i, uint8_t out[64]) {
  return copy_module_import_path64(module, i, out);
}

/** pipeline_should_skip_su_typeck 委托 parse_one_function_ok_for_pipeline。 */
int32_t parser_parse_one_function_ok_for_pipeline(struct ast_Module *module, struct ast_ASTArena *arena,
    struct shulang_slice_uint8_t *source, int32_t *out_main_idx) {
  return parse_one_function_ok_for_pipeline(module, arena, source, out_main_idx);
}
