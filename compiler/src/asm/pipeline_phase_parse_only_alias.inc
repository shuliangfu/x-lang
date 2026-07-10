/**
 * pipeline_phase_parse_only_alias.c — strict asm 编排链：phase_parse_only + phase_parse_load。
 *
 * build_asm/pipeline.o 第二遍 emit 的 parse/phase_parse_load 易错；本 TU 提供 C 薄壳。
 * 勿经 pipeline_parse_into_with_init_buf（partial 内 init 与 runtime 预 init 叠加后 body_ref 易为 0）；
 * 与 bootstrap monolith 一致：strict reset + parser_parse_into_buf + parser_parse_into_set_main_index。
 */
#include <stddef.h>
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;

/** 与 parser 导出 layout 一致。 */
struct parser_ParseIntoResult {
  int32_t ok;
  int32_t main_idx;
};

/** ast_pool.c：等价 parser parse_into_init，重置 sidecar grow 池。 */
extern void pipeline_strict_parse_into_init(struct ast_ASTArena *arena, struct ast_Module *module);
/** pipeline_parse_x_partial.o 提供。 */
extern struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena *arena, struct ast_Module *module,
                                                             uint8_t *data, int32_t len);
extern void parser_parse_into_set_main_index(struct ast_Module *module, int32_t main_idx);
extern int32_t pipeline_module_num_funcs(struct ast_Module *module);
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern void driver_diagnostic_after_entry_parse_module(struct ast_Module *module);
extern void driver_diagnostic_entry_module(struct ast_Module *module, struct ast_ASTArena *arena);

/**
 * 解析 + 诊断（不含 load deps）；与 pipeline.x pipeline_impl_phase_parse_only 语义一致。
 */
__attribute__((noinline)) int32_t pipeline_impl_phase_parse_only(struct ast_Module *module, struct ast_ASTArena *arena,
                                                                   uint8_t *source_data, size_t source_len,
                                                                   struct ast_PipelineDepCtx *ctx) {
  struct parser_ParseIntoResult r;
  int32_t len_i32;
  (void)ctx;
  len_i32 = (int32_t)source_len;
  pipeline_strict_parse_into_init(arena, module);
  r = parser_parse_into_buf(arena, module, source_data, len_i32);
  parser_parse_into_set_main_index(module, r.main_idx);
  driver_diagnostic_after_entry_parse(pipeline_module_num_funcs(module));
  driver_diagnostic_after_entry_parse_module(module);
  driver_diagnostic_entry_module(module, arena);
  return -2 * r.ok;
}

/** 加载 direct import deps；委托 pipeline.o 内 asm stub（单文件 smoke 返回 0）。 */
extern int32_t pipeline_impl_phase_load_deps(struct ast_Module *module, struct ast_ASTArena *arena,
                                             struct ast_PipelineDepCtx *ctx);

/**
 * 解析 + load deps；build_asm/pipeline.o asm 版未传 source_len，须由 C 替代。
 */
__attribute__((noinline)) int32_t pipeline_impl_phase_parse_load(struct ast_Module *module, struct ast_ASTArena *arena,
                                                                 uint8_t *source_data, size_t source_len,
                                                                 struct ast_PipelineDepCtx *ctx) {
  (void)pipeline_impl_phase_parse_only(module, arena, source_data, source_len, ctx);
  return pipeline_impl_phase_load_deps(module, arena, ctx);
}
