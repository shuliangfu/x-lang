/**
 * std_sys_shim.c — 提供 std_sys_os_read_file_into 供 -E-extern pipeline/driver 链接。
 *
 * B-20：读 path 指向文件到 buf[0..cap)；成功返回字节数，失败 -1。
 * 实现与 std.sys.linux.linux_read_file_into 语义一致（open + 循环 read）。
 */
#include <stdint.h>
#include <stddef.h>

#ifdef _WIN32
#include <io.h>
#include <fcntl.h>
#define shux_sys_open(path, flags, mode) _open((char *)(path), (flags), (mode))
#define shux_sys_read(fd, buf, len) _read((fd), (buf), (int)(len))
#define shux_sys_close(fd) _close(fd)
#ifndef O_RDONLY
#define O_RDONLY _O_RDONLY
#endif
#else
#ifndef _WIN32
#include <unistd.h>
#endif
#include <fcntl.h>
#endif

#ifndef O_RDONLY
#define O_RDONLY 0
#endif

/** POSIX open(2) 薄封装；失败 -1。 */
static int32_t shux_sys_open(const uint8_t *path, int32_t flags, int32_t mode) {
  if (!path) {
    return -1;
  }
  return (int32_t)open((const char *)path, flags, mode);
}

/** POSIX read(2) 薄封装。 */
static int32_t shux_sys_read(int32_t fd, uint8_t *buf, int32_t len) {
  if (!buf || len <= 0) {
    return 0;
  }
  return (int32_t)read(fd, buf, (size_t)len);
}

/** POSIX close(2) 薄封装。 */
static int32_t shux_sys_close(int32_t fd) {
  return (int32_t)close(fd);
}

/**
 * std.sys.os_read_file_into 的 C 链接符号（-E-extern import 名）。
 * 成功返回读入字节数；失败 -1。
 */
int32_t std_sys_os_read_file_into(uint8_t *path, uint8_t *buf, int32_t cap) {
  if (!path || !buf || cap <= 0) {
    return -1;
  }
  int32_t fd = shux_sys_open(path, O_RDONLY, 0);
  if (fd < 0) {
    return -1;
  }
  int32_t total = 0;
  while (total < cap) {
    int32_t chunk = cap - total;
    int32_t r = shux_sys_read(fd, buf + total, chunk);
    if (r < 0) {
      shux_sys_close(fd);
      return -1;
    }
    if (r == 0) {
      break;
    }
    total += r;
  }
  shux_sys_close(fd);
  return total;
}
