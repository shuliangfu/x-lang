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

/**
 * Write a missing i32 option.
 * @param out *Option_i32 — destination; must not be null
 * @return i32 — always 0
 * PLATFORM: SHARED — the installed product cannot asm-emit an Option return.
 */
export function none_i32(out: *Option_i32): i32 {
  out.is_some = false;
  out.value = 0;
  return 0;
}

/**
 * Write a present i32 option.
 * @param out *Option_i32 — destination; must not be null
 * @param x i32 — stored value
 * @return i32 — always 0
 * PLATFORM: SHARED — the installed product cannot asm-emit an Option return.
 */
export function some_i32(out: *Option_i32, x: i32): i32 {
  out.is_some = true;
  out.value = x;
  return 0;
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
  let n: Option_i32 = { is_some: false, value: 0 };
  none_i32(&n);
  return n;
}

// --- section ---
allow(padding) struct Option_u8 {
  is_some: bool;
  value: u8;
}
/**
 * Write a missing u8 option.
 * @param out *Option_u8 — destination; must not be null
 * @return i32 — always 0
 * PLATFORM: SHARED — the installed product cannot asm-emit an Option return.
 */
export function none_u8(out: *Option_u8): i32 {
  out.is_some = false;
  out.value = 0;
  return 0;
}
/**
 * Write a present u8 option.
 * @param out *Option_u8 — destination; must not be null
 * @param x u8 — stored value
 * @return i32 — always 0
 * PLATFORM: SHARED — the installed product cannot asm-emit an Option return.
 */
export function some_u8(out: *Option_u8, x: u8): i32 {
  out.is_some = true;
  out.value = x;
  return 0;
}
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
  let n: Option_u8 = { is_some: false, value: 0 };
  none_u8(&n);
  return n;
}

// --- section ---
allow(padding) struct Option_u64 {
  is_some: bool;
  value: u64;
}

/**
 * Write a missing u64 option.
 * @param out *Option_u64 — destination; must not be null
 * @return i32 — always 0
 * PLATFORM: SHARED — the installed product cannot asm-emit an Option return.
 */
export function none_u64(out: *Option_u64): i32 {
  out.is_some = false;
  out.value = 0;
  return 0;
}

/**
 * Write a present u64 option.
 * @param out *Option_u64 — destination; must not be null
 * @param x u64 — stored value
 * @return i32 — always 0
 * PLATFORM: SHARED — the installed product cannot asm-emit an Option return.
 */
export function some_u64(out: *Option_u64, x: u64): i32 {
  out.is_some = true;
  out.value = x;
  return 0;
}

// --- section ---

/** `map_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function map_i32(opt: Option_i32, mapped: i32): Option_i32 {
  let r: Option_i32 = { is_some: false, value: 0 };
  if (is_some_i32(opt)) {
    some_i32(&r, mapped);
    return r;
  }
  none_i32(&r);
  return r;
}

/** `map_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function map_u8(opt: Option_u8, mapped: u8): Option_u8 {
  let r: Option_u8 = { is_some: false, value: 0 };
  if (is_some_u8(opt)) {
    some_u8(&r, mapped);
    return r;
  }
  none_u8(&r);
  return r;
}

/** `and_then_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function and_then_i32(opt: Option_i32, next: Option_i32): Option_i32 {
  if (is_some_i32(opt)) {
    return next;
  }
  let n: Option_i32 = { is_some: false, value: 0 };
  none_i32(&n);
  return n;
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
  return { is_some: false, value: 0 as *u8 };
}

/** `some_ptr_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function some_ptr_u8(ptr: *u8): Option_ptr_u8 {
  return { is_some: true, value: ptr };
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
