/*
 * xlang_dir_cap.h — Cap residual 9.1.10: opendir/readdir/closedir without libc
 * those symbols on Linux (x86_64 + aarch64).
 *
 * Single authority for:
 *   std.fs posix fs_libc_{opendir,readdir,closedir},
 *   xlang_fmt_{opendir,closedir,readdir_name},
 *   pipeline_abi cold sibling-dir scan.
 *
 * Linux: open(O_DIRECTORY) + getdents64 into a heap DIR stream; readdir fills a
 * glibc-layout dirent so DIRENT_D_NAME_OFF=19 stays valid for std.fs.
 * Other POSIX: thin libc wrappers (Darwin residual until later).
 * Windows: not used — call sites keep Win32 FindFirstFile.
 *
 * Heap: malloc/free still host (Cap residual for allocator is separate).
 * Cap residual 9.1.9: syscall asm via xlang_syscall_cap.h (G.7).
 *
 * PLATFORM: LINUX primary; POSIX fallback elsewhere (non-Win).
 */

#ifndef XLANG_DIR_CAP_H
#define XLANG_DIR_CAP_H

#if !defined(_WIN32) && !defined(_WIN64)

#include <errno.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#if defined(__linux__) && (defined(__x86_64__) || defined(__aarch64__))

#include <xlang_syscall_cap.h>

#ifndef O_RDONLY
#define O_RDONLY 0
#endif
/* Linux O_DIRECTORY */
#ifndef O_DIRECTORY
#define O_DIRECTORY 0200000
#endif

/** Cap residual 9.1.9: aliases → single syscall authority. */
#define xlang_dir_syscall3 xlang_syscall3
#define xlang_dir_syscall1 xlang_syscall1

/** Linux getdents64 directory entry (kernel layout). PLATFORM: LINUX */
struct xlang_linux_dirent64 {
  uint64_t d_ino;
  int64_t d_off;
  unsigned short d_reclen;
  unsigned char d_type;
  char d_name[];
};

/**
 * glibc x86_64/aarch64 struct dirent layout used by std.fs DIRENT_D_NAME_OFF=19.
 * PLATFORM: LINUX
 */
struct xlang_dirent_glibc {
  uint64_t d_ino;
  int64_t d_off;
  unsigned short d_reclen;
  unsigned char d_type;
  char d_name[256];
};

/** Opaque DIR stream (heap). PLATFORM: LINUX */
struct xlang_dir_stream {
  int fd;
  unsigned char *buf;
  size_t buf_cap;
  size_t buf_len;
  size_t buf_pos;
  struct xlang_dirent_glibc ent;
};

/** Map negative kernel ret to -1 + errno. PLATFORM: LINUX */
static inline int xlang_dir_ret(long r) {
  if (r < 0) {
    errno = (int)(-r);
    return -1;
  }
  return (int)r;
}

/**
 * Cap residual open(2) for directories (O_RDONLY|O_DIRECTORY).
 * PLATFORM: LINUX
 */
static inline int xlang_dir_sys_open_dir(const char *path) {
  long r;
  if (!path || !path[0])
    return -1;
#if defined(__x86_64__)
  /* open = 2 */
  r = xlang_dir_syscall3(2, (long)path, (long)(O_RDONLY | O_DIRECTORY), 0);
#elif defined(__aarch64__)
  /* openat = 56; AT_FDCWD = -100 */
  r = xlang_syscall4(56, (long)(-100), (long)path, (long)(O_RDONLY | O_DIRECTORY), 0);
#endif
  return xlang_dir_ret(r);
}

/**
 * Cap residual close(2).
 * PLATFORM: LINUX
 */
static inline int xlang_dir_sys_close(int fd) {
  long r;
#if defined(__x86_64__)
  /* close = 3 */
  r = xlang_dir_syscall1(3, (long)fd);
#elif defined(__aarch64__)
  /* close = 57 */
  r = xlang_dir_syscall1(57, (long)fd);
#endif
  return xlang_dir_ret(r);
}

/**
 * Cap residual getdents64(2).
 * @return bytes read, 0 EOF, -1 error
 * PLATFORM: LINUX
 */
static inline long xlang_dir_sys_getdents64(int fd, void *buf, size_t count) {
  long r;
#if defined(__x86_64__)
  /* getdents64 = 217 */
  r = xlang_dir_syscall3(217, (long)fd, (long)buf, (long)count);
#elif defined(__aarch64__)
  /* getdents64 = 61 */
  r = xlang_dir_syscall3(61, (long)fd, (long)buf, (long)count);
#endif
  if (r < 0) {
    errno = (int)(-r);
    return -1;
  }
  return r;
}

/**
 * Cap residual opendir(3) — open + getdents64 buffer.
 * @return opaque DIR* or NULL
 * PLATFORM: LINUX
 */
static inline void *xlang_dir_open(const char *name) {
  struct xlang_dir_stream *d;
  int fd;
  if (!name || !name[0])
    return NULL;
  d = (struct xlang_dir_stream *)calloc(1, sizeof(*d));
  if (!d)
    return NULL;
  fd = xlang_dir_sys_open_dir(name);
  if (fd < 0) {
    free(d);
    return NULL;
  }
  d->fd = fd;
  d->buf_cap = 8192;
  d->buf = (unsigned char *)malloc(d->buf_cap);
  if (!d->buf) {
    (void)xlang_dir_sys_close(d->fd);
    free(d);
    return NULL;
  }
  return (void *)d;
}

/**
 * Cap residual readdir(3) — next glibc-layout dirent, or NULL at EOF/error.
 * d_name at byte 19 (matches std.fs DIRENT_D_NAME_OFF on Linux).
 * PLATFORM: LINUX
 */
static inline void *xlang_dir_read(void *dirp) {
  struct xlang_dir_stream *d = (struct xlang_dir_stream *)dirp;
  struct xlang_linux_dirent64 *de;
  size_t nlen;
  if (!d || d->fd < 0)
    return NULL;
  for (;;) {
    if (d->buf_pos >= d->buf_len) {
      long nr = xlang_dir_sys_getdents64(d->fd, d->buf, d->buf_cap);
      if (nr <= 0)
        return NULL;
      d->buf_len = (size_t)nr;
      d->buf_pos = 0;
    }
    if (d->buf_pos >= d->buf_len)
      return NULL;
    de = (struct xlang_linux_dirent64 *)(d->buf + d->buf_pos);
    d->buf_pos += de->d_reclen;
    if (de->d_name[0] == '\0')
      continue;
    d->ent.d_ino = de->d_ino;
    d->ent.d_off = de->d_off;
    d->ent.d_reclen = de->d_reclen;
    d->ent.d_type = de->d_type;
    nlen = 0;
    while (de->d_name[nlen] && nlen + 1 < sizeof(d->ent.d_name)) {
      d->ent.d_name[nlen] = de->d_name[nlen];
      nlen++;
    }
    d->ent.d_name[nlen] = '\0';
    return (void *)&d->ent;
  }
}

/**
 * Cap residual readdir name only (valid until next read/close).
 * PLATFORM: LINUX
 */
static inline char *xlang_dir_readdir_name(void *dirp) {
  struct xlang_dirent_glibc *ent = (struct xlang_dirent_glibc *)xlang_dir_read(dirp);
  return ent ? ent->d_name : (char *)0;
}

/**
 * Cap residual closedir(3).
 * PLATFORM: LINUX
 */
static inline int xlang_dir_close(void *dirp) {
  struct xlang_dir_stream *d = (struct xlang_dir_stream *)dirp;
  if (!d)
    return -1;
  if (d->fd >= 0)
    (void)xlang_dir_sys_close(d->fd);
  free(d->buf);
  free(d);
  return 0;
}

#else /* !LINUX Cap — POSIX libc thin wrappers */

#include <dirent.h>

/** PLATFORM: POSIX fallback — libc opendir. */
static inline void *xlang_dir_open(const char *name) {
  if (!name)
    return NULL;
  return (void *)opendir(name);
}

/** PLATFORM: POSIX fallback — libc readdir (dirent*). */
static inline void *xlang_dir_read(void *dirp) {
  if (!dirp)
    return NULL;
  return (void *)readdir((DIR *)dirp);
}

/** PLATFORM: POSIX fallback — d_name from libc readdir. */
static inline char *xlang_dir_readdir_name(void *dirp) {
  struct dirent *ent;
  if (!dirp)
    return (char *)0;
  ent = readdir((DIR *)dirp);
  return ent ? ent->d_name : (char *)0;
}

/** PLATFORM: POSIX fallback — libc closedir. */
static inline int xlang_dir_close(void *dirp) {
  if (!dirp)
    return -1;
  return closedir((DIR *)dirp);
}

#endif /* LINUX Cap vs POSIX */

#endif /* !_WIN32 */
#endif /* XLANG_DIR_CAP_H */
