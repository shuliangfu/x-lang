/**
 * pipeline_run_su_link_alias.c — experimental 链 pipeline SU helper 符号别名
 *
 * pipeline_su.o（-E-extern C 生成）导出 pipeline_run_su_pipeline_*；
 * orchestration 期望 run_su_pipeline_* 裸名。
 * strict 链由 build_asm/pipeline.o asm 真 emit 提供裸名，勿链本 TU。
 */
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;
struct codegen_CodegenOutBuf;

extern int32_t pipeline_run_su_pipeline_fill_dep_import_path(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                                             int32_t dep_j);
extern int32_t pipeline_run_su_pipeline_codegen_one_dep(struct ast_Module *module, struct codegen_CodegenOutBuf *out_buf,
                                                          struct ast_PipelineDepCtx *ctx, int32_t dep_j,
                                                          int32_t skip_asm_dep_codegen);
extern int32_t pipeline_run_su_pipeline_codegen_deps(struct ast_Module *module, struct ast_ASTArena *arena,
                                                       struct codegen_CodegenOutBuf *out_buf,
                                                       struct ast_PipelineDepCtx *ctx, int32_t skip_asm_dep_codegen);
extern int32_t pipeline_run_su_pipeline_codegen_entry(struct ast_Module *module, struct ast_ASTArena *arena,
                                                        struct codegen_CodegenOutBuf *out_buf,
                                                        struct ast_PipelineDepCtx *ctx);

/** orchestration 裸名 → pipeline_su.o 模块前缀导出。 */
int32_t run_su_pipeline_fill_dep_import_path(struct ast_Module *module, struct ast_PipelineDepCtx *ctx, int32_t dep_j) {
  return pipeline_run_su_pipeline_fill_dep_import_path(module, ctx, dep_j);
}

/** orchestration 裸名 → pipeline_su.o 模块前缀导出。 */
int32_t run_su_pipeline_codegen_one_dep(struct ast_Module *module, struct codegen_CodegenOutBuf *out_buf,
                                          struct ast_PipelineDepCtx *ctx, int32_t dep_j, int32_t skip_asm_dep_codegen) {
  return pipeline_run_su_pipeline_codegen_one_dep(module, out_buf, ctx, dep_j, skip_asm_dep_codegen);
}

/** orchestration 裸名 → pipeline_su.o 模块前缀导出。 */
int32_t run_su_pipeline_codegen_deps(struct ast_Module *module, struct ast_ASTArena *arena,
                                     struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx,
                                     int32_t skip_asm_dep_codegen) {
  return pipeline_run_su_pipeline_codegen_deps(module, arena, out_buf, ctx, skip_asm_dep_codegen);
}

/** orchestration 裸名 → pipeline_su.o 模块前缀导出。 */
int32_t run_su_pipeline_codegen_entry(struct ast_Module *module, struct ast_ASTArena *arena,
                                      struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx) {
  return pipeline_run_su_pipeline_codegen_entry(module, arena, out_buf, ctx);
}
