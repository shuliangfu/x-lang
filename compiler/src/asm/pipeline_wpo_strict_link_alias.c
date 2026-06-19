/**
 * pipeline_wpo_strict_link_alias.c — strict WPO 链 glue：pipeline_wpo.o SU 编排 + runtime 期望名。
 *
 * pipeline_wpo.o 导出 run_sx_pipeline_impl；glue/driver 仍引用 pipeline_run_sx_pipeline_impl。
 * SU typecheck_entry thin bl 引用 run_sx_pipeline_typecheck_entry_emit → ast_pool emit_c。
 * strict 链不链 C orchestration partial 时由本 TU 补齐，避免 duplicate run_sx_pipeline_impl。
 */
#include <stdint.h>
#include <stddef.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;
struct codegen_CodegenOutBuf;

/** pipeline_wpo.o WPO 根编排（asm emit）。 */
extern int32_t run_sx_pipeline_impl(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                    size_t source_len, struct codegen_CodegenOutBuf *out_buf,
                                    struct ast_PipelineDepCtx *ctx);

/** glue / driver 统一入口名 → pipeline_wpo.o run_sx_pipeline_impl。 */
int32_t pipeline_run_sx_pipeline_impl(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                      size_t source_len, struct codegen_CodegenOutBuf *out_buf,
                                      struct ast_PipelineDepCtx *ctx) {
  return run_sx_pipeline_impl(module, arena, source_data, source_len, out_buf, ctx);
}

/** ast_pool.c：entry typecheck emit C glue。 */
extern int32_t run_sx_pipeline_typecheck_entry_emit_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                       struct ast_PipelineDepCtx *ctx);

/** SU typecheck_entry thin bl → C emit（pipeline_wpo.o U 此符号）。 */
int32_t run_sx_pipeline_typecheck_entry_emit(struct ast_Module *module, struct ast_ASTArena *arena,
                                             struct ast_PipelineDepCtx *ctx) {
  return run_sx_pipeline_typecheck_entry_emit_c(module, arena, ctx);
}
