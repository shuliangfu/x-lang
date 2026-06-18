/**
 * pipeline_wpo_typecheck_emit_bridge.c — WPO helper 链：SU typecheck_entry thin bl 依赖 emit 桥。
 *
 * pipeline_wpo_helpers_partial 可能仍含 run_su_pipeline_typecheck_entry；本 TU 提供
 * run_su_pipeline_typecheck_entry_emit → glue emit_c（勿提供 pipeline_run_su_pipeline_impl）。
 */
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;

extern int32_t run_su_pipeline_typecheck_entry_emit_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                       struct ast_PipelineDepCtx *ctx);

/** pipeline_wpo.o SU typecheck_entry 的 thin bl 目标。 */
int32_t run_su_pipeline_typecheck_entry_emit(struct ast_Module *module, struct ast_ASTArena *arena,
                                             struct ast_PipelineDepCtx *ctx) {
  return run_su_pipeline_typecheck_entry_emit_c(module, arena, ctx);
}
