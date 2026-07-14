/* seeds/rt_parse_diag.from_x.c — G-02f-307 P2 runtime rest (precise parse diag)
 * Logic source: src/runtime/rt_parse_diag.x
 * Hybrid: SHUX_RT_PARSE_DIAG_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2 full（2026-07-14）：runtime_report_precise_parse_failure_if_known 由 .x 提供；
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体（TOKEN_STRING → P001）。
 */
#include <stddef.h>
#include <stdint.h>

#include "token.h"
#include "runtime_diag_codes.h"

struct shux_slice_uint8_t {
  uint8_t *data;
  size_t length;
};

extern int32_t parser_diag_fail_at_token_kind(struct shux_slice_uint8_t *source);
extern void diag_reportf_with_code(const char *file, int line, int col, const char *kind, const char *code,
                                   const char *detail, const char *fmt, ...);

#ifndef SHUX_RT_PARSE_DIAG_FROM_X
int runtime_report_precise_parse_failure_if_known(const char *input_path, const char *src, size_t src_len) {
  struct shux_slice_uint8_t diag_src_slice;
  int32_t fail_tok;
  if (!src || src_len == 0)
    return 0;
  diag_src_slice.data = (uint8_t *)src;
  diag_src_slice.length = src_len;
  fail_tok = parser_diag_fail_at_token_kind(&diag_src_slice);
  if (fail_tok == TOKEN_STRING) {
    diag_reportf_with_code(input_path, 0, 0, "parse error", SHUX_DIAG_CODE_PARSE_P001, NULL,
                           "expected integer literal, float literal, identifier, 'true', 'false', 'if', "
                           "'break', 'continue', 'return', 'panic', 'match', or '('");
    return 1;
  }
  return 0;
}
#else
int runtime_report_precise_parse_failure_if_known(const char *input_path, const char *src, size_t src_len);
#endif

int labi_rt_parse_diag_slice_marker(void) {
  return 1;
}
