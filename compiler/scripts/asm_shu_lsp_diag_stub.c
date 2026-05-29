/**
 * asm_shu_lsp_diag_stub.c — build_shu_asm B-hybrid / asm-only 链接桩
 *
 * lsp_su.o 引用若干 LSP 响应构建符号；整份 lsp_diag_su.o 与 pipeline_su.o 重复 ast 符号，不能并列链入。
 * 本文件提供最小桩，使 shu_asm 可链接；完整 LSP 仍用 bootstrap-driver-seed 的 shu / shu-su。
 */
#include <stdint.h>

/** 空 Diagnostic[] JSON 片段，供 lsp.su 走通链接。 */
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

/** semanticTokens/full：返回空数组占位，避免依赖 lsp_diag_su.o 的 typeck_* 实现。 */
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

/** lsp.su 经 lsp_io 模块名 mangling 后的 invalidate；转发到已链入的 lsp_diag.o。 */
extern void lsp_diag_invalidate_cache(void);

void lsp_io_lsp_diag_invalidate_cache(void) {
  lsp_diag_invalidate_cache();
}
