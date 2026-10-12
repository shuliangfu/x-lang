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

/* note */
export struct Ordering {
  code: i32;
}

/** Less：a < b。 */
export const ORD_LESS: i32 = -1;

/** Equal：a == b。 */
export const ORD_EQUAL: i32 = 0;

/** Greater：a > b。 */
export const ORD_GREATER: i32 = 1;

/**
 * Ordering code for a < b.
 * @return i32 — ORD_LESS (-1). This is Ordering.code. Link name unchanged.
 * PLATFORM: SHARED — the installed product cannot asm-emit an Ordering return.
 */
export function ordering_less(): i32 {
  return ORD_LESS;
}

/**
 * Ordering code for a == b.
 * @return i32 — ORD_EQUAL (0). This is Ordering.code. Link name unchanged.
 * PLATFORM: SHARED — the installed product cannot asm-emit an Ordering return.
 */
export function ordering_equal(): i32 {
  return ORD_EQUAL;
}

/**
 * Ordering code for a > b.
 * @return i32 — ORD_GREATER (1). This is Ordering.code. Link name unchanged.
 * PLATFORM: SHARED — the installed product cannot asm-emit an Ordering return.
 */
export function ordering_greater(): i32 {
  return ORD_GREATER;
}

/**
 * True when the ordering code is less.
 * @param o Ordering — value under test; only code is read
 * @return i32 — 1 when o.code is ORD_LESS, otherwise 0
 * PLATFORM: SHARED — the installed product cannot asm-emit a bool return.
 */
export function is_lt(o: Ordering): i32 {
  if (o.code == ORD_LESS) { return 1; }
  return 0;
}

/**
 * True when the ordering code is equal.
 * @param o Ordering — value under test; only code is read
 * @return i32 — 1 when o.code is ORD_EQUAL, otherwise 0
 * PLATFORM: SHARED — the installed product cannot asm-emit a bool return.
 */
export function is_eq(o: Ordering): i32 {
  if (o.code == ORD_EQUAL) { return 1; }
  return 0;
}

/**
 * True when the ordering code is greater.
 * @param o Ordering — value under test; only code is read
 * @return i32 — 1 when o.code is ORD_GREATER, otherwise 0
 * PLATFORM: SHARED — the installed product cannot asm-emit a bool return.
 */
export function is_gt(o: Ordering): i32 {
  if (o.code == ORD_GREATER) { return 1; }
  return 0;
}

/**
 * Swap less and greater. Equal stays equal.
 * @param o Ordering — value to reverse; only code is read
 * @return i32 — the reversed Ordering.code
 * PLATFORM: SHARED — the installed product cannot asm-emit an Ordering return.
 */
export function reverse(o: Ordering): i32 {
  if (o.code == ORD_LESS) { return ordering_greater(); }
  if (o.code == ORD_GREATER) { return ordering_less(); }
  return ordering_equal();
}

/**
 * Keep o when it is not equal; otherwise use other.
 * @param o Ordering — first ordering; only code is read
 * @param other Ordering — fallback when o is equal; only code is read
 * @return i32 — the chosen Ordering.code
 * PLATFORM: SHARED — the installed product cannot asm-emit an Ordering return.
 */
export function then(o: Ordering, other: Ordering): i32 {
  if (o.code != ORD_EQUAL) { return o.code; }
  return other.code;
}

/**
 * Map a signed difference onto an ordering code.
 * @param code i32 — negative, zero, or positive
 * @return i32 — ORD_LESS, ORD_EQUAL, or ORD_GREATER
 * PLATFORM: SHARED — the installed product cannot asm-emit an Ordering return.
 */
export function ordering_from_i32(code: i32): i32 {
  if (code < 0) { return ordering_less(); }
  if (code > 0) { return ordering_greater(); }
  return ordering_equal();
}

/**
 * Compare two i32 values.
 * @param a i32 — left value
 * @param b i32 — right value
 * @return i32 — ORD_LESS, ORD_EQUAL, or ORD_GREATER
 * PLATFORM: SHARED — the installed product cannot asm-emit an Ordering return.
 */
export function cmp_i32(a: i32, b: i32): i32 {
  if (a < b) { return ordering_less(); }
  if (a > b) { return ordering_greater(); }
  return ordering_equal();
}

/**
 * Compare two u8 values as unsigned quantities.
 * @param a u8 — left value
 * @param b u8 — right value
 * @return i32 — ORD_LESS, ORD_EQUAL, or ORD_GREATER
 * PLATFORM: SHARED — the installed product cannot asm-emit an Ordering return.
 */
export function cmp_u8(a: u8, b: u8): i32 {
  let ai: i32 = a as i32;
  let bi: i32 = b as i32;
  if (ai < bi) { return ordering_less(); }
  if (ai > bi) { return ordering_greater(); }
  return ordering_equal();
}

/**
 * Compare two byte pointers by address.
 * @param a *u8 — left address; null is a valid address
 * @param b *u8 — right address; null is a valid address
 * @return i32 — ORD_LESS, ORD_EQUAL, or ORD_GREATER
 * PLATFORM: SHARED — the installed product cannot asm-emit an Ordering return.
 */
export function cmp_ptr(a: *u8, b: *u8): i32 {
  let ua: usize = a as usize;
  let ub: usize = b as usize;
  if (ua < ub) { return ordering_less(); }
  if (ua > ub) { return ordering_greater(); }
  return ordering_equal();
}
