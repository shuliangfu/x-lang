/* seeds/rt_run_x_emit.from_x.c — G-02f-314 P2 runtime rest (-x -E emit)
 * Logic source: src/runtime/rt_run_x_emit.x
 * Hybrid: XLANG_RT_RUN_X_EMIT_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2 full（2026-07-14）：公共业务符号 driver_run_x_emit_c 由 full .x 提供；
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务符号 H=0）。
 * Cap residual（driver_abi）：stdout/OutBuf/指针表/parse/diag/typeck/work 槽。
 * 冷启动/无 PREFER 时仍编译完整 C 体。
 *
 * Scope: driver_run_x_emit_c（读源 → pipeline → stdout）。
 * Leftover !XLANG_NO_C_FRONTEND -E-extern cparser branch retired
 * (residual 7). Product PREFER already refuses via
 * driver_x_emit_try_extern_via_cparser (always BLD001). Mega wrapper
 * of driver_run_x_emit_c_extern_via_cparser retired (never-defined
 * _impl).
 * run_asm_backend / run_compiler_parsed 仍 mega rest。
 */
#include <limits.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "diag.h"
#include "runtime_diag_codes.h"
#include "runtime_io_abi.h"
#include "runtime_driver_abi.h"
#include "xlang_driver_stream_cap.h" /* Cap residual 9.7.1: opaque FILE* face → fd-handle face */
#include "runtime_pipeline_abi.h"
#include "token.h"

#ifndef X_EMIT_MAX_LIB_ROOTS
#define X_EMIT_MAX_LIB_ROOTS 16
#endif
#ifndef MAX_ALL_DEPS
#define MAX_ALL_DEPS 128
#endif
#ifndef PATH_MAX
#define PATH_MAX 4096
#endif

#ifndef XLANG_RT_RUN_X_EMIT_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RT_RUN_X_EMIT_FROM_X removed */
#ifdef XLANG_USE_X_PIPELINE
#if defined(XLANG_USE_X_DRIVER) && defined(XLANG_USE_X_PIPELINE)
#endif
#else
    (void)input_path;
    typeck_set_allow_legacy_extern_calls(old_allow_legacy_extern);
    return 1;
#endif
#else /* XLANG_RT_RUN_X_EMIT_FROM_X：产品 rest 仅 marker；业务体在 full .x */
int driver_run_x_emit_c(void);
#endif /* XLANG_RT_RUN_X_EMIT_FROM_X */

int labi_rt_run_x_emit_slice_marker(void) {
  return 1;
}
