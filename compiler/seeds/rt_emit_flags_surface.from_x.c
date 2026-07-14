/* seeds/rt_emit_flags_surface.from_x.c
 * G-02f rt_emit_flags L2 thin surface — isomorphic with src/runtime/rt_emit_flags.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_emit_flags.x) + hybrid rest seed
 *   seeds/rt_emit_flags.from_x.c (-DSHUX_RT_EMIT_FLAGS_FROM_X) ld -r into runtime_driver_no_c
 * Hybrid rest seed unchanged: has_emit_c_flag body (macro→_impl) + set_use_lto /
 *   set_print_target_cpu (no .x counterpart)
 * Prove: thin.x vs this seed → nm IDENTICAL (public surface; _impl is U)
 * Regen: ./shux -E ... src/runtime/rt_emit_flags.x | filter DBG + polish prologue
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
extern int32_t driver_argv_has_emit_c_flag_impl(int32_t argc, uint8_t * * argv);
int32_t driver_argv_has_emit_c_flag(int32_t argc, uint8_t * * argv) {
  {
    return driver_argv_has_emit_c_flag_impl(argc, argv);
  }
  return 0;
}
