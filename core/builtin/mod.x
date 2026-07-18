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
/** `min_u32`: see signature for params/returns; contracts in body. */
export function min_u32(a: u32, b: u32): u32 { return if (a < b) { a } else { b }; }
/** `max_u32`: see signature for params/returns; contracts in body. */
export function max_u32(a: u32, b: u32): u32 { return if (a > b) { a } else { b }; }

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

/** `bswap_u32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function bswap_u32(x: u32): u32 {
  let b0: u32 = (x >> 24) & 255;
  let b1: u32 = (x >> 16) & 255;
  let b2: u32 = (x >> 8) & 255;
  let b3: u32 = x & 255;
  return (b3 << 24) | (b2 << 16) | (b1 << 8) | b0;
}

/** `rotl_u32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function rotl_u32(x: u32, count: u32): u32 {
  let c: u32 = count % 32;
  if (c == 0) { return x; }
  return (x << c) | (x >> (32 - c));
}

/** `rotr_u32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function rotr_u32(x: u32, count: u32): u32 {
  let c: u32 = count % 32;
  if (c == 0) { return x; }
  return (x >> c) | (x << (32 - c));
}
