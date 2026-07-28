/* seeds/runtime_time_os.from_x.c — G-02f-19 product TU
 * Product: runtime_time_os.o; logic migrating to .x (wave501 R2).
 *
 * wave501 R2 migration pattern:
 *   - When XLANG_RUNTIME_TIME_OS_FROM_X is defined:
 *     This seed file provides ONLY the OS bridge _impl functions
 *     (time_monotonic_ns_impl, time_wall_ns_impl, time_sleep_ns_impl,
 *     time_format_rfc3339_impl, time_local_offset_min_impl).
 *     The public API (time_now_monotonic_ns_c, etc.) comes from
 *     src/asm/runtime_time_os.x compiled into runtime_time_os_thin.o.
 *   - When NOT defined (cold bootstrap / fallback):
 *     This seed provides both _impl bridges AND public API wrappers.
 *     The .x file exists as source anchor only.
 *
 * PLATFORM: SHARED (POSIX clock_gettime + Windows QPC branches)
 */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#include <time.h> /* struct tm/time/gmtime_s；MinGW windows.h 不提供 */
#define UNIX_EPOCH_100NS 116444736000000000ULL
#else
#include <time.h>
#ifndef _WIN32
#include <sys/time.h>
#endif
#include <unistd.h>
#endif

/* === OS bridge _impl functions (always compiled) === */

/**
 * Bridge: monotonic clock in nanoseconds.
 * POSIX: clock_gettime(CLOCK_MONOTONIC) → ns
 * Windows: QueryPerformanceCounter → ns
 * @return nanoseconds; 0 on failure
 */
int64_t time_monotonic_ns_impl(void) {
#if defined(_WIN32) || defined(_WIN64)
    static LARGE_INTEGER freq = { { 0 } };
    LARGE_INTEGER counter;
    if (freq.QuadPart == 0) {
        QueryPerformanceFrequency(&freq);
        if (freq.QuadPart == 0) return 0;
    }
    QueryPerformanceCounter(&counter);
    return (int64_t)((counter.QuadPart * 1000000000) / freq.QuadPart);
#else
    struct timespec ts;
    if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0) return 0;
    return (int64_t)ts.tv_sec * 1000000000 + (int64_t)ts.tv_nsec;
#endif
}

/**
 * Bridge: wall clock in nanoseconds (UTC).
 * POSIX: clock_gettime(CLOCK_REALTIME) → ns
 * Windows: GetSystemTimePreciseAsFileTime → ns
 * @return nanoseconds since epoch; 0 on failure
 */
int64_t time_wall_ns_impl(void) {
#if defined(_WIN32) || defined(_WIN64)
    FILETIME ft;
    GetSystemTimePreciseAsFileTime(&ft);
    ULARGE_INTEGER u;
    u.LowPart = ft.dwLowDateTime;
    u.HighPart = ft.dwHighDateTime;
    return (int64_t)((u.QuadPart - UNIX_EPOCH_100NS) * 100);
#else
    struct timespec ts;
    if (clock_gettime(CLOCK_REALTIME, &ts) != 0) return 0;
    return (int64_t)ts.tv_sec * 1000000000 + (int64_t)ts.tv_nsec;
#endif
}

/**
 * Bridge: sleep for nanoseconds.
 * POSIX: nanosleep loop (handles spurious wakeups)
 * Windows: Sleep (with minimum 1ms clamp)
 * @param ns duration in nanoseconds; <=0 is no-op
 */
void time_sleep_ns_impl(int64_t ns) {
    if (ns <= 0) return;
#if defined(_WIN32) || defined(_WIN64)
    if (ns < 1000000) ns = 1000000;
    Sleep((DWORD)(ns / 1000000));
#else
    struct timespec req, rem;
    req.tv_sec = (time_t)(ns / 1000000000);
    req.tv_nsec = (long)(ns % 1000000000);
    while (nanosleep(&req, &rem) != 0) {
        req = rem;
    }
#endif
}

/**
 * Bridge: format current UTC wall clock as RFC3339 (trailing Z).
 * POSIX: gmtime_r + snprintf
 * Windows: gmtime_s + snprintf
 * @param buf output buffer
 * @param cap buffer capacity in bytes
 * @return written length; -1 on failure
 */
int32_t time_format_rfc3339_impl(uint8_t *buf, int32_t cap) {
    if (!buf || cap <= 0) return -1;
    time_t now;
    struct tm tm;
    int n;
#if defined(_WIN32) || defined(_WIN64)
    now = time(NULL);
    if (gmtime_s(&tm, &now) != 0) return -1;
#else
    now = time(NULL);
    if (gmtime_r(&now, &tm) == NULL) return -1;
#endif
    n = snprintf((char *)buf, (size_t)cap, "%04d-%02d-%02dT%02d:%02d:%02dZ",
                 tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday,
                 tm.tm_hour, tm.tm_min, tm.tm_sec);
    if (n <= 0 || n >= cap) return -1;
    return (int32_t)n;
}

/**
 * Bridge: local timezone offset from UTC in minutes (east positive).
 * POSIX: localtime_r/gmtime_r + mktime diff
 * Windows: GetTimeZoneInformation.Bias negated
 * @return offset minutes; 0 on failure
 */
int32_t time_local_offset_min_impl(void) {
#if defined(_WIN32) || defined(_WIN64)
    TIME_ZONE_INFORMATION tzi;
    DWORD r = GetTimeZoneInformation(&tzi);
    (void)r;
    return -(int32_t)tzi.Bias;
#else
    time_t now = time(NULL);
    struct tm local_tm;
    struct tm gmt_tm;
    time_t local_sec;
    time_t gmt_sec;
    if (localtime_r(&now, &local_tm) == NULL) return 0;
    if (gmtime_r(&now, &gmt_tm) == NULL) return 0;
    local_tm.tm_isdst = 0;
    gmt_tm.tm_isdst = 0;
    local_sec = mktime(&local_tm);
    gmt_sec = mktime(&gmt_tm);
    if (local_sec == (time_t)-1 || gmt_sec == (time_t)-1) return 0;
    return (int32_t)((local_sec - gmt_sec) / 60);
#endif
}

/* === Public API wrappers (only when NOT in FROM_X mode) === */

#ifndef XLANG_RUNTIME_TIME_OS_FROM_X

/**
 * Public: monotonic clock in nanoseconds.
 * Cold bootstrap wrapper; FROM_X mode uses .x source.
 */
int64_t time_now_monotonic_ns_c(void) {
    return time_monotonic_ns_impl();
}

/**
 * Public: wall clock in nanoseconds since epoch (UTC).
 * Cold bootstrap wrapper; FROM_X mode uses .x source.
 */
int64_t time_now_wall_ns_c(void) {
    return time_wall_ns_impl();
}

/**
 * Public: sleep for nanoseconds. No-op if ns <= 0.
 * Cold bootstrap wrapper; FROM_X mode uses .x source.
 */
void time_sleep_ns_c(int64_t ns) {
    if (ns <= 0) return;
    time_sleep_ns_impl(ns);
}

/**
 * Public: format current UTC wall clock as RFC3339 string.
 * Cold bootstrap wrapper; FROM_X mode uses .x source.
 */
int32_t time_format_wall_rfc3339_c(uint8_t *buf, int32_t cap) {
    if (!buf || cap <= 0) return -1;
    return time_format_rfc3339_impl(buf, cap);
}

/**
 * Public: local timezone offset from UTC in minutes (east positive).
 * Cold bootstrap wrapper; FROM_X mode uses .x source.
 */
int32_t time_wall_local_offset_min_c(void) {
    return time_local_offset_min_impl();
}

#endif /* !XLANG_RUNTIME_TIME_OS_FROM_X */