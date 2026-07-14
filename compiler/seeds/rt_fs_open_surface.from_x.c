/* seeds/rt_fs_open_surface.from_x.c
 * G-02f rt_fs_open L2 thin surface — isomorphic with src/runtime/rt_fs_open.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_fs_open.x) + hybrid rest seed
 *   seeds/rt_fs_open.from_x.c (-DSHUX_RT_FS_OPEN_FROM_X) ld -r into runtime_driver_no_c
 * Hybrid rest seed unchanged: open body (macro→_impl) + marker
 * Prove: thin.x vs this seed → nm IDENTICAL (public surface; _impl is U)
 * Regen: ./shux -E ... src/runtime/rt_fs_open.x | filter DBG + polish externs
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
extern int32_t driver_fs_open_read_path_impl(uint8_t * path, int32_t path_len);
int32_t driver_fs_open_read_path(uint8_t * path, int32_t path_len) {
  {
    return driver_fs_open_read_path_impl(path, path_len);
  }
  return -1;
}
extern int32_t driver_fs_open_write_impl(uint8_t * path, int32_t path_len);
int32_t driver_fs_open_write(uint8_t * path, int32_t path_len) {
  {
    return driver_fs_open_write_impl(path, path_len);
  }
  return -1;
}
