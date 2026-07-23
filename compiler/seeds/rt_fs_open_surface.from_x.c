/* seeds/rt_fs_open_surface.from_x.c
 * G-02f rt_fs_open R2 full surface — isomorphic with src/runtime/rt_fs_open.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_fs_open.x) + rest seed empty under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (path_copy + read_path + open_write)
 * Regen: ./xlang -E ... src/runtime/rt_fs_open.x | filter DBG + polish prologue
 * Note: O_CREAT/O_TRUNC numeric from host cfg at regen; product .x uses target_os cfg.
 * Track-L (2026-07-16): path helper keeps short name; .x has #[no_mangle] (was module mangle).
 * PLATFORM: SHARED — symbol contract; Ubuntu gold + mac prove.
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW
 *            (read/write/close/lseek/open/pread/pwrite/setenv/unsetenv).
 *            include/poll.h and include/sys/uio.h shims also available.
 *            macOS/Linux delegate to system headers via #include_next.
 *            Historical #ifndef _WIN32 guard removed for safe includes. */
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
/* libc open via fcntl.h (prove/g05 strip -E extern int32_t open) */
static const int32_t RT_FS_O_RDONLY = 0;
static const int32_t RT_FS_O_WRONLY = 1;
/* Host-portable: use fcntl.h macros when available so surface matches OS at cc. */
#ifdef O_CREAT
static const int32_t RT_FS_O_CREAT = O_CREAT;
#else
static const int32_t RT_FS_O_CREAT = 512;
#endif
#ifdef O_TRUNC
static const int32_t RT_FS_O_TRUNC = O_TRUNC;
#else
static const int32_t RT_FS_O_TRUNC = 1024;
#endif
int32_t rt_fs_path_copy_nul(uint8_t * path, int32_t path_len, uint8_t * path_buf) {
  int32_t i = 0;
  if ((path == ((uint8_t *)(0)))) {
    return 0;
  }
  if ((path_len <= 0)) {
    return 0;
  }
  if ((path_len >= 512)) {
    return 0;
  }
  while ((i < path_len)) {
    (void)(((path_buf)[((size_t)(i))] = (path)[((size_t)(i))]));
    (void)((i = (i + 1)));
  }
  (void)(((path_buf)[((size_t)(path_len))] = 0));
  return 1;
}
int32_t driver_fs_open_read_path(uint8_t * path, int32_t path_len) {
  uint8_t path_buf[512] = {};
  int32_t fd = (0 - 1);
  if ((rt_fs_path_copy_nul(path, path_len, &((path_buf)[0])) == 0)) {
    return (0 - 1);
  }
  {
    (void)((fd = open((const char *)&((path_buf)[0]), RT_FS_O_RDONLY, 0)));
  }
  return fd;
}
int32_t driver_fs_open_write(uint8_t * path, int32_t path_len) {
  uint8_t path_buf[512] = {};
  int32_t fd = (0 - 1);
  int32_t flags = ((RT_FS_O_WRONLY | RT_FS_O_CREAT) | RT_FS_O_TRUNC);
  if ((rt_fs_path_copy_nul(path, path_len, &((path_buf)[0])) == 0)) {
    return (0 - 1);
  }
  {
    (void)((fd = open((const char *)&((path_buf)[0]), flags, 420)));
  }
  return fd;
}
