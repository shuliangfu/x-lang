/*
 * seeds/runtime_dir_cap.from_x.c — Cap residual 9.1.10 global faces.
 *
 * Emits non-static xlang_dir_* for std.fs KEEP_C / formal fs.o merges
 * (static inline Cap header alone leaves U when -E emits extern calls).
 *
 * G.7: bodies call xlang_dir_cap.h (single authority). Do not reimplement
 * getdents64 here.
 *
 * PLATFORM: SHARED face; LINUX Cap / POSIX fallback inside the header.
 */

#include <stdint.h>
#include <stddef.h>

#if !defined(_WIN32) && !defined(_WIN64)
#include <xlang_dir_cap.h>

/**
 * Cap residual 9.1.10: opendir face for std.fs / product KEEP_C.
 * @param name directory path (NUL-terminated)
 * @return opaque DIR* as uint8_t*, or NULL
 * PLATFORM: SHARED
 */
uint8_t *xlang_dir_opendir(uint8_t *name) {
  if (!name)
    return (uint8_t *)0;
  return (uint8_t *)xlang_dir_open((const char *)(void *)name);
}

/**
 * Cap residual 9.1.10: readdir face — glibc-layout dirent* as uint8_t*.
 * @param dirp opaque from xlang_dir_opendir
 * @return dirent pointer or NULL at EOF
 * PLATFORM: SHARED
 */
uint8_t *xlang_dir_readdir(uint8_t *dirp) {
  return (uint8_t *)xlang_dir_read((void *)dirp);
}

/**
 * Cap residual 9.1.10: closedir face.
 * @param dirp opaque from xlang_dir_opendir
 * @return 0 ok, -1 fail
 * PLATFORM: SHARED
 */
int32_t xlang_dir_closedir(uint8_t *dirp) {
  return (int32_t)xlang_dir_close((void *)dirp);
}

/**
 * Cap residual 9.1.10: readdir d_name only (fmt / pipeline).
 * @param dirp opaque from xlang_dir_opendir
 * @return name pointer valid until next read/close, or NULL
 * PLATFORM: SHARED
 */
uint8_t *xlang_dir_readdir_name_c(uint8_t *dirp) {
  char *n = xlang_dir_readdir_name((void *)dirp);
  return (uint8_t *)(void *)n;
}

#endif /* !_WIN32 */
