/**
 * pipeline_glue_standalone.c — Target B 实验链：独立 pipeline_glue+ast_pool TU（不含 pipeline.x 函数体）。
 *
 * 类型头由 scripts/extract_pipeline_glue_types.pl 从 pipeline_gen.c 抽取至 build_asm/pipeline_glue_types.inc；
 * 与 build_asm/pipeline.o 并列链接，补齐 pool 读写 glue 符号，避免重复 pipeline_run_x_pipeline_impl 等 .x 定义。
 */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "pipeline_glue_types.inc"

#define SHUX_PIPELINE_GLUE_STANDALONE_TU 1
#include "../../pipeline_glue.c"

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;

/** typeck 布局 metrics：strict 链由 typeck_x.o / typeck_asm_layout_partial.o 导出，glue 不重复 wrapper。 */

/** preprocess_x_buf 由 x_seed_bridge.o + preprocess_x.o 提供，勿在此重复定义。 */

/** ast_ast_arena_init 由 pipeline_glue.c（SHUX_PIPELINE_GLUE_STANDALONE_TU）提供，勿在此重复定义。 */

/** runtime_asm_build / main.c 期望的入口名（strict 链不链 build_asm/main.o）。 */
extern int32_t driver_run_compiler_full(int32_t argc, char **argv);

/** 无 bridge 时的入口桩；B-strict 链由 asm_experimental_symbol_bridge.c 强符号 main_entry 覆盖。 */
__attribute__((weak)) int32_t main_entry(int32_t argc, char **argv) {
  return driver_run_compiler_full(argc, argv);
}

int32_t main_run_compiler_c(int32_t argc, uint8_t *argv) {
  return driver_run_compiler_full(argc, (char **)argv);
}

/**
 * build_asm/pipeline.o 非 asm 分支引用 codegen_x_ast；strict 链不链 build_asm/codegen.o 时 weak 桩。
 * 签名须与 pipeline_glue_types.inc 一致，避免与 pipeline_glue.c 内声明冲突。
 */
__attribute__((weak)) int32_t codegen_x_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                              struct codegen_CodegenOutBuf *out, struct ast_PipelineDepCtx *ctx,
                                              int32_t dep_index) {
  (void)module;
  (void)arena;
  (void)out;
  (void)ctx;
  (void)dep_index;
  return -1;
}

/** build_asm/pipeline.o partial 引用 parser.parse_into_init（裸名）；strict_core 提供 parser_parse_into_init。 */
extern void parser_parse_into_init(struct ast_Module *module, struct ast_ASTArena *arena);

void parse_into_init(void *module, void *arena) {
  parser_parse_into_init((struct ast_Module *)module, (struct ast_ASTArena *)arena);
}

/** ast_pool.c 提供 C 实现；glue_standalone 勿 undefined 调 pipeline.x 薄 bl。 */
extern int32_t pipeline_should_skip_x_typeck_c(struct ast_PipelineDepCtx *ctx);

int32_t pipeline_should_skip_x_typeck(struct ast_PipelineDepCtx *ctx) {
  return pipeline_should_skip_x_typeck_c(ctx);
}

/**
 * weak：strict 链无 pipeline.o / pipeline_x.o 时 LSP 路径可链接；
 * 强符号由 pipeline_x.o 或 build_asm/pipeline.o 覆盖。
 */
__attribute__((weak)) int32_t pipeline_load_and_sync_direct_import_deps(struct ast_Module *module,
                                                                        struct ast_ASTArena *arena,
                                                                        struct ast_PipelineDepCtx *ctx) {
  (void)module;
  (void)arena;
  (void)ctx;
  return 0;
}

/** weak：orchestration partial 在无 build_asm/pipeline.o 时仍可链接。 */
__attribute__((weak)) int32_t run_x_pipeline_codegen_deps(struct ast_Module *module, struct ast_ASTArena *arena,
                                                           struct codegen_CodegenOutBuf *out_buf,
                                                           struct ast_PipelineDepCtx *ctx, int32_t skip_asm_dep_codegen) {
  (void)module;
  (void)arena;
  (void)out_buf;
  (void)ctx;
  (void)skip_asm_dep_codegen;
  return 0;
}

__attribute__((weak)) int32_t run_x_pipeline_codegen_entry(struct ast_Module *module, struct ast_ASTArena *arena,
                                                            struct codegen_CodegenOutBuf *out_buf,
                                                            struct ast_PipelineDepCtx *ctx) {
  (void)module;
  (void)arena;
  (void)out_buf;
  (void)ctx;
  return 0;
}
