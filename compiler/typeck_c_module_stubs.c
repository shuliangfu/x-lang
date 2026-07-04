/**
 * typeck_c_module_stubs.c — typeck_module / typeck_one_function weak 桩（回退）
 *
 * B-strict 整链 build_asm/typeck.o 时，编译/诊断走 pipeline typeck_x_ast（slim pool）；
 * 用户 -o C 预检优先 typeck_c_orchestration_partial（seed typeck.o 抽出 typeck_module）；
 * partial 导出失败时本文件 weak 桩满足 lsp_diag.c 链接（strict 用户程序无 C 预检）。
 */
#include "src/typeck/typeck.h"

/**
 * C fat-AST 类型检查入口桩；strict shux_asm 不执行此路径（返回 -1）。
 */
__attribute__((weak)) int typeck_module(struct ASTModule *m, struct ASTModule **dep_mods, int num_deps,
                                        struct ASTModule **all_dep_mods, int n_all_deps) {
  (void)m;
  (void)dep_mods;
  (void)num_deps;
  (void)all_dep_mods;
  (void)n_all_deps;
  return -1;
}

/**
 * 单函数 C typeck 桩；LSP lazy typeck 在 strict shux_asm 上不可用。
 */
__attribute__((weak)) int typeck_one_function(struct ASTModule *m, struct ASTModule **dep_mods, int num_deps,
                                              struct ASTModule **all_dep_mods, int n_all_deps,
                                              int only_func_index) {
  (void)m;
  (void)dep_mods;
  (void)num_deps;
  (void)all_dep_mods;
  (void)n_all_deps;
  (void)only_func_index;
  return -1;
}
