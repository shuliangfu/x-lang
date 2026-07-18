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

/* See implementation. */
extern function random_fill_bytes_c(buf: *u8, len: i32): i32;

/** Exported function `random_u32_c`.
 * Implements `random_u32_c`.
 * @return u32
 */
export function random_u32_c(): u32 {
  let buf: u8[4] = [0, 0, 0, 0];
  unsafe { if (random_fill_bytes_c(&buf[0], 4) != 4) { return 0 as u32; } }
  return (buf[0] as u32)
    | ((buf[1] as u32) << 8)
    | ((buf[2] as u32) << 16)
    | ((buf[3] as u32) << 24);
}

/** Exported function `random_u64_c`.
 * Implements `random_u64_c`.
 * @return u64
 */
export function random_u64_c(): u64 {
  let buf: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  unsafe { if (random_fill_bytes_c(&buf[0], 8) != 8) { return 0 as u64; } }
  return (buf[0] as u64)
    | ((buf[1] as u64) << 8)
    | ((buf[2] as u64) << 16)
    | ((buf[3] as u64) << 24)
    | ((buf[4] as u64) << 32)
    | ((buf[5] as u64) << 40)
    | ((buf[6] as u64) << 48)
    | ((buf[7] as u64) << 56);
}

/* See implementation. */
allow(padding) struct RngC {
  state: u64
}

/** Exported function `random_rng_next_u64`.
 * Implements `random_rng_next_u64`.
 * @param r *RngC
 * @return u64
 */
export function random_rng_next_u64(r: *RngC): u64 {
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

/** Exported function `random_rng_smoke_c`.
 * Implements `random_rng_smoke_c`.
 * @return i32
 */
export function random_rng_smoke_c(): i32 {
  let a: RngC = RngC { state: 0 };
  let b: RngC = RngC { state: 0 };
  let c: RngC = RngC { state: 1 };
  let x: u64 = random_rng_next_u64(&a);
  let y: u64 = random_rng_next_u64(&a);
  if (random_rng_next_u64(&b) != x) { return 1; }
  if (random_rng_next_u64(&b) != y) { return 2; }
  if (random_rng_next_u64(&c) == x) { return 3; }
  return 0;
}
