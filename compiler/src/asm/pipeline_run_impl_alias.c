/**
 * pipeline_run_impl_alias.c — 实验 asm-only 链：build_asm/pipeline.o 导出 run_su_pipeline_impl，
 * runtime/glue 期望 pipeline_run_su_pipeline_impl（与 pipeline_gen.c 一致）。仅在不链 pipeline_su.o 时并入。
 */
#include <stddef.h>
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;
struct codegen_CodegenOutBuf;

extern int32_t run_su_pipeline_impl(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                    size_t source_len, struct codegen_CodegenOutBuf *out_buf,
                                    struct ast_PipelineDepCtx *ctx);

/** glue / runtime 统一入口名。 */
int32_t pipeline_run_su_pipeline_impl(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                      size_t source_len, struct codegen_CodegenOutBuf *out_buf,
                                      struct ast_PipelineDepCtx *ctx) {
  return run_su_pipeline_impl(module, arena, source_data, source_len, out_buf, ctx);
}

/*
 * strict 链：build_asm/parser.o 自举 parse 时跳过大函数（parse_into_buf 等未进 module），
 * 须由 parser_bootstrap_partial.o（自 pipeline_su.o 部分链接）提供 parser_parse_into_buf。
 * 本文件仅导出裸名 parse_into_buf → bootstrap parser_parse_into_buf，供 pipeline.su CALL。
 * 勿转发至 parse_into_with_init_buf（与 pipeline.su 内 parser.parse_into_buf 形成递归）。
 */
struct parser_ParseIntoResult {
  int32_t ok;
  int32_t main_idx;
};

/** bootstrap -E 符号（parser_ 前缀）；ensure_parser_bootstrap_partial_obj 链入。 */
extern struct parser_ParseIntoResult parser_parse_into_buf(void *arena, void *module, uint8_t *data, int32_t len);

/** build_asm 裸名 → bootstrap，pipeline.parse_into_with_init_buf 内 CALL 用。 */
struct parser_ParseIntoResult parse_into_buf(void *arena, void *module, uint8_t *data, int32_t len) {
  return parser_parse_into_buf(arena, module, data, len);
}

/** build_asm/pipeline.o 引用 parser.parse_into_init（裸名）；strict_core partial 提供 parser_parse_into_init。 */
extern void parser_parse_into_init(void *arena, void *module);

void parse_into_init(void *module, void *arena) {
  parser_parse_into_init(arena, module);
}
