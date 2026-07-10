/**
 * lsp_diag_pipeline_ctx.c — LSP PipelineDepCtx 路径填充 + lsp_diag.x 符号别名
 *
 * 仅 bootstrap-driver / shux --lsp 链入；依赖 ast_pool 中 pipeline_ctx_append_lib_root。
 * shux-c 不链本文件，使用 lsp_diag_pipeline_sizes.c 中的弱符号占位。
 *
 * G-02e-8：原 lsp_diag_x_alias.c（typeck_* → 无前缀 / bootstrap 强覆盖）并入本 TU。
 * G-02e-9：原 lsp_state.c（g_lsp_state_buf / typeck_lsp_main / lsp_write_all）并入本 TU。
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include "diag.h"
#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#ifndef _WIN32
#include <unistd.h>
#endif

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

/* ---- G-02e-8：原 lsp_diag_x_alias（lsp_diag.x -E typeck_* 前缀 → 无前缀入口）---- */

extern int32_t typeck_lsp_build_diagnostics_response(int32_t id_val, uint8_t *source, int32_t source_len, uint8_t *out_buf,
                                                     int32_t out_cap);

__attribute__((weak)) int32_t lsp_build_diagnostics_response(int32_t id_val, uint8_t *source, int32_t source_len, uint8_t *out_buf, int32_t out_cap) {
  return typeck_lsp_build_diagnostics_response(id_val, source, source_len, out_buf, out_cap);
}

/* hover: .x 的 lsp_diag_hover_at → typeck_lsp_diag_hover_at */
extern int32_t typeck_lsp_diag_hover_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                         uint8_t *out_buf, int32_t out_cap);

__attribute__((weak)) int32_t lsp_diag_hover_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                           uint8_t *out_buf, int32_t out_cap) {
  return typeck_lsp_diag_hover_at(source, source_len, line_0, col_0, out_buf, out_cap);
}

/* references: .x 的 lsp_diag_references_at → typeck_lsp_diag_references_at */
extern int32_t typeck_lsp_diag_references_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                              int32_t *out_lines, int32_t *out_cols, int32_t max_refs);

__attribute__((weak)) int32_t lsp_diag_references_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                int32_t *out_lines, int32_t *out_cols, int32_t max_refs) {
  return typeck_lsp_diag_references_at(source, source_len, line_0, col_0, out_lines, out_cols, max_refs);
}

/** bootstrap driver：强符号覆盖 lsp_diag.c 内 weak 实现，统一走 parse_into_buf。 */
__attribute__((weak)) int lsp_hover_at(const uint8_t *source, int source_len, int line_0, int col_0, char *out_buf, int out_cap) {
  return (int)typeck_lsp_diag_hover_at((uint8_t *)source, (int32_t)source_len, (int32_t)line_0, (int32_t)col_0,
                                       (uint8_t *)out_buf, (int32_t)out_cap);
}

__attribute__((weak)) int lsp_references_at(const uint8_t *source, int source_len, int line_0, int col_0,
                      int *out_lines, int *out_cols, int max_refs) {
  return (int)typeck_lsp_diag_references_at((uint8_t *)source, (int32_t)source_len, (int32_t)line_0, (int32_t)col_0,
                                            (int32_t *)out_lines, (int32_t *)out_cols, (int32_t)max_refs);
}

/* definition: .x 的 lsp_diag_definition_at → typeck_lsp_diag_definition_at */
extern int32_t typeck_lsp_diag_definition_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                              int32_t *out_line, int32_t *out_col);

__attribute__((weak)) int32_t lsp_diag_definition_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                int32_t *out_line, int32_t *out_col) {
  return typeck_lsp_diag_definition_at(source, source_len, line_0, col_0, out_line, out_col);
}

/** bootstrap driver：强符号覆盖 lsp_diag.c 内 weak 实现，统一走 parse_into_buf。 */
__attribute__((weak)) int lsp_definition_at(const uint8_t *source, int source_len, int line_0, int col_0, int *out_line, int *out_col) {
  int32_t ol = 0;
  int32_t oc = 0;
  if (!typeck_lsp_diag_definition_at((uint8_t *)source, (int32_t)source_len, (int32_t)line_0, (int32_t)col_0, &ol, &oc))
    return 0;
  if (out_line) *out_line = (int)ol;
  if (out_col) *out_col = (int)oc;
  return 1;
}

/* semanticTokens/full：lsp_diag.x -E 产出 typeck_ 前缀，lsp.x 期望无前缀名。 */
extern int32_t typeck_lsp_build_semantic_tokens_response(int32_t id_val, uint8_t *doc_buf, int32_t doc_len,
                                                          uint8_t *out_buf, int32_t out_cap);

__attribute__((weak)) int32_t lsp_build_semantic_tokens_response(int32_t id_val, uint8_t *doc_buf, int32_t doc_len,
                                            uint8_t *out_buf, int32_t out_cap) {
  return typeck_lsp_build_semantic_tokens_response(id_val, doc_buf, doc_len, out_buf, out_cap);
}

/* lsp.x -E 经 lsp_io 模块引用 invalidate，符号名为 lsp_io_lsp_diag_invalidate_cache；实现仍在 C lsp_diag.o。 */
extern void lsp_diag_invalidate_cache(void);

__attribute__((weak)) void lsp_io_lsp_diag_invalidate_cache(void) {
  lsp_diag_invalidate_cache();
}

/* ---- G-02e-9：原 lsp_state（LSP state 缓冲 + large-stack main）---- */

/** 由 lsp.x 导出（function lsp_main_impl）；本文件 wrapper 再导出 typeck_lsp_main 供 main.x 调用。 */
extern int32_t typeck_lsp_main_impl(void);
extern void driver_bump_stack_limit(void);
extern void driver_run_on_large_stack_pthread(void *(*fn)(void *), void *arg);

uint8_t g_lsp_state_buf[16388];

/** LSP 主循环线程参数：pthread 入口写回退出码。 */
typedef struct LspMainThreadArgs {
    int32_t result;
} LspMainThreadArgs;

static void lsp_debug_report_sqpoll_env(void) {
    const char *dbg = getenv("SHUX_LSP_IO_DEBUG");
    const char *sq = getenv("SHUX_IO_URING_SQPOLL");
    if (!dbg || dbg[0] == '\0' || dbg[0] == '0')
        return;
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "lsp io debug: SHUX_IO_URING_SQPOLL=%s",
                 (sq && sq[0]) ? sq : "<unset>");
}

static void lsp_apply_default_io_policy(void) {
    const char *sq = getenv("SHUX_IO_URING_SQPOLL");
    /* LSP 长时间空闲等 stdin，不适合默认拉起 SQPOLL 线程；若用户显式设置，则尊重用户策略。 */
    if (!sq || sq[0] == '\0')
        (void)setenv("SHUX_IO_URING_SQPOLL", "0", 1);
}

/** pthread 入口：抬高栈上限后执行 typeck_lsp_main_impl。 */
static void *lsp_main_large_stack_thread_fn(void *arg) {
    LspMainThreadArgs *a = (LspMainThreadArgs *)arg;
    driver_bump_stack_limit();
    a->result = typeck_lsp_main_impl();
    return NULL;
}

/**
 * LSP 主入口：在 256MiB 栈线程上运行 lsp_main_impl，与 pipeline/typeck 大栈路径一致。
 * main.x --lsp 调用此符号；lsp_gen.c 仅提供 typeck_lsp_main_impl。
 */
int32_t typeck_lsp_main(void) {
    LspMainThreadArgs args;
    args.result = -1;
    lsp_apply_default_io_policy();
    lsp_debug_report_sqpoll_env();
    driver_run_on_large_stack_pthread(lsp_main_large_stack_thread_fn, &args);
    return args.result;
}

/** 供 lsp.x read_message 使用，避免 lsp_main 栈上再放 16KiB state（与 g_lsp_state_buf 同缓冲）。 */
uint8_t *lsp_state_buf_ptr(void) {
    return g_lsp_state_buf;
}

/**
 * 向 fd 完整写入 buf[0..len)；短写时循环直至写完或出错。
 * LSP stdout 走 libc write，绕过 std.io/io_uring（Linux ARM64 pipe 上曾丢 Content-Length 头）。
 * 成功返回 0，失败返回 -1。
 */
int32_t lsp_write_all(int32_t fd, const uint8_t *buf, int32_t len) {
    int32_t off = 0;
    if (fd < 0 || !buf) {
        return -1;
    }
    if (len <= 0) {
        return 0;
    }
    while (off < len) {
        ssize_t n = write(fd, buf + (size_t)off, (size_t)(len - off));
        if (n < 0) {
            if (errno == EINTR) {
                continue;
            }
            return -1;
        }
        if (n == 0) {
            return -1;
        }
        off += (int32_t)n;
    }
    return 0;
}
