/**
 * lsp_diag_sx_alias.c — 将 lsp_diag.sx -E 产出的入口符号（typeck_* 前缀）别名到 lsp_gen 期望的无前缀名。
 * 新增 hover / references 桥接，统一走 .sx pipeline（arena 全量扫描，不依赖 C parser/typeck 缓存）。
 */

#include <stdint.h>

extern int32_t typeck_lsp_build_diagnostics_response(int32_t id_val, uint8_t *source, int32_t source_len, uint8_t *out_buf,
                                                     int32_t out_cap);

int32_t lsp_build_diagnostics_response(int32_t id_val, uint8_t *source, int32_t source_len, uint8_t *out_buf, int32_t out_cap) {
  return typeck_lsp_build_diagnostics_response(id_val, source, source_len, out_buf, out_cap);
}

/* hover: .sx 的 lsp_diag_hover_at → typeck_lsp_diag_hover_at */
extern int32_t typeck_lsp_diag_hover_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                         uint8_t *out_buf, int32_t out_cap);

int32_t lsp_diag_hover_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                           uint8_t *out_buf, int32_t out_cap) {
  return typeck_lsp_diag_hover_at(source, source_len, line_0, col_0, out_buf, out_cap);
}

/* references: .sx 的 lsp_diag_references_at → typeck_lsp_diag_references_at */
extern int32_t typeck_lsp_diag_references_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                              int32_t *out_lines, int32_t *out_cols, int32_t max_refs);

int32_t lsp_diag_references_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                int32_t *out_lines, int32_t *out_cols, int32_t max_refs) {
  return typeck_lsp_diag_references_at(source, source_len, line_0, col_0, out_lines, out_cols, max_refs);
}

/** bootstrap driver：强符号覆盖 lsp_diag.c 内 weak 实现，统一走 parse_into_buf。 */
int lsp_hover_at(const uint8_t *source, int source_len, int line_0, int col_0, char *out_buf, int out_cap) {
  return (int)typeck_lsp_diag_hover_at((uint8_t *)source, (int32_t)source_len, (int32_t)line_0, (int32_t)col_0,
                                       (uint8_t *)out_buf, (int32_t)out_cap);
}

int lsp_references_at(const uint8_t *source, int source_len, int line_0, int col_0,
                      int *out_lines, int *out_cols, int max_refs) {
  return (int)typeck_lsp_diag_references_at((uint8_t *)source, (int32_t)source_len, (int32_t)line_0, (int32_t)col_0,
                                            (int32_t *)out_lines, (int32_t *)out_cols, (int32_t)max_refs);
}

/* definition: .sx 的 lsp_diag_definition_at → typeck_lsp_diag_definition_at */
extern int32_t typeck_lsp_diag_definition_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                              int32_t *out_line, int32_t *out_col);

int32_t lsp_diag_definition_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                int32_t *out_line, int32_t *out_col) {
  return typeck_lsp_diag_definition_at(source, source_len, line_0, col_0, out_line, out_col);
}

/** bootstrap driver：强符号覆盖 lsp_diag.c 内 weak 实现，统一走 parse_into_buf。 */
int lsp_definition_at(const uint8_t *source, int source_len, int line_0, int col_0, int *out_line, int *out_col) {
  int32_t ol = 0;
  int32_t oc = 0;
  if (!typeck_lsp_diag_definition_at((uint8_t *)source, (int32_t)source_len, (int32_t)line_0, (int32_t)col_0, &ol, &oc))
    return 0;
  if (out_line) *out_line = (int)ol;
  if (out_col) *out_col = (int)oc;
  return 1;
}

/* semanticTokens/full：lsp_diag.sx -E 产出 typeck_ 前缀，lsp.sx 期望无前缀名。 */
extern int32_t typeck_lsp_build_semantic_tokens_response(int32_t id_val, uint8_t *doc_buf, int32_t doc_len,
                                                          uint8_t *out_buf, int32_t out_cap);

int32_t lsp_build_semantic_tokens_response(int32_t id_val, uint8_t *doc_buf, int32_t doc_len,
                                            uint8_t *out_buf, int32_t out_cap) {
  return typeck_lsp_build_semantic_tokens_response(id_val, doc_buf, doc_len, out_buf, out_cap);
}

/* lsp.sx -E 经 lsp_io 模块引用 invalidate，符号名为 lsp_io_lsp_diag_invalidate_cache；实现仍在 C lsp_diag.o。 */
extern void lsp_diag_invalidate_cache(void);

void lsp_io_lsp_diag_invalidate_cache(void) {
  lsp_diag_invalidate_cache();
}
