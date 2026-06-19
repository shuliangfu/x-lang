/**
 * pipeline_asm_run_all_alias.c — strict 链：pipeline_impl_run_all / run_sx_pipeline_impl 的 C 实现。
 *
 * build_asm/pipeline.o 第二遍 emit 的 run_all 在 typecheck 失败后 cbz 分支错误，仍会进入 codegen，
 * 导致 return-value smoke 等 case CPU 100% 挂死；本 TU 按 pipeline.sx 语义在 typeck 失败时立即返回。
 */
#include <stddef.h>
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;
struct codegen_CodegenOutBuf;

extern int32_t pipeline_impl_phase_parse_load(struct ast_Module *module, struct ast_ASTArena *arena,
                                              uint8_t *source_data, size_t source_len,
                                              struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_impl_typecheck(struct ast_Module *module, struct ast_ASTArena *arena,
                                       struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_impl_should_skip_codegen(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_impl_codegen_chain(struct ast_Module *module, struct ast_ASTArena *arena,
                                           struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx);

/** 完整流水线编排；与 pipeline.sx pipeline_impl_run_all 一致。 */
int32_t pipeline_impl_run_all(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                              size_t source_len, struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx) {
  int32_t pl;
  int32_t tc;
  pl = pipeline_impl_phase_parse_load(module, arena, source_data, source_len, ctx);
  if (pl != 0) {
    return pl;
  }
  tc = pipeline_impl_typecheck(module, arena, ctx);
  if (tc != 0) {
    return tc;
  }
  if (pipeline_impl_should_skip_codegen(ctx) != 0) {
    return 0;
  }
  return pipeline_impl_codegen_chain(module, arena, out_buf, ctx);
}

/** glue / pipeline_run_impl_alias 调用的裸名入口。 */
int32_t run_sx_pipeline_impl(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                             size_t source_len, struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx) {
  return pipeline_impl_run_all(module, arena, source_data, source_len, out_buf, ctx);
}
