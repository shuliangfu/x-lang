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
//
// See implementation.

const core_opt = import("core.option");
const core_res = import("core.result");

/** Exported function `none`.
 * Implements `none`.
 * @param ) Option_i32 { return core_opt.none_i32(
 * @return void
 */
export function none(): Option_i32 { return core_opt.none_i32(); }

/** Exported function `some`.
 * Implements `some`.
 * @param x i32): Option_i32 { return core_opt.some_i32(x
 * @return void
 */
export function some(x: i32): Option_i32 { return core_opt.some_i32(x); }

/** Exported function `unwrap_or`.
 * Implements `unwrap_or`.
 * @param opt Option_i32
 * @param default_val i32
 * @return i32
 */
export function unwrap_or(opt: Option_i32, default_val: i32): i32 {
  return core_opt.unwrap_or_i32(opt, default_val);
}

/** Exported function `is_some`.
 * Query helper `is_some`.
 * @param opt Option_i32): bool { return core_opt.is_some_i32(opt
 * @return void
 */
export function is_some(opt: Option_i32): bool { return core_opt.is_some_i32(opt); }

/** Exported function `is_none`.
 * Query helper `is_none`.
 * @param opt Option_i32): bool { return core_opt.is_none_i32(opt
 * @return void
 */
export function is_none(opt: Option_i32): bool { return core_opt.is_none_i32(opt); }

/** Exported function `map`.
 * Implements `map`.
 * @param opt Option_i32
 * @param mapped i32
 * @return Option_i32
 */
export function map(opt: Option_i32, mapped: i32): Option_i32 {
  if (core_opt.is_some_i32(opt)) {
    return core_opt.some_i32(mapped);
  }
  return core_opt.none_i32();
}

/** Exported function `and_then`.
 * Implements `and_then`.
 * @param opt Option_i32
 * @param next Option_i32
 * @return Option_i32
 */
export function and_then(opt: Option_i32, next: Option_i32): Option_i32 {
  if (core_opt.is_some_i32(opt)) {
    return next;
  }
  return core_opt.none_i32();
}

/** Exported function `or`.
 * Implements `or`.
 * @param opt Option_i32
 * @param other Option_i32
 * @return Option_i32
 */
export function or(opt: Option_i32, other: Option_i32): Option_i32 {
  return core_opt.or_i32(opt, other);
}

/** Exported function `from_result`.
 * Implements `from_result`.
 * @param r Result_i32
 * @return Option_i32
 */
export function from_result(r: Result_i32): Option_i32 {
  if (core_res.is_ok_i32(r)) {
    return core_opt.some_i32(r.value);
  }
  return core_opt.none_i32();
}

/** Exported function `from_result`.
 * Implements `from_result`.
 * @param r Result_u8
 * @return Option_u8
 */
export function from_result(r: Result_u8): Option_u8 {
  if (core_res.is_ok_u8(r)) {
    return core_opt.some_u8(r.value);
  }
  return core_opt.none_u8();
}

/** Exported function `to_result`.
 * Implements `to_result`.
 * @param opt Option_i32
 * @param err_if_none i32
 * @return Result_i32
 */
export function to_result(opt: Option_i32, err_if_none: i32): Result_i32 {
  if (core_opt.is_some_i32(opt)) {
    return core_res.ok_i32(opt.value);
  }
  return core_res.err_i32(err_if_none);
}
