/* seeds/pipeline_wpo_typecheck_emit_bridge.from_x.c — G-02f-79 product cold-start TU
 * Promoted from compiler/src/asm/pipeline_wpo_typecheck_emit_bridge.inc (alias/stub; retired .inc).
 * Compile: cc -c seeds/pipeline_wpo_typecheck_emit_bridge.from_x.c  (or cc_inc_tu wrap).
 */
/**
 * pipeline_wpo_typecheck_emit_bridge.c — WPO helper 链：X typecheck_entry thin bl 依赖 emit 桥。
 *
 * pipeline_wpo_helpers_partial 可能仍含 run_x_pipeline_typecheck_entry；本 TU 提供
 * run_x_pipeline_typecheck_entry_emit → glue emit_c（勿提供 pipeline_run_x_pipeline_impl）。
 */
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;

extern int32_t run_x_pipeline_typecheck_entry_emit_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                       struct ast_PipelineDepCtx *ctx);

extern int32_t pipeline_resolve_path_try_one_lib_root(struct ast_PipelineDepCtx *ctx, int32_t lib_idx,
                                                      uint8_t *import_path, int32_t path_len);

/** pipeline_wpo.o X typecheck_entry 的 thin bl 目标。 */
int32_t run_x_pipeline_typecheck_entry_emit(struct ast_Module *module, struct ast_ASTArena *arena,
                                             struct ast_PipelineDepCtx *ctx) {
  return run_x_pipeline_typecheck_entry_emit_c(module, arena, ctx);
}

/** pipeline_wpo_helpers_partial 的裸名调用桥接到 pipeline.x 导出的真实符号。 */
int32_t resolve_path_try_one_lib_root(struct ast_PipelineDepCtx *ctx, int32_t lib_idx,
                                      uint8_t *import_path, int32_t path_len) {
  return pipeline_resolve_path_try_one_lib_root(ctx, lib_idx, import_path, path_len);
}
