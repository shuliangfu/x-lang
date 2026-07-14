/* seeds/rt_run_x_emit_surface.from_x.c
 * G-02f rt_run_x_emit L2 thin surface — isomorphic with src/runtime/rt_run_x_emit.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_run_x_emit.x) + hybrid rest seed
 *   seeds/rt_run_x_emit.from_x.c (-DSHUX_RT_RUN_X_EMIT_FROM_X) ld -r into runtime_driver_no_c
 * Hybrid rest seed unchanged: emit body (macro→_impl) + heavy pipeline deps
 * Prove: thin.x vs this seed → nm IDENTICAL (public surface; _impl is U)
 * Regen: ./shux -E ... src/runtime/rt_run_x_emit.x | filter DBG + polish externs
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
extern int32_t driver_run_x_emit_c_impl(void);
int32_t driver_run_x_emit_c(void) {
  {
    return driver_run_x_emit_c_impl();
  }
  return 1;
}
