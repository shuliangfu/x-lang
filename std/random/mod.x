// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// std.random — CSPRNG + 可复现 PRNG（SplitMix64，STD-130）
//
// 【文件职责】
// 对外暴露 std.random 的完整 API：fill_bytes、next、range（[lo,hi]
// 闭区间）、flip/gen（CSPRNG）；以及 Rng / seed / step / fill（可复现 PRNG）。
// 对标 Zig std.crypto / getentropy、Rust getrandom / OsRng；PRNG 对标 SplitMix64 种子流。

extern function random_fill_bytes_c(buf: *u8, len: i32): i32;
extern function random_u32_c(): u32;
extern function random_u64_c(): u64;
extern function random_rng_smoke_c(): i32;

/** 用密码学安全随机字节填满 buf[0..len)，返回写入的字节数（成功时为
 * len），失败时返回负值。对标 getrandom/OsRng.fill_bytes。 */
function fill_bytes(buf: *u8, len: i32): i32 {
  unsafe {
    return random_fill_bytes_c(buf, len);
  }
}

/** 生成密码学安全随机 u64（Tier-S `next`；u32 场景用 `as u32` 截断）。 */
function next(): u64 {
  unsafe {
    return random_u64_c();
  }
}

/** CSPRNG：[lo, hi] 闭区间内均匀 u32（含两端）；lo > hi 时返回 lo。 */
function range(lo: u32, hi: u32): u32 {
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

/** 生成均匀随机布尔，返回 0 或 1。对标 gen_bool。 */
function gen(): i32 {
  unsafe {
    return (random_u32_c() & 1) as i32;
  }
}

/** Tier-S：均匀随机布尔 0/1（gen 别名）。 */
function flip(): i32 {
  return gen();
}

// ——— STD-130：可复现 PRNG（SplitMix64） ———

/** PRNG 状态；仅含 u64 种子流，按值传递时须复制后再 mutate。 */
allow(padding) struct Rng {
  state: u64;
}

/** SplitMix64 单步；更新 *r 并返回下一个 u64。 */
function step(r: *Rng): u64 {
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

/** 用 seed 初始化 PRNG；同 seed 产生同序列。 */
function seed(seed_val: u64): Rng {
  return Rng { state: seed_val };
}

/** 用 PRNG 字节填充 buf[0..len)。 */
function fill(r: *Rng, buf: *u8, len: i32): void {
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

/** PRNG：[lo, hi] 闭区间均匀 u32；lo > hi 时返回 lo。 */
function range(r: *Rng, lo: u32, hi: u32): u32 {
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

/** C 层 PRNG 烟测；0 成功，非 0 失败。 */
function rng_smoke(): i32 {
  unsafe {
    return random_rng_smoke_c();
  }
}
