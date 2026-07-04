/**
 * lsp_diag_pipeline_ctx.c — LSP PipelineDepCtx 路径填充（libRoots / entry_dir）
 *
 * 仅 bootstrap-driver / shux --lsp 链入；依赖 ast_pool 中 pipeline_ctx_append_lib_root。
 * shux-c 不链本文件，使用 lsp_diag_pipeline_sizes.c 中的弱符号占位。
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

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
  int32_t use_macho_o;
  int32_t use_coff_o;
  int32_t current_block_ref;
  int32_t typeck_loop_depth;
  /** typeck: check_expr 递归深度计数器，防 self-typeck.x 编译时循环引用栈溢出（lsp_diag_pipeline_ctx.c）。 */
  int32_t typeck_check_depth;
  int32_t current_func_index;
  int32_t skip_codegen_dep_0;
  int32_t check_only_mode;
  int32_t entry_already_parsed;
  int32_t current_func_single_empty_param_index;
  int32_t current_func_empty_param_count;
  int32_t current_emit_empty_var_next_index;
  int32_t emit_expr_as_callee;
  void *current_codegen_module;
  void *current_codegen_arena;
  int32_t current_codegen_dep_index;
  uint8_t current_codegen_prefix_mirror[64];
  int32_t current_codegen_prefix_len;
  int32_t asm_entry_module_only;
  uint8_t entry_module_import_path_mirror[64];
  int32_t entry_module_import_path_len;
};

extern int32_t pipeline_ctx_append_lib_root(struct ast_PipelineDepCtx *ctx, uint8_t *path, int32_t len);
extern size_t pipeline_sizeof_dep_ctx(void);

/**
 * bootstrap-driver 专用：LSP ctx 须与 ast.x PipelineDepCtx（4MiB×2 内嵌缓冲）同尺寸。
 */
size_t lsp_diag_x_alloc_dep_ctx_size(void) {
  return pipeline_sizeof_dep_ctx();
}

/**
 * 填充 PipelineDepCtx 的 entry_dir 与 libRoots sidecar（供 .x resolve_path_x 使用）。
 * 调用前 ctx 可为任意状态；内部先清零再写入路径缓冲。
 */
void lsp_diag_pipeline_ctx_fill_paths(void *ctx_void, const char *entry_dir, const char **lib_roots, int n_lib_roots) {
    struct ast_PipelineDepCtx *ctx = (struct ast_PipelineDepCtx *)ctx_void;
    int i;
    if (!ctx) return;
    memset(ctx, 0, sizeof(*ctx));
    if (entry_dir && entry_dir[0]) {
        size_t el = strlen(entry_dir);
        if (el >= 512) el = 511;
        memcpy(ctx->entry_dir_buf, entry_dir, el);
        ctx->entry_dir_buf[el] = '\0';
        ctx->entry_dir_len = (int32_t)el;
    }
    if (lib_roots && n_lib_roots > 0) {
        for (i = 0; i < n_lib_roots && lib_roots[i]; i++) {
            size_t ll = strlen(lib_roots[i]);
            if (ll >= 256) ll = 255;
            (void)pipeline_ctx_append_lib_root(ctx, (uint8_t *)lib_roots[i], (int32_t)ll);
        }
    }
}
