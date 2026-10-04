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

/**
 * Write a missing i32 option.
 * Returning Option by value does not asm-emit on the installed product.
 * @param out *Option_i32 — caller storage; must not be null
 * @return i32 — 0 after the slot is written
 * PLATFORM: SHARED
 */
export function none(out: *Option_i32): i32 {
  core_opt.none_i32(out);
  return 0;
}

/**
 * Write a present i32 option.
 * @param x i32 — stored value
 * @param out *Option_i32 — caller storage; must not be null
 * @return i32 — 0 after the slot is written
 * PLATFORM: SHARED
 */
export function some(x: i32, out: *Option_i32): i32 {
  core_opt.some_i32(out, x);
  return 0;
}

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
/**
 * Map a present i32 option onto mapped, or write none.
 * @param opt Option_i32 — source option
 * @param mapped i32 — value stored when opt is present
 * @param out *Option_i32 — caller storage; must not be null
 * @return i32 — 0 after the slot is written
 * PLATFORM: SHARED
 */
export function map(opt: Option_i32, mapped: i32, out: *Option_i32): i32 {
  if (core_opt.is_some_i32(opt)) {
    core_opt.some_i32(out, mapped);
    return 0;
  }
  core_opt.none_i32(out);
  return 0;
}

/** Exported function `and_then`.
 * Implements `and_then`.
 * @param opt Option_i32
 * @param next Option_i32
 * @return Option_i32
 */
/**
 * Keep next when opt is present. Otherwise write none.
 * @param opt Option_i32 — gate
 * @param next Option_i32 — value copied when opt is present
 * @param out *Option_i32 — caller storage; must not be null
 * @return i32 — 0 after the slot is written
 * PLATFORM: SHARED
 */
export function and_then(opt: Option_i32, next: Option_i32, out: *Option_i32): i32 {
  if (core_opt.is_some_i32(opt)) {
    out.is_some = next.is_some;
    out.value = next.value;
    return 0;
  }
  core_opt.none_i32(out);
  return 0;
}

/** Exported function `or`.
 * Implements `or`.
 * @param opt Option_i32
 * @param other Option_i32
 * @return Option_i32
 */
/**
 * Write opt when it is present, otherwise write other.
 * @param opt Option_i32 — preferred option
 * @param other Option_i32 — fallback
 * @param out *Option_i32 — caller storage; must not be null
 * @return i32 — 0 after the slot is written
 * PLATFORM: SHARED
 */
export function or(opt: Option_i32, other: Option_i32, out: *Option_i32): i32 {
  if (opt.is_some) {
    out.is_some = opt.is_some;
    out.value = opt.value;
    return 0;
  }
  out.is_some = other.is_some;
  out.value = other.value;
  return 0;
}

/** Exported function `from_result`.
 * Implements `from_result`.
 * @param r Result_i32
 * @return Option_i32
 */
/**
 * Write some(r.value) when r is ok, otherwise none.
 * @param r Result_i32 — source result
 * @param out *Option_i32 — caller storage; must not be null
 * @return i32 — 0 after the slot is written
 * PLATFORM: SHARED
 */
export function from_result(r: Result_i32, out: *Option_i32): i32 {
  if (core_res.is_ok_i32(r)) {
    core_opt.some_i32(out, r.value);
    return 0;
  }
  core_opt.none_i32(out);
  return 0;
}

/** Exported function `from_result`.
 * Implements `from_result`.
 * @param r Result_u8
 * @return Option_u8
 */
/**
 * Write some(r.value) when r is ok, otherwise none.
 * @param r Result_u8 — source result
 * @param out *Option_u8 — caller storage; must not be null
 * @return i32 — 0 after the slot is written
 * PLATFORM: SHARED
 */
export function from_result(r: Result_u8, out: *Option_u8): i32 {
  if (core_res.is_ok_u8(r)) {
    core_opt.some_u8(out, r.value);
    return 0;
  }
  core_opt.none_u8(out);
  return 0;
}

/** Exported function `to_result`.
 * Implements `to_result`.
 * @param opt Option_i32
 * @param err_if_none i32
 * @return Result_i32
 */
/**
 * Write ok(opt.value) when opt is present, otherwise err(err_if_none).
 * Returning Result by value does not asm-emit on the installed product.
 * @param opt Option_i32 — source option
 * @param err_if_none i32 — error stored when opt is missing
 * @param out *Result_i32 — caller storage; must not be null
 * @return i32 — 0 after the slot is written
 * PLATFORM: SHARED
 */
export function to_result(opt: Option_i32, err_if_none: i32, out: *Result_i32): i32 {
  if (core_opt.is_some_i32(opt)) {
    out.value = opt.value;
    out._pad1 = 0;
    out.err = 0;
    out._pad2 = 0;
    return 0;
  }
  out.value = 0;
  out._pad1 = 0;
  out.err = err_if_none;
  out._pad2 = 0;
  return 0;
}
