/* seeds/rt_fs_open.from_x.c — G-02f-308 P2 runtime rest (path open thin OS)
 * Logic source: src/runtime/rt_fs_open.x
 * Hybrid: SHUX_RT_FS_OPEN_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * Scope: driver_fs_open_read_path / driver_fs_open_write（path 字节 → open fd）。
 * 🔒 open / fcntl 经 libc。
 */
#include <fcntl.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

/** path[0..path_len-1] 打开只读；失败 -1。 */
int driver_fs_open_read_path(const uint8_t *path, int path_len) {
  if (!path || path_len <= 0 || path_len >= 512)
    return -1;
  char buf[512];
  memcpy(buf, path, (size_t)path_len);
  buf[path_len] = '\0';
  return open(buf, O_RDONLY);
}

/** path[0..path_len-1] 打开写（CREAT|TRUNC 0644）；失败 -1。 */
int driver_fs_open_write(const uint8_t *path, int path_len) {
  if (!path || path_len <= 0 || path_len >= 512)
    return -1;
  char buf[512];
  memcpy(buf, path, (size_t)path_len);
  buf[path_len] = '\0';
#ifdef O_WRONLY
#ifdef O_CREAT
#ifdef O_TRUNC
  return open(buf, O_WRONLY | O_CREAT | O_TRUNC, (mode_t)0644);
#endif
#endif
#endif
  return -1;
}

int labi_rt_fs_open_slice_marker(void) {
  return 1;
}
