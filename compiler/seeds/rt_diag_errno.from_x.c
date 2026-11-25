/* seeds/rt_diag_errno.from_x.c — G-02f-302 P2 runtime rest (diag errno pure)
 * Logic source: src/runtime/rt_diag_errno.x
 * w1136: Darwin standalone thin object is pure asm of that .x (errno symbol
 * renamed to the libc ___error). This seed stays the Linux prefer body and
 * the marker-only rest under XLANG_RT_DIAG_ERRNO_FROM_X.
 * Hybrid: XLANG_RT_DIAG_ERRNO_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2 full：code_for_kind + errno{,_path,_path_pair} + cli_usage_note 由 .x 提供；
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体。
 */
#include <errno.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include "runtime_diag_codes.h"

extern void diag_reportf_with_code(const char *file, int line, int col, const char *kind, const char *code,
                                   const char *detail, const char *fmt, ...);
extern void diag_reportf(const char *file, int line, int col, const char *kind, const char *detail, const char *fmt,
                         ...);

#ifndef XLANG_RT_DIAG_ERRNO_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RT_DIAG_ERRNO_FROM_X removed */
#if defined(__GNUC__) || defined(__clang__)
#endif
#else
const char *runtime_diag_code_for_kind(const char *kind);
void runtime_diag_errno(const char *file, const char *kind, const char *op);
void runtime_diag_errno_path(const char *file, const char *kind, const char *op, const char *path);
void runtime_diag_errno_path_pair(const char *file, const char *kind, const char *op, const char *from_path,
                                  const char *to_path);
void runtime_diag_cli_usage_note(const char *argv0);
#endif

int labi_rt_diag_errno_slice_marker(void) {
  return 1;
}
