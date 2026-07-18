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
//
// note
// note
// note

/** Last assert diagnostics triple for CORE-019 smoke tests / debugger. */
let debug_diag_last_a: i32 = 0;
let debug_diag_last_b: i32 = 0;
let debug_diag_last_ok: i32 = 0;

/** `assert`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function assert(b: bool): i32 {
  if (!b) { return panic(); }
  return 0;
}
/** `debug_assert`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function debug_assert(b: bool): i32 {
  if (!b) { return panic(); }
  return 0;
}
/** Assert a == b; panic if unequal; return 0 when equal. */
export function assert_eq_i32(a: i32, b: i32): i32 {
  if (a != b) { return panic(); }
  return 0;
}
/** Assert a != b; panic if equal; return 0 when unequal. */
export function assert_ne_i32(a: i32, b: i32): i32 {
  if (a == b) { return panic(); }
  return 0;
}
/** `assert_eq_u32`: see signature for params/returns; contracts in body. */
export function assert_eq_u32(a: u32, b: u32): i32 {
  if (a != b) { return panic(); }
  return 0;
}
/** `assert_ne_u32`: see signature for params/returns; contracts in body. */
export function assert_ne_u32(a: u32, b: u32): i32 {
  if (a == b) { return panic(); }
  return 0;
}
/** `assert_eq_bool`: see signature for params/returns; contracts in body. */
export function assert_eq_bool(a: bool, b: bool): i32 {
  if (a != b) { return panic(); }
  return 0;
}
/** `assert_ne_bool`: see signature for params/returns; contracts in body. */
export function assert_ne_bool(a: bool, b: bool): i32 {
  if (a == b) { return panic(); }
  return 0;
}
/** `assert_eq_u64`: see signature for params/returns; contracts in body. */
export function assert_eq_u64(a: u64, b: u64): i32 {
  if (a != b) { return panic(); }
  return 0;
}
/** `assert_ne_u64`: see signature for params/returns; contracts in body. */
export function assert_ne_u64(a: u64, b: u64): i32 {
  if (a == b) { return panic(); }
  return 0;
}
/** `assert_eq_ptr`: see signature for params/returns; contracts in body. */
export function assert_eq_ptr(a: *u8, b: *u8): i32 {
  if (a != b) { return panic(); }
  return 0;
}
/** `assert_ne_ptr`: see signature for params/returns; contracts in body. */
export function assert_ne_ptr(a: *u8, b: *u8): i32 {
  if (a == b) { return panic(); }
  return 0;
}
/** `debug_assert_eq_i32_diag`: see signature for params/returns; contracts in body. */
export function debug_assert_eq_i32_diag(a: i32, b: i32, tag: i32): i32 {
  debug_diag_store(a, b, if (a == b) { 1 } else { 0 });
  if (a != b) { return panic(); }
  return 0;
}
/** Store last diagnostics triple (a, b, ok) for smoke / debugger. */
export function debug_diag_store(a: i32, b: i32, ok: i32): void {
  debug_diag_last_a = a;
  debug_diag_last_b = b;
  debug_diag_last_ok = ok;
}

// note
// note
// note
// note

extern function std_debug_write_stderr(buf: *u8, count: usize): isize;

/** Detailed docs for `panic_with_location`: see implementation contracts (params/returns/null/cap). */
export function panic_with_location(file: *u8, line: i32, msg: i32): i32 {
  // note
  // note
  return panic();
}
