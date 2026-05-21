/**
 * lsp_diag_su_alias.c — 将 lsp_diag.su -E 产出的入口符号（typeck_* 前缀）别名到 lsp_gen 期望的无前缀名。
 * 新增 hover / references 桥接，统一走 .su pipeline（arena 全量扫描，不依赖 C parser/typeck 缓存）。
 */

#include <stdint.h>

extern int32_t typeck_lsp_build_diagnostics_response(int32_t id_val, uint8_t *source, int32_t source_len, uint8_t *out_buf,
                                                     int32_t out_cap);

int32_t lsp_build_diagnostics_response(int32_t id_val, uint8_t *source, int32_t source_len, uint8_t *out_buf, int32_t out_cap) {
  return typeck_lsp_build_diagnostics_response(id_val, source, source_len, out_buf, out_cap);
}

/* hover: .su 的 lsp_diag_hover_at → typeck_lsp_diag_hover_at */
extern int32_t typeck_lsp_diag_hover_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                         uint8_t *out_buf, int32_t out_cap);

int32_t lsp_diag_hover_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                           uint8_t *out_buf, int32_t out_cap) {
  return typeck_lsp_diag_hover_at(source, source_len, line_0, col_0, out_buf, out_cap);
}

/* references: .su 的 lsp_diag_references_at → typeck_lsp_diag_references_at */
extern int32_t typeck_lsp_diag_references_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                              int32_t *out_lines, int32_t *out_cols, int32_t max_refs);

int32_t lsp_diag_references_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                int32_t *out_lines, int32_t *out_cols, int32_t max_refs) {
  return typeck_lsp_diag_references_at(source, source_len, line_0, col_0, out_lines, out_cols, max_refs);
}

/* semanticTokens/full：lsp_diag.su -E 产出 typeck_ 前缀，lsp.su 期望无前缀名。 */
extern int32_t typeck_lsp_build_semantic_tokens_response(int32_t id_val, uint8_t *doc_buf, int32_t doc_len,
                                                          uint8_t *out_buf, int32_t out_cap);

int32_t lsp_build_semantic_tokens_response(int32_t id_val, uint8_t *doc_buf, int32_t doc_len,
                                            uint8_t *out_buf, int32_t out_cap) {
  return typeck_lsp_build_semantic_tokens_response(id_val, doc_buf, doc_len, out_buf, out_cap);
}

/* lsp.su -E 经 lsp_io 模块引用 invalidate，符号名为 lsp_io_lsp_diag_invalidate_cache；实现仍在 C lsp_diag.o。 */
extern void lsp_diag_invalidate_cache(void);

void lsp_io_lsp_diag_invalidate_cache(void) {
  lsp_diag_invalidate_cache();
}
