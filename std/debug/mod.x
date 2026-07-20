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
const fmt = import("std.fmt");
const io = import("std.io");
const assert_mod = import("core.assert");

/** Exported function `placeholder`.
 * Module import/smoke marker; returns 0.
 * @return i32
 */
export function placeholder(): i32 { return 0; }

// See implementation.

/** Exported function `print`.
 * Implements `print`.
 * @param ptr *u8
 * @param len i32
 * @return i32
 */
export function print(ptr: *u8, len: i32): i32 {
  let r: i32 = io.write_stderr(ptr, len as usize);
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
  let r: i32 = io.write_stderr(ptr, len as usize);
  if (r < 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stderr(&nl[0], 1);
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
  let n: i32 = fmt.to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stderr(&buf[0], n as usize);
  if (r < 0) { return -1; }
  return 0;
}
/** Exported function `println`.
 * Implements `println`.
 * @param x i32
 * @return i32
 */
export function println(x: i32): i32 {
  let r: i32 = print(x);
  if (r != 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stderr(&nl[0], 1);
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
  let n: i32 = fmt.to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stderr(&buf[0], n as usize);
  if (r < 0) { return -1; }
  return 0;
}
/** Exported function `println`.
 * Implements `println`.
 * @param x u32
 * @return i32
 */
export function println(x: u32): i32 {
  let r: i32 = print(x);
  if (r != 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stderr(&nl[0], 1);
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
  let n: i32 = fmt.to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stderr(&buf[0], n as usize);
  if (r < 0) { return -1; }
  return 0;
}
/** Exported function `println`.
 * Implements `println`.
 * @param x i64
 * @return i32
 */
export function println(x: i64): i32 {
  let r: i32 = print(x);
  if (r != 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stderr(&nl[0], 1);
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
  let n: i32 = fmt.to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stderr(&buf[0], n as usize);
  if (r < 0) { return -1; }
  return 0;
}
/** Exported function `println`.
 * Implements `println`.
 * @param x u64
 * @return i32
 */
export function println(x: u64): i32 {
  let r: i32 = print(x);
  if (r != 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stderr(&nl[0], 1);
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
  let n: i32 = fmt.to_buf(&buf[0], 8, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stderr(&buf[0], n as usize);
  if (r < 0) { return -1; }
  return 0;
}
/** Exported function `println`.
 * Implements `println`.
 * @param x bool
 * @return i32
 */
export function println(x: bool): i32 {
  let r: i32 = print(x);
  if (r != 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stderr(&nl[0], 1);
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
  let n: i32 = fmt.to_buf(&buf[0], 64, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stderr(&buf[0], n as usize);
  if (r < 0) { return -1; }
  return 0;
}
/** Exported function `println`.
 * Implements `println`.
 * @param x f64
 * @return i32
 */
export function println(x: f64): i32 {
  let r: i32 = print(x);
  if (r != 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stderr(&nl[0], 1);
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
  let n: i32 = fmt.to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stderr(&buf[0], n as usize);
  if (r < 0) { return -1; }
  return 0;
}
/** Exported function `println`.
 * Implements `println`.
 * @param x usize
 * @return i32
 */
export function println(x: usize): i32 {
  let r: i32 = print(x);
  if (r != 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stderr(&nl[0], 1);
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
  let n: i32 = fmt.to_buf(&buf[0], 32, x);
  if (n < 0) { return -1; }
  let r: i32 = io.write_stderr(&buf[0], n as usize);
  if (r < 0) { return -1; }
  return 0;
}
/** Exported function `println`.
 * Implements `println`.
 * @param x isize
 * @return i32
 */
export function println(x: isize): i32 {
  let r: i32 = print(x);
  if (r != 0) { return -1; }
  let nl: u8[1] = [10];
  let rn: i32 = io.write_stderr(&nl[0], 1);
  if (rn < 0) { return -1; }
  return 0;
}

// assert: see function docblock below.
/** Exported function `assert`.
 * Assertion helper `assert`: panics on failure, returns 0 on success.
 * @param b bool): i32 { return assert_mod.assert(b
 * @return void
 */
export function assert(b: bool): i32 { return assert_mod.assert(b); }
/** Exported function `debug_assert`.
 * Implements `debug_assert`.
 * @param b bool): i32 { return assert_mod.debug_assert(b
 * @return void
 */
export function debug_assert(b: bool): i32 { return assert_mod.debug_assert(b); }
/** Exported function `assert_eq`.
 * Assertion helper `assert_eq`: panics on failure, returns 0 on success.
 * @param a i32
 * @param b i32): i32 { return assert_mod.assert_eq_i32(a
 * @param b
 * @return void
 */
export function assert_eq(a: i32, b: i32): i32 { return assert_mod.assert_eq_i32(a, b); }
/** Exported function `assert_ne`.
 * Assertion helper `assert_ne`: panics on failure, returns 0 on success.
 * @param a i32
 * @param b i32): i32 { return assert_mod.assert_ne_i32(a
 * @param b
 * @return void
 */
export function assert_ne(a: i32, b: i32): i32 { return assert_mod.assert_ne_i32(a, b); }
/** Exported function `assert_eq`.
 * Assertion helper `assert_eq`: panics on failure, returns 0 on success.
 * @param a u32
 * @param b u32): i32 { return assert_mod.assert_eq_u32(a
 * @param b
 * @return void
 */
export function assert_eq(a: u32, b: u32): i32 { return assert_mod.assert_eq_u32(a, b); }
/** Exported function `assert_ne`.
 * Assertion helper `assert_ne`: panics on failure, returns 0 on success.
 * @param a u32
 * @param b u32): i32 { return assert_mod.assert_ne_u32(a
 * @param b
 * @return void
 */
export function assert_ne(a: u32, b: u32): i32 { return assert_mod.assert_ne_u32(a, b); }
/** Exported function `assert_eq`.
 * Assertion helper `assert_eq`: panics on failure, returns 0 on success.
 * @param a bool
 * @param b bool): i32 { return assert_mod.assert_eq_bool(a
 * @param b
 * @return void
 */
export function assert_eq(a: bool, b: bool): i32 { return assert_mod.assert_eq_bool(a, b); }
/** Exported function `assert_ne`.
 * Assertion helper `assert_ne`: panics on failure, returns 0 on success.
 * @param a bool
 * @param b bool): i32 { return assert_mod.assert_ne_bool(a
 * @param b
 * @return void
 */
export function assert_ne(a: bool, b: bool): i32 { return assert_mod.assert_ne_bool(a, b); }
/** Exported function `assert_eq`.
 * Assertion helper `assert_eq`: panics on failure, returns 0 on success.
 * @param a u64
 * @param b u64): i32 { return assert_mod.assert_eq_u64(a
 * @param b
 * @return void
 */
export function assert_eq(a: u64, b: u64): i32 { return assert_mod.assert_eq_u64(a, b); }
/** Exported function `assert_ne`.
 * Assertion helper `assert_ne`: panics on failure, returns 0 on success.
 * @param a u64
 * @param b u64): i32 { return assert_mod.assert_ne_u64(a
 * @param b
 * @return void
 */
export function assert_ne(a: u64, b: u64): i32 { return assert_mod.assert_ne_u64(a, b); }
/** Exported function `assert_eq`.
 * Assertion helper `assert_eq`: panics on failure, returns 0 on success.
 * @param a *u8
 * @param b *u8): i32 { return assert_mod.assert_eq_ptr(a
 * @param b
 * @return void
 */
export function assert_eq(a: *u8, b: *u8): i32 { return assert_mod.assert_eq_ptr(a, b); }
/** Exported function `assert_ne`.
 * Assertion helper `assert_ne`: panics on failure, returns 0 on success.
 * @param a *u8
 * @param b *u8): i32 { return assert_mod.assert_ne_ptr(a
 * @param b
 * @return void
 */
export function assert_ne(a: *u8, b: *u8): i32 { return assert_mod.assert_ne_ptr(a, b); }

/** Exported function `debug_module_anchor`.
 * Implements `debug_module_anchor`.
 * @return i32
 */
export function debug_module_anchor(): i32 { return 0; }
