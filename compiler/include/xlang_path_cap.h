/*
 * xlang_path_cap.h — Cap residual 9.1.2: path access/stat/fstat/realpath without
 * libc access/stat/fstat/realpath on Linux.
 *
 * Single authority for host mega Cap residual path probes:
 *   link_abi_path_readable_impl / path_executable_impl / realpath_cap_impl,
 *   xlang_path_is_nonempty_regular_file_impl, ELF fstat scan, host gcc probe.
 *
 * Linux: faccessat / newfstatat|fstatat / fstat / open+readlink(/proc/self/fd/N).
 * Other POSIX: thin wrappers over libc (Darwin residual until later).
 * Windows (MinGW/MSYS leftover PE SAT): _access / stat / fstat / _fullpath.
 *   Call sites in runtime_link_abi.from_x.c use xlang_path_access / xlang_path_stat
 *   unconditionally (path_readable_impl / path_executable_impl /
 *   nonempty_regular_file_impl). The previous `#if !defined(_WIN32)` wrapper
 *   left those names undeclared on MinGW, so SAT full-seed cc of current
 *   link_abi failed and leftover PE kept the 7/31 .o
 *   (xlang_link_capture_opt_level_from_argv unique). G.7 有则补全 this header —
 *   do not add a second Windows path probe in the seed.
 *
 * PLATFORM: LINUX primary (x86_64 + aarch64); POSIX fallback elsewhere;
 *           WINDOWS MinGW CRT wrappers (leftover-PE SAT).
 */

#ifndef XLANG_PATH_CAP_H
#define XLANG_PATH_CAP_H

#if !defined(_WIN32) && !defined(_WIN64)

#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>

#ifndef AT_FDCWD
#define AT_FDCWD (-100)
#endif

#if defined(__linux__) && (defined(__x86_64__) || defined(__aarch64__))

#include <xlang_syscall_cap.h>

/** Cap residual 9.1.9: aliases → single syscall authority. */
#define xlang_linux_syscall4 xlang_syscall4
#define xlang_linux_syscall3 xlang_syscall3
#define xlang_linux_syscall2 xlang_syscall2

/**
 * Cap residual access(2): faccessat(AT_FDCWD, path, mode, 0).
 * @return 0 ok, -1 fail (≡ libc access)
 * PLATFORM: LINUX
 */
static inline int xlang_path_access(const char *path, int mode) {
  long r;
  if (!path || !path[0])
    return -1;
#if defined(__x86_64__)
  /* faccessat = 269 */
  r = xlang_linux_syscall4(269, (long)AT_FDCWD, (long)path, (long)mode, 0);
#elif defined(__aarch64__)
  /* faccessat = 48 */
  r = xlang_linux_syscall4(48, (long)AT_FDCWD, (long)path, (long)mode, 0);
#endif
  return r == 0 ? 0 : -1;
}

/**
 * Cap residual stat(2): newfstatat/fstatat into libc-layout struct stat.
 * @return 0 ok, -1 fail
 * PLATFORM: LINUX
 */
static inline int xlang_path_stat(const char *path, struct stat *st) {
  long r;
  if (!path || !path[0] || !st)
    return -1;
#if defined(__x86_64__)
  /* newfstatat = 262 */
  r = xlang_linux_syscall4(262, (long)AT_FDCWD, (long)path, (long)st, 0);
#elif defined(__aarch64__)
  /* fstatat = 79 */
  r = xlang_linux_syscall4(79, (long)AT_FDCWD, (long)path, (long)st, 0);
#endif
  return r == 0 ? 0 : -1;
}

/**
 * Cap residual fstat(2).
 * @return 0 ok, -1 fail
 * PLATFORM: LINUX
 */
static inline int xlang_path_fstat(int fd, struct stat *st) {
  long r;
  if (fd < 0 || !st)
    return -1;
#if defined(__x86_64__)
  /* fstat = 5 */
  r = xlang_linux_syscall2(5, (long)fd, (long)st);
#elif defined(__aarch64__)
  /* fstat = 80 */
  r = xlang_linux_syscall2(80, (long)fd, (long)st);
#endif
  return r == 0 ? 0 : -1;
}

/**
 * Format "/proc/self/fd/<fd>" into buf (caller ≥ 32 bytes).
 * PLATFORM: LINUX
 */
static inline void xlang_path_proc_fd(char *buf, int fd) {
  static const char pref[] = "/proc/self/fd/";
  int i = 0;
  int v;
  char tmp[16];
  int n = 0;
  while (pref[i]) {
    buf[i] = pref[i];
    i++;
  }
  if (fd == 0) {
    buf[i++] = '0';
    buf[i] = '\0';
    return;
  }
  v = fd;
  if (v < 0) {
    buf[i++] = '-';
    v = -v;
  }
  while (v > 0 && n < (int)sizeof(tmp)) {
    tmp[n++] = (char)('0' + (v % 10));
    v /= 10;
  }
  while (n > 0)
    buf[i++] = tmp[--n];
  buf[i] = '\0';
}

/**
 * Cap residual realpath: open(O_PATH|O_CLOEXEC) + readlink(/proc/self/fd/N).
 * Requires path to exist (≡ common libc realpath success case for files/dirs).
 * @param out caller buffer (typically PATH_MAX); written NUL-terminated on success
 * @return out on success, NULL on failure
 * PLATFORM: LINUX
 */
static inline const char *xlang_path_realpath(const char *path, char *out) {
  long fd;
  long n;
  long cr;
  char proc[64];
  /* O_PATH|O_CLOEXEC: 0x200000 | 0x80000 */
  const long o_flags = 0x200000L | 0x80000L;
  if (!path || !path[0] || !out)
    return NULL;
#if defined(__x86_64__)
  /* open = 2 */
  fd = xlang_linux_syscall3(2, (long)path, o_flags, 0);
#elif defined(__aarch64__)
  /* openat = 56 */
  fd = xlang_linux_syscall4(56, (long)AT_FDCWD, (long)path, o_flags, 0);
#endif
  if (fd < 0)
    return NULL;
  xlang_path_proc_fd(proc, (int)fd);
#if defined(__x86_64__)
  /* readlink = 89; leave 1 byte for NUL — use 4095 if out is PATH_MAX */
  n = xlang_linux_syscall3(89, (long)proc, (long)out, 4095);
  /* close = 3 */
  cr = xlang_linux_syscall2(3, fd, 0);
#elif defined(__aarch64__)
  /* readlinkat = 78 */
  n = xlang_linux_syscall4(78, (long)AT_FDCWD, (long)proc, (long)out, 4095);
  /* close = 57 */
  cr = xlang_linux_syscall2(57, fd, 0);
#endif
  (void)cr;
  if (n < 0)
    return NULL;
  out[n] = '\0';
  return out;
}

#else /* !LINUX primary ISA — Darwin / other POSIX residual */

#include <stdlib.h> /* realpath(3); PLATFORM: POSIX (Darwin residual). Linux Cap path above does not call libc realpath. */

static inline int xlang_path_access(const char *path, int mode) {
  if (!path || !path[0])
    return -1;
  return access(path, mode);
}

static inline int xlang_path_stat(const char *path, struct stat *st) {
  if (!path || !path[0] || !st)
    return -1;
  return stat(path, st);
}

static inline int xlang_path_fstat(int fd, struct stat *st) {
  if (fd < 0 || !st)
    return -1;
  return fstat(fd, st);
}

static inline const char *xlang_path_realpath(const char *path, char *out) {
  /* PLATFORM: POSIX — libc realpath; Darwin needs stdlib.h (ISO C99 no implicit decl). */
  if (!path || !path[0] || !out)
    return NULL;
  return realpath(path, out);
}

#endif /* LINUX */

#else /* _WIN32|_WIN64 — leftover PE / MinGW SAT compiles link_abi rest */

/*
 * PLATFORM: WINDOWS — complete the existing path-cap authority (G.7 有则补全).
 * MinGW CRT: _access / stat / fstat / _fullpath. Execute-bit (X_OK) is not a
 * distinct ACL on Win32; treat as R_OK like win32_compat.h (X_OK=4) when the
 * F_OK family is not already defined. POSIX gold path above is unchanged.
 * link_abi_realpath_cap_impl still returns NULL on Windows (product semantic
 * at that layer); this face exists so the four-name family compiles as one
 * authority if a later caller uses xlang_path_realpath on MinGW.
 */
#include <io.h>
#include <stdlib.h>
#include <sys/stat.h>

#ifndef F_OK
#define F_OK 0
#define W_OK 2
#define R_OK 4
#define X_OK 4
#endif

#ifndef _MAX_PATH
#define _MAX_PATH 260
#endif

static inline int xlang_path_access(const char *path, int mode) {
  if (!path || !path[0])
    return -1;
  return _access(path, mode);
}

static inline int xlang_path_stat(const char *path, struct stat *st) {
  if (!path || !path[0] || !st)
    return -1;
  return stat(path, st);
}

static inline int xlang_path_fstat(int fd, struct stat *st) {
  if (fd < 0 || !st)
    return -1;
  return fstat(fd, st);
}

static inline const char *xlang_path_realpath(const char *path, char *out) {
  if (!path || !path[0] || !out)
    return NULL;
  if (!_fullpath(out, path, _MAX_PATH))
    return NULL;
  return out;
}

#endif /* !_WIN32 */

#endif /* XLANG_PATH_CAP_H */
