/*
 * xlang_time_cap.h — Cap residual 9.1.5: clock_gettime / nanosleep / gmtime_r
 * without libc on Linux (x86_64 + aarch64).
 *
 * Single authority for runtime_time_os OS bridges and neighbor C call sites
 * (scheduler trace, channel timedwait, sync smoke sleep).
 *
 * Windows: not used — call sites keep QPC / Sleep / gmtime_s.
 * Other POSIX: thin libc wrappers (Darwin residual until later).
 *
 * PLATFORM: LINUX primary; POSIX fallback elsewhere (non-Win).
 */

#ifndef XLANG_TIME_CAP_H
#define XLANG_TIME_CAP_H

#if !defined(_WIN32) && !defined(_WIN64)

#include <errno.h>
#include <stddef.h>
#include <time.h>

#ifndef CLOCK_REALTIME
#define CLOCK_REALTIME 0
#endif
#ifndef CLOCK_MONOTONIC
#define CLOCK_MONOTONIC 1
#endif

#if defined(__linux__) && (defined(__x86_64__) || defined(__aarch64__))

/** Linux raw syscall ≤3 args. Returns -errno on failure. PLATFORM: LINUX. */
static inline long xlang_time_syscall3(long nr, long a1, long a2, long a3) {
  long r;
#if defined(__x86_64__)
  __asm__ __volatile__("syscall"
                       : "=a"(r)
                       : "a"(nr), "D"(a1), "S"(a2), "d"(a3)
                       : "rcx", "r11", "memory");
#elif defined(__aarch64__)
  register long x8 __asm__("x8") = nr;
  register long x0 __asm__("x0") = a1;
  register long x1 __asm__("x1") = a2;
  register long x2 __asm__("x2") = a3;
  __asm__ __volatile__("svc #0"
                       : "+r"(x0)
                       : "r"(x8), "r"(x1), "r"(x2)
                       : "memory");
  r = x0;
#endif
  return r;
}

/**
 * Cap residual clock_gettime(2).
 * @param clk_id CLOCK_REALTIME (0) or CLOCK_MONOTONIC (1)
 * @param ts out timespec (Linux LP64 layout)
 * @return 0 ok, -1 fail
 * PLATFORM: LINUX
 */
static inline int xlang_time_clock_gettime(int clk_id, struct timespec *ts) {
  long r;
  if (!ts)
    return -1;
#if defined(__x86_64__)
  /* clock_gettime = 228 */
  r = xlang_time_syscall3(228, (long)clk_id, (long)ts, 0);
#elif defined(__aarch64__)
  /* clock_gettime = 113 */
  r = xlang_time_syscall3(113, (long)clk_id, (long)ts, 0);
#endif
  return r == 0 ? 0 : -1;
}

/**
 * Cap residual nanosleep(2). Caller retries on EINTR with rem.
 * @return 0 ok, -1 fail (errno may be EINTR)
 * PLATFORM: LINUX
 */
static inline int xlang_time_nanosleep(const struct timespec *req, struct timespec *rem) {
  long r;
  if (!req)
    return -1;
#if defined(__x86_64__)
  /* nanosleep = 35 */
  r = xlang_time_syscall3(35, (long)req, (long)rem, 0);
#elif defined(__aarch64__)
  /* nanosleep = 101 */
  r = xlang_time_syscall3(101, (long)req, (long)rem, 0);
#endif
  if (r == 0)
    return 0;
  /* Kernel returns -errno; surface POSIX errno for EINTR loops. */
  if (r < 0) {
    errno = (int)(-r);
    return -1;
  }
  return -1;
}

/**
 * Days since Unix epoch from civil (y, m, d) UTC.
 * Algorithm: Howard Hinnant days_from_civil.
 * PLATFORM: SHARED math
 */
static inline long xlang_time_days_from_civil(int y, unsigned m, unsigned d) {
  long era;
  unsigned yoe;
  unsigned doy;
  unsigned doe;
  y -= (m <= 2U);
  era = (y >= 0 ? y : y - 399) / 400;
  yoe = (unsigned)(y - era * 400);
  doy = (153U * (m > 2U ? m - 3U : m + 9U) + 2U) / 5U + d - 1U;
  doe = yoe * 365U + yoe / 4U - yoe / 100U + doy;
  return (long)era * 146097L + (long)doe - 719468L;
}

/**
 * Civil calendar from days since Unix epoch (UTC).
 * Algorithm: Howard Hinnant civil_from_days.
 * PLATFORM: SHARED math (used by Linux Cap gmtime)
 */
static inline void xlang_time_civil_from_days(long z, int *y, unsigned *m, unsigned *d) {
  long era;
  unsigned doe;
  unsigned yoe;
  unsigned doy;
  unsigned mp;
  long yy;
  z += 719468L;
  era = (z >= 0 ? z : z - 146096L) / 146097L;
  doe = (unsigned)(z - era * 146097L);
  yoe = (doe - doe / 1460U + doe / 36524U - doe / 146096U) / 365U;
  yy = (long)yoe + era * 400L;
  doy = doe - (365U * yoe + yoe / 4U - yoe / 100U);
  mp = (5U * doy + 2U) / 153U;
  *d = (unsigned)(doy - (153U * mp + 2U) / 5U + 1U);
  *m = (unsigned)(mp < 10U ? mp + 3U : mp - 9U);
  *y = (int)(yy + (*m <= 2U ? 1 : 0));
}

/**
 * Cap residual gmtime_r: UTC broken-down time without libc gmtime_r.
 * @param t seconds since Unix epoch
 * @param out struct tm (fields filled; tm_isdst=0)
 * @return out on success, NULL on null args
 * PLATFORM: LINUX Cap (pure civil math)
 */
static inline struct tm *xlang_time_gmtime_r(const time_t *t, struct tm *out) {
  long sec;
  long days;
  long tod;
  int y;
  unsigned m;
  unsigned d;
  if (!t || !out)
    return NULL;
  sec = (long)(*t);
  days = sec / 86400L;
  tod = sec % 86400L;
  if (tod < 0) {
    tod += 86400L;
    days -= 1;
  }
  xlang_time_civil_from_days(days, &y, &m, &d);
  out->tm_year = y - 1900;
  out->tm_mon = (int)m - 1;
  out->tm_mday = (int)d;
  out->tm_hour = (int)(tod / 3600L);
  out->tm_min = (int)((tod % 3600L) / 60L);
  out->tm_sec = (int)(tod % 60L);
  /* 1970-01-01 was Thursday → (days+4) % 7 */
  out->tm_wday = (int)((days + 4L) % 7L);
  if (out->tm_wday < 0)
    out->tm_wday += 7;
  out->tm_yday = (int)(days - xlang_time_days_from_civil(y, 1U, 1U));
  out->tm_isdst = 0;
  return out;
}

#else /* !LINUX Cap — POSIX libc thin wrappers (Darwin residual) */

/** PLATFORM: POSIX fallback — libc clock_gettime. */
static inline int xlang_time_clock_gettime(int clk_id, struct timespec *ts) {
  return clock_gettime(clk_id, ts);
}

/** PLATFORM: POSIX fallback — libc nanosleep. */
static inline int xlang_time_nanosleep(const struct timespec *req, struct timespec *rem) {
  return nanosleep(req, rem);
}

/** PLATFORM: POSIX fallback — libc gmtime_r. */
static inline struct tm *xlang_time_gmtime_r(const time_t *t, struct tm *out) {
  return gmtime_r(t, out);
}

#endif /* LINUX Cap vs POSIX fallback */

/**
 * Sleep ns with EINTR restart (Cap residual sleep loop helper).
 * @param ns duration; <=0 is no-op
 * PLATFORM: POSIX via xlang_time_nanosleep
 */
static inline void xlang_time_sleep_ns(long long ns) {
  struct timespec req;
  struct timespec rem;
  if (ns <= 0)
    return;
  req.tv_sec = (time_t)(ns / 1000000000LL);
  req.tv_nsec = (long)(ns % 1000000000LL);
  for (;;) {
    if (xlang_time_nanosleep(&req, &rem) == 0)
      return;
    if (errno != EINTR)
      return;
    req = rem;
  }
}

#endif /* !_WIN32 */

#endif /* XLANG_TIME_CAP_H */
