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
const fmt = import("core.fmt");
const io = import("std.io");

/** Exported function `placeholder`.
 * Module import/smoke marker; returns 0.
 * @return i32
 */
export function placeholder(): i32 { return 0; }

/** Exported function `format`.
 * Implements `format`.
 * @param x i32
 * @return i32
 */
export function format(x: i32): i32 { return fmt.fmt_i32(x); }

/** Exported function `to_buf`.
 * Implements `to_buf`.
 * @param buf *u8
 * @param cap i32
 * @param x i32
 * @return i32
 */
export function to_buf(buf: *u8, cap: i32, x: i32): i32 { return fmt.fmt_i32_to_buf(buf, cap, x); }
/** Exported function `to_buf`.
 * Implements `to_buf`.
 * @param buf *u8
 * @param cap i32
 * @param u u32
 * @return i32
 */
export function to_buf(buf: *u8, cap: i32, u: u32): i32 { return fmt.fmt_u32_to_buf(buf, cap, u); }
/** Exported function `to_buf`.
 * Implements `to_buf`.
 * @param buf *u8
 * @param cap i32
 * @param x i64
 * @return i32
 */
export function to_buf(buf: *u8, cap: i32, x: i64): i32 { return fmt.fmt_i64_to_buf(buf, cap, x); }
/** Exported function `to_buf`.
 * Implements `to_buf`.
 * @param buf *u8
 * @param cap i32
 * @param u u64
 * @return i32
 */
export function to_buf(buf: *u8, cap: i32, u: u64): i32 { return fmt.fmt_u64_to_buf(buf, cap, u); }
/** Exported function `to_buf`.
 * Implements `to_buf`.
 * @param buf *u8
 * @param cap i32
 * @param x usize
 * @return i32
 */
export function to_buf(buf: *u8, cap: i32, x: usize): i32 { return fmt.fmt_usize_to_buf(buf, cap, x); }
/** Exported function `to_buf`.
 * Implements `to_buf`.
 * @param buf *u8
 * @param cap i32
 * @param x isize
 * @return i32
 */
export function to_buf(buf: *u8, cap: i32, x: isize): i32 { return fmt.fmt_isize_to_buf(buf, cap, x); }
/** Exported function `to_buf`.
 * Implements `to_buf`.
 * @param buf *u8
 * @param cap i32
 * @param b bool
 * @return i32
 */
export function to_buf(buf: *u8, cap: i32, b: bool): i32 { return fmt.fmt_bool_to_buf(buf, cap, b); }
/** Exported function `to_buf`.
 * Implements `to_buf`.
 * @param buf *u8
 * @param cap i32
 * @param x f64
 * @return i32
 */
export function to_buf(buf: *u8, cap: i32, x: f64): i32 { return fmt.fmt_f64_to_buf(buf, cap, x); }
/** Exported function `to_buf_prec`.
 * Implements `to_buf_prec`.
 * @param buf *u8
 * @param cap i32
 * @param x f64
 * @param prec i32
 * @return i32
 */
export function to_buf_prec(buf: *u8, cap: i32, x: f64, prec: i32): i32 {
  return fmt.fmt_f64_to_buf_prec(buf, cap, x, prec);
}
/** Exported function `hex_to_buf`.
 * Implements `hex_to_buf`.
 * @param buf *u8
 * @param cap i32
 * @param u u32
 * @return i32
 */
export function hex_to_buf(buf: *u8, cap: i32, u: u32): i32 { return fmt.fmt_u32_hex_to_buf(buf, cap, u); }
/** Exported function `hex_to_buf`.
 * Implements `hex_to_buf`.
 * @param buf *u8
 * @param cap i32
 * @param u u64
 * @return i32
 */
export function hex_to_buf(buf: *u8, cap: i32, u: u64): i32 { return fmt.fmt_u64_hex_to_buf(buf, cap, u); }
/** Exported function `append_to_buf`.
 * Implements `append_to_buf`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @param x i32
 * @return i32
 */
export function append_to_buf(buf: *u8, cap: i32, off: i32, x: i32): i32 {
  return fmt.fmt_append_i32_to_buf(buf, cap, off, x);
}
/** Exported function `append_to_buf`.
 * Implements `append_to_buf`.
 * @param buf *u8
 * @param cap i32
 * @param off i32
 * @param x i64
 * @return i32
 */
export function append_to_buf(buf: *u8, cap: i32, off: i32, x: i64): i32 {
  return fmt.fmt_append_i64_to_buf(buf, cap, off, x);
}

/** Exported function `format_template`.
 * Implements `format_template`.
 * @param buf *u8
 * @param cap i32
 * @param pat *u8
 * @param pat_len i32
 * @param val i32
 * @return i32
 */
export function format_template(buf: *u8, cap: i32, pat: *u8, pat_len: i32, val: i32): i32 {
  let i: i32 = 0;
  let o: i32 = 0;
  let replaced: i32 = 0;
  while (i < pat_len) {
    if (replaced == 0 && i + 1 < pat_len && pat[i] == 123 && pat[i + 1] == 125) {
      let n: i32 = fmt.fmt_i32_to_buf(&buf[o], cap - o, val);
      if (n < 0) { return -1; }
      o = o + n;
      i = i + 2;
      replaced = 1;
    } else {
      if (o >= cap) { return -1; }
      buf[o] = pat[i];
      o = o + 1;
      i = i + 1;
    }
  }
  return o;
}

/** Exported function `print`.
 * Implements `print`.
 * @param ptr *u8
 * @param len i32
 * @return i32
 */
export function print(ptr: *u8, len: i32): i32 {
  let r: i32 = io.write_stdout(ptr, len as usize);
  if (r < 0) { return -1; }
  return 0;
}
/** Exported function `print`.
 * Implements `print`.
 * @param s u8[]
 * @return i32
 */
export function print(s: u8[]): i32 {
  let r: i32 = io.write_stdout(s.data, s.length);
  if (r < 0) { return -1; }
  return 0;
}

/** Exported function `println`.
 * Implements `println`.
 * @param ptr *u8
 * @param len i32
 * @return i32
 */
export function println(ptr: *u8, len: i32): i32 {
  let r: i32 = io.write_stdout(ptr, len as usize);
  if (r < 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stdout(&nl[0], 1);
  if (rn < 0) { return -1; }
  return 0;
}
/** Exported function `println`.
 * Implements `println`.
 * @param s u8[]
 * @return i32
 */
export function println(s: u8[]): i32 {
  let r: i32 = io.write_stdout(s.data, s.length);
  if (r < 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stdout(&nl[0], 1);
  if (rn < 0) { return -1; }
  return 0;
}

/** Exported function `print`.
 * Implements `print`.
 * @param x i32
 * @return i32
 */
export function print(x: i32): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_i32_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stdout(&buf[0], n as usize);
  if (r < 0) { return -1; }
  return 0;
}
/** Exported function `println`.
 * Implements `println`.
 * @param x i32
 * @return i32
 */
export function println(x: i32): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_i32_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stdout(&buf[0], n as usize);
  if (r < 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stdout(&nl[0], 1);
  if (rn < 0) { return -1; }
  return 0;
}
/** Exported function `print`.
 * Implements `print`.
 * @param x u32
 * @return i32
 */
export function print(x: u32): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_u32_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stdout(&buf[0], n as usize);
  if (r < 0) { return -1; }
  return 0;
}
/** Exported function `println`.
 * Implements `println`.
 * @param x u32
 * @return i32
 */
export function println(x: u32): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_u32_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stdout(&buf[0], n as usize);
  if (r < 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stdout(&nl[0], 1);
  if (rn < 0) { return -1; }
  return 0;
}
/** Exported function `print`.
 * Implements `print`.
 * @param x i64
 * @return i32
 */
export function print(x: i64): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_i64_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stdout(&buf[0], n as usize);
  if (r < 0) { return -1; }
  return 0;
}
/** Exported function `println`.
 * Implements `println`.
 * @param x i64
 * @return i32
 */
export function println(x: i64): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_i64_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stdout(&buf[0], n as usize);
  if (r < 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stdout(&nl[0], 1);
  if (rn < 0) { return -1; }
  return 0;
}
/** Exported function `print`.
 * Implements `print`.
 * @param x u64
 * @return i32
 */
export function print(x: u64): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_u64_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stdout(&buf[0], n as usize);
  if (r < 0) { return -1; }
  return 0;
}
/** Exported function `println`.
 * Implements `println`.
 * @param x u64
 * @return i32
 */
export function println(x: u64): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_u64_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stdout(&buf[0], n as usize);
  if (r < 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stdout(&nl[0], 1);
  if (rn < 0) { return -1; }
  return 0;
}
/** Exported function `print`.
 * Implements `print`.
 * @param x usize
 * @return i32
 */
export function print(x: usize): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_usize_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stdout(&buf[0], n as usize);
  if (r < 0) { return -1; }
  return 0;
}
/** Exported function `println`.
 * Implements `println`.
 * @param x usize
 * @return i32
 */
export function println(x: usize): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_usize_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stdout(&buf[0], n as usize);
  if (r < 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stdout(&nl[0], 1);
  if (rn < 0) { return -1; }
  return 0;
}
/** Exported function `print`.
 * Implements `print`.
 * @param x isize
 * @return i32
 */
export function print(x: isize): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_isize_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stdout(&buf[0], n as usize);
  if (r < 0) { return -1; }
  return 0;
}
/** Exported function `println`.
 * Implements `println`.
 * @param x isize
 * @return i32
 */
export function println(x: isize): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_isize_to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stdout(&buf[0], n as usize);
  if (r < 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stdout(&nl[0], 1);
  if (rn < 0) { return -1; }
  return 0;
}
/** Exported function `print`.
 * Implements `print`.
 * @param x bool
 * @return i32
 */
export function print(x: bool): i32 {
  let buf: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_bool_to_buf(&buf[0], 8, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stdout(&buf[0], n as usize);
  if (r < 0) { return -1; }
  return 0;
}
/** Exported function `println`.
 * Implements `println`.
 * @param x bool
 * @return i32
 */
export function println(x: bool): i32 {
  let buf: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_bool_to_buf(&buf[0], 8, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stdout(&buf[0], n as usize);
  if (r < 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stdout(&nl[0], 1);
  if (rn < 0) { return -1; }
  return 0;
}
/** Exported function `print`.
 * Implements `print`.
 * @param x f64
 * @return i32
 */
export function print(x: f64): i32 {
  let buf: u8[64] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_f64_to_buf(&buf[0], 64, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stdout(&buf[0], n as usize);
  if (r < 0) { return -1; }
  return 0;
}
/** Exported function `println`.
 * Implements `println`.
 * @param x f64
 * @return i32
 */
export function println(x: f64): i32 {
  let buf: u8[64] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.fmt_f64_to_buf(&buf[0], 64, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stdout(&buf[0], n as usize);
  if (r < 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stdout(&nl[0], 1);
  if (rn < 0) { return -1; }
  return 0;
}

/** Exported function `format`.
 * Implements `format`.
 * @param buf *u8
 * @param cap i32
 * @param a i32
 * @param b i32
 * @param c i32
 * @return i32
 */
export function format(buf: *u8, cap: i32, a: i32, b: i32, c: i32): i32 {
  let n1: i32 = fmt.fmt_i32_to_buf(buf, cap, a);
  if (n1 < 0) { return -1; }
  let n2: i32 = fmt.fmt_i32_to_buf(&buf[n1], cap - n1, b);
  if (n2 < 0) { return -1; }
  let n3: i32 = fmt.fmt_i32_to_buf(&buf[n1 + n2], cap - n1 - n2, c);
  if (n3 < 0) { return -1; }
  return n1 + n2 + n3;
}
/** Exported function `format`.
 * Implements `format`.
 * @param buf *u8
 * @param cap i32
 * @param a i32
 * @param b u32
 * @param c usize
 * @return i32
 */
export function format(buf: *u8, cap: i32, a: i32, b: u32, c: usize): i32 {
  let n1: i32 = fmt.fmt_i32_to_buf(buf, cap, a);
  if (n1 < 0) { return -1; }
  let n2: i32 = fmt.fmt_u32_to_buf(&buf[n1], cap - n1, b);
  if (n2 < 0) { return -1; }
  let n3: i32 = fmt.fmt_usize_to_buf(&buf[n1 + n2], cap - n1 - n2, c);
  if (n3 < 0) { return -1; }
  return n1 + n2 + n3;
}

/** Exported function `ptr_to_buf`.
 * Implements `ptr_to_buf`.
 * @param buf *u8
 * @param cap i32
 * @param p *u8
 * @return i32
 */
export function ptr_to_buf(buf: *u8, cap: i32, p: *u8): i32 {
  return fmt.fmt_ptr_to_buf(buf, cap, p);
}
/** Exported function `fmt_module_anchor`.
 * Implements `fmt_module_anchor`.
 * @return i32
 */
export function fmt_module_anchor(): i32 { return 0; }
