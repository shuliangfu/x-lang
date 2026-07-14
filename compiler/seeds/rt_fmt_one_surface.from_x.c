/* seeds/rt_fmt_one_surface.from_x.c
 * G-02f rt_fmt_one L2 thin surface — isomorphic with src/runtime/rt_fmt_one.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_fmt_one.x) + hybrid rest seed
 *   seeds/rt_fmt_one.from_x.c (-DSHUX_RT_FMT_ONE_FROM_X) ld -r into runtime_driver_no_c
 * Hybrid rest seed unchanged: read/format/write body (macro→_impl) + marker
 * Prove: thin.x vs this seed → nm IDENTICAL (public surface; _impl is U)
 * Regen: ./shux -E ... src/runtime/rt_fmt_one.x | filter DBG + polish externs
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
extern int32_t driver_fmt_one_file_impl(uint8_t * path, int32_t path_len);
int32_t driver_fmt_one_file(uint8_t * path, int32_t path_len) {
  {
    return driver_fmt_one_file_impl(path, path_len);
  }
  return 1;
}
