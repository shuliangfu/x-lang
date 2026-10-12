/* seeds/rt_dispatch_thin.from_x.c — G-02f-312 P2 runtime rest → R2 full (dispatch thin)
 * Logic source: src/runtime/rt_dispatch_thin.x
 * Hybrid: XLANG_RT_DISPATCH_THIN_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * 记253／9.1: cold #ifndef body emptied (business lives in .x).
 * knife 256 / 10.2: do not host-cc this file as a full cold TU — rt-prefer
 * pure-asms the .x. FROM_X rest is decls + slice marker only.
 */
#include <stddef.h>
#include <stdint.h>

#ifndef XLANG_RT_DISPATCH_THIN_FROM_X
/* Cold full body retired (9.1). Product = src/runtime/rt_dispatch_thin.x. */
#else
int32_t driver_run_asm_backend_c(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key, uint8_t *target, int32_t argc,
                                 uint8_t *argv);
int32_t driver_run_emit_c_path_c(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key, uint8_t *target,
                                 uint8_t *opt_level, int32_t use_lto, int32_t argc, uint8_t *argv);
int driver_run_compiler_full(int argc, char **argv);
int driver_try_compile_via_shu_c_sibling(int argc, char **argv);
#endif

int labi_rt_dispatch_thin_slice_marker(void) {
  return 1;
}
