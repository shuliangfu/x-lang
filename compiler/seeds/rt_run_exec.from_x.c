/* seeds/rt_run_exec.from_x.c — G-02f-297～299/311 P2 runtime R7 (run/exec gates)
 * Logic source: src/runtime/rt_run_exec.x
 * Hybrid: XLANG_RT_RUN_EXEC_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2 full（2026-07-14）：8 公共业务符号均由 .x 提供；
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务符号 H=0）。
 * Cap residual：driver_print_usage_write 在 driver_abi（巨型 usage 字面量）。
 * 冷启动/无 PREFER 时仍编译完整 C 体。
 *
 * f-297: want_asm_emit_to_file + print_usage
 * f-298: runtime_test_status_to_rc + print_target_cpu_features
 * f-299: exec pure path helpers + driver_exec_compiled (spawn)
 * f-311: driver_run_test（bash tests/run-all.sh；wave226 → link_abi_system）
 */
#include <stddef.h>
#include <stdint.h>
#include <xlang_fmt_cap.h> /* Cap residual 10.7.2: run-test cmd path → Cap snprintf */
/* G.7: Cap snprintf mapping (no libc stdio since 9.7.2). */
#undef snprintf
#define snprintf xlang_snprintf
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
#include <process.h>
#endif

#include "runtime_diag_codes.h"

#include <stdlib.h>

extern int driver_get_argv_i(int argc, char **argv, int i, char *buf, int max);
extern void runtime_diag_errno_path(const char *file, const char *kind, const char *op, const char *path);
extern void diag_reportf_with_code(const char *file, int line, int col, const char *kind, const char *code,
                                   const char *detail, const char *fmt, ...);
extern void diag_reportf(const char *file, int line, int col, const char *kind, const char *detail, const char *fmt,
                         ...);
extern void diag_report_with_code(const char *file, int line, int col, const char *kind, const char *code,
                                  const char *msg, const char *detail);
/* Cap residual 9.7.2: fd-handle face — print goes through driver_stdio_stdout
 * (encoded fd 1), no libc FILE star / stdout. */
extern void xlang_target_cpu_print(uint8_t *out, uint32_t features);
extern uint8_t *driver_stdio_stdout(void);
/* 9.7.5 G.7: single OS-spawn authority lives in driver_abi (wave42 body +
 * xlang_driver_exec_spawn_wait); this TU only delegates. */
extern int driver_exec_compiled_body(int argc, uint8_t *argv_opaque);
extern const char *xlang_repo_root_from_argv0(const char *argv0);
/* wave226 G.7: bash test shell via public pure thin link_abi_system (wave224 → _impl host system). */
extern int link_abi_system(const char *cmd);
extern void driver_print_usage_write(void);

#ifndef XLANG_RT_RUN_EXEC_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RT_RUN_EXEC_FROM_X removed */
#else /* XLANG_RT_RUN_EXEC_FROM_X：产品 rest 仅 marker；业务符号由 full .x 提供 */

int driver_want_asm_emit_to_file(int argc, char **argv);
void driver_print_usage_c(void);
int runtime_test_status_to_rc(const char *script, int st);
int32_t driver_print_target_cpu_features_c(int32_t features);
const char *driver_exec_scan_out_path(int argc, char **argv);
int driver_exec_path_is_non_exe(const char *exe);
int driver_exec_compiled(int argc, uint8_t *argv_opaque);
int driver_run_test(int argc, char **argv);

#endif /* XLANG_RT_RUN_EXEC_FROM_X */

int labi_rt_run_exec_slice_marker(void) {
  return 1;
}
