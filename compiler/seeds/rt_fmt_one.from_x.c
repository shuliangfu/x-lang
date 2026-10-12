/* seeds/rt_fmt_one.from_x.c — G-02f-311 P2 runtime rest (fmt one file)
 * Logic source: src/runtime/rt_fmt_one.x
 * Hybrid: XLANG_RT_FMT_ONE_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2 full：driver_fmt_one_file 由 .x 提供；
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体（read → format → 可选写回）。
 */
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "runtime_diag_codes.h"
#include "runtime_io_abi.h"

extern int xlang_format_x_document(const uint8_t *doc, int doc_len, uint8_t *out_buf, int out_cap);
extern int32_t driver_fmt_check_only_get(void);
extern void diag_reportf_with_code(const char *file, int line, int col, const char *kind, const char *code,
                                   const char *detail, const char *fmt, ...);
extern void diag_reportf(const char *file, int line, int col, const char *kind, const char *detail, const char *fmt,
                         ...);

#ifndef XLANG_RT_FMT_ONE_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RT_FMT_ONE_FROM_X removed */
#else
int driver_fmt_one_file(const uint8_t *path, int path_len);
#endif

int labi_rt_fmt_one_slice_marker(void) {
  return 1;
}
