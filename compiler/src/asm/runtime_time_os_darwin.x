// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_time_os_darwin.x — Darwin arm64 whole body of runtime_time_os.o.
//
// The cold ensure path pure-asms this file and does not pass the C seed to
// host cc. Linux and Windows still compile seeds/runtime_time_os.from_x.c.
// That seed calls the static inline helpers in include/xlang_time_cap.h
// (Linux raw syscalls, Windows Win32). Those helpers are not linkable
// symbols, so this object cannot call them.
//
// src/asm/runtime_time_os.x stays the shared thin: it forwards to the C
// _impl bridges. Compiling that thin still leaves the C rest on host cc.
// Darwin does not compile that thin. This file is the only Darwin body.
//
// Darwin product clocks are libSystem clock_gettime and nanosleep.
// CLOCK_REALTIME is 0. CLOCK_MONOTONIC is 6. An interrupted nanosleep is
// not retried: reading errno would leave __error undefined, and the pure-asm
// install rejects that symbol. RFC3339 is Howard Hinnant's civil calendar
// (the same math as xlang_time_gmtime_r) written as digits, not snprintf.
// The local offset is struct tm.tm_gmtoff / 60. On Darwin arm64 that long
// is the sixth i64 of a 56-byte tm (byte 40). It matches the C seed's
// mktime difference when tm_isdst is 0.
// Each function's frame must cover its slots. A slot past the frame stores
// through the caller's saved return address.
//
// Public names stay strong. The C _impl bridges are not emitted. Nothing
// outside this TU references them. This object is a user / STD_AND_PANIC
// companion. It is not in the g05 compiler image. A missing object after a
// pure-asm fault falls back to the C seed, which still uses the raw syscall.
//
// PLATFORM: MACOS|DARWIN arm64.

/**
 * Two i64 words, matching Darwin arm64 struct timespec.
 * tv_sec at offset 0, tv_nsec at offset 8. Both are 8-byte longs.
 * PLATFORM: MACOS|DARWIN arm64.
 */
struct TimeOsSpec {
  sec: i64;
  nsec: i64;
}

/**
 * libSystem clock_gettime. clk 0 is CLOCK_REALTIME. clk 6 is CLOCK_MONOTONIC.
 * @param clk i32 — Darwin clock id
 * @param ts *i64 — first word of a TimeOsSpec; the call writes both words
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN — libSystem, not the raw syscall in xlang_time_cap.h
 */
export extern "C" function clock_gettime(clk: i32, ts: *i64): i32;

/**
 * libSystem nanosleep. rem may be null. EINTR is not observed here.
 * @param req *i64 — first word of the requested TimeOsSpec
 * @param rem *i64 — first word of the remainder TimeOsSpec; may be null
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function nanosleep(req: *i64, rem: *i64): i32;

/**
 * libSystem localtime_r. Fills a Darwin struct tm (56 bytes, seven i64 words).
 * @param clock *i64 — Unix seconds
 * @param out *i64 — first of seven i64 words; gmtoff is word 5
 * @return *i64 — out on success, null on failure
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function localtime_r(clock: *i64, out: *i64): *i64;

/**
 * Read path helper for codegen discovery.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function runtime_time_os_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Write two decimal digits of n at buf[off]. n is 0 through 99.
 * @param buf *u8 — destination; caller owns; must hold off+2 bytes
 * @param off i32 — start index
 * @param n i32 — value; only the last two digits are written
 * PLATFORM: MACOS|DARWIN
 */
function time_os_put_2(buf: *u8, off: i32, n: i32): void {
  let q: i32 = n / 10;
  let r: i32 = n - q * 10;
  buf[off] = (48 + q) as u8;
  buf[off + 1] = (48 + r) as u8;
}

/**
 * Write four decimal digits of n at buf[off]. n is 0 through 9999.
 * @param buf *u8 — destination; caller owns; must hold off+4 bytes
 * @param off i32 — start index
 * @param n i32 — year or other four-digit value
 * PLATFORM: MACOS|DARWIN
 */
function time_os_put_4(buf: *u8, off: i32, n: i32): void {
  let a: i32 = n / 1000;
  let b: i32 = (n / 100) - a * 10;
  let c: i32 = (n / 10) - (n / 100) * 10;
  let d: i32 = n - (n / 10) * 10;
  buf[off] = (48 + a) as u8;
  buf[off + 1] = (48 + b) as u8;
  buf[off + 2] = (48 + c) as u8;
  buf[off + 3] = (48 + d) as u8;
}

/**
 * Double v with a 64-bit left shift.
 * In a loop, `b << 1` is dropped and a later load reads an empty slot.
 * A call keeps the shift in its own frame, and the caller stores the result.
 * @param v i64 — non-negative value
 * @return i64 — v * 2
 * PLATFORM: MACOS|DARWIN
 */
function time_os_shl1(v: i64): i64 {
  let s: i64 = v << 1;
  return s;
}

/**
 * Multiply a non-negative value by a non-negative factor that fits in 32 bits.
 * The product compiler lowers i64 times a small constant as a 32-bit mul,
 * so unix seconds times 1000000000 wrap. i64 addition is a 64-bit add, and
 * i64 division by a small constant is a 64-bit sdiv. This doubles the
 * multiplicand and adds it for each set bit of the factor.
 * @param value i64 — non-negative multiplicand; widened by doubling
 * @param factor i64 — non-negative; must fit in a signed 32-bit word
 * @return i64 — value * factor
 * PLATFORM: MACOS|DARWIN — avoids the 32-bit mul lowering
 */
function time_os_mul(value: i64, factor: i64): i64 {
  let b: i64 = value;
  let k: i64 = factor;
  let acc: i64 = 0;
  while (k != 0) {
    if (k % 2 != 0) {
      let acc_now: i64 = acc;
      let addend: i64 = b;
      acc = acc_now + addend;
    }
    b = time_os_shl1(b);
    k = k / 2;
  }
  return acc;
}

/**
 * Read a Darwin clock. Returns 0 on failure, else sec*1e9+nsec.
 * @param clk i32 — 0 realtime, 6 monotonic
 * @return i64 — nanoseconds, or 0 when clock_gettime fails
 * PLATFORM: MACOS|DARWIN
 */
function time_os_read_ns(clk: i32): i64 {
  let ts: TimeOsSpec = { sec: 0, nsec: 0 };
  let rc: i32 = 0;
  unsafe {
    rc = clock_gettime(clk, &ts.sec);
  }
  if (rc != 0) {
    return 0;
  }
  return time_os_mul(ts.sec, 1000000000) + ts.nsec;
}

/**
 * Monotonic clock in nanoseconds.
 * @return i64 — nanoseconds; 0 when libSystem clock_gettime fails
 * PLATFORM: MACOS|DARWIN — CLOCK_MONOTONIC is 6
 */
#[no_mangle]
export function time_now_monotonic_ns_c(): i64 {
  return time_os_read_ns(6);
}

/**
 * UTC wall clock in nanoseconds since the Unix epoch.
 * @return i64 — nanoseconds; 0 when libSystem clock_gettime fails
 * PLATFORM: MACOS|DARWIN — CLOCK_REALTIME is 0
 */
#[no_mangle]
export function time_now_wall_ns_c(): i64 {
  return time_os_read_ns(0);
}

/**
 * Sleep for one timespec. Kept separate so its frame covers every slot.
 * The product compiler's frame is short of the last locals in a larger body,
 * and that store lands on the caller's saved return address.
 * @param sec i64 — whole seconds; non-negative
 * @param nsec i64 — leftover nanoseconds; 0 through 999999999
 * PLATFORM: MACOS|DARWIN
 */
function time_os_nanosleep(sec: i64, nsec: i64): void {
  let req: TimeOsSpec = { sec: 0, nsec: 0 };
  req.sec = sec;
  req.nsec = nsec;
  unsafe {
    nanosleep(&req.sec, 0);
  }
}

/**
 * Sleep for ns nanoseconds. ns <= 0 returns without a call.
 * One nanosleep. An interrupted sleep is not resumed.
 * @param ns i64 — duration in nanoseconds; non-positive is a no-op
 * PLATFORM: MACOS|DARWIN — libSystem nanosleep, no __error retry
 */
#[no_mangle]
export function time_sleep_ns_c(ns: i64): void {
  if (ns <= 0) {
    return;
  }
  let sec: i64 = ns / 1000000000;
  let nsec: i64 = ns - time_os_mul(sec, 1000000000);
  time_os_nanosleep(sec, nsec);
}

/**
 * Whole days since the Unix epoch. A negative time-of-day borrows one day.
 * @param sec i64 — Unix seconds
 * @return i64 — day count
 * PLATFORM: MACOS|DARWIN
 */
function time_os_days(sec: i64): i64 {
  let days: i64 = sec / 86400;
  let tod: i64 = sec - time_os_mul(days, 86400);
  if (tod < 0) {
    days = days - 1;
  }
  return days;
}

/**
 * Seconds since midnight, UTC. A negative remainder is folded into the day.
 * @param sec i64 — Unix seconds
 * @return i64 — 0 through 86399
 * PLATFORM: MACOS|DARWIN
 */
function time_os_tod(sec: i64): i64 {
  let days: i64 = sec / 86400;
  let tod: i64 = sec - time_os_mul(days, 86400);
  if (tod < 0) {
    tod = tod + 86400;
  }
  return tod;
}

/**
 * Month*100+day from the Hinnant day-of-year. Month and day are 1-based.
 * @param doy i64 — day of year in the Hinnant cycle
 * @return i64 — month*100+day
 * PLATFORM: MACOS|DARWIN
 */
function time_os_month_day(doy: i64): i64 {
  let mp: i64 = (time_os_mul(doy, 5) + 2) / 153;
  let d: i64 = doy - (time_os_mul(mp, 153) + 2) / 5 + 1;
  let m: i64 = mp + 3;
  if (mp >= 10) {
    m = mp - 9;
  }
  return time_os_mul(m, 100) + d;
}

/**
 * Finish civil_from_days from the day-of-era and the era.
 * @param doe i64 — day of era
 * @param era i64 — 400-year era index
 * @return i64 — packed year*10000+month*100+day
 * PLATFORM: MACOS|DARWIN
 */
function time_os_ymd_tail(doe: i64, era: i64): i64 {
  let yoe: i64 = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
  let yy: i64 = yoe + time_os_mul(era, 400);
  let doy: i64 = doe - (time_os_mul(yoe, 365) + yoe / 4 - yoe / 100);
  let md: i64 = time_os_month_day(doy);
  let y: i64 = yy;
  if (md / 100 <= 2) {
    y = yy + 1;
  }
  return time_os_mul(y, 10000) + md;
}

/**
 * Howard Hinnant civil_from_days, packed as year*10000+month*100+day.
 * Month and day are 1-based. Same calendar as xlang_time_gmtime_r.
 * @param days i64 — days since the Unix epoch
 * @return i64 — packed year, month, day
 * PLATFORM: MACOS|DARWIN
 */
function time_os_ymd(days: i64): i64 {
  let z: i64 = days + 719468;
  let era: i64 = 0;
  if (z >= 0) {
    era = z / 146097;
  } else {
    era = (z - 146096) / 146097;
  }
  let doe: i64 = z - time_os_mul(era, 146097);
  return time_os_ymd_tail(doe, era);
}

/**
 * Pack hour*10000+minute*100+second from a time-of-day.
 * @param tod i64 — seconds since midnight
 * @return i64 — packed hour, minute, second
 * PLATFORM: MACOS|DARWIN
 */
function time_os_hms(tod: i64): i64 {
  let hour: i64 = tod / 3600;
  let min: i64 = (tod - time_os_mul(hour, 3600)) / 60;
  let second: i64 = tod - time_os_mul(tod / 60, 60);
  return time_os_mul(hour, 10000) + time_os_mul(min, 100) + second;
}

/**
 * Write YYYY-MM-DD from a packed year*10000+month*100+day.
 * @param buf *u8 — destination; caller owns; must hold 10 bytes at the start
 * @param ymd i64 — packed civil date
 * PLATFORM: MACOS|DARWIN
 */
function time_os_put_ymd(buf: *u8, ymd: i64): void {
  let y: i32 = (ymd / 10000) as i32;
  let m: i32 = ((ymd / 100) - time_os_mul(ymd / 10000, 100)) as i32;
  let d: i32 = (ymd - time_os_mul(ymd / 100, 100)) as i32;
  time_os_put_4(buf, 0, y);
  buf[4] = 45 as u8;
  time_os_put_2(buf, 5, m);
  buf[7] = 45 as u8;
  time_os_put_2(buf, 8, d);
}

/**
 * Write HH:MM:SS at buf[11] from a packed hour*10000+minute*100+second.
 * @param buf *u8 — destination; caller owns; must hold 19 bytes
 * @param hms i64 — packed time of day
 * PLATFORM: MACOS|DARWIN
 */
function time_os_put_hms(buf: *u8, hms: i64): void {
  let hour: i32 = (hms / 10000) as i32;
  let minute: i32 = ((hms / 100) - time_os_mul(hms / 10000, 100)) as i32;
  let second: i32 = (hms - time_os_mul(hms / 100, 100)) as i32;
  time_os_put_2(buf, 11, hour);
  buf[13] = 58 as u8;
  time_os_put_2(buf, 14, minute);
  buf[16] = 58 as u8;
  time_os_put_2(buf, 17, second);
}

/**
 * Format the current UTC wall clock as RFC3339 with a trailing Z.
 * Needs 21 bytes: 20 characters plus a NUL. A null buffer or a smaller
 * cap returns -1. The calendar is Howard Hinnant civil_from_days, matching
 * xlang_time_gmtime_r. Digits are written here; snprintf is not called.
 * @param buf *u8 — destination; null is rejected
 * @param cap i32 — capacity in bytes; must be greater than 20
 * @return i32 — 20 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function time_format_wall_rfc3339_c(buf: *u8, cap: i32): i32 {
  if (buf == 0 || cap <= 20) {
    return -1;
  }
  let ns: i64 = time_os_read_ns(0);
  if (ns <= 0) {
    return -1;
  }
  let sec: i64 = ns / 1000000000;
  time_os_put_ymd(buf, time_os_ymd(time_os_days(sec)));
  buf[10] = 84 as u8;
  time_os_put_hms(buf, time_os_hms(time_os_tod(sec)));
  buf[19] = 90 as u8;
  buf[20] = 0 as u8;
  return 20;
}

/**
 * Darwin tm_gmtoff for one Unix second. The seven i64 words are the
 * 56-byte arm64 struct tm. localtime_r fills them.
 * @param sec i64 — Unix seconds
 * @return i64 — seconds east of UTC; 0 when localtime_r fails
 * PLATFORM: MACOS|DARWIN
 */
function time_os_gmtoff(sec: i64): i64 {
  let raw: i64[7];
  raw[0] = 0;
  raw[1] = 0;
  raw[2] = 0;
  raw[3] = 0;
  raw[4] = 0;
  raw[5] = 0;
  raw[6] = 0;
  let got: *i64 = 0;
  unsafe {
    got = localtime_r(&sec, &raw[0]);
  }
  if (got == 0) {
    return 0;
  }
  return raw[5];
}

/**
 * Local timezone offset from UTC in minutes, east positive.
 * @return i32 — minutes; 0 when the clock or localtime_r fails
 * PLATFORM: MACOS|DARWIN — tm_gmtoff divided by 60
 */
#[no_mangle]
export function time_wall_local_offset_min_c(): i32 {
  let ns: i64 = time_os_read_ns(0);
  if (ns <= 0) {
    return 0;
  }
  let sec: i64 = ns / 1000000000;
  return (time_os_gmtoff(sec) / 60) as i32;
}
