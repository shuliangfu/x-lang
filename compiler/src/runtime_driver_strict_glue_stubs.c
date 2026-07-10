/**
 * runtime_driver_strict_glue_stubs.c — seed/no_c weak stubs + asm_driver_* 桥（G-02e-10 并入 _stubs_driver）。
  * G-02e-11：原 lsp_codegen_extern.c 并入本 TU。
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

#include "token.h"
#include "codegen/codegen.h"
#include <string.h>

/* SHUX_WEAK: POSIX 用 weak attribute；Windows/MinGW 不支持 weak 函数符号，改为正常定义，
 * 配合 Makefile 的 -Wl,--allow-multiple-definition 解决重复定义冲突。 */
#ifndef SHUX_WEAK
#if defined(_WIN32) || defined(_WIN64)
#define SHUX_WEAK
#else
#define SHUX_WEAK __attribute__((weak))
#endif
#endif

struct ASTModule;
struct ASTFunc;
typedef struct ASTModule ASTModule;

typedef struct Lexer Lexer;

SHUX_WEAK void codegen_emit_fmt_json_helpers_once(FILE *out) {
  (void)out;
}

SHUX_WEAK void codegen_emit_builtin_inline_decls(FILE *out) {
  (void)out;
}

SHUX_WEAK int codegen_emit_dep_types_only(struct ASTModule **mods, const char **import_paths, int n, FILE *out,
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

SHUX_WEAK void codegen_set_eextern_entry_path(const char *entry_path) {
  (void)entry_path;
}

SHUX_WEAK Lexer *lexer_new(const char *source) {
  (void)source;
  return NULL;
}

SHUX_WEAK void lexer_free(Lexer *l) {
  (void)l;
}

SHUX_WEAK void lexer_next(Lexer *l, Token *out) {
  (void)l;
  if (!out)
    return;
  out->kind = TOKEN_EOF;
  out->line = 1;
  out->col = 1;
  out->ident_len = 0;
}

SHUX_WEAK int parse(Lexer *lex, ASTModule **out) {
  (void)lex;
  (void)out;
  return -1;
}

SHUX_WEAK int typeck_module(ASTModule *m, ASTModule **dep_mods, int num_deps, ASTModule **all_dep_mods, int n_all_deps) {
  (void)m;
  (void)dep_mods;
  (void)num_deps;
  (void)all_dep_mods;
  (void)n_all_deps;
  return -1;
}

/** G-02e：原 typeck_c_module_stubs.c 的 typeck_one_function，并入本 TU 以便产品链去掉独立 stubs.o。 */
SHUX_WEAK int typeck_one_function(ASTModule *m, ASTModule **dep_mods, int num_deps, ASTModule **all_dep_mods, int n_all_deps,
                                  int only_func_index) {
  (void)m;
  (void)dep_mods;
  (void)num_deps;
  (void)all_dep_mods;
  (void)n_all_deps;
  (void)only_func_index;
  return -1;
}

SHUX_WEAK int typeck_set_allow_legacy_extern_calls(int allow) {
  (void)allow;
  return 0;
}

SHUX_WEAK char *preprocess(const char *source, size_t source_len, const char **defines, int ndefines,
                                       size_t *out_length) {
  (void)source;
  (void)source_len;
  (void)defines;
  (void)ndefines;
  if (out_length)
    *out_length = 0;
  return NULL;
}

SHUX_WEAK void driver_print_usage_c(void) {
  static const char msg[] = "Shux (stub)\nUsage: shux [options] file.x\n";
  (void)write(STDOUT_FILENO, msg, sizeof(msg) - 1u);
}

SHUX_WEAK int shu_c_resolve_and_load_imports(ASTModule *mod, const char **lib_roots, int n_lib_roots,
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

SHUX_WEAK int shu_lsp_resolve_and_load_imports(ASTModule *mod, const char **lib_roots, int n_lib_roots,
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

SHUX_WEAK int32_t pipeline_typeck_module_for_ctx(void *module, void *arena, void *ctx_void) {
  (void)module;
  (void)arena;
  (void)ctx_void;
  return -1;
}

SHUX_WEAK void ast_module_free(ASTModule *mod) {
  (void)mod;
}


/* -------------------------------------------------------------------------- */
/* G-02e：原 codegen_pipeline_stubs.c 并入本 TU。 */
/* -------------------------------------------------------------------------- */

SHUX_WEAK void codegen_set_preamble_has_core_option_result(int on) { (void)on; }
SHUX_WEAK void codegen_reset_preamble_skip_mask(void) { }
SHUX_WEAK void codegen_or_preamble_skip_mask(unsigned mask) { (void)mask; }
SHUX_WEAK unsigned codegen_get_preamble_skip_mask(void) { return 0; }

SHUX_WEAK void codegen_set_dep_slots_for_x_pipeline(struct ASTModule **mods, const char **paths, int n) {
  (void)mods;
  (void)paths;
  (void)n;
}

SHUX_WEAK int codegen_wpo_mono_sym_format(const char *base, int nargs, const int *args, char *out, int cap) {
  (void)base;
  (void)nargs;
  (void)args;
  (void)out;
  (void)cap;
  return -1;
}

SHUX_WEAK int codegen_module_to_c(struct ASTModule *m, FILE *out, struct ASTModule **dep_mods, const char **dep_import_paths, int ndep,
    codegen_is_func_used_fn is_func_used, codegen_is_mono_used_fn is_mono_used, codegen_is_type_used_fn is_type_used, void *dce_ctx,
    char (*emitted_type_names)[CODEGEN_EMITTED_TYPE_NAME_MAX], int *n_emitted_inout, int max_emitted) {
  (void)m; (void)out; (void)dep_mods; (void)dep_import_paths; (void)ndep;
  (void)is_func_used; (void)is_mono_used; (void)is_type_used; (void)dce_ctx;
  (void)emitted_type_names; (void)n_emitted_inout; (void)max_emitted;
  return -1;
}

SHUX_WEAK int codegen_library_module_to_c(struct ASTModule *m, const char *import_path,
    struct ASTModule **lib_dep_mods, const char **lib_dep_paths, int n_lib_dep,
    FILE *out,
    codegen_is_func_used_fn is_func_used, codegen_is_mono_used_fn is_mono_used, codegen_is_type_used_fn is_type_used, void *dce_ctx,
    char (*emitted_type_names)[CODEGEN_EMITTED_TYPE_NAME_MAX], int *n_emitted_inout, int max_emitted,
    const char *emit_entry_path) {
  (void)m; (void)import_path; (void)lib_dep_mods; (void)lib_dep_paths; (void)n_lib_dep;
  (void)out; (void)is_func_used; (void)is_mono_used; (void)is_type_used; (void)dce_ctx;
  (void)emitted_type_names; (void)n_emitted_inout; (void)max_emitted; (void)emit_entry_path;
  return -1;
}

SHUX_WEAK void codegen_compute_used(struct ASTModule *entry, struct ASTModule **dep_mods, int ndep,
    struct ASTFunc **used_funcs_out, int *n_used_out, int max_used, int used_mono[][64]) {
  (void)entry; (void)dep_mods; (void)ndep; (void)used_funcs_out; (void)max_used; (void)used_mono;
  if (n_used_out) *n_used_out = 0;
}

SHUX_WEAK struct ASTFunc *codegen_entry_root_func(struct ASTModule *entry) {
  (void)entry;
  return NULL;
}

SHUX_WEAK void codegen_wpo_reach_compute(CodegenWpoReach *out,
    struct ASTModule *entry,
    struct ASTModule **all_mods, int n_all) {
  (void)entry; (void)all_mods; (void)n_all;
  if (!out) return;
  memset(out, 0, sizeof(*out));
  out->root_id = -1;
}

SHUX_WEAK int codegen_wpo_reach_is_reachable(const CodegenWpoReach *wpo, const struct ASTModule *mod,
    const struct ASTFunc *func) {
  (void)wpo; (void)mod; (void)func;
  return 0;
}

SHUX_WEAK void codegen_compute_used_types(struct ASTModule *entry, struct ASTModule **dep_mods, int ndep,
    struct ASTFunc **used_funcs, int n_used, const char **used_type_names_out, int *n_out, int max_types) {
  (void)entry; (void)dep_mods; (void)ndep; (void)used_funcs; (void)n_used;
  (void)used_type_names_out; (void)max_types;
  if (n_out) *n_out = 0;
}

SHUX_WEAK void codegen_dump_wpo_callgraph_json(FILE *out,
    struct ASTModule *entry, const char *entry_path,
    struct ASTModule **all_mods, const char **all_paths, int n_all) {
  (void)entry; (void)entry_path; (void)all_mods; (void)all_paths; (void)n_all;
  if (out) fputs("{\"version\":2,\"nodes\":[]}\n", out);
}

/* ---- G-02e-10：原 _stubs_driver.c（pipeline_gen asm_driver_* → driver_*）---- */

extern int32_t driver_skip_codegen_dep_0_get(void);
extern void driver_set_current_dep_path_for_codegen(const char *path);

int32_t asm_driver_skip_codegen_dep_0_get(void) {
  return driver_skip_codegen_dep_0_get();
}

void asm_driver_set_current_dep_path_for_codegen(uint8_t *path) {
  driver_set_current_dep_path_for_codegen((const char *)path);
}

/* ---- G-02e-11：原 lsp_codegen_extern（LSP -E-extern 字符串块）---- */

/** 与 runtime.c 中 codegen_CodegenOutBuf 布局一致。 */
struct codegen_CodegenOutBuf {
  unsigned char data[9 * 1024 * 1024];
  int32_t len;
};

/** 路径是否 lsp_io.x 的 -E-extern 入口。 */
int lsp_codegen_emit_path_is_lsp_io_x(const char *path) {
  return path != NULL && strstr(path, "lsp_io.x") != NULL;
}

/** 路径是否 lsp/lsp.x 的 -E-extern 入口（排除 lsp_io 等子路径误匹配）。 */
int lsp_codegen_emit_path_is_lsp_main_x(const char *path) {
  if (!path)
    return 0;
  if (strstr(path, "/lsp/lsp.x") != NULL || strstr(path, "\\lsp\\lsp.x") != NULL)
    return 1;
  if (strstr(path, "lsp/lsp.x") != NULL && strstr(path, "lsp_io") == NULL)
    return 1;
  return 0;
}

static const char *lsp_heap_alias_block =
    "\n/* lsp_codegen_extern: std.heap typeck 链接别名（C-04 v0；std_io extern 由 codegen 自动生成） */\n"
    "extern uint8_t *typeck_std_heap_alloc(size_t size);\n"
    "extern void typeck_std_heap_free(uint8_t *ptr);\n"
    "#define std_heap_alloc typeck_std_heap_alloc\n"
    "#define std_heap_free typeck_std_heap_free\n";

static const char *lsp_io_extern_block =
    "\n/* lsp_codegen_extern: deprecated full io block — 保留给旧 bootstrap 路径 */\n"
    "extern int32_t std_io_read(size_t handle, uint8_t *ptr, size_t len, uint32_t timeout_ms);\n"
    "extern int32_t std_io_write(size_t handle, uint8_t *ptr, size_t len, uint32_t timeout_ms);\n"
    "extern void lsp_debug_u32(uint32_t n);\n"
    "#define typeck_lsp_debug_u32 lsp_debug_u32\n"
    "extern void lsp_debug_ptr(uint8_t *p);\n"
    "#define typeck_lsp_debug_ptr lsp_debug_ptr\n"
    "extern uint8_t *typeck_std_heap_alloc(size_t size);\n"
    "extern void typeck_std_heap_free(uint8_t *ptr);\n"
    "#define std_heap_alloc typeck_std_heap_alloc\n"
    "#define std_heap_free typeck_std_heap_free\n";

static const char *lsp_gen_extern_block =
    "\n/* lsp_codegen_extern: lsp.x -E-extern stubs (lsp_io_x.o 符号桥接) */\n"
    "extern ptrdiff_t typeck_read_message(int32_t fd, uint8_t *body_out, int32_t body_cap, uint8_t *state_buf);\n"
    "extern ptrdiff_t typeck_write_fd(int32_t fd, uint8_t *ptr, size_t count);\n"
    "extern uint8_t *typeck_lsp_alloc(size_t size);\n"
    "extern void typeck_lsp_free(uint8_t *ptr);\n"
    "extern int32_t typeck_lsp_is_null(uint8_t *ptr);\n"
    "extern int32_t typeck_extract_document_text(uint8_t *body, int32_t body_len, uint8_t *out_buf, int32_t out_cap);\n"
    "static inline ptrdiff_t lsp_io_read_message(int32_t fd, uint8_t *body_out, int32_t body_cap, uint8_t *state_buf) {\n"
    "  return typeck_read_message(fd, body_out, body_cap, state_buf);\n"
    "}\n"
    "static inline ptrdiff_t lsp_io_write_fd(int32_t fd, uint8_t *ptr, size_t count) {\n"
    "  return typeck_write_fd(fd, ptr, count);\n"
    "}\n"
    "static inline uint8_t *lsp_io_lsp_alloc(size_t size) {\n"
    "  return typeck_lsp_alloc(size);\n"
    "}\n"
    "static inline void lsp_io_lsp_free(uint8_t *ptr) {\n"
    "  typeck_lsp_free(ptr);\n"
    "}\n"
    "static inline int32_t lsp_io_lsp_is_null(uint8_t *ptr) {\n"
    "  return typeck_lsp_is_null(ptr);\n"
    "}\n"
    "static inline int32_t lsp_io_extract_document_text(uint8_t *body, int32_t body_len, uint8_t *out_buf, int32_t out_cap) {\n"
    "  return typeck_extract_document_text(body, body_len, out_buf, out_cap);\n"
    "}\n";

/** 追加文本到 CodegenOutBuf；容量不足返回 -1。 */
static int append_text_to_codegen_buf(struct codegen_CodegenOutBuf *out, const char *text) {
  size_t n;
  if (!out || !text)
    return -1;
  n = strlen(text);
  if (out->len < 0 || (size_t)out->len + n >= sizeof(out->data))
    return -1;
  memcpy(out->data + (size_t)out->len, text, n);
  out->len += (int32_t)n;
  return 0;
}

void lsp_codegen_emit_heap_alias_block(FILE *out) {
  if (out)
    fputs(lsp_heap_alias_block, out);
}

void lsp_codegen_emit_io_extern_block(FILE *out) {
  if (out)
    fputs(lsp_io_extern_block, out);
}

void lsp_codegen_emit_gen_extern_block(FILE *out) {
  if (out)
    fputs(lsp_gen_extern_block, out);
}

int lsp_codegen_emit_heap_alias_to_buf(struct codegen_CodegenOutBuf *out) {
  return append_text_to_codegen_buf(out, lsp_heap_alias_block);
}

int lsp_codegen_emit_io_extern_to_buf(struct codegen_CodegenOutBuf *out) {
  return append_text_to_codegen_buf(out, lsp_io_extern_block);
}

int lsp_codegen_emit_gen_extern_to_buf(struct codegen_CodegenOutBuf *out) {
  return append_text_to_codegen_buf(out, lsp_gen_extern_block);
}
