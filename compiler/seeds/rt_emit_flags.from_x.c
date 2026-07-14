/* seeds/rt_emit_flags.from_x.c — G-02f-264 pure emit/argv flag helpers
 * Logic source: src/runtime/rt_emit_flags.x
 * Note: RFC R4 DCE is under #if !SHUX_USE_X_DRIVER and is NOT in product G05
 * runtime_driver_no_c.o; this slice is the product-path substitute (R5-lite flags).
 * Hybrid: SHUX_RT_EMIT_FLAGS_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2（2026-07-14）：has_emit + set_use_lto + set_print_target_cpu 均由 .x 提供；
 * FROM_X 下本文件仅前向声明（产品 rest 业务符号 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体。
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>

/* Minimal layout matching seeds/runtime.from_x.c DriverCompileStateSU fields used here. */
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
  uint8_t target_cpu_buf[64];
  int32_t target_cpu_len;
  int32_t target_cpu_features;
  int32_t print_target_cpu;
  int32_t parse_saw_target_cpu;
} DriverCompileStateSU;

#ifndef SHUX_RT_EMIT_FLAGS_FROM_X
/** argv 是否含 -E / -E-extern。 */
int driver_argv_has_emit_c_flag(int argc, char **argv) {
  int i;
  if (argc < 2 || !argv)
    return 0;
  for (i = 1; i < argc; i++) {
    if (!strcmp(argv[i], "-E") || !strcmp(argv[i], "-E-extern"))
      return 1;
  }
  return 0;
}

void driver_compile_argv_set_use_lto_c(DriverCompileStateSU *state) {
  if (state)
    state->use_lto = 1;
}

void driver_compile_argv_set_print_target_cpu_c(DriverCompileStateSU *state) {
  if (state)
    state->print_target_cpu = 1;
}
#else
int driver_argv_has_emit_c_flag(int argc, char **argv);
void driver_compile_argv_set_use_lto_c(DriverCompileStateSU *state);
void driver_compile_argv_set_print_target_cpu_c(DriverCompileStateSU *state);
#endif
