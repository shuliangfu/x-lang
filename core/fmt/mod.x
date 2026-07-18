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

// note
// note

// Module import marker.
/** `placeholder`: see signature for params/returns; contracts in body. */
export function placeholder(): i32 { return 0; }

// fmt_i32
/** `fmt_i32`: see signature for params/returns; contracts in body. */
export function fmt_i32(x: i32): i32 { return x; }

// note
// fmt_i32_to_buf
/** `fmt_i32_to_buf`: see signature for params/returns; contracts in body. */
export function fmt_i32_to_buf(buf: *u8, cap: i32, x: i32): i32 {
  let digits: u8[10] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57];
  if (cap < 1) { return -1; }
  let u: i32 = 0 - x;
  if (x < 0 && u < 0) {
    if (cap < 11) { return -1; }
    let s: u8[11] = [45, 50, 49, 52, 55, 52, 56, 51, 54, 52, 56];
    let k: i32 = 0;
    while (k < 11) { buf[k] = s[k]; k = k + 1; }
    return 11;
  }
  let off: i32 = 0;
  let max: i32 = cap;
  let val: i32 = x;
  if (val < 0) {
    buf[0] = 45;
    off = 1;
    max = cap - 1;
    val = u;
  }
  if (max < 1) { return -1; }
  let tmp: u8[10] = [];
  let num_digits: i32 = 0;
  let v: i32 = val;
  while (v > 0 && num_digits < 10) {
    tmp[num_digits] = digits[v % 10];
    num_digits = num_digits + 1;
    v = v / 10;
  }
  if (num_digits == 0) {
    buf[off] = digits[0];
    return off + 1;
  }
  if (num_digits > max) { return -1; }
  let idx: i32 = 0;
  while (idx < num_digits) {
    buf[off + idx] = tmp[num_digits - 1 - idx];
    idx = idx + 1;
  }
  return off + num_digits;
}

// fmt_u32_to_buf
/** `fmt_u32_to_buf`: see signature for params/returns; contracts in body. */
export function fmt_u32_to_buf(buf: *u8, cap: i32, u: u32): i32 {
  let digits: u8[10] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57];
  if (cap < 1) { return -1; }
  let tmp: u8[10] = [];
  let num_digits: i32 = 0;
  let v: u32 = u;
  while (v > 0 && num_digits < 10) {
    tmp[num_digits] = digits[v % 10];
    num_digits = num_digits + 1;
    v = v / 10;
  }
  if (num_digits == 0) {
    buf[0] = digits[0];
    return 1;
  }
  if (num_digits > cap) { return -1; }
  let idx: i32 = 0;
  while (idx < num_digits) {
    buf[idx] = tmp[num_digits - 1 - idx];
    idx = idx + 1;
  }
  return num_digits;
}

// fmt_u64_to_buf
/** `fmt_u64_to_buf`: see signature for params/returns; contracts in body. */
export function fmt_u64_to_buf(buf: *u8, cap: i32, u: u64): i32 {
  let digits: u8[10] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57];
  if (cap < 1) { return -1; }
  let tmp: u8[20] = [];
  let num_digits: i32 = 0;
  let v: u64 = u;
  while (v > 0 && num_digits < 20) {
    tmp[num_digits] = digits[v % 10];
    num_digits = num_digits + 1;
    v = v / 10;
  }
  if (num_digits == 0) {
    buf[0] = digits[0];
    return 1;
  }
  if (num_digits > cap) { return -1; }
  let idx: i32 = 0;
  while (idx < num_digits) {
    buf[idx] = tmp[num_digits - 1 - idx];
    idx = idx + 1;
  }
  return num_digits;
}

// fmt_i64_to_buf
/** `fmt_i64_to_buf`: see signature for params/returns; contracts in body. */
export function fmt_i64_to_buf(buf: *u8, cap: i32, x: i64): i32 {
  let digits: u8[10] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57];
  if (cap < 1) { return -1; }
  /** See implementation. */
  let one_u: u64 = 1;
  let i64_min: i64 = (one_u << 63) as i64;
  if (x == i64_min) {
    if (cap < 20) { return -1; }
    let s: u8[20] = [45, 57, 50, 50, 51, 51, 55, 50, 48, 51, 54, 56, 53, 52, 55, 55, 53, 56, 48, 56];
    let k: i32 = 0;
    while (k < 20) { buf[k] = s[k]; k = k + 1; }
    return 20;
  }
  let u: i64 = 0 - x;
  if (x < 0 && u < 0) {
    if (cap < 20) { return -1; }
    let s: u8[20] = [45, 57, 50, 50, 51, 51, 55, 50, 48, 51, 54, 56, 53, 52, 55, 55, 53, 56, 48, 56];
    let k: i32 = 0;
    while (k < 20) { buf[k] = s[k]; k = k + 1; }
    return 20;
  }
  let off: i32 = 0;
  let max: i32 = cap;
  let val: i64 = x;
  if (val < 0) {
    buf[0] = 45;
    off = 1;
    max = cap - 1;
    val = u;
  }
  if (max < 1) { return -1; }
  let tmp: u8[20] = [];
  let num_digits: i32 = 0;
  let v: i64 = val;
  while (v > 0 && num_digits < 20) {
    tmp[num_digits] = digits[v % 10];
    num_digits = num_digits + 1;
    v = v / 10;
  }
  if (num_digits == 0) {
    buf[off] = digits[0];
    return off + 1;
  }
  if (num_digits > max) { return -1; }
  let idx: i32 = 0;
  while (idx < num_digits) {
    buf[off + idx] = tmp[num_digits - 1 - idx];
    idx = idx + 1;
  }
  return off + num_digits;
}

// fmt_bool_to_buf
/** `fmt_bool_to_buf`: see signature for params/returns; contracts in body. */
export function fmt_bool_to_buf(buf: *u8, cap: i32, b: bool): i32 {
  if (b) {
    if (cap < 4) { return -1; }
    buf[0] = 116; buf[1] = 114; buf[2] = 117; buf[3] = 101;
    return 4;
  }
  if (cap < 5) { return -1; }
  buf[0] = 102; buf[1] = 97; buf[2] = 108; buf[3] = 115; buf[4] = 101;
  return 5;
}

// --- section ---
// fmt_u32_hex_to_buf
/** `fmt_u32_hex_to_buf`: see signature for params/returns; contracts in body. */
export function fmt_u32_hex_to_buf(buf: *u8, cap: i32, u: u32): i32 {
  let hex: u8[16] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102];
  if (cap < 1) { return -1; }
  if (u == 0) { buf[0] = 48; return 1; }
  let tmp: u8[8] = [];
  let num_digits: i32 = 0;
  let v: u32 = u;
  while (v > 0 && num_digits < 8) {
    tmp[num_digits] = hex[v % 16];
    num_digits = num_digits + 1;
    v = v / 16;
  }
  if (num_digits > cap) { return -1; }
  let idx: i32 = 0;
  while (idx < num_digits) {
    buf[idx] = tmp[num_digits - 1 - idx];
    idx = idx + 1;
  }
  return num_digits;
}

/** `fmt_u64_hex_to_buf`: see signature for params/returns; contracts in body. */
export function fmt_u64_hex_to_buf(buf: *u8, cap: i32, u: u64): i32 {
  let hex: u8[16] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102];
  if (cap < 1) { return -1; }
  if (u == 0) { buf[0] = 48; return 1; }
  let tmp: u8[16] = [];
  let num_digits: i32 = 0;
  let v: u64 = u;
  while (v > 0 && num_digits < 16) {
    tmp[num_digits] = hex[v % 16];
    num_digits = num_digits + 1;
    v = v / 16;
  }
  if (num_digits > cap) { return -1; }
  let idx: i32 = 0;
  while (idx < num_digits) {
    buf[idx] = tmp[num_digits - 1 - idx];
    idx = idx + 1;
  }
  return num_digits;
}

// --- section ---
// fmt_append_i32_to_buf
/** `fmt_append_i32_to_buf`: see signature for params/returns; contracts in body. */
export function fmt_append_i32_to_buf(buf: *u8, cap: i32, off: i32, x: i32): i32 {
  if (off < 0 || off >= cap) { return -1; }
  let tmp: u8[24] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt_i32_to_buf(tmp, 24, x);
  if (n < 0 || off + n > cap) { return -1; }
  let i: i32 = 0;
  while (i < n) { buf[off + i] = tmp[i]; i = i + 1; }
  return off + n;
}

// fmt_append_i64_to_buf
/** `fmt_append_i64_to_buf`: see signature for params/returns; contracts in body. */
export function fmt_append_i64_to_buf(buf: *u8, cap: i32, off: i32, x: i64): i32 {
  if (off < 0 || off >= cap) { return -1; }
  let tmp: u8[24] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt_i64_to_buf(tmp, 24, x);
  if (n < 0 || off + n > cap) { return -1; }
  let i: i32 = 0;
  while (i < n) { buf[off + i] = tmp[i]; i = i + 1; }
  return off + n;
}

// --- section ---
/* note */
export const FMT_F64_DEFAULT_PREC: i32 = 6;

/** `fmt_f64_is_nan`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function fmt_f64_is_nan(x: f64): bool {
  return x != x;
}

/** `fmt_f64_is_inf`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function fmt_f64_is_inf(x: f64): bool {
  if (fmt_f64_is_nan(x)) {
    return false;
  }
  if (x == 0.0) {
    return false;
  }
  return x + x == x;
}

/** `fmt_f64_write_special`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function fmt_f64_write_special(buf: *u8, cap: i32, x: f64): i32 {
  if (fmt_f64_is_nan(x)) {
    if (cap < 3) { return -1; }
    buf[0] = 78;
    buf[1] = 97;
    buf[2] = 110;
    return 3;
  }
  if (fmt_f64_is_inf(x)) {
    if (x < 0.0) {
      if (cap < 4) { return -1; }
      buf[0] = 45;
      buf[1] = 73;
      buf[2] = 110;
      buf[3] = 102;
      return 4;
    }
    if (cap < 3) { return -1; }
    buf[0] = 73;
    buf[1] = 110;
    buf[2] = 102;
    return 3;
  }
  return -1;
}

/**
 /* note */
 /* note */
 */
export function fmt_f64_to_buf_prec(buf: *u8, cap: i32, x: f64, prec: i32): i32 {
  let digits: u8[10] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57];
  if (cap < 1) { return -1; }
  if (prec < 0 || prec > 9) { return -1; }
  let special: i32 = fmt_f64_write_special(buf, cap, x);
  if (special >= 0) { return special; }
  let abs_x: f64 = x;
  if (x < 0.0) { abs_x = 0.0 - x; }
  let whole: i64 = (abs_x as i64);
  let frac: f64 = abs_x - (whole as f64);
  let off: i32 = 0;
  if (x < 0.0) {
    if (cap < 1) { return -1; }
    buf[0] = 45;
    off = 1;
  }
  let tmp: u8[24] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n_whole: i32 = fmt_i64_to_buf(tmp, 24, whole);
  if (n_whole < 0 || off + n_whole > cap) { return -1; }
  let i: i32 = 0;
  while (i < n_whole) { buf[off + i] = tmp[i]; i = i + 1; }
  off = off + n_whole;
  if (prec == 0) { return off; }
  if (off + 1 + prec > cap) { return -1; }
  buf[off] = 46;
  off = off + 1;
  let k: i32 = 0;
  while (k < prec) {
    frac = frac * 10.0;
    let d: i64 = (frac as i64);
    buf[off + k] = digits[(d as i32)];
    frac = frac - (d as f64);
    k = k + 1;
  }
  return off + prec;
}

/** `fmt_f64_to_buf`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function fmt_f64_to_buf(buf: *u8, cap: i32, x: f64): i32 {
  return fmt_f64_to_buf_prec(buf, cap, x, FMT_F64_DEFAULT_PREC);
}

/** `fmt_scalar_to_buf`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function fmt_scalar_to_buf(buf: *u8, cap: i32, x: i32): i32 { return fmt_i32_to_buf(buf, cap, x); }
/** `fmt_scalar_to_buf`: see signature for params/returns; contracts in body. */
export function fmt_scalar_to_buf(buf: *u8, cap: i32, x: i64): i32 { return fmt_i64_to_buf(buf, cap, x); }
/** `fmt_scalar_to_buf`: see signature for params/returns; contracts in body. */
export function fmt_scalar_to_buf(buf: *u8, cap: i32, x: u32): i32 { return fmt_u32_to_buf(buf, cap, x); }
/** `fmt_scalar_to_buf`: see signature for params/returns; contracts in body. */
export function fmt_scalar_to_buf(buf: *u8, cap: i32, x: u64): i32 { return fmt_u64_to_buf(buf, cap, x); }
/** `fmt_scalar_to_buf`: see signature for params/returns; contracts in body. */
export function fmt_scalar_to_buf(buf: *u8, cap: i32, x: usize): i32 { return fmt_u32_to_buf(buf, cap, x as u32); }
/** `fmt_scalar_to_buf`: see signature for params/returns; contracts in body. */
export function fmt_scalar_to_buf(buf: *u8, cap: i32, x: isize): i32 { return fmt_i64_to_buf(buf, cap, x as i64); }

/** `fmt_usize_to_buf`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function fmt_usize_to_buf(buf: *u8, cap: i32, x: usize): i32 {
  return fmt_u32_to_buf(buf, cap, x as u32);
}
/** `fmt_isize_to_buf`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function fmt_isize_to_buf(buf: *u8, cap: i32, x: isize): i32 {
  return fmt_i64_to_buf(buf, cap, x as i64);
}

/** `fmt_ptr_to_buf`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function fmt_ptr_to_buf(buf: *u8, cap: i32, p: *u8): i32 {
  if (cap < 2) { return -1; }
  buf[0] = 48;
  buf[1] = 120;
  let n: i32 = fmt_u64_hex_to_buf(&buf[2], cap - 2, p as u64);
  if (n < 0) { return -1; }
  return 2 + n;
}
/** `fmt_module_anchor`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function fmt_module_anchor(): i32 { return 0; }
