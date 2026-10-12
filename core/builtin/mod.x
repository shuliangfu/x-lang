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

const mem = import("core.mem");

// placeholder
/** `placeholder`: see signature for params/returns; contracts in body. */
export function placeholder(): i32 { return 0; }

// copy
/** `copy`: see signature for params/returns; contracts in body. */
export function copy(dst: *u8, src: *u8, n: usize): void { mem.mem_copy(dst, src, n); }
/** `unreachable`: see signature for params/returns; contracts in body. */
export function unreachable(): void { panic(); }
/** `abort`: see signature for params/returns; contracts in body. */
export function abort(): void { panic(); }

// min_i32
/** `min_i32`: see signature for params/returns; contracts in body. */
export function min_i32(a: i32, b: i32): i32 { return if (a < b) { a } else { b }; }
/** `max_i32`: see signature for params/returns; contracts in body. */
export function max_i32(a: i32, b: i32): i32 { return if (a > b) { a } else { b }; }
/**
 * Smaller of two u32 values.
 * @param a u32 — first value
 * @param b u32 — second value
 * @return i32 — the smaller value in eax. Low 32 bits match u32.
 * PLATFORM: SHARED — the installed product cannot asm-emit this u32 return.
 */
export function min_u32(a: u32, b: u32): i32 { return if (a < b) { a as i32 } else { b as i32 }; }
/**
 * Larger of two u32 values.
 * @param a u32 — first value
 * @param b u32 — second value
 * @return i32 — the larger value in eax. Low 32 bits match u32.
 * PLATFORM: SHARED — the installed product cannot asm-emit this u32 return.
 */
export function max_u32(a: u32, b: u32): i32 { return if (a > b) { a as i32 } else { b as i32 }; }

// --- section ---
// clz_u32
/** `clz_u32`: see signature for params/returns; contracts in body. */
export function clz_u32(x: u32): i32 {
  if (x == 0) { return 32; }
  let n: i32 = 0;
  let t: u32 = x;
  while (t != 0) { t = t >> 1; n = n + 1; }
  return 32 - n;
}
// ctz_u32
/** `ctz_u32`: see signature for params/returns; contracts in body. */
export function ctz_u32(x: u32): i32 {
  if (x == 0) { return 32; }
  let n: i32 = 0;
  let t: u32 = x;
  while (t % 2 == 0) { t = t >> 1; n = n + 1; }
  return n;
}
// popcount_u32
/** `popcount_u32`: see signature for params/returns; contracts in body. */
export function popcount_u32(x: u32): i32 {
  let c: i32 = 0;
  let t: u32 = x;
  while (t != 0) {
    c = c + ((t % 2) as i32);
    t = t >> 1;
  }
  return c;
}

/**
 * Reverse the four bytes of a u32.
 * @param x u32 — value to swap
 * @return i32 — swapped bytes in eax. Low 32 bits match u32.
 * PLATFORM: SHARED — the installed product cannot asm-emit this u32 return.
 */
export function bswap_u32(x: u32): i32 {
  let b0: u32 = (x >> 24) & 255;
  let b1: u32 = (x >> 16) & 255;
  let b2: u32 = (x >> 8) & 255;
  let b3: u32 = x & 255;
  return ((b3 << 24) | (b2 << 16) | (b1 << 8) | b0) as i32;
}

/**
 * Rotate a u32 left by count bits.
 * @param x u32 — value to rotate
 * @param count u32 — bit count; only the low 5 bits are used
 * @return i32 — rotated value in eax. Low 32 bits match u32.
 * PLATFORM: SHARED — the installed product cannot asm-emit this u32 return.
 */
export function rotl_u32(x: u32, count: u32): i32 {
  let c: u32 = count % 32;
  if (c == 0) { return x as i32; }
  return ((x << c) | (x >> (32 - c))) as i32;
}

/**
 * Rotate a u32 right by count bits.
 * @param x u32 — value to rotate
 * @param count u32 — bit count; only the low 5 bits are used
 * @return i32 — rotated value in eax. Low 32 bits match u32.
 * PLATFORM: SHARED — the installed product cannot asm-emit this u32 return.
 */
export function rotr_u32(x: u32, count: u32): i32 {
  let c: u32 = count % 32;
  if (c == 0) { return x as i32; }
  return ((x >> c) | (x << (32 - c))) as i32;
}
