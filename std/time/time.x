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

/* See implementation. */
extern function time_now_monotonic_ns_c(): i64;
/* See implementation. */
extern function time_now_wall_ns_c(): i64;

/* See implementation. */
extern function time_sleep_ns_c(ns: i64): void;

/* See implementation. */
extern function time_format_wall_rfc3339_c(buf: *u8, cap: i32): i32;

/* See implementation. */
extern function time_wall_local_offset_min_c(): i32;

/** Exported function `time_now_monotonic_us_c`.
 * Implements `time_now_monotonic_us_c`.
 * @return i64
 */
export function time_now_monotonic_us_c(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_monotonic_ns_c() / 1000; }
  return _rc;
}

/** Exported function `time_now_monotonic_ms_c`.
 * Implements `time_now_monotonic_ms_c`.
 * @return i64
 */
export function time_now_monotonic_ms_c(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_monotonic_ns_c() / 1000000; }
  return _rc;
}

/** Exported function `time_now_monotonic_sec_c`.
 * Implements `time_now_monotonic_sec_c`.
 * @return i64
 */
export function time_now_monotonic_sec_c(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_monotonic_ns_c() / 1000000000; }
  return _rc;
}

/** Exported function `time_now_wall_sec_c`.
 * Implements `time_now_wall_sec_c`.
 * @return i64
 */
export function time_now_wall_sec_c(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_wall_ns_c() / 1000000000; }
  return _rc;
}

/** Exported function `time_now_wall_ms_c`.
 * Implements `time_now_wall_ms_c`.
 * @return i64
 */
export function time_now_wall_ms_c(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_wall_ns_c() / 1000000; }
  return _rc;
}

/** Exported function `time_now_wall_us_c`.
 * Implements `time_now_wall_us_c`.
 * @return i64
 */
export function time_now_wall_us_c(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_wall_ns_c() / 1000; }
  return _rc;
}

/** Exported function `time_sleep_us_c`.
 * Implements `time_sleep_us_c`.
 * @param us i64
 * @return void
 */
export function time_sleep_us_c(us: i64): void {
  unsafe {
    time_sleep_ns_c(us * 1000);
  }
}

/** Exported function `time_sleep_ms_c`.
 * Implements `time_sleep_ms_c`.
 * @param ms i32
 * @return void
 */
export function time_sleep_ms_c(ms: i32): void {
  if (ms <= 0) { return; }
  unsafe {
    time_sleep_ns_c((ms as i64) * 1000000);
  }
}

/** Exported function `time_sleep_sec_c`.
 * Implements `time_sleep_sec_c`.
 * @param s i32
 * @return void
 */
export function time_sleep_sec_c(s: i32): void {
  if (s <= 0) { return; }
  unsafe {
    time_sleep_ns_c((s as i64) * 1000000000);
  }
}

/** Exported function `time_duration_ns_c`.
 * Implements `time_duration_ns_c`.
 * @param from_ns i64
 * @param to_ns i64
 * @return i64
 */
export function time_duration_ns_c(from_ns: i64, to_ns: i64): i64 {
  return to_ns - from_ns;
}

/** Exported function `time_format_timezone_smoke_c`.
 * Implements `time_format_timezone_smoke_c`.
 * @return i32
 */
export function time_format_timezone_smoke_c(): i32 {
  let buf: u8[32];
  let i: i32 = 0;
  /* See implementation. */
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
