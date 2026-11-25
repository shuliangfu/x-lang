/* seeds/rt_dispatch_impl.from_x.c — G-02f-313 P2 runtime rest (dispatch impl gates)
 * Logic source: src/runtime/rt_dispatch_impl.x
 * Hybrid: XLANG_RT_DISPATCH_IMPL_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2 full（2026-07-14）：公共业务符号由 full .x 提供：
 *   driver_run_asm_backend_impl_c / driver_run_emit_c_path_impl_c /
 *   driver_run_x_emit_c_from_compile_state /
 *   driver_run_compiler_full_x_post_parse_impl_c /
 *   driver_run_compiler_full_x_impl_c
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务符号 H=0）。
 * Cap residual（driver_abi）：lib_key→lib_roots 槽 + Parsed 填表。
 * Leftover !XLANG_NO_C_FRONTEND sibling demote in emit_c_path retired
 * (residual 6). Spawn helper stays in rt_dispatch_thin (Cap residual,
 * different class — HAS a real fork/exec body). Mega leftover sibling
 * → _impl wrapper retired (residual 9).
 * 冷启动/无 PREFER 时仍编译完整 C 体。
 *
 * Scope: asm/emit/full_x/post_parse/x_emit_from_state 中型分派；
 * run_asm_backend / run_compiler_parsed / run_x_emit_c 巨石已 R2。
 */
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#ifndef X_FULL_MAX_LIB_ROOTS
#define X_FULL_MAX_LIB_ROOTS 16
#endif
#ifndef X_EMIT_MAX_LIB_ROOTS
#define X_EMIT_MAX_LIB_ROOTS 16
#endif

/** compile.x DriverCompileState 布局（与 mega 一致）。 */
typedef struct DriverCompileStateSU {
  uint8_t path_buf[512];
  int32_t path_len;
  uint8_t out_path_buf[512];
  int32_t out_path_len;
  int32_t use_asm_backend;
  int32_t target_arch;
  uint8_t target_buf[512];
  int32_t target_len;
  uint8_t opt_level_buf[8];
  int32_t opt_level_len;
  int32_t use_lto;
  int32_t backend_asm_explicit;
  int32_t use_freestanding;
  int32_t parse_saw_target;
  uint8_t target_cpu_buf[128];
  int32_t target_cpu_len;
  int32_t target_cpu_features;
  int32_t print_target_cpu;
  int32_t parse_saw_target_cpu;
} DriverCompileStateSU;

typedef struct DriverCompileParsed {
  const char *input_path;
  const char *out_path;
  const char *lib_roots_arr[X_FULL_MAX_LIB_ROOTS];
  int n_lib_roots;
  int want_asm_backend;
  const char *target;
  const char *opt_level;
  int use_lto;
} DriverCompileParsed;

#ifndef XLANG_RT_DISPATCH_IMPL_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RT_DISPATCH_IMPL_FROM_X removed */
#if defined(XLANG_USE_X_DRIVER) && defined(XLANG_USE_X_PIPELINE)
#endif
#if defined(XLANG_ASM_USE_COMPILER_IMPL_C)
#endif
#else /* XLANG_RT_DISPATCH_IMPL_FROM_X：产品 rest 仅 marker；业务体在 full .x */
int32_t driver_run_asm_backend_impl_c(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key, uint8_t *target,
                                      int32_t argc, uint8_t *argv);
int32_t driver_run_emit_c_path_impl_c(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key, uint8_t *target,
                                      uint8_t *opt_level, int32_t use_lto, int32_t argc, uint8_t *argv);
int32_t driver_run_x_emit_c_from_compile_state(void *state, int argc, char **argv);
int32_t driver_run_compiler_full_x_post_parse_impl_c(void *state, int32_t argc, uint8_t *argv);
int32_t driver_run_compiler_full_x_impl_c(int32_t argc, uint8_t *argv);
#endif /* XLANG_RT_DISPATCH_IMPL_FROM_X */

int labi_rt_dispatch_impl_slice_marker(void) {
  return 1;
}
