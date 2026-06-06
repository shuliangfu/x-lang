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
extern void typeck_wpo_unify_soa_layouts(struct ast_Module *entry,
                                           struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_struct_layout_metrics(struct ast_Module *module, struct ast_ASTArena *arena,
                                            int32_t li, int32_t depth, int32_t check_pad,
                                            int32_t *out_sz, int32_t *out_al);
extern int32_t pipeline_typeck_check_block_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                  int32_t block_ref, int32_t return_type_ref,
                                                  struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_check_expr_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                 int32_t expr_ref, int32_t return_type_ref,
                                                 struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_find_or_alloc_ptr_type_ref(struct ast_ASTArena *arena, int32_t elem_ref);
extern int32_t pipeline_module_num_funcs(struct ast_Module *module);
extern int32_t pipeline_module_main_func_index(struct ast_Module *module);

/** pipeline_gen.c 经 typeck 模块前缀修饰的 glue 读 → ast_pool pipeline_module_*。 */
int32_t typeck_pipeline_module_num_funcs(struct ast_Module *module) {
  return pipeline_module_num_funcs(module);
}

/** pipeline_gen.c 经 typeck 模块前缀修饰的 glue 读 → ast_pool pipeline_module_*。 */
int32_t typeck_pipeline_module_main_func_index(struct ast_Module *module) {
  return pipeline_module_main_func_index(module);
}

/** pipeline_glue 期望的无前缀符号 → typeck_su 的 typeck_*（整链 build_asm/typeck.o 时由强符号覆盖）。 */
__attribute__((weak)) int32_t check_block_impl(struct ast_Module *module, struct ast_ASTArena *arena, int32_t block_ref,
                                               int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return pipeline_typeck_check_block_impl_c(module, arena, block_ref, return_type_ref, ctx);
}

__attribute__((weak)) int32_t check_expr_impl(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                              int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return pipeline_typeck_check_expr_impl_c(module, arena, expr_ref, return_type_ref, ctx);
}

/** typeck_su 导出名 → glue addr_of；build_asm 已导出裸符号时 weak 被覆盖。 */
__attribute__((weak)) int32_t find_or_alloc_ptr_type_ref(struct ast_ASTArena *arena, int32_t elem_ref) {
  return typeck_find_or_alloc_ptr_type_ref(arena, elem_ref);
}

/** WPO-S3：bootstrap 链 typeck_su.o 链接期弱 stub；shu_asm 链 ast_pool 强符号覆盖。 */
__attribute__((weak)) void pipeline_typeck_set_active_ctx_c(struct ast_Module *module,
                                                            struct ast_PipelineDepCtx *ctx) {
  (void)module;
  (void)ctx;
}

__attribute__((weak)) int32_t pipeline_typeck_ptr_for_addr_of_operand_c(struct ast_ASTArena *arena, int32_t op_ref,
                                                                      int32_t elem_ty, struct ast_Module *module,
                                                                      struct ast_PipelineDepCtx *ctx) {
  (void)arena;
  (void)op_ref;
  (void)elem_ty;
  (void)module;
  (void)ctx;
  return 0;
}

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

void typeck_typeck_wpo_unify_soa_layouts(struct ast_Module *entry,
                                         struct ast_PipelineDepCtx *ctx) {
  typeck_wpo_unify_soa_layouts(entry, ctx);
}

/** typeck_gen 对 ast 模块 extern 加 ast_ 前缀；定义在 pipeline_su.o（ast_pool.c）。 */
extern void pipeline_module_struct_layout_set_soa(struct ast_Module *m, int32_t idx, int32_t v);
extern int32_t pipeline_module_struct_layout_soa_at(struct ast_Module *m, int32_t idx);
extern int32_t pipeline_module_struct_layout_field_align_at(struct ast_Module *m, int32_t li, int32_t j);
extern void pipeline_module_struct_layout_set_field_align(struct ast_Module *m, int32_t li, int32_t j,
                                                          int32_t al);

void ast_pipeline_module_struct_layout_set_soa(struct ast_Module *m, int32_t idx, int32_t v) {
  pipeline_module_struct_layout_set_soa(m, idx, v);
}

int32_t ast_pipeline_module_struct_layout_soa_at(struct ast_Module *m, int32_t idx) {
  return pipeline_module_struct_layout_soa_at(m, idx);
}

int32_t ast_pipeline_module_struct_layout_field_align_at(struct ast_Module *m, int32_t li, int32_t j) {
  return pipeline_module_struct_layout_field_align_at(m, li, j);
}

void ast_pipeline_module_struct_layout_set_field_align(struct ast_Module *m, int32_t li, int32_t j, int32_t al) {
  pipeline_module_struct_layout_set_field_align(m, li, j, al);
}

/** 定义在 pipeline_glue.c（C metrics 热路径）；此处勿重复导出以免 duplicate symbol。 */
