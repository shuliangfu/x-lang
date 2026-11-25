/* seeds/rt_compile.from_x.c — G-02f-291～296 P2 runtime R6 compile helpers
 * Logic source: src/runtime/rt_compile.x
 * Hybrid: XLANG_RT_COMPILE_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2 full（2026-07-14）：25 公共业务符号均由 .x 提供；
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务符号 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体。
 *
 * f-291～295: deps / flags / apply_* / init-ensure / step-scan
 * f-296: parse_argv_impl + resolve_target_cpu + cfg_sync + state_alloc/free
 */
#if !defined(_POSIX_C_SOURCE)
#define _POSIX_C_SOURCE 200809L
#endif
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/* Layout matches seeds/runtime.from_x.c DriverCompileStateSU (fields used here). */
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

extern void driver_freestanding_set(int on);
extern void cfg_set_freestanding(int on);
extern void driver_sanitize_address_set(int on);
extern int driver_get_argv_i(int argc, char **argv, int i, char *buf, int max);
extern void cfg_reset_compile_target(void);
extern int32_t driver_emit_lib_root_count(uint8_t *state);
extern int32_t driver_emit_append_lib_root(uint8_t *state, uint8_t *path, int32_t len);
extern void driver_emit_lib_root_reset(uint8_t *state);
/* From rt_argv seed when hybrid; else mega rest. */
extern int drv_eq_minus_o(const char *buf, int len);
extern int drv_eq_minus_L(const char *buf, int len);
extern int drv_eq_minus_O(const char *buf, int len);
extern int drv_eq_flto(const char *buf, int len);
extern int drv_eq_minus_freestanding(const char *buf, int len);
extern int drv_eq_legacy_f32_abi(const char *buf, int len);
extern int drv_eq_fsanitize_address(const char *buf, int len);
extern int drv_eq_minus_backend(const char *buf, int len);
extern int drv_eq_minus_target(const char *buf, int len);
extern int drv_eq_minus_target_cpu(const char *buf, int len);
extern int drv_eq_print_target_cpu(const char *buf, int len);
extern int drv_eq_asm_word(const char *buf, int len);
extern int drv_eq_c_word(const char *buf, int len);
extern int drv_path_ends_x(const char *buf, int len);
extern int drv_target_has_arm(const char *buf, int len);
extern int xlang_target_cpu_resolve(const char *spec, size_t spec_len, uint32_t *out);
extern uint32_t xlang_target_cpu_generic_for_host(void);
extern void diag_reportf(const char *file, int line, int col, const char *kind, const char *detail, const char *fmt,
                         ...);
extern void diag_report_with_code(const char *file, int line, int col, const char *kind, const char *code,
                                  const char *msg, const char *detail);
extern void cfg_apply_compile_target_from_triple(const char *triple, int32_t len);
extern int32_t driver_resolve_target_arch(int32_t parsed_target, int32_t saw_target_flag);

#ifndef XLANG_RT_COMPILE_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RT_COMPILE_FROM_X removed */
#else /* XLANG_RT_COMPILE_FROM_X：产品 rest 仅前向声明；业务体在 .x */

int driver_deps_are_std_core_closure_only(char **dep_paths, int n_deps);
int driver_x_emit_asm_dep_parse_only_ok(const char *input_path, const char *dep_path);
int driver_x_emit_asm_direct_import_only(const char *input_path);
int driver_x_emit_asm_dep_parse_skip_typeck_ok(const char *input_path, const char *dep_path);
void driver_compile_argv_copy_path_c(DriverCompileStateSU *state, uint8_t *arg_buf, int32_t plen);
void driver_compile_argv_set_use_freestanding_c(DriverCompileStateSU *state);
void driver_compile_argv_set_legacy_f32_abi_c(void);
void driver_compile_argv_set_sanitize_address_c(void);
int32_t driver_compile_argv_is_help_c(int32_t argc, uint8_t *argv_opaque);
void driver_compile_append_lib_root_c(DriverCompileStateSU *state, uint8_t *path, int32_t len);
void driver_compile_ensure_default_lib_c(uint8_t *key);
void driver_compile_parse_argv_init_c(DriverCompileStateSU *state);
void driver_compile_argv_apply_minus_o_next_c(DriverCompileStateSU *state, int32_t argc, uint8_t *argv_opaque,
                                              int32_t i);
void driver_compile_argv_apply_minus_L_next_c(DriverCompileStateSU *state, int32_t argc, uint8_t *argv_opaque,
                                               int32_t i, uint8_t *arg_buf, int32_t arg_cap);
void driver_compile_argv_apply_minus_O_next_c(DriverCompileStateSU *state, int32_t argc, uint8_t *argv_opaque,
                                              int32_t i);
void driver_compile_argv_apply_backend_next_c(DriverCompileStateSU *state, int32_t argc, uint8_t *argv_opaque,
                                              int32_t i, uint8_t *arg_buf, int32_t arg_cap);
void driver_compile_argv_apply_target_next_c(DriverCompileStateSU *state, int32_t argc, uint8_t *argv_opaque,
                                             int32_t i);
void driver_compile_argv_apply_target_cpu_next_c(DriverCompileStateSU *state, int32_t argc, uint8_t *argv_opaque,
                                                  int32_t i);
int driver_compile_parse_argv_step_c(int argc, char **argv, DriverCompileStateSU *state, int i, char *arg_buf,
                                     int arg_cap);
void driver_compile_parse_argv_scan_c(int32_t argc, uint8_t *argv_opaque, DriverCompileStateSU *state);
void driver_compile_resolve_target_cpu_c(DriverCompileStateSU *state);
void cfg_sync_compile_target_from_state_c(void *state);
int32_t driver_compile_parse_argv_impl_c(int32_t argc, uint8_t *argv_opaque, DriverCompileStateSU *state);
DriverCompileStateSU *driver_compile_state_alloc_c(void);
void driver_compile_state_free_c(DriverCompileStateSU *state);

#endif /* XLANG_RT_COMPILE_FROM_X */

int labi_rt_compile_slice_marker(void) {
  return 1;
}
