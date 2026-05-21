/**
 * asm_shu_lsp_diag_stub.c — build_shu_asm B-hybrid 链接桩
 *
 * lsp_su.o 引用 lsp_build_diagnostics_response；整份 lsp_diag_su.o 与 pipeline_su.o 重复 ast 符号。
 * 本桩返回空诊断数组，使 shu_asm 可链接；完整 LSP 诊断仍用 bootstrap-driver-seed 的 shu / shu-su。
 */
#include <stdint.h>

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
