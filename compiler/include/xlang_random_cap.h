/*
 * xlang_random_cap.h — Cap residual 9.1.6: getrandom without libc on Linux
 * (x86_64 + aarch64). Darwin keeps getentropy; Windows keeps BCrypt at call sites.
 *
 * Single authority for runtime_random_fill_bytes_impl CSPRNG fill.
 *
 * PLATFORM: LINUX primary; POSIX/Darwin getentropy fallback elsewhere (non-Win).
 */

#ifndef XLANG_RANDOM_CAP_H
#define XLANG_RANDOM_CAP_H

#if !defined(_WIN32) && !defined(_WIN64)

#include <errno.h>
#include <stddef.h>
#include <stdint.h>

#ifndef GETENTROPY_MAX
#define GETENTROPY_MAX 256
#endif

#if defined(__linux__) && (defined(__x86_64__) || defined(__aarch64__))

#include <xlang_syscall_cap.h>

/** Cap residual 9.1.9: alias → single syscall authority. */
#define xlang_random_syscall3 xlang_syscall3

/**
 * Cap residual getrandom(2).
 * @param buf output buffer
 * @param buflen bytes requested
 * @param flags 0 = block until entropy available
 * @return bytes written (>0), or -1 with errno set (EINTR etc.)
 * PLATFORM: LINUX
 */
static inline long xlang_random_getrandom(void *buf, size_t buflen, unsigned int flags) {
  long r;
  if (!buf && buflen != 0)
    return -1;
#if defined(__x86_64__)
  /* getrandom = 318 */
  r = xlang_random_syscall3(318, (long)buf, (long)buflen, (long)flags);
#elif defined(__aarch64__)
  /* getrandom = 278 */
  r = xlang_random_syscall3(278, (long)buf, (long)buflen, (long)flags);
#endif
  if (r >= 0)
    return r;
  errno = (int)(-r);
  return -1;
}

/**
 * Fill buf with CSPRNG bytes via Cap getrandom (EINTR restart).
 * @return len on full success; partial >0 or -1 on failure
 * PLATFORM: LINUX
 */
static inline int32_t xlang_random_fill_bytes(uint8_t *buf, int32_t len) {
  size_t done = 0;
  size_t want;
  if (!buf || len < 0)
    return -1;
  if (len == 0)
    return 0;
  want = (size_t)len;
  while (done < want) {
    long n = xlang_random_getrandom(buf + done, want - done, 0);
    if (n < 0) {
      if (errno == EINTR)
        continue;
      return (int32_t)(done > 0 ? (int32_t)done : -1);
    }
    if (n == 0)
      return (int32_t)(done > 0 ? (int32_t)done : -1);
    done += (size_t)n;
  }
  return len;
}

#else /* !LINUX Cap — Darwin / other POSIX: getentropy */

#if defined(__APPLE__)
#include <sys/random.h>
#else
#include <unistd.h>
#endif

/**
 * Fill buf via getentropy (chunked ≤GETENTROPY_MAX).
 * PLATFORM: Darwin／POSIX residual (libc getentropy)
 */
static inline int32_t xlang_random_fill_bytes(uint8_t *buf, int32_t len) {
  size_t done = 0;
  size_t total;
  if (!buf || len < 0)
    return -1;
  if (len == 0)
    return 0;
  total = (size_t)len;
  while (done < total) {
    size_t chunk = total - done;
    if (chunk > (size_t)GETENTROPY_MAX)
      chunk = (size_t)GETENTROPY_MAX;
    if (getentropy(buf + done, chunk) != 0)
      return (int32_t)(done > 0 ? (int32_t)done : -1);
    done += chunk;
  }
  return len;
}

#endif /* LINUX Cap vs Darwin/POSIX */

#endif /* !_WIN32 */

#endif /* XLANG_RANDOM_CAP_H */
