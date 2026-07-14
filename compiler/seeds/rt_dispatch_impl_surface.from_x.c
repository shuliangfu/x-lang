/* seeds/rt_dispatch_impl_surface.from_x.c
 * G-02f rt_dispatch_impl L2 thin surface — isomorphic with src/runtime/rt_dispatch_impl.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_dispatch_impl.x) + hybrid rest seed
 *   seeds/rt_dispatch_impl.from_x.c (-DSHUX_RT_DISPATCH_IMPL_FROM_X) ld -r into runtime_driver_no_c
 * Hybrid rest seed unchanged: asm/emit/post_parse/x_emit_from_state + full_x body (macro→_impl) + marker
 * Prove: thin.x vs this seed → nm IDENTICAL (public surface; _c_impl is U)
 * Regen: ./shux -E ... src/runtime/rt_dispatch_impl.x | filter DBG + polish externs
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
extern int32_t driver_run_compiler_full_x_impl_c_impl(int32_t argc, uint8_t * argv);
int32_t driver_run_compiler_full_x_impl_c(int32_t argc, uint8_t * argv) {
  {
    return driver_run_compiler_full_x_impl_c_impl(argc, argv);
  }
  return 0;
}
