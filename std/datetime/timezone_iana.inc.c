/**
 * std/datetime/timezone_iana.inc.c — IANA 时区 + DST 规则（STD-136 / #80）
 *
 * 【文件职责】内置常见 IANA 时区名；按 Unix 秒计算含夏令时的 UTC 偏移（分钟，东为正）。
 * 美国区用 2007+ 规则；欧洲用 1996+ 末周日 UTC 切换；无 DST 区固定偏移。
 * 由 datetime.c 末尾 #include；依赖 dt_utc_to_unix / dt_unix_to_utc / dt_days_in_month。
 */

#include <stdint.h>
#include <string.h>

extern int dt_is_leap(int y);
extern int dt_days_in_month(int y, int mo);
extern int64_t dt_utc_to_unix(int y, int mo, int d, int h, int mi, int s);
extern void dt_unix_to_utc(int64_t sec, int *y, int *mo, int *d, int *h, int *mi, int *s);
extern void datetime_local_fields_c(int64_t sec, int32_t offset_min, int32_t *y, int32_t *mo, int32_t *d,
                                    int32_t *h, int32_t *mi, int32_t *s);

/** IANA 时区种类。 */
typedef enum {
    DT_IANA_UTC = 0,
    DT_IANA_US_EASTERN,
    DT_IANA_US_PACIFIC,
    DT_IANA_EU_LONDON,
    DT_IANA_EU_PARIS,
    DT_IANA_ASIA_TOKYO,
    DT_IANA_ASIA_SHANGHAI,
    DT_IANA_COUNT
} dt_iana_kind_t;

/** 单条 IANA 时区元数据。 */
typedef struct {
    const char *name;
    int32_t std_off_min;
    int32_t dst_off_min;
    dt_iana_kind_t kind;
} dt_iana_zone_t;

static const dt_iana_zone_t dt_iana_zones[] = {
    { "UTC", 0, 0, DT_IANA_UTC },
    { "America/New_York", -300, -240, DT_IANA_US_EASTERN },
    { "America/Los_Angeles", -480, -420, DT_IANA_US_PACIFIC },
    { "Europe/London", 0, 60, DT_IANA_EU_LONDON },
    { "Europe/Paris", 60, 120, DT_IANA_EU_PARIS },
    { "Asia/Tokyo", 540, 540, DT_IANA_ASIA_TOKYO },
    { "Asia/Shanghai", 480, 480, DT_IANA_ASIA_SHANGHAI },
};

/** 星期（0=周日）由 UTC 日历日推算。 */
static int dt_dow_utc(int y, int mo, int d) {
    int64_t sec = dt_utc_to_unix(y, mo, d, 12, 0, 0);
    int64_t days = sec / 86400;
    int dow = (int)((days + 4) % 7);
    if (dow < 0)
        dow += 7;
    return dow;
}

/** 月内第 n 个星期几（n=1 首个 …）；weekday 0=周日。 */
static int dt_nth_weekday(int y, int mo, int n, int weekday) {
    int dow1 = dt_dow_utc(y, mo, 1);
    int day = 1 + (weekday - dow1 + 7) % 7 + (n - 1) * 7;
    return day;
}

/** 月内最后一个星期几。 */
static int dt_last_weekday(int y, int mo, int weekday) {
    int dim = dt_days_in_month(y, mo);
    int dow_last = dt_dow_utc(y, mo, dim);
    return dim - (dow_last - weekday + 7) % 7;
}

/** 美国 DST：3 月第 2 个周日 02:00 标准时 → UTC。 */
static int64_t dt_us_dst_start_utc(int year, int32_t std_off_min) {
    int day = dt_nth_weekday(year, 3, 2, 0);
    int64_t wall = dt_utc_to_unix(year, 3, day, 2, 0, 0);
    return wall - (int64_t)std_off_min * 60;
}

/** 美国 DST：11 月第 1 个周日 02:00 夏令时 → UTC。 */
static int64_t dt_us_dst_end_utc(int year, int32_t dst_off_min) {
    int day = dt_nth_weekday(year, 11, 1, 0);
    int64_t wall = dt_utc_to_unix(year, 11, day, 2, 0, 0);
    return wall - (int64_t)dst_off_min * 60;
}

/** 欧洲 DST：3 月最后一个周日 01:00 UTC。 */
static int64_t dt_eu_dst_start_utc(int year) {
    int day = dt_last_weekday(year, 3, 0);
    return dt_utc_to_unix(year, 3, day, 1, 0, 0);
}

/** 欧洲 DST：10 月最后一个周日 01:00 UTC。 */
static int64_t dt_eu_dst_end_utc(int year) {
    int day = dt_last_weekday(year, 10, 0);
    return dt_utc_to_unix(year, 10, day, 1, 0, 0);
}

/** 由 UTC 秒取日历年（近似：用 UTC 字段）。 */
static int dt_year_from_utc_sec(int64_t sec) {
    int y = 0, mo = 0, d = 0, h = 0, mi = 0, s = 0;
    dt_unix_to_utc(sec, &y, &mo, &d, &h, &mi, &s);
    return y;
}

/** 按 IANA 种类与 UTC 秒计算偏移（分钟，东为正）。 */
static int32_t dt_iana_offset_for_kind(const dt_iana_zone_t *z, int64_t sec) {
    int year;
    int64_t start;
    int64_t end;

    if (!z)
        return 0;
    switch (z->kind) {
    case DT_IANA_UTC:
        return 0;
    case DT_IANA_ASIA_TOKYO:
    case DT_IANA_ASIA_SHANGHAI:
        return z->std_off_min;
    case DT_IANA_US_EASTERN:
    case DT_IANA_US_PACIFIC:
        year = dt_year_from_utc_sec(sec);
        start = dt_us_dst_start_utc(year, z->std_off_min);
        end = dt_us_dst_end_utc(year, z->dst_off_min);
        if (sec >= start && sec < end)
            return z->dst_off_min;
        return z->std_off_min;
    case DT_IANA_EU_LONDON:
    case DT_IANA_EU_PARIS:
        year = dt_year_from_utc_sec(sec);
        start = dt_eu_dst_start_utc(year);
        end = dt_eu_dst_end_utc(year);
        if (sec >= start && sec < end)
            return z->dst_off_min;
        return z->std_off_min;
    default:
        return z->std_off_min;
    }
}

/** 名称精确匹配 IANA 表；成功返回 zone id（>=0），失败 -1。 */
int32_t datetime_iana_from_name_c(const uint8_t *name, int32_t name_len) {
    int32_t i;
    if (!name || name_len <= 0)
        return -1;
    for (i = 0; i < (int32_t)(sizeof(dt_iana_zones) / sizeof(dt_iana_zones[0])); i++) {
        size_t n = strlen(dt_iana_zones[i].name);
        if ((int32_t)n == name_len && memcmp(name, dt_iana_zones[i].name, (size_t)name_len) == 0)
            return i;
    }
    return -1;
}

/** 按 IANA zone id 与 UTC 秒取偏移（含 DST）；非法 id 返回 0。 */
int32_t datetime_iana_offset_at_c(int32_t iana_id, int64_t sec) {
    if (iana_id < 0 || iana_id >= (int32_t)(sizeof(dt_iana_zones) / sizeof(dt_iana_zones[0])))
        return 0;
    return dt_iana_offset_for_kind(&dt_iana_zones[iana_id], sec);
}

/**
 * IANA 墙钟字段 → UTC（一次 refinement 处理 DST 边界）。
 */
int datetime_from_iana_zoned_fields_c(int32_t iana_id, int32_t y, int32_t mo, int32_t d, int32_t h, int32_t mi,
                                      int32_t s, int32_t nsec, int64_t *out_sec, int32_t *out_nsec) {
    const dt_iana_zone_t *z;
    int64_t naive;
    int32_t off;
    if (iana_id < 0 || iana_id >= (int32_t)(sizeof(dt_iana_zones) / sizeof(dt_iana_zones[0])) || !out_sec ||
        !out_nsec)
        return -1;
    if (nsec < 0 || nsec >= 1000000000)
        return -1;
    z = &dt_iana_zones[iana_id];
    naive = dt_utc_to_unix(y, mo, d, h, mi, s);
    off = dt_iana_offset_for_kind(z, naive - (int64_t)z->std_off_min * 60);
    *out_sec = naive - (int64_t)off * 60;
    *out_nsec = nsec;
    off = dt_iana_offset_for_kind(z, *out_sec);
    *out_sec = naive - (int64_t)off * 60;
    return 0;
}

/** IANA DST 烟测：纽约冬/夏偏移 + 伦敦 BST；0 通过。 */
int32_t datetime_iana_dst_smoke_c(void) {
    int32_t id;
    int32_t off;
    int32_t y, mo, d, h, mi, s;
    /* 2024-01-15 12:00 UTC — 纽约 EST (-300) */
    const int64_t winter = 1705320000LL;
    /* 2024-07-15 12:00 UTC — 纽约 EDT (-240) */
    const int64_t summer = 1721044800LL;

    id = datetime_iana_from_name_c((const uint8_t *)"America/New_York", 16);
    if (id < 0)
        return 1;
    off = datetime_iana_offset_at_c(id, winter);
    if (off != -300)
        return 2;
    off = datetime_iana_offset_at_c(id, summer);
    if (off != -240)
        return 3;
    datetime_local_fields_c(winter, -300, &y, &mo, &d, &h, &mi, &s);
    if (h != 7)
        return 4;
    datetime_local_fields_c(summer, off, &y, &mo, &d, &h, &mi, &s);
    if (h != 8)
        return 5;

    id = datetime_iana_from_name_c((const uint8_t *)"Europe/London", 13);
    if (id < 0)
        return 6;
    off = datetime_iana_offset_at_c(id, winter);
    if (off != 0)
        return 7;
    off = datetime_iana_offset_at_c(id, summer);
    if (off != 60)
        return 8;
    datetime_local_fields_c(summer, off, &y, &mo, &d, &h, &mi, &s);
    if (h != 13)
        return 9;

    if (datetime_iana_from_name_c((const uint8_t *)"Asia/Tokyo", 10) < 0)
        return 10;
    if (datetime_iana_offset_at_c(datetime_iana_from_name_c((const uint8_t *)"Asia/Tokyo", 10), summer) != 540)
        return 11;
    return 0;
}
