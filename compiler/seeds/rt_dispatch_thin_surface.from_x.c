/* seeds/rt_dispatch_thin_surface.from_x.c
 * G-02f rt_dispatch L2 thin surface — isomorphic with src/runtime/rt_dispatch_thin.x
 * Product PREFER_X_O: g05_try_x_to_o(thin.x) + hybrid rest seed
 *   seeds/rt_dispatch_thin.from_x.c (-DSHUX_RT_DISPATCH_THIN_FROM_X) ld -r into runtime_driver_no_c
 * Hybrid rest seed unchanged: emit_c_path / run_compiler_full / try_compile_via_shu_c_sibling / marker
 * Prove: thin.x vs this seed → nm IDENTICAL (public surface; _c_impl is U)
 * Regen: ./shux -E ... src/runtime/rt_dispatch_thin.x | filter DBG + polish externs
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#ifndef _WIN32
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#endif
extern int32_t driver_run_asm_backend_c_impl(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_key, uint8_t * target, int32_t argc, uint8_t * argv);
int32_t driver_run_asm_backend_c(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_key, uint8_t * target, int32_t argc, uint8_t * argv) {
  {
    return driver_run_asm_backend_c_impl(input_path, out_path, lib_key, target, argc, argv);
  }
  return 0;
}
