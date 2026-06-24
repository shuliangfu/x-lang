/**
 * pipeline_asm_orchestration_alias.c — strict 链 pipeline 编排 C 实现
 *
 * build_asm/pipeline.o 第二遍 emit 对 parse/typecheck 多实参 CALL / thin bl reloc 不可靠；
 * 本 TU 按 pipeline.sx 提供 run_sx_pipeline_impl、parse entry 与 parse_into_with_init_buf。
 * codegen/load 仍由 pipeline_strict_link_partial.o（build_asm/pipeline.o 子集）SX 真 emit。
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

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
extern void pipeline_strict_parse_into_init(struct ast_ASTArena *arena, struct ast_Module *module);
extern struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena *arena, struct ast_Module *module,
                                                           uint8_t *data, int32_t len);
extern int32_t pipeline_module_num_funcs(struct ast_Module *module);
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern void driver_diagnostic_entry_module(struct ast_Module *module, struct ast_ASTArena *arena);
extern void driver_diagnostic_source_len(int32_t len);
extern int32_t pipeline_parse_set_main_from_buf_c(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *data,
                                                  int32_t len);
extern void driver_diagnostic_before_codegen(int32_t num_funcs, int32_t out_len);
extern int32_t driver_check_only_get(void);
extern int32_t driver_sx_pipeline_skip_codegen_get(void);
extern void codegen_out_buf_set_len(struct codegen_CodegenOutBuf *out, int32_t n);
extern int32_t pipeline_dep_ctx_asm_entry_module_only(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx);
extern void driver_diagnostic_entry_already(int32_t already);
extern int32_t run_sx_pipeline_parse_entry_do_parse_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                      uint8_t *source_data, size_t source_len,
                                                      struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_load_and_sync_direct_import_deps(struct ast_Module *module, struct ast_ASTArena *arena,
                                                           struct ast_PipelineDepCtx *ctx);
extern int32_t parser_get_module_num_imports(struct ast_Module *module);
extern int32_t run_sx_pipeline_typecheck_entry_emit_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                      struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_dep_prerun_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   struct ast_PipelineDepCtx *ctx);
extern int32_t driver_sx_pipeline_skip_typeck_get(void);
extern int32_t driver_asm_build_skip_typeck(void);
extern int32_t run_sx_pipeline_codegen_deps(struct ast_Module *module, struct ast_ASTArena *arena,
                                            struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx,
                                            int32_t skip_asm_dep_codegen);
extern int32_t run_sx_pipeline_codegen_entry(struct ast_Module *module, struct ast_ASTArena *arena,
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

/** 对外符号：pipeline.sx parse_into_with_init_buf。 */
struct parser_ParseIntoResult parse_into_with_init_buf(struct ast_ASTArena *arena, struct ast_Module *module,
                                                       uint8_t *data, int32_t len) {
  return parse_into_with_init_buf_impl(arena, module, data, len);
}

/** pipeline.sx run_sx_pipeline_parse_entry_do_parse；与 SX emit 一致（set_main + 诊断）。 */
int32_t run_sx_pipeline_parse_entry_do_parse(struct ast_Module *module, struct ast_ASTArena *arena,
                                             uint8_t *source_data, size_t source_len,
                                             struct ast_PipelineDepCtx *ctx) {
  int32_t len_i32;
  int32_t parse_rc;
  if (!module || !arena || !ctx || !source_data)
    return -1;
  if (source_len > (size_t)INT32_MAX)
    return -1;
  len_i32 = (int32_t)source_len;
  driver_diagnostic_source_len(len_i32);
  parse_rc = pipeline_parse_set_main_from_buf_c(module, arena, source_data, len_i32);
  if (parse_rc != 0)
    return parse_rc;
  driver_diagnostic_after_entry_parse(pipeline_module_num_funcs(module));
  extern void driver_diagnostic_after_entry_parse_module(struct ast_Module *module);
  driver_diagnostic_after_entry_parse_module(module);
  driver_diagnostic_entry_module(module, arena);
  return 0;
}

/** pipeline.sx run_sx_pipeline_parse_entry_if_needed；勿链 pipeline.o 内 broken parse stub。 */
int32_t run_sx_pipeline_parse_entry_if_needed(struct ast_Module *module, struct ast_ASTArena *arena,
                                              uint8_t *source_data, size_t source_len,
                                              struct ast_PipelineDepCtx *ctx) {
  if (!module || !arena || !ctx)
    return -1;
  driver_diagnostic_entry_already(pipeline_dep_ctx_entry_already_parsed(ctx));
  if (pipeline_dep_ctx_entry_already_parsed(ctx) != 0) {
    driver_diagnostic_after_entry_parse(pipeline_module_num_funcs(module));
    driver_diagnostic_entry_module(module, arena);
    return 0;
  }
  return run_sx_pipeline_parse_entry_do_parse(module, arena, source_data, source_len, ctx);
}

/**
 * 完整 .sx 流水线：parse → load/sync deps → typeck → codegen（与 pipeline.sx run_sx_pipeline_impl 一致）。
 */
int32_t run_sx_pipeline_impl(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                             size_t source_len, struct codegen_CodegenOutBuf *out_buf,
                             struct ast_PipelineDepCtx *ctx) {
  int32_t load_rc;
  int32_t tc_rc;
  int32_t skip_asm_dep_codegen;
  if (!module || !arena || !out_buf || !ctx)
    return -1;
  if (getenv("SHUX_ASM_ENTRY_ONLY_DEBUG")) {
    fprintf(stderr, ">> [ASM_ORCH] parse_entry_if_needed\n");
    fflush(stderr);
  }
  if (run_sx_pipeline_parse_entry_if_needed(module, arena, source_data, source_len, ctx) != 0)
    return -2;
  /** 无 import 的单文件 entry：跳过 load/sync SX（build_asm partial 在 ndep=0 时仍可能 SIGSEGV）。 */
  if (parser_get_module_num_imports(module) == 0)
    load_rc = 0;
  else if (pipeline_dep_ctx_ndep(ctx) > 0 && pipeline_dep_ctx_asm_entry_module_only(ctx) == 0) {
    /** driver_run_asm_backend 已 collect_deps + prerun + seed 槽；勿再调 build_asm SX load/sync（hello 等 SIGSEGV）。 */
    load_rc = 0;
  } else {
    if (getenv("SHUX_ASM_ENTRY_ONLY_DEBUG")) {
      fprintf(stderr, ">> [ASM_ORCH] load_and_sync_direct_import_deps\n");
      fflush(stderr);
    }
    load_rc = pipeline_load_and_sync_direct_import_deps(module, arena, ctx);
  }
  if (load_rc != 0)
    return load_rc;
  if (getenv("SHUX_ASM_ENTRY_ONLY_DEBUG")) {
    fprintf(stderr, ">> [ASM_ORCH] typecheck_entry (check_only=%d skip_flag=%d skip_codegen=%d build_skip=%d)\n",
            (int)driver_check_only_get(), (int)driver_sx_pipeline_skip_typeck_get(),
            (int)driver_sx_pipeline_skip_codegen_get(), (int)driver_asm_build_skip_typeck());
    fflush(stderr);
  }
  /*
   * 用户 asm -o：runtime 设 skip_typeck/skip_codegen；build_shux_asm 仅设 SHUX_ASM_BUILD_SKIP_TYPECK（勿再跑 .sx typeck）。
   * shux check：须始终跑 .sx typeck（含 WPO-S3 post-scan）；勿因 skip_codegen 跳过。
   */
  if (driver_check_only_get() != 0) {
    tc_rc = run_sx_pipeline_typecheck_entry_emit_c(module, arena, ctx);
  } else if (driver_sx_pipeline_skip_typeck_get() != 0 || driver_sx_pipeline_skip_codegen_get() != 0 ||
             driver_asm_build_skip_typeck() != 0) {
    /*
     * asm -o 跳过全量 check_block 时：无 import 单文件仍须全量 typeck（field_access_offset）；
     * 有 import 或多文件仅 dep_prerun（§11.1 padding + parent link）。
     */
    if (driver_sx_pipeline_skip_typeck_get() != 0 && parser_get_module_num_imports(module) == 0 &&
        driver_sx_pipeline_skip_codegen_get() != 0) {
      tc_rc = run_sx_pipeline_typecheck_entry_emit_c(module, arena, ctx);
    } else if (driver_sx_pipeline_skip_typeck_get() != 0 || driver_asm_build_skip_typeck() != 0) {
      tc_rc = pipeline_typeck_dep_prerun_module_c(module, arena, ctx);
    } else {
      tc_rc = 0;
    }
  } else {
    tc_rc = run_sx_pipeline_typecheck_entry_emit_c(module, arena, ctx);
  }
  if (tc_rc != 0)
    return tc_rc;
  if (driver_check_only_get() != 0)
    return 0;
  if (driver_sx_pipeline_skip_codegen_get() != 0)
    return 0;
  codegen_out_buf_set_len(out_buf, 0);
  driver_diagnostic_before_codegen(pipeline_module_num_funcs(module), 0);
  skip_asm_dep_codegen = (pipeline_dep_ctx_asm_entry_module_only(ctx) != 0) ? 1 : 0;
  if (run_sx_pipeline_codegen_deps(module, arena, out_buf, ctx, skip_asm_dep_codegen) != 0)
    return -6;
  if (run_sx_pipeline_codegen_entry(module, arena, out_buf, ctx) != 0)
    return -6;
  return 0;
}

/** glue / runtime 统一入口名。 */
int32_t pipeline_run_sx_pipeline_impl(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                      size_t source_len, struct codegen_CodegenOutBuf *out_buf,
                                      struct ast_PipelineDepCtx *ctx) {
  return run_sx_pipeline_impl(module, arena, source_data, source_len, out_buf, ctx);
}
