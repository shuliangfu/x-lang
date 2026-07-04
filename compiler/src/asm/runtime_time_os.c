/**
 * runtime_time_os.c — 时间与睡眠 OS 胶层（F-ZC：自 std/time/time_os_glue.c 迁入）
 *
 * 提供 time_now_monotonic_ns_c / wall / sleep / RFC3339 / 时区偏移；
 * time.x 经 extern 调用；与 time.o 一并链入。
 */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#define UNIX_EPOCH_100NS 116444736000000000ULL
#else
#include <time.h>
#ifndef _WIN32
#include <sys/time.h>
#endif
#include <unistd.h>
#endif

/**
 * 单调时钟纳秒；POSIX clock_gettime / Windows QPC。
 * 返回值：纳秒；失败 0。
 */
int64_t time_now_monotonic_ns_c(void) {
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
 * 墙钟纳秒；Windows 100ns 粒度。
 * 返回值：UTC 纳秒；失败 0。
 */
int64_t time_now_wall_ns_c(void) {
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
 * 睡眠纳秒；可能 spurious wakeup。
 * 参数：ns 睡眠时长（≤0 无操作）。
 */
void time_sleep_ns_c(int64_t ns) {
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
 * UTC 墙钟 RFC3339（末尾 Z）。
 * 参数：buf 输出；cap 容量。
 * 返回值：写入长度；失败 -1。
 */
int32_t time_format_wall_rfc3339_c(uint8_t *buf, int32_t cap) {
    time_t now;
    struct tm tm;
    int n;
#if defined(_WIN32) || defined(_WIN64)
    if (!buf || cap <= 0) return -1;
    now = time(NULL);
    if (gmtime_s(&tm, &now) != 0) return -1;
#else
    if (!buf || cap <= 0) return -1;
    now = time(NULL);
    if (gmtime_r(&now, &tm) == NULL) return -1;
#endif
    n = snprintf((char *)buf, (size_t)cap, "%04d-%02d-%02dT%02d:%02d:%02dZ",
                 tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday,
                 tm.tm_hour, tm.tm_min, tm.tm_sec);
    if (n <= 0 || n >= cap) return -1;
    return n;
}

/**
 * 本地时区相对 UTC 偏移（分钟；东为正）。
 * 返回值：偏移分钟；失败 0。
 */
int32_t time_wall_local_offset_min_c(void) {
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
