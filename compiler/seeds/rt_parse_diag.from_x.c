/* seeds/rt_parse_diag.from_x.c — G-02f-307 P2 runtime rest (precise parse diag)
 * Logic source: src/runtime/rt_parse_diag.x
 * Hybrid: SHUX_RT_PARSE_DIAG_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * Scope: runtime_report_precise_parse_failure_if_known（TOKEN_STRING → P001 文案）。
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

/* G-02f-448：thin+rest PREFER_X_O
 *   thin .x provides 1 #[no_mangle] wrapper (calls *_impl in rest).
 *   rest seed C (compiled with -DSHUX_RT_PARSE_DIAG_FROM_X):
 *     - runtime_report_precise_parse_failure_if_known renamed to *_impl via macro.
 *   No #ifndef guard needed (no real .x implementation; .x is thin-only). */
#ifdef SHUX_RT_PARSE_DIAG_FROM_X
#define runtime_report_precise_parse_failure_if_known    runtime_report_precise_parse_failure_if_known_impl
#endif

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

int labi_rt_parse_diag_slice_marker(void) {
  return 1;
}
