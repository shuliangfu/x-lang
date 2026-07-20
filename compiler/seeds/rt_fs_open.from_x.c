/* seeds/rt_fs_open.from_x.c — G-02f-308 P2 runtime rest (path open)
 * Logic source: src/runtime/rt_fs_open.x
 * Hybrid: SHUX_RT_FS_OPEN_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2 full（2026-07-14）：driver_fs_open_read_path / driver_fs_open_write
 * 均由 .x 提供；FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体。
 * 🔒 open / fcntl 经 libc。
 */
#include <fcntl.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#ifndef SHUX_RT_FS_OPEN_FROM_X
/** path[0..path_len-1] 打开只读；失败 -1。 */
int driver_fs_open_read_path(const uint8_t *path, int path_len) {
  if (!path || path_len <= 0 || path_len >= 512)
    return -1;
  char buf[512];
  memcpy(buf, path, (size_t)path_len);
  buf[path_len] = '\0';
  return open(buf, O_RDONLY, 0);
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
#else
int driver_fs_open_read_path(const uint8_t *path, int path_len);
int driver_fs_open_write(const uint8_t *path, int path_len);
#endif

int labi_rt_fs_open_slice_marker(void) {
  return 1;
}
