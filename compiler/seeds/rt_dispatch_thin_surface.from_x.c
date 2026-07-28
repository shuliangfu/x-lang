/* seeds/rt_dispatch_thin_surface.from_x.c
 * G-02f-90 rt_dispatch_thin R2 thin+rest surface - isomorphic with src/runtime/rt_dispatch_thin.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/rt_dispatch_thin.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (4 #[no_mangle])
 * Mode: thin+rest - 4 thin forwards to _impl extern bridges
 * Cap residual: 4 _impl bridges (driver_run_asm_backend_impl_c + driver_run_emit_c_path_impl_c
 *   + driver_run_compiler_full_x_impl_c + driver_dispatch_sibling_try_spawn)
 * No doc_anchor (rt_dispatch_thin.x has none).
 * Note: driver_ prefix not trigger ast_ (confirmed wave545+).
 * Logic: 4 thin+rest functions.
 * Regen: ./xlang-c -E ... rt_dispatch_thin.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern int32_t driver_run_asm_backend_impl_c(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key,
                                             uint8_t *target, int32_t argc, uint8_t *argv);
extern int32_t driver_run_emit_c_path_impl_c(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key,
                                             uint8_t *target, uint8_t *opt_level, int32_t use_lto,
                                             int32_t argc, uint8_t *argv);
extern int32_t driver_run_compiler_full_x_impl_c(int32_t argc, uint8_t *argv);
extern int32_t driver_dispatch_sibling_try_spawn(int32_t argc, uint8_t *argv);

/* === 4 thin+rest forwards === */

int32_t driver_run_asm_backend_c(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key,
                                 uint8_t *target, int32_t argc, uint8_t *argv) {
  return driver_run_asm_backend_impl_c(input_path, out_path, lib_key, target, argc, argv);
}

int32_t driver_run_emit_c_path_c(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key,
                                 uint8_t *target, uint8_t *opt_level, int32_t use_lto,
                                 int32_t argc, uint8_t *argv) {
  return driver_run_emit_c_path_impl_c(input_path, out_path, lib_key, target, opt_level,
                                       use_lto, argc, argv);
}

int32_t driver_run_compiler_full(int32_t argc, uint8_t *argv) {
  return driver_run_compiler_full_x_impl_c(argc, argv);
}

int32_t driver_try_compile_via_shu_c_sibling(int32_t argc, uint8_t *argv) {
  return driver_dispatch_sibling_try_spawn(argc, argv);
}
