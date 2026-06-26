/**
 * time_import_alias.c — import binding `-o` 链接桩
 *
 * asm co-emit 对 `const time = import("std.time")` 生成 std_time_* 符号；
 * time.o 仅导出 time_*_c。本 TU 提供 std_time_* 实现（语义对齐 mod.sx）。
 *
 * asm `-o` ABI：Timer 栈槽为 8 字节 ShuxTimer*；只读 timer_elapsed_*(t) 用 rdi=Timer*，
 * timer_reset / timer_lap_ns 用 rdi=Timer**。
 */
#include <stdint.h>
#include <stdlib.h>

extern int64_t time_now_monotonic_ns_c(void);
extern int64_t time_now_monotonic_us_c(void);
extern int64_t time_now_monotonic_ms_c(void);
extern int64_t time_now_monotonic_sec_c(void);
extern int64_t time_now_wall_sec_c(void);
extern int64_t time_now_wall_ms_c(void);
extern int64_t time_now_wall_us_c(void);
extern int64_t time_now_wall_ns_c(void);
extern void time_sleep_ns_c(int64_t ns);
extern void time_sleep_us_c(int64_t us);
extern void time_sleep_ms_c(int32_t ms);
extern void time_sleep_sec_c(int32_t s);
extern int64_t time_duration_ns_c(int64_t from_ns, int64_t to_ns);
extern int32_t time_format_wall_rfc3339_c(uint8_t *buf, int32_t cap);
extern int32_t time_wall_local_offset_min_c(void);
extern int32_t time_format_timezone_smoke_c(void);

/** 与 mod.sx Timer 布局一致。 */
typedef struct ShuxTimer {
  int64_t start_ns;
} ShuxTimer;

/** 单调纳秒；转发 time_now_monotonic_ns_c。 */
int64_t std_time_now_monotonic_ns(void) { return time_now_monotonic_ns_c(); }

/** 单调毫秒；转发 time_now_monotonic_ms_c。 */
int64_t std_time_now_monotonic_ms(void) { return time_now_monotonic_ms_c(); }

/** 单调微秒；转发 time_now_monotonic_us_c。 */
int64_t std_time_now_monotonic_us(void) { return time_now_monotonic_us_c(); }

/** 单调秒；转发 time_now_monotonic_sec_c。 */
int64_t std_time_now_monotonic_sec(void) { return time_now_monotonic_sec_c(); }

/** 墙钟秒；转发 time_now_wall_sec_c。 */
int64_t std_time_now_wall_sec(void) { return time_now_wall_sec_c(); }

/** 墙钟毫秒；转发 time_now_wall_ms_c。 */
int64_t std_time_now_wall_ms(void) { return time_now_wall_ms_c(); }

/** 墙钟微秒；转发 time_now_wall_us_c。 */
int64_t std_time_now_wall_us(void) { return time_now_wall_us_c(); }

/** 墙钟纳秒；转发 time_now_wall_ns_c。 */
int64_t std_time_now_wall_ns(void) { return time_now_wall_ns_c(); }

/** 睡眠纳秒；转发 time_sleep_ns_c。 */
void std_time_sleep_ns(int64_t ns) { time_sleep_ns_c(ns); }

/** 睡眠微秒；转发 time_sleep_us_c。 */
void std_time_sleep_us(int64_t us) { time_sleep_us_c(us); }

/** 睡眠毫秒；转发 time_sleep_ms_c。 */
void std_time_sleep_ms(int32_t ms) { time_sleep_ms_c(ms); }

/** 睡眠秒；转发 time_sleep_sec_c。 */
void std_time_sleep_sec(int32_t s) { time_sleep_sec_c(s); }

/** 时间差纳秒；转发 time_duration_ns_c。 */
int64_t std_time_duration_ns(int64_t from_ns, int64_t to_ns) {
  return time_duration_ns_c(from_ns, to_ns);
}

/** 启动计时器；返回堆 ShuxTimer*。 */
ShuxTimer *std_time_timer_start(void) {
  ShuxTimer *t = (ShuxTimer *)calloc(1, sizeof(ShuxTimer));
  if (!t)
    return 0;
  t->start_ns = time_now_monotonic_ns_c();
  return t;
}

/** 重置计时器；rdi=ShuxTimer**。 */
void std_time_timer_reset(ShuxTimer **slot) {
  ShuxTimer *t;
  if (!slot || !*slot)
    return;
  t = *slot;
  t->start_ns = time_now_monotonic_ns_c();
}

/** 经过纳秒；rdi=ShuxTimer*。 */
int64_t std_time_timer_elapsed_ns(ShuxTimer *t) {
  if (!t)
    return 0;
  return time_now_monotonic_ns_c() - t->start_ns;
}

/** 经过微秒。 */
int64_t std_time_timer_elapsed_us(ShuxTimer *t) { return std_time_timer_elapsed_ns(t) / 1000; }

/** 经过毫秒。 */
int64_t std_time_timer_elapsed_ms(ShuxTimer *t) { return std_time_timer_elapsed_ns(t) / 1000000; }

/** 经过秒。 */
int64_t std_time_timer_elapsed_sec(ShuxTimer *t) { return std_time_timer_elapsed_ns(t) / 1000000000; }

/** lap 并更新起点；rdi=ShuxTimer**。 */
int64_t std_time_timer_lap_ns(ShuxTimer **slot) {
  ShuxTimer *t;
  int64_t now;
  int64_t lap;
  if (!slot || !*slot)
    return 0;
  t = *slot;
  now = time_now_monotonic_ns_c();
  lap = now - t->start_ns;
  t->start_ns = now;
  return lap;
}

/** RFC3339 格式化；转发 time_format_wall_rfc3339_c。 */
int32_t std_time_format_wall_rfc3339(uint8_t *buf, int32_t cap) {
  return time_format_wall_rfc3339_c(buf, cap);
}

/** 本地时区偏移（分钟）；转发 time_wall_local_offset_min_c。 */
int32_t std_time_wall_local_offset_min(void) { return time_wall_local_offset_min_c(); }

/** 时区烟测；转发 time_format_timezone_smoke_c。 */
int32_t std_time_format_timezone_smoke(void) { return time_format_timezone_smoke_c(); }
