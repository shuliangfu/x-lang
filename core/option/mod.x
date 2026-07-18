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

/* note */
allow(padding) struct Option<T> {
  is_some: bool;
  value: T;
}

// note
export struct Option_i32 {
  is_some: bool;
  value: i32;
}

// none_i32
/** `none_i32`: see signature for params/returns; contracts in body. */
export function none_i32(): Option_i32 {
  return Option_i32 { is_some: false, value: 0 }
}

// some_i32
/** `some_i32`: see signature for params/returns; contracts in body. */
export function some_i32(x: i32): Option_i32 {
  return Option_i32 { is_some: true, value: x }
}

// unwrap_or_i32
/** `unwrap_or_i32`: see signature for params/returns; contracts in body. */
export function unwrap_or_i32(opt: Option_i32, default_val: i32): i32 {
  if (opt.is_some) {
    return opt.value;
  }
  return default_val;
}

// is_some_i32
/** `is_some_i32`: see signature for params/returns; contracts in body. */
export function is_some_i32(opt: Option_i32): bool {
  return opt.is_some;
}

// is_none_i32
/** `is_none_i32`: see signature for params/returns; contracts in body. */
export function is_none_i32(opt: Option_i32): bool {
  return !opt.is_some;
}

// expect_i32
/** `expect_i32`: see signature for params/returns; contracts in body. */
export function expect_i32(opt: Option_i32): i32 {
  if (opt.is_some) {
    return opt.value;
  }
  return panic();
}

// or_i32
/** `or_i32`: see signature for params/returns; contracts in body. */
export function or_i32(opt: Option_i32, other: Option_i32): Option_i32 {
  if (opt.is_some) {
    return opt;
  }
  return other;
}

// and_i32
/** `and_i32`: see signature for params/returns; contracts in body. */
export function and_i32(opt: Option_i32, other: Option_i32): Option_i32 {
  if (opt.is_some) {
    return other;
  }
  return none_i32();
}

// --- section ---
allow(padding) struct Option_u8 {
  is_some: bool;
  value: u8;
}
/** `none_u8`: see signature for params/returns; contracts in body. */
export function none_u8(): Option_u8 { return Option_u8 { is_some: false, value: 0 } }
/** `some_u8`: see signature for params/returns; contracts in body. */
export function some_u8(x: u8): Option_u8 { return Option_u8 { is_some: true, value: x } }
/** `unwrap_or_u8`: see signature for params/returns; contracts in body. */
export function unwrap_or_u8(opt: Option_u8, default_val: u8): u8 {
  if (opt.is_some) {
    return opt.value;
  }
  return default_val;
}
/** `is_some_u8`: see signature for params/returns; contracts in body. */
export function is_some_u8(opt: Option_u8): bool { return opt.is_some; }
/** `is_none_u8`: see signature for params/returns; contracts in body. */
export function is_none_u8(opt: Option_u8): bool { return !opt.is_some; }
/** `expect_u8`: see signature for params/returns; contracts in body. */
export function expect_u8(opt: Option_u8): u8 {
  if (opt.is_some) {
    return opt.value;
  }
  return panic();
}

/** `or_u8`: see signature for params/returns; contracts in body. */
export function or_u8(opt: Option_u8, other: Option_u8): Option_u8 {
  if (opt.is_some) {
    return opt;
  }
  return other;
}
/** `and_u8`: see signature for params/returns; contracts in body. */
export function and_u8(opt: Option_u8, other: Option_u8): Option_u8 {
  if (opt.is_some) {
    return other;
  }
  return none_u8();
}

// --- section ---
allow(padding) struct Option_u64 {
  is_some: bool;
  value: u64;
}

/** `none_u64`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function none_u64(): Option_u64 { return Option_u64 { is_some: false, value: 0 } }

/** `some_u64`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function some_u64(x: u64): Option_u64 { return Option_u64 { is_some: true, value: x } }

// --- section ---

/** `map_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function map_i32(opt: Option_i32, mapped: i32): Option_i32 {
  if (is_some_i32(opt)) {
    return some_i32(mapped);
  }
  return none_i32();
}

/** `map_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function map_u8(opt: Option_u8, mapped: u8): Option_u8 {
  if (is_some_u8(opt)) {
    return some_u8(mapped);
  }
  return none_u8();
}

/** `and_then_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function and_then_i32(opt: Option_i32, next: Option_i32): Option_i32 {
  if (is_some_i32(opt)) {
    return next;
  }
  return none_i32();
}

/** `unwrap_or`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function unwrap_or<T>(is_some: bool, value: T, default_val: T): T {
  if (is_some) {
    return value;
  }
  return default_val;
}

// --- section ---
allow(padding) struct Option_ptr_u8 {
  is_some: bool;
  value: *u8;
}

/** `none_ptr_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function none_ptr_u8(): Option_ptr_u8 {
  return Option_ptr_u8 { is_some: false, value: 0 as *u8 };
}

/** `some_ptr_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function some_ptr_u8(ptr: *u8): Option_ptr_u8 {
  return Option_ptr_u8 { is_some: true, value: ptr };
}

/** `map_ptr_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function map_ptr_u8(opt: Option_ptr_u8, mapped: *u8): Option_ptr_u8 {
  if (is_some_ptr_u8(opt)) {
    return some_ptr_u8(mapped);
  }
  return none_ptr_u8();
}

/** `is_some_ptr_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function is_some_ptr_u8(opt: Option_ptr_u8): bool {
  return opt.is_some;
}

/** `is_none_ptr_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function is_none_ptr_u8(opt: Option_ptr_u8): bool {
  return !opt.is_some;
}

/** `expect_ptr_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function expect_ptr_u8(opt: Option_ptr_u8): *u8 {
  if (opt.is_some) {
    return opt.value;
  }
  return panic();
}

// option_placeholder
/** `option_placeholder`: see signature for params/returns; contracts in body. */
export function option_placeholder<T>(x: T): T { return x; }
/** `option_module_anchor`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function option_module_anchor(): i32 { return 0; }
