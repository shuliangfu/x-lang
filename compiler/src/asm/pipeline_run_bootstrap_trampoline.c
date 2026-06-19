/**
 * pipeline_run_bootstrap_trampoline.c — B-strict 链 runtime 入口薄壳
 *
 * 勿链 pipeline_sx.o 仅导出 run_sx_pipeline_impl 的 partial（同 TU 内 local 编排/codegen 绑定 → 大模块 SIGSEGV）。
 * build_asm/pipeline.o 自举完成（__text>512B 且 run_sx_pipeline_impl 含 bl 真机码）时链真 run_sx_pipeline_impl；
 * 否则 strict_core partial 的 pipeline_impl_run_all（由 pipeline_sx.o / strict_core partial 导出；-E-extern 瘦 TU 无 pipeline_pipeline_* 前缀）。
 */
#include <stddef.h>
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;
struct codegen_CodegenOutBuf;

#ifdef STRICT_LINK_BUILD_ASM_PIPELINE
/** build_asm/pipeline.o 真 emit 编排入口（asm 裸名）。 */
extern int32_t run_sx_pipeline_impl(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                    size_t source_len, struct codegen_CodegenOutBuf *out_buf,
                                    struct ast_PipelineDepCtx *ctx);
#else
/** strict_core partial（pipeline_sx.o ld -r）导出的完整编排入口。 */
extern int32_t pipeline_impl_run_all(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                     size_t source_len, struct codegen_CodegenOutBuf *out_buf,
                                     struct ast_PipelineDepCtx *ctx);
#endif

/** runtime / glue 统一入口；须为全局 T，供 pipeline_glue 与 pthread 大栈路径调用。 */
int32_t pipeline_run_sx_pipeline_impl(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                      size_t source_len, struct codegen_CodegenOutBuf *out_buf,
                                      struct ast_PipelineDepCtx *ctx) {
#ifdef STRICT_LINK_BUILD_ASM_PIPELINE
  return run_sx_pipeline_impl(module, arena, source_data, source_len, out_buf, ctx);
#else
  return pipeline_impl_run_all(module, arena, source_data, source_len, out_buf, ctx);
#endif
}
