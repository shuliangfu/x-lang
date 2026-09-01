/*
 * xlang_io_cap.h — Cap residual 9.1.8: write/read/writev without libc on Linux
 * (x86_64 + aarch64).
 *
 * Single authority for rt_preamble xlang_sys_write/read/writev inlines and
 * freestanding_io syscall face (asm twin keeps same numbers).
 *
 * Windows: not used — call sites keep _write / Win32.
 * Darwin: syscall write (x86_64 + arm64) for print Cap residual 9.5.2.
 * Other POSIX: thin libc wrappers.
 *
 * PLATFORM: LINUX primary; DARWIN syscall; POSIX fallback elsewhere (non-Win).
 */

#ifndef XLANG_IO_CAP_H
#define XLANG_IO_CAP_H

#if !defined(_WIN32) && !defined(_WIN64)

#include <errno.h>
#include <stddef.h>
#include <stdint.h>

#if defined(__linux__) && (defined(__x86_64__) || defined(__aarch64__))

#include <xlang_syscall_cap.h>

/** Cap residual 9.1.9: aliases → single syscall authority. */
#define xlang_io_syscall6 xlang_syscall6
#define xlang_io_syscall3 xlang_syscall3

/**
 * Cap residual write(2).
 * @return bytes written, or -1 with errno
 * PLATFORM: LINUX
 */
static inline long xlang_io_write(int fd, const void *buf, size_t count) {
  long r;
  if (!buf && count != 0)
    return -1;
#if defined(__x86_64__)
  /* write = 1 */
  r = xlang_io_syscall3(1, (long)fd, (long)buf, (long)count);
#elif defined(__aarch64__)
  /* write = 64 */
  r = xlang_io_syscall3(64, (long)fd, (long)buf, (long)count);
#endif
  if (r < 0) {
    errno = (int)(-r);
    return -1;
  }
  return r;
}

/**
 * Cap residual read(2).
 * PLATFORM: LINUX
 */
static inline long xlang_io_read(int fd, void *buf, size_t count) {
  long r;
  if (!buf && count != 0)
    return -1;
#if defined(__x86_64__)
  /* read = 0 */
  r = xlang_io_syscall3(0, (long)fd, (long)buf, (long)count);
#elif defined(__aarch64__)
  /* read = 63 */
  r = xlang_io_syscall3(63, (long)fd, (long)buf, (long)count);
#endif
  if (r < 0) {
    errno = (int)(-r);
    return -1;
  }
  return r;
}

/**
 * Cap residual writev(2).
 * PLATFORM: LINUX
 */
static inline long xlang_io_writev(int fd, const void *iov, int iovcnt) {
  long r;
  if (!iov && iovcnt != 0)
    return -1;
#if defined(__x86_64__)
  /* writev = 20 */
  r = xlang_io_syscall3(20, (long)fd, (long)iov, (long)iovcnt);
#elif defined(__aarch64__)
  /* writev = 66 */
  r = xlang_io_syscall3(66, (long)fd, (long)iov, (long)iovcnt);
#endif
  if (r < 0) {
    errno = (int)(-r);
    return -1;
  }
  return r;
}

#elif defined(__APPLE__) && (defined(__x86_64__) || defined(__aarch64__))

/**
 * Darwin raw write via syscall (no libc write).
 * @return bytes written, or -1 with errno
 * PLATFORM: MACOS|DARWIN
 */
static inline long xlang_io_write(int fd, const void *buf, size_t count) {
  long r;
  if (!buf && count != 0)
    return -1;
#if defined(__x86_64__)
  {
    /* write = 4 → 0x2000004 on macOS x86_64 */
    register long r10 __asm__("r10") = (long)count;
    __asm__ __volatile__("syscall"
                         : "=a"(r)
                         : "a"(0x2000004L), "D"(fd), "S"(buf), "d"(r10)
                         : "rcx", "r11", "memory");
  }
#elif defined(__aarch64__)
  {
    register long x8 __asm__("x8") = 4;
    register long x0 __asm__("x0") = (long)fd;
    register long x1 __asm__("x1") = (long)buf;
    register long x2 __asm__("x2") = (long)count;
    __asm__ __volatile__("svc #0" : "+r"(x0) : "r"(x8), "r"(x1), "r"(x2) : "memory");
    r = x0;
  }
#endif
  if (r < 0) {
    errno = (int)(-r);
    return -1;
  }
  return r;
}

/** PLATFORM: DARWIN — print Cap only; read not wired yet. */
static inline long xlang_io_read(int fd, void *buf, size_t count) {
  (void)fd;
  (void)buf;
  (void)count;
  errno = ENOSYS;
  return -1;
}

/** PLATFORM: DARWIN — print Cap only; writev not wired yet. */
static inline long xlang_io_writev(int fd, const void *iov, int iovcnt) {
  (void)fd;
  (void)iov;
  (void)iovcnt;
  errno = ENOSYS;
  return -1;
}

#else /* !LINUX Cap && !DARWIN Cap — POSIX libc thin wrappers */

#include <sys/uio.h>
#include <unistd.h>

/** PLATFORM: POSIX fallback — libc write. */
static inline long xlang_io_write(int fd, const void *buf, size_t count) {
  return (long)write(fd, buf, count);
}

/** PLATFORM: POSIX fallback — libc read. */
static inline long xlang_io_read(int fd, void *buf, size_t count) {
  return (long)read(fd, buf, count);
}

/** PLATFORM: POSIX fallback — libc writev. */
static inline long xlang_io_writev(int fd, const void *iov, int iovcnt) {
  return (long)writev(fd, (const struct iovec *)iov, iovcnt);
}

#endif /* LINUX Cap vs POSIX */

#endif /* !_WIN32 */

#endif /* XLANG_IO_CAP_H */
