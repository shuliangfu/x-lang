/* seeds/rt_util_surface.from_x.c
 * G-02f rt_util L2 thin surface — isomorphic with src/runtime/rt_util.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_util.x) + hybrid rest seed
 *   seeds/rt_util.from_x.c (-DSHUX_RT_UTIL_FROM_X) ld -r into runtime_driver_no_c
 * Hybrid rest seed unchanged: driver_argv0_basename_is body (+ cold unlink body)
 * Prove: thin.x vs this seed → nm IDENTICAL (public surface: unlink_failed_output)
 * Regen: ./shux -E ... src/runtime/rt_util.x | filter DBG + polish prologue
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
/* libc unlink via unistd.h (prove/g05 strip -E extern int32_t unlink) */
void driver_unlink_failed_output(uint8_t * out_path) {
  if ((out_path == ((uint8_t *)(0)))) {
    return;
  }
  if (((out_path)[((size_t)(0))] == ((uint8_t)(0)))) {
    return;
  }
  {
    (void)(unlink((const char *)out_path));
  }
  (void)(0);
  return;
}
