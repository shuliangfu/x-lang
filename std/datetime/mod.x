// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Full text: LICENSE.Apache-2.0

// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.

const time = import("std.time");

/* See implementation. */
allow(padding) struct DateTime {
  sec: i64;
  nsec: i32;
}

/* See implementation. */
allow(padding) struct Duration {
  ns: i64;
}

/* See implementation. */
allow(padding) struct DateFields {
  year: i32;
  month: i32;
  day: i32;
  hour: i32;
  minute: i32;
  second: i32;
  nsec: i32;
}

extern function datetime_now_utc_c(out_sec: *i64, out_nsec: *i32): void;
extern function datetime_utc_fields_c(sec: i64, y: *i32, mo: *i32, d: *i32, h: *i32, mi: *i32, s: *i32): void;
extern function datetime_from_utc_fields_c(y: i32, mo: i32, d: i32, h: i32, mi: i32, s: i32, nsec: i32, out_sec: *i64, out_nsec: *i32): i32;
extern function datetime_compare_c(a_sec: i64, a_nsec: i32, b_sec: i64, b_nsec: i32): i32;
extern function datetime_parse_rfc3339_c(ptr: *u8, len: i32, out_sec: *i64, out_nsec: *i32, out_offset_min: *i32): i32;
extern function datetime_format_rfc3339_c(sec: i64, nsec: i32, out: *u8, out_cap: i32): i32;
extern function datetime_format_rfc3339_nano_c(sec: i64, nsec: i32, out: *u8, out_cap: i32): i32;
extern function datetime_local_offset_min_c(): i32;
extern function datetime_local_fields_c(sec: i64, offset_min: i32, y: *i32, mo: *i32, d: *i32, h: *i32, mi: *i32, s: *i32): void;
extern function datetime_duration_between_ns_c(a_sec: i64, a_nsec: i32, b_sec: i64, b_nsec: i32): i64;
extern function datetime_add_duration_ns_c(sec: i64, nsec: i32, delta_ns: i64, out_sec: *i64, out_nsec: *i32): i32;
extern function datetime_timezone_from_name_c(name: *u8, name_len: i32, out_offset_min: *i32): i32;
extern function datetime_parse_offset_min_c(ptr: *u8, len: i32, out_offset_min: *i32): i32;
extern function datetime_from_zoned_fields_c(y: i32, mo: i32, d: i32, h: i32, mi: i32, s: i32, nsec: i32,
  offset_min: i32, out_sec: *i64, out_nsec: *i32): i32;
extern function datetime_iana_from_name_c(name: *u8, name_len: i32): i32;
extern function datetime_iana_offset_at_c(iana_id: i32, sec: i64): i32;
extern function datetime_from_iana_zoned_fields_c(iana_id: i32, y: i32, mo: i32, d: i32, h: i32, mi: i32, s: i32,
  nsec: i32, out_sec: *i64, out_nsec: *i32): i32;
extern function datetime_iana_dst_smoke_c(): i32;
extern function datetime_timezone_smoke_c(): i32;

/** Exported function `now_utc`.
 * Implements `now_utc`.
 * @return DateTime
 */
export function now_utc(): DateTime {
  let sec: i64 = 0;
  let nsec: i32 = 0;
  unsafe {
    datetime_now_utc_c(&sec, &nsec);
  }
  return DateTime { sec: sec, nsec: nsec };
}

/** Exported function `from_unix`.
 * Implements `from_unix`.
 * @param sec i64
 * @param nsec i32
 * @return DateTime
 */
export function from_unix(sec: i64, nsec: i32): DateTime {
  return DateTime { sec: sec, nsec: nsec };
}

/** Exported function `from_utc_fields`.
 * Implements `from_utc_fields`.
 * @param f DateFields
 * @return DateTime
 */
export function from_utc_fields(f: DateFields): DateTime {
  let sec: i64 = 0;
  let nsec: i32 = 0;
  unsafe {
    if (datetime_from_utc_fields_c(f.year, f.month, f.day, f.hour, f.minute, f.second, f.nsec, &sec, &nsec) != 0) {
      return DateTime { sec: -1, nsec: 0 };
    }
  }
  return DateTime { sec: sec, nsec: nsec };
}

/** Exported function `to_utc_fields`.
 * Implements `to_utc_fields`.
 * @param t DateTime
 * @return DateFields
 */
export function to_utc_fields(t: DateTime): DateFields {
  let y: i32 = 0;
  let mo: i32 = 0;
  let d: i32 = 0;
  let h: i32 = 0;
  let mi: i32 = 0;
  let s: i32 = 0;
  unsafe {
    datetime_utc_fields_c(t.sec, &y, &mo, &d, &h, &mi, &s);
  }
  return DateFields { year: y, month: mo, day: d, hour: h, minute: mi, second: s, nsec: t.nsec };
}

/** Exported function `compare`.
 * Implements `compare`.
 * @param a DateTime
 * @param b DateTime
 * @return i32
 */
export function compare(a: DateTime, b: DateTime): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = datetime_compare_c(a.sec, a.nsec, b.sec, b.nsec); }
  return _rc;
}

/** Exported function `parse_rfc3339`.
 * Implements `parse_rfc3339`.
 * @param ptr *u8
 * @param len i32
 * @param out *DateTime
 * @param offset_min *i32
 * @return i32
 */
export function parse_rfc3339(ptr: *u8, len: i32, out: *DateTime, offset_min: *i32): i32 {
  let sec: i64 = 0;
  let nsec: i32 = 0;
  unsafe {
    if (datetime_parse_rfc3339_c(ptr, len, &sec, &nsec, offset_min) != 0) {
      return -1;
    }
    out.sec = sec;
    out.nsec = nsec;
  }
  return 0;
}

/** Exported function `format_rfc3339`.
 * Implements `format_rfc3339`.
 * @param t DateTime
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function format_rfc3339(t: DateTime, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = datetime_format_rfc3339_c(t.sec, t.nsec, out, out_cap); }
  return _rc;
}

/** Exported function `format_rfc3339_nano`.
 * Implements `format_rfc3339_nano`.
 * @param t DateTime
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function format_rfc3339_nano(t: DateTime, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = datetime_format_rfc3339_nano_c(t.sec, t.nsec, out, out_cap); }
  return _rc;
}

/** Exported function `local_offset_min`.
 * Implements `local_offset_min`.
 * @return i32
 */
export function local_offset_min(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = datetime_local_offset_min_c(); }
  return _rc;
}

/** Exported function `to_local_fields`.
 * Implements `to_local_fields`.
 * @param t DateTime
 * @param offset_min i32
 * @return DateFields
 */
export function to_local_fields(t: DateTime, offset_min: i32): DateFields {
  let y: i32 = 0;
  let mo: i32 = 0;
  let d: i32 = 0;
  let h: i32 = 0;
  let mi: i32 = 0;
  let s: i32 = 0;
  unsafe {
    datetime_local_fields_c(t.sec, offset_min, &y, &mo, &d, &h, &mi, &s);
  }
  return DateFields { year: y, month: mo, day: d, hour: h, minute: mi, second: s, nsec: t.nsec };
}

/** Exported function `duration_from_ns`.
 * Implements `duration_from_ns`.
 * @param ns i64
 * @return Duration
 */
export function duration_from_ns(ns: i64): Duration {
  return Duration { ns: ns };
}

/** Exported function `duration_from_sec`.
 * Implements `duration_from_sec`.
 * @param s i64
 * @return Duration
 */
export function duration_from_sec(s: i64): Duration {
  return Duration { ns: s * 1000000000 };
}

/** Exported function `duration_between`.
 * Implements `duration_between`.
 * @param a DateTime
 * @param b DateTime
 * @return Duration
 */
export function duration_between(a: DateTime, b: DateTime): Duration {
  let ns: i64 = 0;
  unsafe {
    ns = datetime_duration_between_ns_c(a.sec, a.nsec, b.sec, b.nsec);
  }
  return Duration { ns: ns };
}

/** Exported function `add_duration`.
 * Implements `add_duration`.
 * @param t DateTime
 * @param d Duration
 * @return DateTime
 */
export function add_duration(t: DateTime, d: Duration): DateTime {
  let sec: i64 = 0;
  let nsec: i32 = 0;
  unsafe {
    if (datetime_add_duration_ns_c(t.sec, t.nsec, d.ns, &sec, &nsec) != 0) {
      return DateTime { sec: -1, nsec: 0 };
    }
  }
  return DateTime { sec: sec, nsec: nsec };
}

/** Exported function `duration_sleep`.
 * Implements `duration_sleep`.
 * @param d Duration
 * @return void
 */
export function duration_sleep(d: Duration): void {
  time.sleep_ns(d.ns);
}

/** Exported function `duration_from_monotonic`.
 * Implements `duration_from_monotonic`.
 * @param from_ns i64
 * @param to_ns i64
 * @return Duration
 */
export function duration_from_monotonic(from_ns: i64, to_ns: i64): Duration {
  return Duration { ns: time.duration_ns(from_ns, to_ns) };
}

// See implementation.

/* See implementation. */
allow(padding) struct TimeZone {
  offset_min: i32;
  iana_id: i32;
}

/** Exported function `timezone_utc`.
 * Implements `timezone_utc`.
 * @return TimeZone
 */
export function timezone_utc(): TimeZone {
  return TimeZone { offset_min: 0, iana_id: 0 };
}

/** Exported function `timezone_local`.
 * Implements `timezone_local`.
 * @return TimeZone
 */
export function timezone_local(): TimeZone {
  return TimeZone { offset_min: local_offset_min(), iana_id: -1 };
}

/** Exported function `timezone_fixed`.
 * Implements `timezone_fixed`.
 * @param offset_min i32
 * @return TimeZone
 */
export function timezone_fixed(offset_min: i32): TimeZone {
  return TimeZone { offset_min: offset_min, iana_id: -1 };
}

/**
 * See implementation.
 * See implementation.
 */
export function timezone_from_name(name: *u8, name_len: i32, out: *TimeZone): i32 {
  let off: i32 = 0;
  unsafe {
    if (datetime_timezone_from_name_c(name, name_len, &off) != 0) {
      return -1;
    }
    out.offset_min = off;
    out.iana_id = -1;
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function timezone_iana(name: *u8, name_len: i32, out: *TimeZone): i32 {
  let id: i32 = 0;
  unsafe {
    id = datetime_iana_from_name_c(name, name_len);
    if (id < 0) {
      return -1;
    }
    out.iana_id = id;
    out.offset_min = 0;
  }
  return 0;
}

/** Exported function `timezone_offset_at`.
 * Implements `timezone_offset_at`.
 * @param t DateTime
 * @param tz TimeZone
 * @return i32
 */
export function timezone_offset_at(t: DateTime, tz: TimeZone): i32 {
  if (tz.iana_id >= 0) {
    unsafe {
      return datetime_iana_offset_at_c(tz.iana_id, t.sec);
    }
  }
  return tz.offset_min;
}

/** Exported function `parse_offset_min`.
 * Implements `parse_offset_min`.
 * @param ptr *u8
 * @param len i32
 * @param out *i32
 * @return i32
 */
export function parse_offset_min(ptr: *u8, len: i32, out: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = datetime_parse_offset_min_c(ptr, len, out); }
  return _rc;
}

/** Exported function `to_zoned_fields`.
 * Implements `to_zoned_fields`.
 * @param t DateTime
 * @param tz TimeZone
 * @return DateFields
 */
export function to_zoned_fields(t: DateTime, tz: TimeZone): DateFields {
  let off: i32 = timezone_offset_at(t, tz);
  return to_local_fields(t, off);
}

/** Exported function `from_zoned_fields`.
 * Implements `from_zoned_fields`.
 * @param f DateFields
 * @param tz TimeZone
 * @return DateTime
 */
export function from_zoned_fields(f: DateFields, tz: TimeZone): DateTime {
  let sec: i64 = 0;
  let nsec: i32 = 0;
  if (tz.iana_id >= 0) {
    unsafe {
      if (datetime_from_iana_zoned_fields_c(tz.iana_id, f.year, f.month, f.day, f.hour, f.minute, f.second, f.nsec,
          &sec, &nsec) != 0) {
        return DateTime { sec: -1, nsec: 0 };
      }
    }
    return DateTime { sec: sec, nsec: nsec };
  }
  unsafe {
    if (datetime_from_zoned_fields_c(f.year, f.month, f.day, f.hour, f.minute, f.second, f.nsec,
        tz.offset_min, &sec, &nsec) != 0) {
      return DateTime { sec: -1, nsec: 0 };
    }
  }
  return DateTime { sec: sec, nsec: nsec };
}

/** Exported function `iana_dst_smoke`.
 * Implements `iana_dst_smoke`.
 * @return i32
 */
export function iana_dst_smoke(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = datetime_iana_dst_smoke_c(); }
  return _rc;
}

/** Exported function `timezone_smoke`.
 * Implements `timezone_smoke`.
 * @return i32
 */
export function timezone_smoke(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = datetime_timezone_smoke_c(); }
  return _rc;
}
