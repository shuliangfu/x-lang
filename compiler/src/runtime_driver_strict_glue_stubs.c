#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

#include "token.h"

struct ASTModule;
struct ASTFunc;
typedef struct ASTModule ASTModule;

typedef struct Lexer Lexer;

__attribute__((weak)) void codegen_emit_fmt_json_helpers_once(FILE *out) {
  (void)out;
}

__attribute__((weak)) int codegen_emit_dep_types_only(struct ASTModule **mods, const char **import_paths, int n, FILE *out,
                                                      char (*emitted_type_names)[64], int *n_emitted_inout,
                                                      int max_emitted) {
  (void)mods;
  (void)import_paths;
  (void)n;
  (void)out;
  (void)emitted_type_names;
  (void)n_emitted_inout;
  (void)max_emitted;
  return -1;
}

__attribute__((weak)) void codegen_set_eextern_entry_path(const char *entry_path) {
  (void)entry_path;
}

__attribute__((weak)) Lexer *lexer_new(const char *source) {
  (void)source;
  return NULL;
}

__attribute__((weak)) void lexer_free(Lexer *l) {
  (void)l;
}

__attribute__((weak)) void lexer_next(Lexer *l, Token *out) {
  (void)l;
  if (!out)
    return;
  out->kind = TOKEN_EOF;
  out->line = 1;
  out->col = 1;
  out->ident_len = 0;
}

__attribute__((weak)) int parse(Lexer *lex, ASTModule **out) {
  (void)lex;
  (void)out;
  return -1;
}

__attribute__((weak)) int typeck_module(ASTModule *m, ASTModule **dep_mods, int num_deps, ASTModule **all_dep_mods, int n_all_deps) {
  (void)m;
  (void)dep_mods;
  (void)num_deps;
  (void)all_dep_mods;
  (void)n_all_deps;
  return -1;
}

__attribute__((weak)) int typeck_set_allow_legacy_extern_calls(int allow) {
  (void)allow;
  return 0;
}

__attribute__((weak)) char *preprocess(const char *source, size_t source_len, const char **defines, int ndefines,
                                       size_t *out_length) {
  (void)source;
  (void)source_len;
  (void)defines;
  (void)ndefines;
  if (out_length)
    *out_length = 0;
  return NULL;
}

__attribute__((weak)) void driver_print_usage_c(void) {
  fputs("Shux (stub)\nUsage: shux [options] file.sx\n", stdout);
}

__attribute__((weak)) int shu_c_resolve_and_load_imports(ASTModule *mod, const char **lib_roots, int n_lib_roots,
                                                         const char *entry_dir, const char **defines, int ndefines,
                                                         int allow_legacy_extern, ASTModule **dep_mods, int *ndep_out,
                                                         ASTModule **all_dep_mods, char **all_dep_paths, char all_dep_fs[][512],
                                                         int *n_all_out, int max_deps) {
  (void)mod;
  (void)lib_roots;
  (void)n_lib_roots;
  (void)entry_dir;
  (void)defines;
  (void)ndefines;
  (void)allow_legacy_extern;
  (void)dep_mods;
  (void)ndep_out;
  (void)all_dep_mods;
  (void)all_dep_paths;
  (void)all_dep_fs;
  (void)n_all_out;
  (void)max_deps;
  return -1;
}

__attribute__((weak)) int shu_lsp_resolve_and_load_imports(ASTModule *mod, const char **lib_roots, int n_lib_roots,
                                                           const char *entry_dir, ASTModule **dep_mods, int *ndep_out,
                                                           ASTModule **all_dep_mods, char **all_dep_paths,
                                                           char all_dep_fs[][512], int *n_all_out, int max_deps) {
  (void)mod;
  (void)lib_roots;
  (void)n_lib_roots;
  (void)entry_dir;
  (void)dep_mods;
  (void)ndep_out;
  (void)all_dep_mods;
  (void)all_dep_paths;
  (void)all_dep_fs;
  (void)n_all_out;
  (void)max_deps;
  return -1;
}

__attribute__((weak)) int32_t pipeline_typeck_module_for_ctx(void *module, void *arena, void *ctx_void) {
  (void)module;
  (void)arena;
  (void)ctx_void;
  return -1;
}

#if !defined(_WIN32) && !defined(_WIN64)
/* MinGW 不支持 __attribute__((weak)) 函数符号；Windows 上由 runtime_pipeline_abi_shux_c_stubs.c 单一提供。 */
__attribute__((weak)) void ast_module_free(ASTModule *mod) {
  (void)mod;
}
#endif
