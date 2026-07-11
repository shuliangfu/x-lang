/* seeds/rt_emit_flags.from_x.c — G-02f-264 pure emit/argv flag helpers
 * Logic source: src/runtime/rt_emit_flags.x
 * Note: RFC R4 DCE is under #if !SHUX_USE_X_DRIVER and is NOT in product G05
 * runtime_driver_no_c.o; this slice is the product-path substitute (R5-lite flags).
 * Hybrid: SHUX_RT_EMIT_FLAGS_FROM_X + ld -r into runtime_driver_no_c.o
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

/* G-02f-451：thin+rest PREFER_X_O
 *   thin .x provides 1 #[no_mangle] wrapper (calls *_impl in rest).
 *   rest seed C (compiled with -DSHUX_RT_EMIT_FLAGS_FROM_X):
 *     - driver_argv_has_emit_c_flag renamed to *_impl via macro.
 *   Other functions stay in rest (no .x counterpart). */
#ifdef SHUX_RT_EMIT_FLAGS_FROM_X
#define driver_argv_has_emit_c_flag    driver_argv_has_emit_c_flag_impl
#endif

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
