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

extern function time_now_monotonic_ns_c(): i64;
extern function test_call_i32_void_c(fn: usize): i32;
extern function env_getenv_c(key: *u8, key_len: i32, out: *u8, out_cap: i32): i32;
/* See implementation. */
extern "C" function shux_sys_write(fd: i32, buf: *u8, count: usize): isize;
extern "C" function strtoul(nptr: *u8, endptr: *u8, base: i32): u32;
extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;

/** Exported function `test_f_test_v1_marker_c`.
 * Implements `test_f_test_v1_marker_c`.
 * @return i32
 */
export function test_f_test_v1_marker_c(): i32 {
  return 1;
}

/** Exported function `test_f_test_v2_marker_c`.
 * Implements `test_f_test_v2_marker_c`.
 * @return i32
 */
export function test_f_test_v2_marker_c(): i32 {
  return 1;
}

/** Exported function `test_f_zero_c_marker_c`.
 * Implements `test_f_zero_c_marker_c`.
 * @return i32
 */
export function test_f_zero_c_marker_c(): i32 {
  return 1;
}

/* See implementation. */
export const TST_LIT_SUMMARY: u8[32] = [115, 104, 117, 120, 58, 32, 91, 83, 72, 85, 88, 95, 84, 69, 83, 84, 95, 83, 85, 77, 77, 65, 82, 89, 93, 32, 116, 111, 116, 97, 108, 61, 0];
export const TST_LIT_PASS: u8[7] = [32, 112, 97, 115, 115, 61, 0];
export const TST_LIT_FAIL: u8[7] = [32, 102, 97, 105, 108, 61, 0];
export const TST_LIT_SKIP: u8[7] = [32, 115, 107, 105, 112, 61, 0];

/* See implementation. */
let test_s_runner_total: i32 = 0;
let test_s_runner_pass: i32 = 0;
let test_s_runner_fail: i32 = 0;
let test_s_runner_skip: i32 = 0;

/** Exported function `test_io_copy_name`.
 * Implements `test_io_copy_name`.
 * @param out *u8
 * @param cap i32
 * @param name *u8
 * @param len i32
 * @return void
 */
export function test_io_copy_name(out: *u8, cap: i32, name: *u8, len: i32): void {
  let n: i32 = len;
  if (out == 0 || cap <= 0) { return; }
  if (name == 0 || len <= 0) {
    out[0] = 0;
    return;
  }
  if (n >= cap) { n = cap - 1; }
  unsafe { memcpy(out, name, n); }
  out[n] = 0;
}

/** Exported function `test_io_append_byte`.
 * Implements `test_io_append_byte`.
 * @param out *u8
 * @param pos i32
 * @param cap i32
 * @param b u8
 * @return i32
 */
export function test_io_append_byte(out: *u8, pos: i32, cap: i32, b: u8): i32 {
  if (out == 0 || pos < 0 || cap <= pos) { return -1; }
  out[pos] = b;
  return pos + 1;
}

/** Exported function `test_io_append_i32`.
 * Implements `test_io_append_i32`.
 * @param out *u8
 * @param pos i32
 * @param cap i32
 * @param v i32
 * @return i32
 */
export function test_io_append_i32(out: *u8, pos: i32, cap: i32, v: i32): i32 {
  let tmp: u8[16];
  let n: i32 = 0;
  let x: i32 = v;
  if (out == 0 || pos < 0 || cap <= pos) { return -1; }
  if (x == 0) {
    return test_io_append_byte(out, pos, cap, 48);
  }
  if (x < 0) {
    pos = test_io_append_byte(out, pos, cap, 45);
    if (pos < 0) { return -1; }
    x = -x;
  }
  while (x > 0) {
    tmp[n] = (48 + (x % 10)) as u8;
    n = n + 1;
    x = x / 10;
  }
  while (n > 0) {
    n = n - 1;
    pos = test_io_append_byte(out, pos, cap, tmp[n]);
    if (pos < 0) { return -1; }
  }
  return pos;
}

/** Exported function `test_io_append_i64`.
 * Implements `test_io_append_i64`.
 * @param out *u8
 * @param pos i32
 * @param cap i32
 * @param v i64
 * @return i32
 */
export function test_io_append_i64(out: *u8, pos: i32, cap: i32, v: i64): i32 {
  let tmp: u8[24];
  let n: i32 = 0;
  let x: i64 = v;
  if (out == 0 || pos < 0 || cap <= pos) { return -1; }
  if (x == 0) {
    return test_io_append_byte(out, pos, cap, 48);
  }
  if (x < 0) {
    pos = test_io_append_byte(out, pos, cap, 45);
    if (pos < 0) { return -1; }
    x = -x;
  }
  while (x > 0) {
    tmp[n] = (48 + (x % 10 as i64)) as u8;
    n = n + 1;
    x = x / 10;
  }
  while (n > 0) {
    n = n - 1;
    pos = test_io_append_byte(out, pos, cap, tmp[n]);
    if (pos < 0) { return -1; }
  }
  return pos;
}

/** Exported function `test_io_append_cstr`.
 * Implements `test_io_append_cstr`.
 * @param out *u8
 * @param pos i32
 * @param cap i32
 * @param s *u8
 * @return i32
 */
export function test_io_append_cstr(out: *u8, pos: i32, cap: i32, s: *u8): i32 {
  let i: i32 = 0;
  let c: u8 = 0;
  if (out == 0 || s == 0) { return -1; }
  loop {
    c = (s + i)[0];
    if (c == 0) { break; }
    pos = test_io_append_byte(out, pos, cap, c);
    if (pos < 0) { return -1; }
    i = i + 1;
  }
  return pos;
}

/** Exported function `test_io_append_name`.
 * Implements `test_io_append_name`.
 * @param out *u8
 * @param pos i32
 * @param cap i32
 * @param name *u8
 * @param len i32
 * @return i32
 */
export function test_io_append_name(out: *u8, pos: i32, cap: i32, name: *u8, len: i32): i32 {
  let i: i32 = 0;
  if (out == 0 || name == 0 || len <= 0) { return -1; }
  while (i < len) {
    pos = test_io_append_byte(out, pos, cap, (name + i)[0]);
    if (pos < 0) { return -1; }
    i = i + 1;
  }
  return pos;
}

/** Exported function `test_io_write_stderr`.
 * Write path helper `test_io_write_stderr`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function test_io_write_stderr(buf: *u8, len: i32): i32 {
  let r: isize = 0 as isize;
  if (buf == 0 || len <= 0) { return -1; }
  unsafe { r = shux_sys_write(2, buf, len as usize); }
  if (r != len as isize) { return -1; }
  return 0;
}

/** Exported function `test_fuzz_seed_c`.
 * Implements `test_fuzz_seed_c`.
 * @return u32
 */
export function test_fuzz_seed_c(): u32 {
  let key: u8[15] = [83, 72, 85, 88, 95, 70, 85, 90, 90, 95, 83, 69, 69, 68, 0];
  let buf: u8[64];
  let n: i32 = 0;
  let v: u32 = 0;
  unsafe { n = env_getenv_c(&key[0], 14, &buf[0], 64); }
  if (n > 0) {
    unsafe { v = strtoul(&buf[0], 0 as *u8, 0); }
    return v;
  }
  return 0xABCDEF01 as u32;
}

/** Exported function `test_io_bench_line_c`.
 * Implements `test_io_bench_line_c`.
 * @param name *u8
 * @param len i32
 * @param ns i64
 * @return i32
 */
export function test_io_bench_line_c(name: *u8, len: i32, ns: i64): i32 {
  let line: u8[256];
  let pos: i32 = 0;
  let pfx: u8[24] = [115, 104, 117, 120, 58, 32, 91, 83, 72, 85, 88, 95, 66, 69, 78, 67, 72, 93, 32, 110, 97, 109, 101, 61];
  let mid: u8[5] = [32, 110, 115, 61, 0];
  if (name == 0 || len <= 0) { return -1; }
  pos = test_io_append_cstr(&line[0], 0, 256, &pfx[0]);
  if (pos < 0) { return -1; }
  pos = test_io_append_name(&line[0], pos, 256, name, len);
  if (pos < 0) { return -1; }
  pos = test_io_append_cstr(&line[0], pos, 256, &mid[0]);
  if (pos < 0) { return -1; }
  pos = test_io_append_i64(&line[0], pos, 256, ns);
  if (pos < 0) { return -1; }
  pos = test_io_append_byte(&line[0], pos, 256, 10);
  if (pos < 0) { return -1; }
  return test_io_write_stderr(&line[0], pos);
}

/** Exported function `test_io_runner_case_line_c`.
 * Implements `test_io_runner_case_line_c`.
 * @param name *u8
 * @param len i32
 * @param exit_code i32
 * @return i32
 */
export function test_io_runner_case_line_c(name: *u8, len: i32, exit_code: i32): i32 {
  let line: u8[256];
  let nbuf: u8[128];
  let pos: i32 = 0;
  let pfx: u8[24] = [115, 104, 117, 120, 58, 32, 91, 83, 72, 85, 88, 95, 84, 69, 83, 84, 93, 32, 110, 97, 109, 101, 61, 0];
  let st_pass: u8[5] = [112, 97, 115, 115, 0];
  let st_fail: u8[5] = [102, 97, 105, 108, 0];
  let mid: u8[8] = [32, 115, 116, 97, 116, 117, 115, 61];
  let mid2: u8[7] = [32, 99, 111, 100, 101, 61, 0];
  test_io_copy_name(&nbuf[0], 128, name, len);
  pos = test_io_append_cstr(&line[0], 0, 256, &pfx[0]);
  if (pos < 0) { return -1; }
  pos = test_io_append_cstr(&line[0], pos, 256, &nbuf[0]);
  if (pos < 0) { return -1; }
  pos = test_io_append_cstr(&line[0], pos, 256, &mid[0]);
  if (pos < 0) { return -1; }
  if (exit_code == 0) {
    pos = test_io_append_cstr(&line[0], pos, 256, &st_pass[0]);
  } else {
    pos = test_io_append_cstr(&line[0], pos, 256, &st_fail[0]);
  }
  if (pos < 0) { return -1; }
  pos = test_io_append_cstr(&line[0], pos, 256, &mid2[0]);
  if (pos < 0) { return -1; }
  pos = test_io_append_i32(&line[0], pos, 256, exit_code);
  if (pos < 0) { return -1; }
  pos = test_io_append_byte(&line[0], pos, 256, 10);
  if (pos < 0) { return -1; }
  return test_io_write_stderr(&line[0], pos);
}

/** Exported function `test_io_runner_skip_line_c`.
 * Implements `test_io_runner_skip_line_c`.
 * @param name *u8
 * @param len i32
 * @return i32
 */
export function test_io_runner_skip_line_c(name: *u8, len: i32): i32 {
  let line: u8[256];
  let nbuf: u8[128];
  let pos: i32 = 0;
  let pfx: u8[24] = [115, 104, 117, 120, 58, 32, 91, 83, 72, 85, 88, 95, 84, 69, 83, 84, 93, 32, 110, 97, 109, 101, 61, 0];
  let tail: u8[22] = [32, 115, 116, 97, 116, 117, 115, 61, 115, 107, 105, 112, 32, 99, 111, 100, 101, 61, 48, 10, 0, 0];
  test_io_copy_name(&nbuf[0], 128, name, len);
  pos = test_io_append_cstr(&line[0], 0, 256, &pfx[0]);
  if (pos < 0) { return -1; }
  pos = test_io_append_cstr(&line[0], pos, 256, &nbuf[0]);
  if (pos < 0) { return -1; }
  pos = test_io_append_cstr(&line[0], pos, 256, &tail[0]);
  if (pos < 0) { return -1; }
  return test_io_write_stderr(&line[0], pos);
}

/** Exported function `test_io_runner_summary_line_c`.
 * Implements `test_io_runner_summary_line_c`.
 * @param total i32
 * @param pass i32
 * @param fail i32
 * @param skip i32
 * @return i32
 */
export function test_io_runner_summary_line_c(total: i32, pass: i32, fail: i32, skip: i32): i32 {
  let line: u8[256];
  let pos: i32 = 0;
  pos = test_io_append_cstr(&line[0], 0, 256, &TST_LIT_SUMMARY[0]);
  if (pos < 0) { return -1; }
  pos = test_io_append_i32(&line[0], pos, 256, total);
  if (pos < 0) { return -1; }
  pos = test_io_append_cstr(&line[0], pos, 256, &TST_LIT_PASS[0]);
  if (pos < 0) { return -1; }
  pos = test_io_append_i32(&line[0], pos, 256, pass);
  if (pos < 0) { return -1; }
  pos = test_io_append_cstr(&line[0], pos, 256, &TST_LIT_FAIL[0]);
  if (pos < 0) { return -1; }
  pos = test_io_append_i32(&line[0], pos, 256, fail);
  if (pos < 0) { return -1; }
  pos = test_io_append_cstr(&line[0], pos, 256, &TST_LIT_SKIP[0]);
  if (pos < 0) { return -1; }
  pos = test_io_append_i32(&line[0], pos, 256, skip);
  if (pos < 0) { return -1; }
  pos = test_io_append_byte(&line[0], pos, 256, 10);
  if (pos < 0) { return -1; }
  return test_io_write_stderr(&line[0], pos);
}

/** Exported function `test_noop_impl`.
 * Implements `test_noop_impl`.
 * @return i32
 */
export function test_noop_impl(): i32 {
  return 0;
}

/** Exported function `test_expect_c`.
 * Implements `test_expect_c`.
 * @param cond i32
 * @return i32
 */
export function test_expect_c(cond: i32): i32 {
  if (cond != 0) { return 0; }
  return 1;
}

/** Exported function `test_expect_eq_i32_c`.
 * Implements `test_expect_eq_i32_c`.
 * @param a i32
 * @param b i32
 * @return i32
 */
export function test_expect_eq_i32_c(a: i32, b: i32): i32 {
  if (a == b) { return 0; }
  return 1;
}

/** Exported function `test_expect_eq_u32_c`.
 * Implements `test_expect_eq_u32_c`.
 * @param a u32
 * @param b u32
 * @return i32
 */
export function test_expect_eq_u32_c(a: u32, b: u32): i32 {
  if (a == b) { return 0; }
  return 1;
}

/** Exported function `test_expect_ne_i32_c`.
 * Implements `test_expect_ne_i32_c`.
 * @param a i32
 * @param b i32
 * @return i32
 */
export function test_expect_ne_i32_c(a: i32, b: i32): i32 {
  if (a != b) { return 0; }
  return 1;
}

/** Exported function `test_run_c`.
 * Implements `test_run_c`.
 * @param fn usize
 * @return i32
 */
export function test_run_c(fn: usize): i32 {
  if (fn == 0) { return -1; }
  unsafe { return test_call_i32_void_c(fn); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `test_bench_run_c`.
 * Implements `test_bench_run_c`.
 * @param fn usize
 * @param iters i32
 * @return i64
 */
export function test_bench_run_c(fn: usize, iters: i32): i64 {
  let t0: i64 = 0;
  let t1: i64 = 0;
  let i: i32 = 0;
  if (fn == 0 || iters <= 0) { return -1 as i64; }
  unsafe { t0 = time_now_monotonic_ns_c(); }
  while (i < iters) {
    unsafe { test_call_i32_void_c(fn); }
    i = i + 1;
  }
  unsafe { t1 = time_now_monotonic_ns_c(); }
  return t1 - t0;
}

/** Exported function `test_bench_report_c`.
 * Implements `test_bench_report_c`.
 * @param name *u8
 * @param len i32
 * @param ns i64
 * @return i32
 */
export function test_bench_report_c(name: *u8, len: i32, ns: i64): i32 {
  return test_io_bench_line_c(name, len, ns);
}

/** Exported function `test_fuzz_next_c`.
 * Implements `test_fuzz_next_c`.
 * @param state *u32
 * @return u32
 */
export function test_fuzz_next_c(state: *u32): u32 {
  let s: u32 = 0;
  if (state == 0) { return 0 as u32; }
  unsafe { s = *state; }
  s = (s * 1103515245 + 12345) & 0x7fffffff;
  unsafe { *state = s; }
  return s;
}

/** Exported function `test_fuzz_run_c`.
 * Implements `test_fuzz_run_c`.
 * @param fn usize
 * @param iters i32
 * @return i32
 */
export function test_fuzz_run_c(fn: usize, iters: i32): i32 {
  let state: u32 = 0;
  let i: i32 = 0;
  if (fn == 0 || iters <= 0) { return -1; }
  state = test_fuzz_seed_c();
  while (i < iters) {
    test_fuzz_next_c(&state);
    unsafe { if (test_call_i32_void_c(fn) != 0) { return 1; } }
    i = i + 1;
  }
  return 0;
}

/** Exported function `test_bench_run_noop_c`.
 * Implements `test_bench_run_noop_c`.
 * @param iters i32
 * @return i64
 */
export function test_bench_run_noop_c(iters: i32): i64 {
  let t0: i64 = 0;
  let t1: i64 = 0;
  let i: i32 = 0;
  if (iters <= 0) { return -1 as i64; }
  unsafe { t0 = time_now_monotonic_ns_c(); }
  while (i < iters) {
    test_noop_impl();
    i = i + 1;
  }
  unsafe { t1 = time_now_monotonic_ns_c(); }
  return t1 - t0;
}

/** Exported function `test_fuzz_run_noop_c`.
 * Implements `test_fuzz_run_noop_c`.
 * @param iters i32
 * @return i32
 */
export function test_fuzz_run_noop_c(iters: i32): i32 {
  let state: u32 = 0;
  let i: i32 = 0;
  if (iters <= 0) { return -1; }
  state = test_fuzz_seed_c();
  while (i < iters) {
    test_fuzz_next_c(&state);
    if (test_noop_impl() != 0) { return 1; }
    i = i + 1;
  }
  return 0;
}

/** Exported function `test_bench_fuzz_smoke_c`.
 * Implements `test_bench_fuzz_smoke_c`.
 * @return i32
 */
export function test_bench_fuzz_smoke_c(): i32 {
  let name: u8[6] = [115, 109, 111, 107, 101, 0];
  let ns: i64 = 0;
  let st: u32 = 0;
  if (test_io_bench_line_c(&name[0], 5, 42) != 0) { return 1; }
  ns = test_bench_run_noop_c(8);
  if (ns < 0) { return 2; }
  st = test_fuzz_seed_c();
  if (test_fuzz_next_c(&st) == 0) { return 3; }
  return 0;
}

/** Exported function `test_runner_reset_c`.
 * Implements `test_runner_reset_c`.
 * @return void
 */
export function test_runner_reset_c(): void {
  test_s_runner_total = 0;
  test_s_runner_pass = 0;
  test_s_runner_fail = 0;
  test_s_runner_skip = 0;
}

/** Exported function `test_runner_report_case_c`.
 * Implements `test_runner_report_case_c`.
 * @param name *u8
 * @param len i32
 * @param exit_code i32
 * @return i32
 */
export function test_runner_report_case_c(name: *u8, len: i32, exit_code: i32): i32 {
  test_s_runner_total = test_s_runner_total + 1;
  if (exit_code == 0) {
    test_s_runner_pass = test_s_runner_pass + 1;
  } else {
    test_s_runner_fail = test_s_runner_fail + 1;
  }
  test_io_runner_case_line_c(name, len, exit_code);
  return exit_code;
}

/** Exported function `test_runner_report_skip_c`.
 * Implements `test_runner_report_skip_c`.
 * @param name *u8
 * @param len i32
 * @return i32
 */
export function test_runner_report_skip_c(name: *u8, len: i32): i32 {
  test_s_runner_total = test_s_runner_total + 1;
  test_s_runner_skip = test_s_runner_skip + 1;
  test_io_runner_skip_line_c(name, len);
  return 0;
}

/** Exported function `test_runner_finish_c`.
 * Implements `test_runner_finish_c`.
 * @return i32
 */
export function test_runner_finish_c(): i32 {
  test_io_runner_summary_line_c(test_s_runner_total, test_s_runner_pass, test_s_runner_fail, test_s_runner_skip);
  return test_s_runner_fail;
}
