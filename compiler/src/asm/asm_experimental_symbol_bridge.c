/**
 * asm_experimental_symbol_bridge.c — 实验 asm-only 链符号桥
 *
 * build_asm 裸符号名（如 entry、parse_into_buf），runtime 期望
 * main_entry、parser_parse_into_buf、asm_asm_codegen_elf_o 等。
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

struct shux_slice_uint8_t {
  uint8_t *data;
  size_t length;
};

/** runtime 与 main.c 统一入口名。 */
struct parser_ParseIntoResult {
  int32_t ok;
  int32_t main_idx;
};

extern int32_t entry(int32_t argc, uint8_t *argv);
/** runtime.c 完整编译驱动（-o / -backend asm 等）；实验链无 driver_sx.o 时作 main_run_compiler_c 兜底。 */
extern int32_t driver_run_compiler_full(int32_t argc, uint8_t *argv);

/** main.o 链入时其强符号 entry 覆盖本 weak 实现；未链 main.o 时转 runtime run_compiler_c（缺 run_compiler_sx_path_impl 会 silent fail）。 */
__attribute__((weak)) int32_t entry(int32_t argc, uint8_t *argv) {
  extern int32_t run_compiler_c(int32_t, char **);
  return run_compiler_c(argc, (char **)argv);
}

/** driver_sx.o 的 main_entry 引用；B-strict 未链 lsp_sx.o 时弱桩。 */
__attribute__((weak)) int32_t typeck_lsp_main(void) {
  return -1;
}

/** build_asm/main.o 导出 run_compiler_sx_path_impl；driver/build.sx 经 -E 期望 main_ 前缀。 */
extern int32_t driver_run_compiler_full(int32_t argc, uint8_t *argv);
__attribute__((weak)) int32_t run_compiler_sx_path_impl(int32_t argc, uint8_t *argv) {
  return driver_run_compiler_full(argc, (uint8_t *)argv);
}
/** driver/build.sx、driver/run.sx 引用；experimental 链未并 driver_sx.o 时由本弱桩转发 driver_run_compiler_full。 */
__attribute__((weak)) int32_t main_run_compiler_sx_path_impl(int32_t argc, uint8_t *argv) {
  return driver_run_compiler_full(argc, (uint8_t *)argv);
}

extern uint8_t *driver_argv_drop_subcommand(int32_t argc, uint8_t *argv);
extern int32_t driver_cmd_fmt(int32_t argc, uint8_t *argv);
extern int32_t driver_cmd_check(int32_t argc, uint8_t *argv);
extern int32_t driver_cmd_test(int32_t argc, uint8_t *argv);
/** main.sx / driver_sx.o 提供；experimental 链未并 driver_sx 时由弱桩兜底。 */
extern int32_t main_cmd_build(int32_t argc, uint8_t *argv);
extern int32_t driver_cmd_run(int32_t argc, uint8_t *argv);

/** build 子命令弱桩：experimental 链无 driver_sx.o 时返回失败（勿误用 build_cmd_build 旧名）。 */
__attribute__((weak)) int32_t main_cmd_build(int32_t argc, uint8_t *argv) {
  (void)argc;
  (void)argv;
  return -1;
}

/**
 * B-strict：build_asm/main.o 为 ENTRY_MODULE_ONLY 桩时，在此路由 check/fmt/test/build/run 到 driver_*_sx.o。
 * 与 main.sx entry() 子命令语义一致（argc-1 + driver_argv_drop_subcommand）。
 * 弱符号：链入 driver_sx.o / build_asm/main.o 真 entry 时由其强符号覆盖。
 */
__attribute__((weak)) int32_t main_entry(int32_t argc, char **argv) {
  uint8_t *adj;
  if (argc >= 2 && argv[1] && argv[1][0] != '-') {
    adj = driver_argv_drop_subcommand((int32_t)argc, (uint8_t *)argv);
    if (strcmp(argv[1], "fmt") == 0)
      return driver_cmd_fmt((int32_t)argc - 1, adj);
    if (strcmp(argv[1], "check") == 0)
      return driver_cmd_check((int32_t)argc - 1, adj);
    if (strcmp(argv[1], "test") == 0)
      return driver_cmd_test((int32_t)argc - 1, adj);
    if (strcmp(argv[1], "build") == 0)
      return main_cmd_build((int32_t)argc - 1, adj);
    if (strcmp(argv[1], "run") == 0)
      return driver_cmd_run((int32_t)argc - 1, adj);
  }
  return entry(argc, (uint8_t *)argv);
}

/**
 * runtime.c 的 run_compiler_c 转调本符号；须避免 entry→run_compiler_c→本函数→entry 递归。
 * build_asm/main.o 链入时其强符号覆盖本 weak 实现。
 */
__attribute__((weak)) int32_t main_run_compiler_c(int32_t argc, uint8_t *argv) {
  return driver_run_compiler_full(argc, argv);
}

/** build_asm/asm.o 未导出 elf 路径时弱符号兜底（实验链可链通；完整功能仍须真 asm_codegen_elf_o）。 */
__attribute__((weak)) int32_t asm_codegen_elf_o(void *module, void *arena, void *ctx, void *elf_ctx, void *out_buf) {
  (void)module;
  (void)arena;
  (void)ctx;
  (void)elf_ctx;
  (void)out_buf;
  return -1;
}

/** asm 模块导出名与 runtime 期望的 asm_asm_codegen_elf_o 对齐；pipeline_sx.o 链入时由其强符号覆盖。 */
__attribute__((weak)) int32_t asm_asm_codegen_elf_o(void *module, void *arena, void *ctx, void *elf_ctx, void *out_buf) {
  return asm_codegen_elf_o(module, arena, ctx, elf_ctx, out_buf);
}

/** parser.o 在 SKIP_TYPECK 下常缺 parse_into_buf；弱符号供 bridge 转发。 */
__attribute__((weak)) struct parser_ParseIntoResult parse_into_buf(void *arena, void *module, uint8_t *data,
                                                                       int32_t len) {
  (void)arena;
  (void)module;
  (void)data;
  (void)len;
  struct parser_ParseIntoResult r;
  r.ok = -1;
  r.main_idx = -1;
  return r;
}

__attribute__((weak)) struct parser_ParseIntoResult parse_into(void *arena, void *module,
                                                                 struct shux_slice_uint8_t *source) {
  (void)source;
  return parse_into_buf(arena, module, NULL, 0);
}

__attribute__((weak)) void parse_into_init(void *module, void *arena) {
  (void)module;
  (void)arena;
}

__attribute__((weak)) void parse_into_set_main_index(void *module, int32_t main_idx) {
  (void)module;
  (void)main_idx;
}

__attribute__((weak)) int32_t get_module_num_imports(void *module) {
  (void)module;
  return 0;
}

/** pipeline.sx 直调；强符号转发 parser.sx（strict 无 parser_sx.o 时由下方 weak 桩清零）。 */
void parser_get_module_import_path(void *module, int32_t i, uint8_t *out);

void get_module_import_path(void *module, int32_t i, uint8_t *out) {
  parser_get_module_import_path(module, i, out);
}

__attribute__((weak)) void parser_get_module_import_path(void *module, int32_t i, uint8_t *out) {
  (void)module;
  (void)i;
  if (out)
    out[0] = '\0';
}

/** build_asm/preprocess.o 有真实现时覆盖弱符号（与 runtime.c / sx_seed_bridge 一致用 const 源指针）。 */
__attribute__((weak)) int32_t preprocess_sx_buf(const uint8_t *source_buf, ptrdiff_t source_len, uint8_t *out_buf,
                                                  int32_t out_cap) {
  (void)source_buf;
  (void)source_len;
  (void)out_buf;
  (void)out_cap;
  return -1;
}

/** parser 裸名 → runtime 的 parser_ 前缀 API（pipeline_sx.o 链入时弱符号被覆盖）。 */
__attribute__((weak)) void parser_parse_into_init(void *arena, void *module) {
  parse_into_init(module, arena);
}

__attribute__((weak)) struct parser_ParseIntoResult parser_parse_into_buf(void *arena, void *module, uint8_t *data, int32_t len) {
  return parse_into_buf(arena, module, data, len);
}

__attribute__((weak)) struct parser_ParseIntoResult parser_parse_into(void *arena, void *module, struct shux_slice_uint8_t *source) {
  return parse_into(arena, module, source);
}

__attribute__((weak)) void parser_parse_into_set_main_index(void *module, int32_t main_idx) {
  parse_into_set_main_index(module, main_idx);
}

__attribute__((weak)) int32_t parser_get_module_num_imports(void *module) {
  return get_module_num_imports(module);
}

/** asm.sx import peephole.peephole_run → peephole_peephole_run；build_asm/peephole.o 提供强符号。 */
__attribute__((weak)) int32_t peephole_peephole_run(void *out) {
  (void)out;
  return 0;
}

/** build_asm/backend.o 导出 asm_codegen_ast；asm.o 期望 backend_asm_codegen_ast。 */
extern int32_t asm_codegen_ast(void *module, void *arena, void *out_buf, void *ctx);

/** backend.o 未产出时 asm.o 仍须链通；有 backend.o 时转发到 asm_codegen_ast。 */
__attribute__((weak)) int32_t backend_asm_codegen_ast(void *module, void *arena, void *out, void *ctx) {
  return asm_codegen_ast(module, arena, out, ctx);
}

/** build_asm/backend.o 导出 asm_codegen_ast；pipeline/orchestration 期望 asm_asm_codegen_ast。 */
__attribute__((weak)) int32_t asm_codegen_ast(void *module, void *arena, void *out_buf, void *ctx) {
  (void)module;
  (void)arena;
  (void)out_buf;
  (void)ctx;
  return -1;
}

__attribute__((weak)) int32_t asm_asm_codegen_ast(void *module, void *arena, void *out_buf, void *ctx) {
  return asm_codegen_ast(module, arena, out_buf, ctx);
}

/** build_asm/typeck.o 导出 typeck_sx_ast*；orchestration 期望 typeck_typeck_sx_ast*（pipeline_sx 链入时由其强符号覆盖）。 */
__attribute__((weak)) int32_t typeck_sx_ast(void *module, void *arena, void *ctx) {
  (void)module;
  (void)arena;
  (void)ctx;
  return -1;
}

__attribute__((weak)) int32_t typeck_sx_ast_library(void *module, void *arena, void *ctx) {
  (void)module;
  (void)arena;
  (void)ctx;
  return -1;
}

__attribute__((weak)) int32_t typeck_typeck_sx_ast(void *module, void *arena, void *ctx) {
  return typeck_sx_ast(module, arena, ctx);
}

__attribute__((weak)) int32_t typeck_typeck_sx_ast_library(void *module, void *arena, void *ctx) {
  return typeck_sx_ast_library(module, arena, ctx);
}

/** runtime 诊断路径；C parser 未导出时弱符号兜底。 */
__attribute__((weak)) int32_t parser_diag_token_after_collect_imports(struct shux_slice_uint8_t *source, void *module) {
  (void)source;
  (void)module;
  return -1;
}

/** strict 链：build_asm/typeck.o 导出 typeck_struct_layout_metrics；未链 typeck.o 时 weak 桩返回 -1。 */
struct ast_Module;
struct ast_ASTArena;

__attribute__((weak)) int32_t typeck_struct_layout_metrics(struct ast_Module *module, struct ast_ASTArena *arena,
                                                           int32_t li, int32_t depth, int32_t check_pad,
                                                           int32_t *out_sz, int32_t *out_al) {
  (void)module;
  (void)arena;
  (void)li;
  (void)depth;
  (void)check_pad;
  (void)out_sz;
  (void)out_al;
  return -1;
}

__attribute__((weak)) int32_t typeck_typeck_struct_layout_metrics(struct ast_Module *module, struct ast_ASTArena *arena,
                                                                  int32_t li, int32_t depth, int32_t check_pad,
                                                                  int32_t *out_sz, int32_t *out_al) {
  return typeck_struct_layout_metrics(module, arena, li, depth, check_pad, out_sz, out_al);
}

/** parser_from_gen.o 引用 std.io 读 ptr；strict 链无 driver_sx 时弱符号兜底。 */
__attribute__((weak)) int32_t std_io_driver_driver_read_ptr(void *out_slice, void *fd) {
  (void)out_slice;
  (void)fd;
  return -1;
}

__attribute__((weak)) int32_t std_io_driver_driver_read_ptr_len(void *fd) {
  (void)fd;
  return -1;
}

/**
 * strict 链：pipeline codegen_deps/entry 在非 asm 分支引用 codegen_sx_ast；
 * build_asm/codegen.o 未链入时 weak 桩（asm 后端走 asm_codegen_ast）。
 */
__attribute__((weak)) int32_t codegen_sx_ast(void *module, void *arena, void *out_buf, void *ctx, int32_t dep_index) {
  (void)module;
  (void)arena;
  (void)out_buf;
  (void)ctx;
  (void)dep_index;
  return -1;
}

/** strict 链：load_and_sync 末尾 merge dep struct layout；typeck.o 未链入时 no-op。 */
__attribute__((weak)) void typeck_merge_dep_struct_layouts_into_entry(void *module, void *arena, void *ctx) {
  (void)module;
  (void)arena;
  (void)ctx;
}

/** pipeline.sx import 前缀名；typeck_sx.o 链入时强符号覆盖。 */
__attribute__((weak)) void typeck_typeck_merge_dep_struct_layouts_into_entry(void *module, void *arena, void *ctx) {
  typeck_merge_dep_struct_layouts_into_entry(module, arena, ctx);
}

/** DOD-S3：WPO SoA layout 统一；typeck_sx.o 未链入时 no-op。 */
__attribute__((weak)) void typeck_wpo_unify_soa_layouts(void *entry, void *ctx) {
  (void)entry;
  (void)ctx;
}

__attribute__((weak)) void typeck_typeck_wpo_unify_soa_layouts(void *entry, void *ctx) {
  typeck_wpo_unify_soa_layouts(entry, ctx);
}

/**
 * strict 链：parse_into_with_init_buf 经 import ast 引用 ast_ast_arena_init；
 * build_asm/ast.o 未链入、ast_seed 仅 C 种子时，由本 weak 桥接转发 ast_arena_init；
 * pipeline_sx.o / build_asm/ast.o 链入时强符号覆盖。
 */
extern void ast_arena_init(void *arena);

__attribute__((weak)) void ast_arena_init(void *arena) {
  (void)arena;
}

__attribute__((weak)) void ast_ast_arena_init(void *arena) {
  ast_arena_init(arena);
}
