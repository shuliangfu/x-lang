/**
 * pipeline_asm_orchestration_alias.c — strict 链 pipeline 编排 C 实现
 *
 * build_asm/pipeline.o 中多参函数 emit 暂不可用（参数从 [x29,#-4] 误加载、bl 目标错误）；
 * 本 TU 按 pipeline.su 语义提供 run_su_pipeline_impl 及阶段函数，供 strict 链 smoke 与第二遍 emit。
 * 勿链入 pipeline_su.o（会拉入 pipeline_run_su_pipeline* 重复符号）。
 */
#include <stddef.h>
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;
struct codegen_CodegenOutBuf;

/** 与 parser 导出 layout 一致。 */
struct parser_ParseIntoResult {
  int32_t ok;
  int32_t main_idx;
};

extern void parser_parse_into_set_main_index(struct ast_Module *module, int32_t main_idx);
/** ast_pool.c：strict 链 parse 前 reset（等价 parse_into_init + sidecar 池清零）。 */
extern void pipeline_strict_parse_into_init(struct ast_ASTArena *arena, struct ast_Module *module);
/** strict_support / parse_su partial 提供；勿经 pipeline_parse_into_with_init_buf（init 与 runtime 预 init 叠加 → body_ref=0）。 */
extern struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena *arena, struct ast_Module *module,
                                                           uint8_t *data, int32_t len);
extern int32_t pipeline_module_num_funcs(struct ast_Module *module);
extern int32_t pipeline_module_main_func_index(struct ast_Module *module);
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern void driver_diagnostic_entry_module(struct ast_Module *module, struct ast_ASTArena *arena);
extern void driver_diagnostic_typeck_fail(void);
extern void driver_diagnostic_before_codegen(int32_t num_funcs, int32_t out_len);
extern void driver_diagnostic_after_dep_codegen(int32_t j, int32_t out_len);
extern void driver_diagnostic_codegen_fail(int32_t dep_index, int32_t is_dep);
extern int32_t driver_skip_codegen_dep_0_get(void);
extern int32_t driver_typeck_skip_large_entry(void);
extern int32_t driver_asm_build_skip_typeck(void);
extern int32_t driver_typeck_force_c_enabled(void);
extern void driver_set_current_dep_path_for_codegen(uint8_t *path);
extern int32_t codegen_out_buf_len(struct codegen_CodegenOutBuf *out);
extern void codegen_out_buf_set_len(struct codegen_CodegenOutBuf *out, int32_t n);
extern int32_t typeck_typeck_su_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                    struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_typeck_su_ast_library(struct ast_Module *module, struct ast_ASTArena *arena,
                                            struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_module_for_ctx(struct ast_Module *module, struct ast_ASTArena *arena,
                                              struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_check_only_mode(struct ast_PipelineDepCtx *ctx);
/** build_asm/pipeline.o partial 提供（与 C parse/typecheck 拆分，避免 duplicate）。 */
extern int32_t pipeline_impl_phase_load_deps(struct ast_Module *module, struct ast_ASTArena *arena,
                                             struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_impl_should_skip_codegen(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_impl_codegen_chain(struct ast_Module *module, struct ast_ASTArena *arena,
                                           struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx);

/**
 * strict parse：pipeline_strict_parse_into_init + parser_parse_into_buf；
 * 与 pipeline_phase_parse_only_alias.c / bootstrap monolith 一致，避免双重 init。
 */
static struct parser_ParseIntoResult parse_into_with_init_buf_impl(struct ast_ASTArena *arena, struct ast_Module *module,
                                                                   uint8_t *data, int32_t len) {
  struct parser_ParseIntoResult r;
  pipeline_strict_parse_into_init(arena, module);
  r = parser_parse_into_buf(arena, module, data, len);
  return r;
}

/** 对外符号：pipeline.su parse_into_with_init_buf。 */
struct parser_ParseIntoResult parse_into_with_init_buf(struct ast_ASTArena *arena, struct ast_Module *module,
                                                       uint8_t *data, int32_t len) {
  return parse_into_with_init_buf_impl(arena, module, data, len);
}

/**
 * 解析 + 诊断（不含 load deps）；runtime 在调用前已 memset module/arena 且 entry_already_parsed=0。
 */
int32_t pipeline_impl_phase_parse_only(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                       size_t source_len, struct ast_PipelineDepCtx *ctx) {
  struct parser_ParseIntoResult r;
  int32_t len_i32;
  (void)ctx;
  len_i32 = (int32_t)source_len;
  r = parse_into_with_init_buf_impl(arena, module, source_data, len_i32);
  parser_parse_into_set_main_index(module, r.main_idx);
  driver_diagnostic_after_entry_parse(pipeline_module_num_funcs(module));
  driver_diagnostic_entry_module(module, arena);
  return -2 * r.ok;
}

/** 解析 + load deps；load_deps 由 pipeline.o partial 提供。 */
int32_t pipeline_impl_phase_parse_load(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                       size_t source_len, struct ast_PipelineDepCtx *ctx) {
  pipeline_impl_phase_parse_only(module, arena, source_data, source_len, ctx);
  return pipeline_impl_phase_load_deps(module, arena, ctx);
}

/** typeck 阶段；strict 链优先 pipeline_su partial 的 typeck_typeck_su_ast*，与 bootstrap 一致。 */
int32_t pipeline_impl_typecheck(struct ast_Module *module, struct ast_ASTArena *arena, struct ast_PipelineDepCtx *ctx) {
  int32_t tc_lib;
  int32_t tc_main;
  if (driver_typeck_skip_large_entry() != 0 || driver_asm_build_skip_typeck() != 0) {
    return 0;
  }
  if (pipeline_module_main_func_index(module) < 0) {
    if (driver_typeck_force_c_enabled() != 0) {
      tc_lib = pipeline_typeck_module_for_ctx(module, arena, ctx);
    } else {
      tc_lib = typeck_typeck_su_ast_library(module, arena, ctx);
    }
    if (tc_lib != 0) {
      driver_diagnostic_typeck_fail();
      return tc_lib;
    }
    return 0;
  }
  tc_main = 0;
  if (driver_typeck_force_c_enabled() != 0) {
    tc_main = pipeline_typeck_module_for_ctx(module, arena, ctx);
  } else if (typeck_typeck_su_ast(module, arena, ctx) != 0) {
    tc_main = -1;
  }
  if (tc_main != 0) {
    driver_diagnostic_typeck_fail();
    return -1;
  }
  return 0;
}

/** 完整流水线编排；codegen 经 pipeline.o partial 真 emit，parse/typecheck 走本 TU。 */
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
int32_t run_su_pipeline_impl(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                               size_t source_len, struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx) {
  return pipeline_impl_run_all(module, arena, source_data, source_len, out_buf, ctx);
}

/** glue / runtime 统一入口名（替代 pipeline_run_impl_alias.o，避免重复符号）。 */
int32_t pipeline_run_su_pipeline_impl(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                      size_t source_len, struct codegen_CodegenOutBuf *out_buf,
                                      struct ast_PipelineDepCtx *ctx) {
  return run_su_pipeline_impl(module, arena, source_data, source_len, out_buf, ctx);
}
