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
//
// See implementation.

const result = import("core.result");
const error = import("std.error");

/** Exported function `ok`.
 * Implements `ok`.
 * @param x i32): Result_i32 { return result.ok(x
 * @return void
 */
export function ok(x: i32): Result_i32 { return result.ok(x); }

/** Exported function `err`.
 * Implements `err`.
 * @param e i32): Result_i32 { return result.err(e
 * @return void
 */
export function err(e: i32): Result_i32 { return result.err(e); }

/** Exported function `is_ok`.
 * Query helper `is_ok`.
 * @param r Result_i32): bool { return result.is_ok(r
 * @return void
 */
export function is_ok(r: Result_i32): bool { return result.is_ok(r); }

/** Exported function `is_err`.
 * Query helper `is_err`.
 * @param r Result_i32): bool { return result.is_err(r
 * @return void
 */
export function is_err(r: Result_i32): bool { return result.is_err(r); }

/** Exported function `unwrap_or`.
 * Implements `unwrap_or`.
 * @param r Result_i32
 * @param default_val i32
 * @return i32
 */
export function unwrap_or(r: Result_i32, default_val: i32): i32 {
  return result.unwrap_or(r, default_val);
}

/** Exported function `map`.
 * Implements `map`.
 * @param r Result_i32
 * @param mapped i32
 * @return Result_i32
 */
export function map(r: Result_i32, mapped: i32): Result_i32 {
  if (result.is_ok(r)) {
    return result.ok(mapped);
  }
  return result.err(r.err);
}

/** Exported function `and_then`.
 * Implements `and_then`.
 * @param r Result_i32
 * @param next Result_i32
 * @return Result_i32
 */
export function and_then(r: Result_i32, next: Result_i32): Result_i32 {
  if (result.is_ok(r)) {
    return next;
  }
  return result.err(r.err);
}

/** Exported function `or_else`.
 * Implements `or_else`.
 * @param r Result_i32
 * @param fallback Result_i32
 * @return Result_i32
 */
export function or_else(r: Result_i32, fallback: Result_i32): Result_i32 {
  if (result.is_ok(r)) {
    return r;
  }
  return fallback;
}

/** Exported function `from_error_code`.
 * Implements `from_error_code`.
 * @param code i32
 * @return Result_i32
 */
export function from_error_code(code: i32): Result_i32 {
  if (code == error.ok()) {
    return result.ok(0);
  }
  return result.err(code);
}

/** Exported function `from_value`.
 * Implements `from_value`.
 * @param value i32
 * @param err_code i32
 * @return Result_i32
 */
export function from_value(value: i32, err_code: i32): Result_i32 {
  if (err_code == error.ok()) {
    return result.ok(value);
  }
  return result.err(err_code);
}

/** Exported function `err_code`.
 * Implements `err_code`.
 * @param r Result_i32
 * @return i32
 */
export function err_code(r: Result_i32): i32 {
  if (result.is_ok(r)) {
    return error.ok();
  }
  return r.err;
}
