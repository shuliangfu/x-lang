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
// std::time::Instant/SystemTime/Duration。
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
// std/time/time.o。
// See implementation.
// time.c）。
//
// See implementation.
// See implementation.
// See implementation.

extern function time_now_monotonic_ns_c(): i64;
extern function time_now_wall_ns_c(): i64;
extern function time_sleep_ns_c(ns: i64): void;
extern function time_format_wall_rfc3339_c(buf: *u8, cap: i32): i32;
extern function time_wall_local_offset_min_c(): i32;

/** Exported function `now_monotonic_ns`.
 * Implements `now_monotonic_ns`.
 * @return i64
 */
export function now_monotonic_ns(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_monotonic_ns_c(); }
  return _rc;
}

/** Exported function `now_monotonic_us`.
 * Implements `now_monotonic_us`.
 * @return i64
 */
export function now_monotonic_us(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_monotonic_ns_c() / 1000; }
  return _rc;
}

/** Exported function `now_monotonic_ms`.
 * Implements `now_monotonic_ms`.
 * @return i64
 */
export function now_monotonic_ms(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_monotonic_ns_c() / 1000000; }
  return _rc;
}

/** Exported function `now_monotonic_sec`.
 * Implements `now_monotonic_sec`.
 * @return i64
 */
export function now_monotonic_sec(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_monotonic_ns_c() / 1000000000; }
  return _rc;
}

/** Exported function `now_wall_sec`.
 * Implements `now_wall_sec`.
 * @return i64
 */
export function now_wall_sec(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_wall_ns_c() / 1000000000; }
  return _rc;
}

/** Exported function `now_wall_ms`.
 * Implements `now_wall_ms`.
 * @return i64
 */
export function now_wall_ms(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_wall_ns_c() / 1000000; }
  return _rc;
}

/** Exported function `now_wall_us`.
 * Implements `now_wall_us`.
 * @return i64
 */
export function now_wall_us(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_wall_ns_c() / 1000; }
  return _rc;
}

/** Exported function `now_wall_ns`.
 * Implements `now_wall_ns`.
 * @return i64
 */
export function now_wall_ns(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_wall_ns_c(); }
  return _rc;
}

/** Exported function `sleep_ns`.
 * Implements `sleep_ns`.
 * @param ns i64
 * @return void
 */
export function sleep_ns(ns: i64): void {
  unsafe {
    time_sleep_ns_c(ns);
  }
}

/** Exported function `sleep_us`.
 * Implements `sleep_us`.
 * @param us i64
 * @return void
 */
export function sleep_us(us: i64): void {
  unsafe {
    time_sleep_ns_c(us * 1000);
  }
}

/** Exported function `sleep_ms`.
 * Implements `sleep_ms`.
 * @param ms i32
 * @return void
 */
export function sleep_ms(ms: i32): void {
  if (ms <= 0) { return; }
  unsafe {
    time_sleep_ns_c((ms as i64) * 1000000);
  }
}

/** Exported function `sleep_sec`.
 * Implements `sleep_sec`.
 * @param s i32
 * @return void
 */
export function sleep_sec(s: i32): void {
  if (s <= 0) { return; }
  unsafe {
    time_sleep_ns_c((s as i64) * 1000000000);
  }
}

/** Exported function `duration_ns`.
 * Implements `duration_ns`.
 * @param from_ns i64
 * @param to_ns i64
 * @return i64
 */
export function duration_ns(from_ns: i64, to_ns: i64): i64 {
  return to_ns - from_ns;
}

/* See implementation. */
export struct Timer {
  start_ns: i64;
}

/** Exported function `start`.
 * Implements `start`.
 * @return Timer
 */
export function start(): Timer {
    return Timer { start_ns: now_monotonic_ns() };
}

/** Exported function `reset`.
 * Implements `reset`.
 * @param t *Timer
 * @return void
 */
export function reset(t: *Timer): void {
    unsafe {
        t.start_ns = now_monotonic_ns();
    }
}

/** Exported function `elapsed_ns`.
 * Implements `elapsed_ns`.
 * @param t Timer
 * @return i64
 */
export function elapsed_ns(t: Timer): i64 {
    let start_ns: i64 = t.start_ns;
    return now_monotonic_ns() - start_ns;
}

/** Exported function `elapsed_us`.
 * Implements `elapsed_us`.
 * @param t Timer
 * @return i64
 */
export function elapsed_us(t: Timer): i64 {
    return elapsed_ns(t) / 1000;
}

/** Exported function `elapsed_ms`.
 * Implements `elapsed_ms`.
 * @param t Timer
 * @return i64
 */
export function elapsed_ms(t: Timer): i64 {
    return elapsed_ns(t) / 1000000;
}

/** Exported function `elapsed_sec`.
 * Implements `elapsed_sec`.
 * @param t Timer
 * @return i64
 */
export function elapsed_sec(t: Timer): i64 {
    return elapsed_ns(t) / 1000000000;
}

/** Exported function `lap_ns`.
 * Implements `lap_ns`.
 * @param t *Timer
 * @return i64
 */
export function lap_ns(t: *Timer): i64 {
    let now: i64 = now_monotonic_ns();
    let start_ns: i64 = t.start_ns;
    let lap: i64 = now - start_ns;
    unsafe {
        t.start_ns = now;
    }
    return lap;
}

/** Exported function `format_wall_rfc3339`.
 * Implements `format_wall_rfc3339`.
 * @param buf *u8
 * @param cap i32
 * @return i32
 */
export function format_wall_rfc3339(buf: *u8, cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = time_format_wall_rfc3339_c(buf, cap); }
  return _rc;
}

/** Exported function `wall_local_offset_min`.
 * Implements `wall_local_offset_min`.
 * @return i32
 */
export function wall_local_offset_min(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = time_wall_local_offset_min_c(); }
  return _rc;
}

/** Exported function `format_timezone_smoke`.
 * Implements `format_timezone_smoke`.
 * @return i32
 */
export function format_timezone_smoke(): i32 {
  let buf: u8[32];
  let i: i32 = 0;
  while (i < 32) {
    buf[i] = 0;
    i = i + 1;
  }
  let n: i32 = 0;
  let off: i32 = 0;
  unsafe {
    n = time_format_wall_rfc3339_c(&buf[0], 32);
    off = time_wall_local_offset_min_c();
  }
  if (n < 20) { return 1; }
  if (buf[(n - 1)] != 90) { return 2; }
  if (off < -840 || off > 840) { return 3; }
  return 0;
}
