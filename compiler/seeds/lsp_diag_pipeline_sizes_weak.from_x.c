/* seeds/lsp_diag_pipeline_sizes_weak.from_x.c — G-02f-81
 * Non-product shux-c chain: sizeof + weak fill_paths stubs.
 * Product G05 uses seeds/lsp_diag_pipeline_sizes.from_x.c (nostub).
 * Promoted from compiler/src/lsp/lsp_diag_pipeline_sizes.inc.
 */
/**
 * lsp_diag_pipeline_sizes_weak.from_x.c — 非产品链（含 weak fill_paths 占位）的瘦 sizeof + 弱桩。
 *
 * G-02f-1：产品 G05 的 `lsp_diag_pipeline_sizes_nostub.o` 已改由
 * `src/lsp/lsp_diag_pipeline_sizes.x`（#[no_mangle]）→ `seeds/lsp_diag_pipeline_sizes.from_x.c` 提供；
 * 本 .inc 仅供 `lsp_diag_pipeline_sizes.o`（shux-c / 无 ctx 链）继续使用。
 * 瘦 sizeof 常量须与 .x 一致：arena=16 / module=40 / dep_ctx=1368。
 */
#include <stddef.h>
#include <stdint.h>
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

enum ast_TypeKind { ast_TypeKind_TYPE_I32 };
enum ast_ExprKind { ast_ExprKind_EXPR_LIT };
struct ast_Type {
  int32_t kind;
  uint8_t name[64];
  int32_t name_len;
  int32_t elem_type_ref;
  int32_t array_size;
  uint8_t region_label[64];
  int32_t region_label_len;
};
struct ast_Expr { int32_t kind; };
struct ast_Block { int32_t const_base; int32_t num_consts; };
struct ast_Func { uint8_t name[64]; int32_t name_len; int32_t param_base; int32_t num_params; };
struct ast_StructLayout { uint8_t name[64]; int32_t name_len; int32_t field_base; int32_t num_fields; int32_t allow_padding; int32_t soa; };

/** 瘦身后 Module：import/struct/top_level/enum 在 C grow pool。 */
struct ast_Module {
  int32_t num_funcs;
  int32_t main_func_index;
  int32_t num_imports;
  int32_t num_top_level_lets;
  int32_t num_struct_layouts;
  int32_t pending_allow_padding;
  int32_t pending_soa_struct;
  int32_t pending_cfg_skip;
  int32_t pending_repr_c_struct;
  int32_t num_module_enums;
};

/** 瘦身后 ASTArena：主池在 C grow pool。 */
struct ast_ASTArena {
  int32_t num_types;
  int32_t num_exprs;
  int32_t num_blocks;
  int32_t num_funcs;
};

struct ast_PipelineDepCtx {
  int32_t ndep;
  uint8_t entry_dir_buf[512];
  int32_t entry_dir_len;
  int32_t num_lib_roots;
  uint8_t path_buf[512];
  uint8_t *loaded_buf;
  ptrdiff_t loaded_len;
  uint8_t *preprocess_buf;
  int32_t preprocess_len;
  int32_t use_asm_backend;
  int32_t target_arch;
  int32_t target_cpu_features;
  int32_t use_macho_o;
  int32_t use_coff_o;
  int32_t current_block_ref;
  int32_t typeck_loop_depth;
  /** typeck: check_expr 递归深度计数器，防 self-typeck.x 编译时循环引用栈溢出（lsp_diag_pipeline_sizes.c）。 */
  int32_t typeck_check_depth;
  int32_t current_func_index;
  int32_t skip_codegen_dep_0;
  int32_t check_only_mode;
  int32_t entry_already_parsed;
  int32_t current_func_single_empty_param_index;
  int32_t current_func_empty_param_count;
  int32_t current_emit_empty_var_next_index;
  int32_t emit_expr_as_callee;
  struct ast_Module *current_codegen_module;
  struct ast_ASTArena *current_codegen_arena;
  int32_t current_codegen_dep_index;
  uint8_t current_codegen_prefix_mirror[64];
  int32_t current_codegen_prefix_len;
  int32_t asm_entry_module_only;
  uint8_t entry_module_import_path_mirror[64];
  int32_t entry_module_import_path_len;
  int32_t typeck_scope_region_len;
  uint8_t typeck_scope_region_label[64];
};

size_t lsp_diag_pipeline_sizeof_arena(void) { return sizeof(struct ast_ASTArena); }
size_t lsp_diag_pipeline_sizeof_module(void) { return sizeof(struct ast_Module); }
size_t lsp_diag_pipeline_sizeof_dep_ctx(void) { return sizeof(struct ast_PipelineDepCtx); }

/**
 * shux-c / 无 pipeline_x 时的弱占位：返回 0 表示用瘦 struct 尺寸。
 * bootstrap-driver 链 lsp_diag_pipeline_ctx.o 时由强符号覆盖为 pipeline_sizeof_dep_ctx()。
 * SHUX_LSP_PIPELINE_CTX_LINKED：bootstrap 同时链 ctx.o，本 TU 勿再导出占位（Cygwin 无 weak）。
 */
#ifndef SHUX_LSP_PIPELINE_CTX_LINKED
#if defined(__CYGWIN__) || defined(_WIN32) || defined(__MINGW32__)
size_t lsp_diag_x_alloc_dep_ctx_size(void) { return 0; }
#else
SHUX_WEAK size_t lsp_diag_x_alloc_dep_ctx_size(void) { return 0; }
#endif

/** shux-c 链接用占位；bootstrap-driver 链入 lsp_diag_pipeline_ctx.o 强符号覆盖。MSYS2/Cygwin 不支持 ELF weak。 */
#if defined(__CYGWIN__) || defined(_WIN32) || defined(__MINGW32__)
void lsp_diag_pipeline_ctx_fill_paths(void *ctx_void, const char *entry_dir,
                                      const char **lib_roots, int n_lib_roots) {
#else
SHUX_WEAK void lsp_diag_pipeline_ctx_fill_paths(void *ctx_void, const char *entry_dir,
                                                            const char **lib_roots, int n_lib_roots) {
#endif
    (void)ctx_void;
    (void)entry_dir;
    (void)lib_roots;
    (void)n_lib_roots;
}
#endif /* !SHUX_LSP_PIPELINE_CTX_LINKED */
