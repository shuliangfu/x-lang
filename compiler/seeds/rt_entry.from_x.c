/* seeds/rt_entry.from_x.c — G-02f-301/310 P2 runtime R10 entry gates
 * Logic source: src/runtime/rt_entry.x
 * Hybrid: XLANG_RT_ENTRY_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2（2026-07-14）：6 公共符号（explain_cli / smoke_diag / smoke_summary /
 *   fmt_report_no_files / run_compiler_c / build_build_x）均由 .x 提供；
 * FROM_X 下本文件仅前向声明 + marker（产品 rest 业务 H=0）。
 * Cap residual：driver_stdio_{stdout,stderr} 与 driver_entry_*_slot 在 driver_abi。
 * 冷启动/无 PREFER 时仍编译完整 C 体。
 * 9.7.4：冷体脱离 libc stdio——explain/smoke 输出走 fd 句柄脸
 *   （driver_stdio_stdout/stderr + xlang_io_write + xlang_snprintf），与 .x
 *   权威一致；diag_print_* extern 脸 FILE*→uint8_t*（与 include/diag.h 对齐，
 *   修复冷启动二进制把 FILE* 当 fd 句柄解码的语义错位）；fmt_report_no_files
 *   本地 argv 数组→wave21 driver_entry_fmt_argv_slot（G.7 单权威）。
 */
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <xlang_io_cap.h>   /* Cap residual 9.1.x: raw fd write (no libc stdio) */
#include <xlang_fmt_cap.h>  /* Cap residual 10.7.2: bounded format (no libc stdio) */
/* G.7: Cap snprintf mapping (no libc stdio since 9.7.4). */
#undef snprintf
#define snprintf xlang_snprintf

#include "runtime_diag_codes.h"

extern void diag_reportf_with_code(const char *file, int line, int col, const char *kind, const char *code,
                                   const char *detail, const char *fmt, ...);
extern void diag_reportf(const char *file, int line, int col, const char *kind, const char *detail, const char *fmt,
                         ...);
extern void diag_report_with_code(const char *file, int line, int col, const char *kind, const char *code,
                                  const char *msg, const char *detail);
/* 9.7.4: fd-handle face, matches include/diag.h (out = driver_stdio_stdout() etc.). */
extern void diag_print_code_table(uint8_t *out);
extern int diag_code_is_known(const char *code);
extern const char *diag_code_suggest(const char *code, char *buf, size_t cap);
extern void diag_print_code_explain(uint8_t *out, const char *code);
extern void diag_print_known_codes(uint8_t *out);
extern int diag_json_enabled(void);
extern int driver_run_fmt(int argc, char **argv);
extern int main_run_compiler_c(int argc, uint8_t *argv);
/* wave15/21/39/40 accessors: authority = runtime_driver_abi_thin.x; cold twins
 * in seeds/runtime_driver_abi.from_x.c; decls also in runtime_driver_abi.h. */
extern uint8_t *driver_stdio_stdout(void);
extern uint8_t *driver_stdio_stderr(void);
extern char **driver_entry_fmt_argv_slot(void);
/* wave226 G.7: shell make via public pure thin link_abi_system (wave224 → _impl host system). */
extern int link_abi_system(const char *cmd);
/* wave227 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv). */
extern char *link_abi_getenv(const char *name);

#ifndef XLANG_RT_ENTRY_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RT_ENTRY_FROM_X removed */
#else
int runtime_try_handle_explain_cli(int argc, char **argv);
int xlang_smoke_diag_enabled(void);
void driver_emit_legacy_smoke_summary_stdout(const char *main_name, int main_final_lit, int has_main_body);
int driver_fmt_report_no_files(void);
int run_compiler_c(int argc, char **argv);
int driver_build_build_x(void);

int labi_rt_entry_slice_marker(void) {
  return 1;
}
#endif /* !XLANG_RT_ENTRY_FROM_X */
