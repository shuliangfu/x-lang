/*
 * xlang_proc_cap.h — Cap residual 9.1.12: read small /proc (and config) files
 * without libc fopen/fread on Linux (x86_64 + aarch64).
 *
 * Single authority for target_cpu /proc/cpuinfo and similar proc reads.
 * DNS hosts/resolv uses parallel xlang_dns_read_file (same syscall face).
 *
 * PLATFORM: LINUX primary.
 */

#ifndef XLANG_PROC_CAP_H
#define XLANG_PROC_CAP_H

#if defined(__linux__) && (defined(__x86_64__) || defined(__aarch64__))

#include <fcntl.h>
#include <stddef.h>
#include <stdint.h>

#include <xlang_io_cap.h>
#include <xlang_syscall_cap.h>

#if defined(__x86_64__)
#define XLANG_PROC_SYS_open(path) ((int)xlang_syscall3(2, (long)(path), (long)O_RDONLY, 0))
#define XLANG_PROC_SYS_close(fd)  ((int)xlang_syscall1(3, (long)(fd)))
#elif defined(__aarch64__)
#ifndef AT_FDCWD
#define AT_FDCWD (-100)
#endif
#define XLANG_PROC_SYS_open(path) \
  ((int)xlang_syscall4(56, (long)AT_FDCWD, (long)(path), (long)O_RDONLY, 0))
#define XLANG_PROC_SYS_close(fd)  ((int)xlang_syscall1(57, (long)(fd)))
#endif

/**
 * Open path read-only via Cap syscall (no libc open).
 * @return fd or -1
 * PLATFORM: LINUX
 */
static inline int xlang_proc_open_ro(const char *path) {
  if (!path || !path[0])
    return -1;
  return XLANG_PROC_SYS_open(path);
}

/**
 * Read a small pseudo-file (e.g. /proc/cpuinfo) into buf; NUL-terminate.
 * @return bytes read (excluding NUL), or -1 on error
 * PLATFORM: LINUX
 */
static inline long xlang_proc_read_file(const char *path, char *buf, size_t cap) {
  int fd;
  long n;
  long off;
  if (!path || !buf || cap < 2)
    return -1;
  fd = xlang_proc_open_ro(path);
  if (fd < 0)
    return -1;
  off = 0;
  while ((size_t)off + 1 < cap) {
    n = xlang_io_read(fd, buf + off, cap - 1 - (size_t)off);
    if (n < 0) {
      (void)XLANG_PROC_SYS_close(fd);
      return -1;
    }
    if (n == 0)
      break;
    off += n;
  }
  (void)XLANG_PROC_SYS_close(fd);
  buf[off] = '\0';
  return off;
}

/**
 * Split in-place buffer at first '\\n'; returns next line or NULL.
 * PLATFORM: LINUX
 */
static inline char *xlang_proc_next_line(char *line) {
  char *nl;
  if (!line)
    return NULL;
  nl = line;
  while (*nl && *nl != '\n')
    nl++;
  if (*nl == '\n') {
    *nl = '\0';
    return nl + 1;
  }
  return NULL;
}

#endif /* LINUX Cap */

#endif /* XLANG_PROC_CAP_H */
