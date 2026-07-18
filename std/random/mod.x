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
// See implementation.

extern function random_fill_bytes_c(buf: *u8, len: i32): i32;
extern function random_u32_c(): u32;
extern function random_u64_c(): u64;
extern function random_rng_smoke_c(): i32;

/** Exported function `fill_bytes`.
 * Implements `fill_bytes`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function fill_bytes(buf: *u8, len: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = random_fill_bytes_c(buf, len); }
  return _rc;
}

/** Exported function `next`.
 * Implements `next`.
 * @return u64
 */
export function next(): u64 {
  let _rc: u64 = 0;
  unsafe { _rc = random_u64_c(); }
  return _rc;
}

/** Exported function `range`.
 * Implements `range`.
 * @param lo u32
 * @param hi u32
 * @return u32
 */
export function range(lo: u32, hi: u32): u32 {
  if (lo > hi) {
    return lo;
  }
  let range_val: u32 = hi - lo + 1;
  if (range_val == 0) {
    return lo;
  }
  let max_u32: u32 = 4294967295;
  let limit: u32 = max_u32 - (max_u32 % range_val);
  let x: u32 = 0;
  unsafe {
    x = random_u32_c();
    while (x >= limit) {
      x = random_u32_c();
    }
  }
  return lo + (x % range_val);
}

/** Exported function `gen`.
 * Implements `gen`.
 * @return i32
 */
export function gen(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = (random_u32_c() & 1) as i32; }
  return _rc;
}

/** Exported function `flip`.
 * Implements `flip`.
 * @return i32
 */
export function flip(): i32 {
  return gen();
}

// See implementation.

/* See implementation. */
allow(padding) struct Rng {
  state: u64;
}

/** Exported function `step`.
 * Implements `step`.
 * @param r *Rng
 * @return u64
 */
export function step(r: *Rng): u64 {
  let z: u64 = r.state + 0x9e3779b97f4a7c15 as u64;
  r.state = z;
  let t: u64 = z >> 30;
  let x: u64 = z ^ t;
  z = x * 0xbf58476d1ce4e5b9 as u64;
  t = z >> 27;
  x = z ^ t;
  z = x * 0x94d049bb133111eb as u64;
  t = z >> 31;
  return z ^ t;
}

/** Exported function `seed`.
 * Implements `seed`.
 * @param seed_val u64
 * @return Rng
 */
export function seed(seed_val: u64): Rng {
  return Rng { state: seed_val };
}

/** Exported function `fill`.
 * Implements `fill`.
 * @param r *Rng
 * @param buf *u8
 * @param len i32
 * @return void
 */
export function fill(r: *Rng, buf: *u8, len: i32): void {
  let i: i32 = 0;
  while (i < len) {
    let w: u64 = step(r);
    let j: i32 = 0;
    while (j < 8 && i < len) {
      buf[i] = (w & 255) as u8;
      w = w >> 8;
      i = i + 1;
      j = j + 1;
    }
  }
}

/** Exported function `range`.
 * Implements `range`.
 * @param r *Rng
 * @param lo u32
 * @param hi u32
 * @return u32
 */
export function range(r: *Rng, lo: u32, hi: u32): u32 {
  if (lo > hi) {
    return lo;
  }
  let range_val: u32 = hi - lo + 1;
  if (range_val == 0) {
    return lo;
  }
  let max_u32: u32 = 4294967295;
  let limit: u32 = max_u32 - (max_u32 % range_val);
  let x: u32 = step(r) as u32;
  while (x >= limit) {
    x = step(r) as u32;
  }
  return lo + (x % range_val);
}

/** Exported function `rng_smoke`.
 * Implements `rng_smoke`.
 * @return i32
 */
export function rng_smoke(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = random_rng_smoke_c(); }
  return _rc;
}
