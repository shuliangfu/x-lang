/**
 * pipeline_glue_link.c — Target B 实验链用最小 C 桥（不拉整份 pipeline_gen.c）。
 *
 * 提供 runtime_driver.o 调用的 pipeline_run_su_pipeline 包装；实现体为 pipeline_run_su_pipeline_impl
 *（pipeline_su.o）或 build_asm/pipeline.o 的 run_su_pipeline_impl（经 pipeline_run_impl_alias.o 别名）。
 */
#include <stddef.h>
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;
struct codegen_CodegenOutBuf;

extern int32_t pipeline_run_su_pipeline_impl(struct ast_Module *module, struct ast_ASTArena *arena,
                                             uint8_t *source_data, size_t source_len,
                                             struct codegen_CodegenOutBuf *out_buf,
                                             struct ast_PipelineDepCtx *ctx);

/** runtime.c 经 buf+len 调 pipeline；转发至 .su pipeline 实现符号。 */
int32_t pipeline_run_su_pipeline(struct ast_Module *module, struct ast_ASTArena *arena,
                                 const uint8_t *source_data, size_t source_len,
                                 struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx) {
  return pipeline_run_su_pipeline_impl(module, arena, (uint8_t *)source_data, source_len, out_buf, ctx);
}
