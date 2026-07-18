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
// note
// note

// note
allow(padding) struct Result_i32 {
  value: i32;
  _pad1: i32;
  err: i32;
  _pad2: i32;
}

// ok
/** `ok`: see signature for params/returns; contracts in body. */
export function ok(x: i32): Result_i32 {
  return Result_i32 { value: x, _pad1: 0, err: 0, _pad2: 0 }
}

// err
/** `err`: see signature for params/returns; contracts in body. */
export function err(e: i32): Result_i32 {
  return Result_i32 { value: 0, _pad1: 0, err: e, _pad2: 0 }
}

// unwrap_or
/** `unwrap_or`: see signature for params/returns; contracts in body. */
export function unwrap_or(r: Result_i32, default_val: i32): i32 {
  if (r.err == 0) {
    return r.value;
  }
  return default_val;
}

// is_ok
/** `is_ok`: see signature for params/returns; contracts in body. */
export function is_ok(r: Result_i32): bool {
  return r.err == 0;
}

/** `is_ok_gen`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function is_ok_gen(r: Result_i32): bool {
  return is_ok(r);
}

/** `unwrap_or_gen`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function unwrap_or_gen(r: Result_i32, default_val: i32): i32 {
  return unwrap_or(r, default_val);
}

// is_err
/** `is_err`: see signature for params/returns; contracts in body. */
export function is_err(r: Result_i32): bool {
  return r.err != 0;
}

// expect
/** `expect`: see signature for params/returns; contracts in body. */
export function expect(r: Result_i32, default_val: i32): i32 {
  if (r.err == 0) {
    return r.value;
  }
  return default_val;
}

// expect_or_panic
/** `expect_or_panic`: see signature for params/returns; contracts in body. */
export function expect_or_panic(r: Result_i32): i32 {
  if (r.err == 0) {
    return r.value;
  }
  return panic();
}

// or
/** `or`: see signature for params/returns; contracts in body. */
export function or(r: Result_i32, other: Result_i32): Result_i32 {
  if (r.err == 0) {
    return r;
  }
  return other;
}

// and
/** `and`: see signature for params/returns; contracts in body. */
export function and(r: Result_i32, other: Result_i32): Result_i32 {
  if (r.err != 0) {
    return r;
  }
  return other;
}

// --- section ---

/** `map`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function map(r: Result_i32, mapped: i32): Result_i32 {
  if (is_ok(r)) {
    return ok(mapped);
  }
  return r;
}

/** `and_then`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function and_then(r: Result_i32, next: Result_i32): Result_i32 {
  if (is_ok(r)) {
    return next;
  }
  return r;
}

/** `or_else`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function or_else(r: Result_i32, other: Result_i32): Result_i32 {
  if (is_err(r)) {
    return other;
  }
  return r;
}

// ——— Result_u8 ———
allow(padding) struct Result_u8 {
  value: u8;
  _pad1: u8;
  _pad2: u8;
  _pad3: u8;
  err: i32;
  _pad4: i32;
}

/** `ok_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function ok_u8(x: u8): Result_u8 {
  return Result_u8 { value: x, _pad1: 0, _pad2: 0, _pad3: 0, err: 0, _pad4: 0 };
}

/** `err_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function err_u8(e: i32): Result_u8 {
  return Result_u8 { value: 0, _pad1: 0, _pad2: 0, _pad3: 0, err: e, _pad4: 0 };
}

/** `unwrap_or_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function unwrap_or_u8(r: Result_u8, default_val: u8): u8 {
  if (r.err == 0) {
    return r.value;
  }
  return default_val;
}

/** `is_ok_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function is_ok_u8(r: Result_u8): bool {
  return r.err == 0;
}

/** `is_err_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function is_err_u8(r: Result_u8): bool {
  return r.err != 0;
}

/** `expect_u8_or_panic`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function expect_u8_or_panic(r: Result_u8): u8 {
  if (r.err == 0) {
    return r.value;
  }
  return panic();
}

/** `map_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function map_u8(r: Result_u8, mapped: u8): Result_u8 {
  if (is_ok_u8(r)) {
    return ok_u8(mapped);
  }
  return r;
}

/** `or_else_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function or_else_u8(r: Result_u8, other: Result_u8): Result_u8 {
  if (is_err_u8(r)) {
    return other;
  }
  return r;
}

// ok_i32
/** `ok_i32`: see signature for params/returns; contracts in body. */
export function ok_i32(x: i32): Result_i32 { return ok(x); }
/** `err_i32`: see signature for params/returns; contracts in body. */
export function err_i32(e: i32): Result_i32 { return err(e); }
/** `unwrap_or_i32`: see signature for params/returns; contracts in body. */
export function unwrap_or_i32(r: Result_i32, default_val: i32): i32 { return unwrap_or(r, default_val); }
/** `is_ok_i32`: see signature for params/returns; contracts in body. */
export function is_ok_i32(r: Result_i32): bool { return is_ok(r); }
/** `is_err_i32`: see signature for params/returns; contracts in body. */
export function is_err_i32(r: Result_i32): bool { return is_err(r); }
/** `expect_i32`: see signature for params/returns; contracts in body. */
export function expect_i32(r: Result_i32, default_val: i32): i32 { return expect(r, default_val); }
/** `expect_i32_or_panic`: see signature for params/returns; contracts in body. */
export function expect_i32_or_panic(r: Result_i32): i32 { return expect_or_panic(r); }
/** `or_i32`: see signature for params/returns; contracts in body. */
export function or_i32(r: Result_i32, other: Result_i32): Result_i32 { return or(r, other); }
/** `and_i32`: see signature for params/returns; contracts in body. */
export function and_i32(r: Result_i32, other: Result_i32): Result_i32 { return and(r, other); }
/** `map_i32`: see signature for params/returns; contracts in body. */
export function map_i32(r: Result_i32, mapped: i32): Result_i32 { return map(r, mapped); }
/** `and_then_i32`: see signature for params/returns; contracts in body. */
export function and_then_i32(r: Result_i32, next: Result_i32): Result_i32 { return and_then(r, next); }
/** `or_else_i32`: see signature for params/returns; contracts in body. */
export function or_else_i32(r: Result_i32, other: Result_i32): Result_i32 { return or_else(r, other); }

/** `result_module_anchor`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function result_module_anchor(): i32 { return 0; }
