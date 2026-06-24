/* G-06 cold-start seed stub for lsp_diag.sx (C-04 marker required by Makefile) */
#include <stdint.h>
#include <stddef.h>

/* C-04 -E-extern TU aliases */

int32_t typeck_lsp_diag_hover_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
    uint8_t *out_buf, int32_t out_cap) {
  (void)source; (void)source_len; (void)line_0; (void)col_0; (void)out_buf; (void)out_cap;
  return 0;
}

int32_t typeck_lsp_diag_references_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
    int32_t *out_lines, int32_t *out_cols, int32_t max_refs) {
  (void)source; (void)source_len; (void)line_0; (void)col_0; (void)out_lines; (void)out_cols; (void)max_refs;
  return 0;
}

int32_t typeck_lsp_diag_definition_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
    int32_t *out_line, int32_t *out_col) {
  (void)source; (void)source_len; (void)line_0; (void)col_0;
  if (out_line) { *out_line = 0; }
  if (out_col) { *out_col = 0; }
  return 0;
}

int32_t typeck_lsp_build_diagnostics_response(int32_t id_val, uint8_t *source, int32_t source_len,
    uint8_t *out_buf, int32_t out_cap) {
  (void)id_val; (void)source; (void)source_len; (void)out_buf; (void)out_cap;
  return 0;
}

int32_t typeck_lsp_build_definition_response(int32_t id_val, uint8_t *body, int32_t body_len,
    uint8_t *doc_buf, int32_t doc_len, uint8_t *out_buf, int32_t out_cap) {
  (void)id_val; (void)body; (void)body_len; (void)doc_buf; (void)doc_len; (void)out_buf; (void)out_cap;
  return 0;
}

int32_t typeck_lsp_build_references_response(int32_t id_val, uint8_t *body, int32_t body_len,
    uint8_t *doc_buf, int32_t doc_len, uint8_t *out_buf, int32_t out_cap) {
  (void)id_val; (void)body; (void)body_len; (void)doc_buf; (void)doc_len; (void)out_buf; (void)out_cap;
  return 0;
}

int32_t typeck_lsp_build_hover_response(int32_t id_val, uint8_t *body, int32_t body_len,
    uint8_t *doc_buf, int32_t doc_len, uint8_t *out_buf, int32_t out_cap) {
  (void)id_val; (void)body; (void)body_len; (void)doc_buf; (void)doc_len; (void)out_buf; (void)out_cap;
  return 0;
}

void typeck_lsp_diag_invalidate_cache(void) {}

int32_t typeck_lsp_build_initialize_result(uint8_t *out_buf, int32_t out_cap) {
  (void)out_buf; (void)out_cap;
  return 0;
}
