/**
 * seeds/asm_xlang_lsp_diag_stub.from_x.c — 8.3.7 B-hybrid / asm-only LSP diag link stubs
 * Authority (G.7): minimal stubs for lsp_x.o (diagnostics/semanticTokens + invalidate
 * forward). Full LSP lives on bootstrap-driver-seed xlang / xlang-x; cannot link full
 * lsp_diag_x.o next to pipeline_x.o (duplicate ast symbols).
 * Host leaf scripts/asm_xlang_lsp_diag_stub.c deleted (wave297); ensure seed-only .o.
 * PLATFORM: SHARED — build_xlang_asm / strict_glue / experimental_bootstrap.
 */

#include <stdint.h>

/** 空 Diagnostic[] JSON 片段，供 lsp.x 走通链接。 */
int32_t lsp_build_diagnostics_response(int32_t id_val, const uint8_t *source, int32_t source_len,
                                       uint8_t *out_buf, int32_t out_cap) {
  (void)id_val;
  (void)source;
  (void)source_len;
  if (!out_buf || out_cap < 2) {
    return -1;
  }
  out_buf[0] = (uint8_t)'[';
  out_buf[1] = (uint8_t)']';
  return 2;
}

/** semanticTokens/full：返回空数组占位，避免依赖 lsp_diag_x.o 的 typeck_* 实现。 */
int32_t lsp_build_semantic_tokens_response(int32_t id_val, const uint8_t *doc_buf, int32_t doc_len,
                                           uint8_t *out_buf, int32_t out_cap) {
  (void)id_val;
  (void)doc_buf;
  (void)doc_len;
  if (!out_buf || out_cap < 2) {
    return -1;
  }
  out_buf[0] = (uint8_t)'[';
  out_buf[1] = (uint8_t)']';
  return 2;
}

/** lsp.x 经 lsp_io 模块名 mangling 后的 invalidate；转发到已链入的 lsp_diag.o。 */
extern void lsp_diag_invalidate_cache(void);

void lsp_io_lsp_diag_invalidate_cache(void) {
  lsp_diag_invalidate_cache();
}
