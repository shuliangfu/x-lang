/**
 * pipeline_asm_typecheck_alias.c — strict asm 编排链：仅 pipeline_impl_typecheck。
 *
 * build_asm/pipeline.o 第二遍 emit 的 if/else（force_c / typeck_sx_ast）分支不完整，
 * 会跳过 typeck 或误走 library 路径（null module smoke 失败）；本 TU 单独 ld -r 链入，
 * 语义与 pipeline_asm_orchestration_alias.c / pipeline.sx 一致，调用 C 侧 typeck_typeck_sx_ast*。
 */
#include <stddef.h>
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;

extern int32_t driver_typeck_skip_large_entry(void);
extern int32_t driver_asm_build_skip_typeck(void);
extern int32_t driver_typeck_force_c_enabled(void);
extern void driver_diagnostic_typeck_fail(void);
extern int32_t pipeline_module_main_func_index(struct ast_Module *module);
extern int32_t typeck_typeck_sx_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                    struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_typeck_sx_ast_library(struct ast_Module *module, struct ast_ASTArena *arena,
                                            struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_module_for_ctx(struct ast_Module *module, struct ast_ASTArena *arena,
                                              struct ast_PipelineDepCtx *ctx);

/** typeck 阶段；失败返回负码，跳过时返回 0。 */
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
      tc_lib = typeck_typeck_sx_ast_library(module, arena, ctx);
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
  } else if (typeck_typeck_sx_ast(module, arena, ctx) != 0) {
    tc_main = -1;
  }
  if (tc_main != 0) {
    driver_diagnostic_typeck_fail();
    return -1;
  }
  return 0;
}
