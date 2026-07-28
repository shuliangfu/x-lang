/* seeds/lsp_diag_pipeline_ctx_surface.from_x.c
 * G-02f-91 lsp_diag_pipeline_ctx R2 thin+rest surface - isomorphic with src/lsp/lsp_diag_pipeline_ctx.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/lsp_diag_pipeline_ctx.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (14 #[no_mangle])
 * Mode: thin+rest - 14 thin forwards to extern bridges
 * Cap residual: 14 extern bridges (pipeline_sizeof_dep_ctx + typeck_lsp_build_diagnostics_response
 *   + typeck_lsp_diag_hover_at + typeck_lsp_diag_references_at + typeck_lsp_diag_definition_at
 *   + typeck_lsp_build_semantic_tokens_response + lsp_diag_invalidate_cache
 *   + lsp_diag_pipeline_ctx_fill_paths_impl + typeck_lsp_main_impl + lsp_write_all_impl
 *   + lsp_debug_report_sqpoll_env_impl + lsp_apply_default_io_policy_impl)
 *   Note: typeck_lsp_diag_hover_at and typeck_lsp_diag_references_at are each called by 2 wrappers.
 * No doc_anchor (lsp_diag_pipeline_ctx.x has none).
 * Note: lsp_/typeck_ prefix not trigger ast_ (confirmed wave545+).
 * Logic: 14 thin+rest functions.
 * Regen: ./xlang-c -E ... lsp_diag_pipeline_ctx.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern size_t pipeline_sizeof_dep_ctx(void);
extern int32_t typeck_lsp_build_diagnostics_response(int32_t id_val, uint8_t *source, int32_t source_len,
                                                     uint8_t *out_buf, int32_t out_cap);
extern int32_t typeck_lsp_diag_hover_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                        uint8_t *out_buf, int32_t out_cap);
extern int32_t typeck_lsp_diag_references_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                             int32_t *out_lines, int32_t *out_cols, int32_t max_refs);
extern int32_t typeck_lsp_diag_definition_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                             int32_t *out_line, int32_t *out_col);
extern int32_t typeck_lsp_build_semantic_tokens_response(int32_t id_val, uint8_t *doc_buf, int32_t doc_len,
                                                         uint8_t *out_buf, int32_t out_cap);
extern void lsp_diag_invalidate_cache(void);
extern void lsp_diag_pipeline_ctx_fill_paths_impl(uint8_t *ctx_void, uint8_t *entry_dir, uint8_t *lib_roots,
                                                  int32_t n_lib_roots);
extern int32_t typeck_lsp_main_impl(void);
extern int32_t lsp_write_all_impl(int32_t fd, uint8_t *buf, int32_t len);
extern void lsp_debug_report_sqpoll_env_impl(void);
extern void lsp_apply_default_io_policy_impl(void);

/* === 14 thin+rest forwards === */

size_t lsp_diag_x_alloc_dep_ctx_size(void) {
  return pipeline_sizeof_dep_ctx();
}

int32_t lsp_build_diagnostics_response(int32_t id_val, uint8_t *source, int32_t source_len,
                                       uint8_t *out_buf, int32_t out_cap) {
  return typeck_lsp_build_diagnostics_response(id_val, source, source_len, out_buf, out_cap);
}

int32_t lsp_diag_hover_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                          uint8_t *out_buf, int32_t out_cap) {
  return typeck_lsp_diag_hover_at(source, source_len, line_0, col_0, out_buf, out_cap);
}

int32_t lsp_diag_references_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                               int32_t *out_lines, int32_t *out_cols, int32_t max_refs) {
  return typeck_lsp_diag_references_at(source, source_len, line_0, col_0, out_lines, out_cols, max_refs);
}

int32_t lsp_hover_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                     uint8_t *out_buf, int32_t out_cap) {
  return typeck_lsp_diag_hover_at(source, source_len, line_0, col_0, out_buf, out_cap);
}

int32_t lsp_references_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                          int32_t *out_lines, int32_t *out_cols, int32_t max_refs) {
  return typeck_lsp_diag_references_at(source, source_len, line_0, col_0, out_lines, out_cols, max_refs);
}

int32_t lsp_diag_definition_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                               int32_t *out_line, int32_t *out_col) {
  return typeck_lsp_diag_definition_at(source, source_len, line_0, col_0, out_line, out_col);
}

int32_t lsp_build_semantic_tokens_response(int32_t id_val, uint8_t *doc_buf, int32_t doc_len,
                                           uint8_t *out_buf, int32_t out_cap) {
  return typeck_lsp_build_semantic_tokens_response(id_val, doc_buf, doc_len, out_buf, out_cap);
}

void lsp_io_lsp_diag_invalidate_cache(void) {
  lsp_diag_invalidate_cache();
}

void lsp_diag_pipeline_ctx_fill_paths(uint8_t *ctx_void, uint8_t *entry_dir, uint8_t *lib_roots,
                                      int32_t n_lib_roots) {
  lsp_diag_pipeline_ctx_fill_paths_impl(ctx_void, entry_dir, lib_roots, n_lib_roots);
}

int32_t typeck_lsp_main(void) {
  return typeck_lsp_main_impl();
}

int32_t lsp_write_all(int32_t fd, uint8_t *buf, int32_t len) {
  return lsp_write_all_impl(fd, buf, len);
}

void lsp_debug_report_sqpoll_env(void) {
  lsp_debug_report_sqpoll_env_impl();
}

void lsp_apply_default_io_policy(void) {
  lsp_apply_default_io_policy_impl();
}
