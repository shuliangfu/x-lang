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

// std/time/time.x — 时间派生与烟测（F-time v1；替代 time.c 非 OS 段）
//
// 【文件职责】单调/墙钟单位换算、sleep 包装、duration_ns、format 烟测。
// 底层 syscall 见 runtime_time_os.c（compiler runtime）。

/** OS 胶层：单调纳秒。 */
extern function time_now_monotonic_ns_c(): i64;
/** OS 胶层：墙钟纳秒。 */
extern function time_now_wall_ns_c(): i64;

/** OS 胶层：睡眠纳秒。 */
extern function time_sleep_ns_c(ns: i64): void;

/** OS 胶层：RFC3339 格式化。 */
extern function time_format_wall_rfc3339_c(buf: *u8, cap: i32): i32;

/** OS 胶层：本地时区偏移（分钟）。 */
extern function time_wall_local_offset_min_c(): i32;

/** 单调：微秒。 */
export function time_now_monotonic_us_c(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_monotonic_ns_c() / 1000; }
  return _rc;
}

/** 单调：毫秒。 */
export function time_now_monotonic_ms_c(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_monotonic_ns_c() / 1000000; }
  return _rc;
}

/** 单调：秒。 */
export function time_now_monotonic_sec_c(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_monotonic_ns_c() / 1000000000; }
  return _rc;
}

/** 墙钟：秒。 */
export function time_now_wall_sec_c(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_wall_ns_c() / 1000000000; }
  return _rc;
}

/** 墙钟：毫秒。 */
export function time_now_wall_ms_c(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_wall_ns_c() / 1000000; }
  return _rc;
}

/** 墙钟：微秒。 */
export function time_now_wall_us_c(): i64 {
  let _rc: i64 = 0;
  unsafe { _rc = time_now_wall_ns_c() / 1000; }
  return _rc;
}

/** 睡眠：微秒。 */
export function time_sleep_us_c(us: i64): void {
  unsafe {
    time_sleep_ns_c(us * 1000);
  }
}

/** 睡眠：毫秒。 */
export function time_sleep_ms_c(ms: i32): void {
  if (ms <= 0) { return; }
  unsafe {
    time_sleep_ns_c((ms as i64) * 1000000);
  }
}

/** 睡眠：秒。 */
export function time_sleep_sec_c(s: i32): void {
  if (s <= 0) { return; }
  unsafe {
    time_sleep_ns_c((s as i64) * 1000000000);
  }
}

/** 时间差（纳秒）：纯算术。 */
export function time_duration_ns_c(from_ns: i64, to_ns: i64): i64 {
  return to_ns - from_ns;
}

/** format + offset 烟测；0 成功。 */
export function time_format_timezone_smoke_c(): i32 {
  let buf: u8[32];
  let i: i32 = 0;
  /* seed asm：栈数组勿用 = [] 初始化；显式清零。 */
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
