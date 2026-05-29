/**
 * pipeline_glue_strict_minimal.c — B-strict 链最小 glue（不含 ast_pool / pipeline_glue_types.inc）
 *
 * strict_core partial 已含 pipeline_su 几乎全部符号；本 TU 仅补 runtime 入口与裸名 parse_into_init。
 */
#include <stdint.h>
#include <stddef.h>

struct ast_Module;
struct ast_ASTArena;

/** runtime 期望的程序入口名。 */
extern int32_t driver_run_compiler_full(int32_t argc, char **argv);

/** runtime 期望的程序入口名；weak 以便与 asm_experimental_symbol_bridge 共存（B-strict 链 build_asm/pipeline.o 时）。 */
__attribute__((weak)) int32_t main_entry(int32_t argc, char **argv) {
  return driver_run_compiler_full(argc, argv);
}

int32_t main_run_compiler_c(int32_t argc, uint8_t *argv) {
  return driver_run_compiler_full(argc, (char **)argv);
}

/** pipeline 非 asm 分支 weak 桩（asm 路径不走此符号）。 */
__attribute__((weak)) int32_t codegen_su_ast(void *module, void *arena, void *out_buf, void *ctx, int32_t dep_index) {
  (void)module;
  (void)arena;
  (void)out_buf;
  (void)ctx;
  (void)dep_index;
  return -1;
}

/** runtime 调用的裸名 parse_into_init → partial 导出的 parser_parse_into_init。 */
extern void parser_parse_into_init(struct ast_Module *module, struct ast_ASTArena *arena);

void parse_into_init(void *module, void *arena) {
  parser_parse_into_init((struct ast_Module *)module, (struct ast_ASTArena *)arena);
}
