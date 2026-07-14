/* seeds/rt_lib_root_surface.from_x.c
 * G-02f rt_lib_root L2 thin surface — isomorphic with src/runtime/rt_lib_root.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_lib_root.x) + hybrid rest seed
 *   seeds/rt_lib_root.from_x.c (-DSHUX_RT_LIB_ROOT_FROM_X) ld -r into runtime_driver_no_c
 * Hybrid rest seed unchanged: default/roots_from_key body + marker
 *   (#ifndef SHUX_RT_LIB_ROOT_FROM_X skips C ptr_usable when .x owns it)
 * Prove: thin.x vs this seed → nm IDENTICAL (public surface: ptr_usable)
 * Regen: ./shux -E ... src/runtime/rt_lib_root.x | filter DBG + polish prologue
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
int32_t driver_lib_root_ptr_usable(uint8_t * p) {
  if ((p == ((uint8_t *)(0)))) {
    return 0;
  }
  if (((p)[0] == 0)) {
    return 0;
  }
  return 1;
}
