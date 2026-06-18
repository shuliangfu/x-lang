/**
 * std/datetime/datetime.c — 墙钟 UTC、RFC3339、日历字段、Duration（STD-074）
 *
 * 【文件职责】
 * DateTime（Unix 纪元 UTC sec+nsec）、RFC3339/RFC3339Nano 解析与格式化、
 * UTC 日历字段、本地时区偏移（平台）、Duration 纳秒算术。
 *
 * 【依赖】C 标准库 time；now_utc 复用 std/time/time.c 墙钟符号。
 */

#include <stdint.h>
#include <stdio.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#else
#include <time.h>
#endif

extern int64_t time_now_wall_sec_c(void);
extern int64_t time_now_wall_ns_c(void);

/** 闰年判定。 */
static int dt_is_leap(int y) {
    return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
}

/** 月天数（month 1..12）。 */
static int dt_days_in_month(int y, int mo) {
    static const int d[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    if (mo < 1 || mo > 12) return 0;
    if (mo == 2 && dt_is_leap(y)) return 29;
    return d[mo - 1];
}

/** UTC 日历字段 → Unix 秒（1970-01-01 起）。 */
static int64_t dt_utc_to_unix(int y, int mo, int d, int h, int mi, int s) {
    int64_t days = 0;
    int yy;
    if (y >= 1970) {
        for (yy = 1970; yy < y; yy++)
            days += dt_is_leap(yy) ? 366 : 365;
    } else {
        for (yy = y; yy < 1970; yy++)
            days -= dt_is_leap(yy) ? 366 : 365;
    }
    for (yy = 1; yy < mo; yy++)
        days += dt_days_in_month(y, yy);
    days += (int64_t)d - 1;
    return days * 86400 + (int64_t)h * 3600 + (int64_t)mi * 60 + (int64_t)s;
}

/** Unix 秒 → UTC 日历字段。 */
static void dt_unix_to_utc(int64_t sec, int *y, int *mo, int *d, int *h, int *mi, int *s) {
    int64_t days;
    int yy, mm;
    int rem = (int)(sec % 86400);
    if (rem < 0) {
        rem += 86400;
        sec -= 86400;
    }
    days = sec / 86400;
    yy = 1970;
    if (days >= 0) {
        for (;;) {
            int dy = dt_is_leap(yy) ? 366 : 365;
            if (days < dy) break;
            days -= dy;
            yy++;
        }
    } else {
        yy = 1969;
        for (;;) {
            int dy = dt_is_leap(yy) ? 366 : 365;
            days += dy;
            if (days >= 0) {
                yy++;
                break;
            }
            yy--;
        }
    }
    mm = 1;
    while (mm <= 12) {
        int dm = dt_days_in_month(yy, mm);
        if (days < dm) break;
        days -= dm;
        mm++;
    }
    *y = yy;
    *mo = mm;
    *d = (int)days + 1;
    *h = rem / 3600;
    *mi = (rem % 3600) / 60;
    *s = rem % 60;
}

/** 读十进制数字；成功返回 0。 */
static int dt_read_digits(const uint8_t *p, int32_t len, int *pos, int count, int *out) {
    int i, v = 0;
    if (*pos + count > len) return -1;
    for (i = 0; i < count; i++) {
        uint8_t c = p[*pos + i];
        if (c < (uint8_t)'0' || c > (uint8_t)'9') return -1;
        v = v * 10 + (int)(c - (uint8_t)'0');
    }
    *pos += count;
    *out = v;
    return 0;
}

/** 当前 UTC 墙钟。 */
void datetime_now_utc_c(int64_t *out_sec, int32_t *out_nsec) {
    if (!out_sec || !out_nsec) return;
    *out_sec = time_now_wall_sec_c();
    {
        int64_t ns = time_now_wall_ns_c();
        *out_nsec = (int32_t)(ns % 1000000000);
        if (*out_nsec < 0) *out_nsec += 1000000000;
    }
}

/** UTC 日历字段分解。 */
void datetime_utc_fields_c(int64_t sec, int32_t *y, int32_t *mo, int32_t *d, int32_t *h, int32_t *mi, int32_t *s) {
    int yi, moi, di, hi, mii, si;
    dt_unix_to_utc(sec, &yi, &moi, &di, &hi, &mii, &si);
    if (y) *y = (int32_t)yi;
    if (mo) *mo = (int32_t)moi;
    if (d) *d = (int32_t)di;
    if (h) *h = (int32_t)hi;
    if (mi) *mi = (int32_t)mii;
    if (s) *s = (int32_t)si;
}

/** 由 UTC 日历构造 DateTime；非法返回 -1。 */
int datetime_from_utc_fields_c(int32_t y, int32_t mo, int32_t d, int32_t h, int32_t mi, int32_t s, int32_t nsec,
                                 int64_t *out_sec, int32_t *out_nsec) {
    if (!out_sec || !out_nsec) return -1;
    if (mo < 1 || mo > 12 || d < 1 || d > dt_days_in_month(y, mo)) return -1;
    if (h < 0 || h > 23 || mi < 0 || mi > 59 || s < 0 || s > 59) return -1;
    if (nsec < 0 || nsec >= 1000000000) return -1;
    *out_sec = dt_utc_to_unix(y, mo, d, h, mi, s);
    *out_nsec = nsec;
    return 0;
}

/** 比较两个 DateTime：-1/0/1。 */
int datetime_compare_c(int64_t a_sec, int32_t a_nsec, int64_t b_sec, int32_t b_nsec) {
    if (a_sec < b_sec) return -1;
    if (a_sec > b_sec) return 1;
    if (a_nsec < b_nsec) return -1;
    if (a_nsec > b_nsec) return 1;
    return 0;
}

/**
 * 解析 RFC3339 / RFC3339Nano（Z 或 ±HH:MM 偏移）。
 * out_offset_min：相对 UTC 的分钟偏移（东为正）；Z 时为 0。
 */
int datetime_parse_rfc3339_c(const uint8_t *ptr, int32_t len, int64_t *out_sec, int32_t *out_nsec, int32_t *out_offset_min) {
    int pos = 0;
    int y, mo, d, h, mi, s;
    int32_t nsec = 0;
    int32_t off_min = 0;
    int64_t unix_sec;
    if (!ptr || len < 20 || !out_sec || !out_nsec) return -1;
    if (dt_read_digits(ptr, len, &pos, 4, &y) != 0) return -1;
    if (pos >= len || ptr[pos] != (uint8_t)'-') return -1;
    pos++;
    if (dt_read_digits(ptr, len, &pos, 2, &mo) != 0) return -1;
    if (pos >= len || ptr[pos] != (uint8_t)'-') return -1;
    pos++;
    if (dt_read_digits(ptr, len, &pos, 2, &d) != 0) return -1;
    if (pos >= len || ptr[pos] != (uint8_t)'T') return -1;
    pos++;
    if (dt_read_digits(ptr, len, &pos, 2, &h) != 0) return -1;
    if (pos >= len || ptr[pos] != (uint8_t)':') return -1;
    pos++;
    if (dt_read_digits(ptr, len, &pos, 2, &mi) != 0) return -1;
    if (pos >= len || ptr[pos] != (uint8_t)':') return -1;
    pos++;
    if (dt_read_digits(ptr, len, &pos, 2, &s) != 0) return -1;
    if (pos < len && ptr[pos] == (uint8_t)'.') {
        int frac_digits = 0;
        int frac = 0;
        pos++;
        while (pos < len && ptr[pos] >= (uint8_t)'0' && ptr[pos] <= (uint8_t)'9' && frac_digits < 9) {
            frac = frac * 10 + (int)(ptr[pos] - (uint8_t)'0');
            frac_digits++;
            pos++;
        }
        while (frac_digits < 9) {
            frac *= 10;
            frac_digits++;
        }
        nsec = frac;
    }
    if (pos >= len) return -1;
    if (ptr[pos] == (uint8_t)'Z') {
        off_min = 0;
        pos++;
    } else if (ptr[pos] == (uint8_t)'+' || ptr[pos] == (uint8_t)'-') {
        int sign = (ptr[pos] == (uint8_t)'+') ? 1 : -1;
        int oh, om;
        pos++;
        if (dt_read_digits(ptr, len, &pos, 2, &oh) != 0) return -1;
        if (pos >= len || ptr[pos] != (uint8_t)':') return -1;
        pos++;
        if (dt_read_digits(ptr, len, &pos, 2, &om) != 0) return -1;
        off_min = sign * (oh * 60 + om);
    } else {
        return -1;
    }
    if (pos != len) return -1;
    unix_sec = dt_utc_to_unix(y, mo, d, h, mi, s);
    unix_sec -= (int64_t)off_min * 60;
    *out_sec = unix_sec;
    *out_nsec = nsec;
    if (out_offset_min) *out_offset_min = off_min;
    return 0;
}

/** 格式化 RFC3339 UTC（Z 后缀）；返回写入长度，失败 -1。 */
int datetime_format_rfc3339_c(int64_t sec, int32_t nsec, uint8_t *out, int32_t out_cap) {
    int y, mo, d, h, mi, s;
    int n;
    if (!out || out_cap < 21) return -1;
    if (nsec < 0 || nsec >= 1000000000) return -1;
    dt_unix_to_utc(sec, &y, &mo, &d, &h, &mi, &s);
    n = snprintf((char *)out, (size_t)out_cap, "%04d-%02d-%02dT%02d:%02d:%02dZ", y, mo, d, h, mi, s);
    (void)nsec;
    if (n < 0 || n >= out_cap) return -1;
    return n;
}

/** 格式化 RFC3339Nano UTC；返回写入长度，失败 -1。 */
int datetime_format_rfc3339_nano_c(int64_t sec, int32_t nsec, uint8_t *out, int32_t out_cap) {
    int y, mo, d, h, mi, s;
    int n;
    if (!out || out_cap < 32) return -1;
    if (nsec < 0 || nsec >= 1000000000) return -1;
    dt_unix_to_utc(sec, &y, &mo, &d, &h, &mi, &s);
    n = snprintf((char *)out, (size_t)out_cap, "%04d-%02d-%02dT%02d:%02d:%02d.%09dZ", y, mo, d, h, mi, s, nsec);
    if (n < 0 || n >= out_cap) return -1;
    return n;
}

/** 本地时区相对 UTC 偏移（分钟，东为正）；平台回退。 */
int32_t datetime_local_offset_min_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    TIME_ZONE_INFORMATION tzi;
    DWORD r = GetTimeZoneInformation(&tzi);
    LONG bias = tzi.Bias;
    if (r == TIME_ZONE_ID_DAYLIGHT && tzi.DaylightBias != 0)
        bias += tzi.DaylightBias;
    return (int32_t)(-bias);
#else
    time_t t = time(NULL);
    struct tm lt, gt;
    if (t == (time_t)-1) return 0;
#if defined(_POSIX_VERSION)
    if (localtime_r(&t, &lt) == NULL || gmtime_r(&t, &gt) == NULL) return 0;
#else
    {
        struct tm *pl = localtime(&t);
        struct tm *pg = gmtime(&t);
        if (!pl || !pg) return 0;
        lt = *pl;
        gt = *pg;
    }
#endif
    {
        int lt_sec = lt.tm_hour * 3600 + lt.tm_min * 60 + lt.tm_sec;
        int gt_sec = gt.tm_hour * 3600 + gt.tm_min * 60 + gt.tm_sec;
        int day_diff = lt.tm_mday - gt.tm_mday;
        int diff_sec = lt_sec - gt_sec + day_diff * 86400;
        return (int32_t)(diff_sec / 60);
    }
#endif
}

/** UTC + 偏移分钟 → 本地日历字段。 */
void datetime_local_fields_c(int64_t sec, int32_t offset_min, int32_t *y, int32_t *mo, int32_t *d, int32_t *h, int32_t *mi, int32_t *s) {
    datetime_utc_fields_c(sec + (int64_t)offset_min * 60, y, mo, d, h, mi, s);
}

/** 两时刻差（纳秒）：b - a。 */
int64_t datetime_duration_between_ns_c(int64_t a_sec, int32_t a_nsec, int64_t b_sec, int32_t b_nsec) {
    int64_t da = a_sec * 1000000000LL + (int64_t)a_nsec;
    int64_t db = b_sec * 1000000000LL + (int64_t)b_nsec;
    return db - da;
}

/** DateTime 加 Duration（纳秒）；溢出归一化。 */
int datetime_add_duration_ns_c(int64_t sec, int32_t nsec, int64_t delta_ns, int64_t *out_sec, int32_t *out_nsec) {
    int64_t total;
    int64_t s;
    int32_t ns;
    if (!out_sec || !out_nsec) return -1;
    total = sec * 1000000000LL + (int64_t)nsec + delta_ns;
    s = total / 1000000000LL;
    ns = (int32_t)(total % 1000000000LL);
    if (ns < 0) {
        ns += 1000000000;
        s -= 1;
    }
    *out_sec = s;
    *out_nsec = ns;
    return 0;
}

/** 名称不区分大小写比较（ASCII）。 */
static int dt_name_eq_ci(const uint8_t *p, int32_t len, const char *lit) {
    size_t n = strlen(lit);
    int32_t i;
    if ((int32_t)n != len) return 0;
    for (i = 0; i < len; i++) {
        uint8_t a = p[i];
        uint8_t b = (uint8_t)lit[i];
        if (a >= (uint8_t)'A' && a <= (uint8_t)'Z') a = (uint8_t)(a + 32);
        if (b >= (uint8_t)'A' && b <= (uint8_t)'Z') b = (uint8_t)(b + 32);
        if (a != b) return 0;
    }
    return 1;
}

/**
 * 内置固定偏移时区名 → offset_min（东为正；无 DST）。
 * 支持 UTC/GMT/JST/CST/HKT/IST/CET/EST/PST 等；未知返回 -1。
 */
int datetime_timezone_from_name_c(const uint8_t *name, int32_t name_len, int32_t *out_offset_min) {
    if (!name || !out_offset_min || name_len <= 0) return -1;
    if (dt_name_eq_ci(name, name_len, "UTC") || dt_name_eq_ci(name, name_len, "GMT") ||
        dt_name_eq_ci(name, name_len, "Z"))
        { *out_offset_min = 0; return 0; }
    if (dt_name_eq_ci(name, name_len, "JST") || dt_name_eq_ci(name, name_len, "KST"))
        { *out_offset_min = 540; return 0; }
    if (dt_name_eq_ci(name, name_len, "CST") || dt_name_eq_ci(name, name_len, "HKT"))
        { *out_offset_min = 480; return 0; }
    if (dt_name_eq_ci(name, name_len, "IST"))
        { *out_offset_min = 330; return 0; }
    if (dt_name_eq_ci(name, name_len, "CET"))
        { *out_offset_min = 60; return 0; }
    if (dt_name_eq_ci(name, name_len, "EST"))
        { *out_offset_min = -300; return 0; }
    if (dt_name_eq_ci(name, name_len, "PST"))
        { *out_offset_min = -480; return 0; }
    return -1;
}

/**
 * 解析 ±HH:MM / ±HHMM / Z 或内置时区名；成功 0 并写 offset_min。
 */
int datetime_parse_offset_min_c(const uint8_t *ptr, int32_t len, int32_t *out_offset_min) {
    int pos = 0;
    int sign;
    int oh = 0;
    int om = 0;
    if (!ptr || len <= 0 || !out_offset_min) return -1;
    if (len == 1 && ptr[0] == (uint8_t)'Z') {
        *out_offset_min = 0;
        return 0;
    }
    if (ptr[0] != (uint8_t)'+' && ptr[0] != (uint8_t)'-')
        return datetime_timezone_from_name_c(ptr, len, out_offset_min);
    sign = (ptr[0] == (uint8_t)'+') ? 1 : -1;
    pos = 1;
    if (pos + 5 <= len && ptr[pos + 2] == (uint8_t)':') {
        if (dt_read_digits(ptr, len, &pos, 2, &oh) != 0) return -1;
        pos++;
        if (dt_read_digits(ptr, len, &pos, 2, &om) != 0) return -1;
    } else if (pos + 4 <= len) {
        if (dt_read_digits(ptr, len, &pos, 2, &oh) != 0) return -1;
        if (dt_read_digits(ptr, len, &pos, 2, &om) != 0) return -1;
    } else if (pos + 2 <= len) {
        if (dt_read_digits(ptr, len, &pos, 2, &oh) != 0) return -1;
    } else {
        return -1;
    }
    if (pos != len || oh > 18 || om > 59) return -1;
    *out_offset_min = sign * (oh * 60 + om);
    return 0;
}

/**
 * 时区墙钟日历字段 → UTC DateTime（sec+nsec）。
 * offset_min 为相对 UTC 的分钟偏移（东为正）。
 */
int datetime_from_zoned_fields_c(int32_t y, int32_t mo, int32_t d, int32_t h, int32_t mi, int32_t s, int32_t nsec,
                                 int32_t offset_min, int64_t *out_sec, int32_t *out_nsec) {
    int64_t local_sec;
    if (!out_sec || !out_nsec) return -1;
    if (datetime_from_utc_fields_c(y, mo, d, h, mi, s, nsec, &local_sec, out_nsec) != 0) return -1;
    *out_sec = local_sec - (int64_t)offset_min * 60;
    return 0;
}

/** STD-135：固定偏移时区名与 UTC/本地字段转换金样。 */
int datetime_timezone_smoke_c(void) {
    int32_t off = 0;
    int64_t sec = 0;
    int32_t nsec = 0;
    int32_t y = 0;
    int32_t mo = 0;
    int32_t d = 0;
    int32_t h = 0;
    int32_t mi = 0;
    int32_t s = 0;
    if (datetime_timezone_from_name_c((const uint8_t *)"JST", 3, &off) != 0 || off != 540) return 1;
    if (datetime_parse_offset_min_c((const uint8_t *)"+08:00", 6, &off) != 0 || off != 480) return 2;
    if (datetime_parse_offset_min_c((const uint8_t *)"-05:00", 6, &off) != 0 || off != -300) return 3;
    if (datetime_from_zoned_fields_c(2020, 1, 1, 12, 0, 0, 0, 480, &sec, &nsec) != 0) return 4;
    if (sec != 1577851200LL || nsec != 0) return 5;
    datetime_local_fields_c(sec, 480, &y, &mo, &d, &h, &mi, &s);
    if (y != 2020 || mo != 1 || d != 1 || h != 12 || mi != 0 || s != 0) return 6;
    if (datetime_timezone_from_name_c((const uint8_t *)"BAD", 3, &off) == 0) return 7;
    return 0;
}

/** C 烟测：RFC3339 往返 + 已知时间戳。 */
int datetime_smoke_c(void) {
    int64_t sec = 0;
    int32_t nsec = 0;
    uint8_t buf[64];
    int n;
    if (datetime_parse_rfc3339_c((const uint8_t *)"2020-01-02T03:04:05Z", 20, &sec, &nsec, NULL) != 0) return 1;
    if (sec != 1577934245LL || nsec != 0) return 2;
    n = datetime_format_rfc3339_c(sec, nsec, buf, 64);
    if (n != 20) return 3;
    if (memcmp(buf, "2020-01-02T03:04:05Z", 20) != 0) return 4;
    if (datetime_parse_rfc3339_c((const uint8_t *)"2020-01-02T03:04:05.123456789Z", 30, &sec, &nsec, NULL) != 0) return 5;
    if (sec != 1577934245LL || nsec != 123456789) return 6;
    if (datetime_add_duration_ns_c(sec, nsec, 1000000000LL, &sec, &nsec) != 0) return 7;
    if (sec != 1577934246LL) return 8;
    if (datetime_timezone_smoke_c() != 0) return 9;
    return 0;
}
