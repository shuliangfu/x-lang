/**
 * pipeline_gen.c 调用 typeck_typeck_su_ast*；typeck_gen.c 导出 typeck_su_ast*。
 * 链接期别名，避免重编不同命名约定的 pipeline_su.o。
 */
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;

extern int32_t typeck_su_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                             struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_su_ast_library(struct ast_Module *module, struct ast_ASTArena *arena,
                                     struct ast_PipelineDepCtx *ctx);
extern void typeck_merge_dep_struct_layouts_into_entry(struct ast_Module *mod,
                                                       struct ast_ASTArena *arena,
                                                       struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_struct_layout_metrics(struct ast_Module *module, struct ast_ASTArena *arena,
                                            int32_t li, int32_t depth, int32_t check_pad,
                                            int32_t *out_sz, int32_t *out_al);

int32_t typeck_typeck_su_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                             struct ast_PipelineDepCtx *ctx) {
  return typeck_su_ast(module, arena, ctx);
}

int32_t typeck_typeck_su_ast_library(struct ast_Module *module, struct ast_ASTArena *arena,
                                     struct ast_PipelineDepCtx *ctx) {
  return typeck_su_ast_library(module, arena, ctx);
}

void typeck_typeck_merge_dep_struct_layouts_into_entry(struct ast_Module *mod,
                                                       struct ast_ASTArena *arena,
                                                       struct ast_PipelineDepCtx *ctx) {
  typeck_merge_dep_struct_layouts_into_entry(mod, arena, ctx);
}

int32_t typeck_typeck_struct_layout_metrics(struct ast_Module *module,
                                            struct ast_ASTArena *arena, int32_t li,
                                            int32_t depth, int32_t check_pad, int32_t *out_sz,
                                            int32_t *out_al) {
  return typeck_struct_layout_metrics(module, arena, li, depth, check_pad, out_sz, out_al);
}
