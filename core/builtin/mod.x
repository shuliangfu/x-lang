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

// core.builtin — 内建函数 / intrinsics（自举前最小实现）
// 已提供：copy、unreachable、abort、min/max、clz/ctz/popcount（u32）、placeholder；不新增 extern，保持 core 零 OS 依赖。
// 与编译器内建对齐后，可改为 extern 或编译器识别符号，以产生单指令/ libcall 优化。

const mem = import("core.mem");

// ——— 占位与测试用 ———
function placeholder(): i32 { return 0; }

// ——— 内存与终止 ———
function copy(dst: *u8, src: *u8, n: usize): void { mem.mem_copy(dst, src, n); }
function unreachable(): void { panic(); }
function abort(): void { panic(); }

// ——— 比较（可内联，后续可映射为 min/max 指令） ———
function min_i32(a: i32, b: i32): i32 { return if (a < b) { a } else { b }; }
function max_i32(a: i32, b: i32): i32 { return if (a > b) { a } else { b }; }
function min_u32(a: u32, b: u32): u32 { return if (a < b) { a } else { b }; }
function max_u32(a: u32, b: u32): u32 { return if (a > b) { a } else { b }; }

// ——— 位运算（后续可映射为 __builtin_clz/ctz/popcount） ———
// 前导零个数；x==0 返回 32。
function clz_u32(x: u32): i32 {
  if (x == 0) { return 32; }
  let n: i32 = 0;
  let t: u32 = x;
  while (t != 0) { t = t >> 1; n = n + 1; }
  return 32 - n;
}
// 尾随零个数；x==0 返回 32。
function ctz_u32(x: u32): i32 {
  if (x == 0) { return 32; }
  let n: i32 = 0;
  let t: u32 = x;
  while (t % 2 == 0) { t = t >> 1; n = n + 1; }
  return n;
}
// 二进制中 1 的个数。
function popcount_u32(x: u32): i32 {
  let c: i32 = 0;
  let t: u32 = x;
  while (t != 0) {
    c = c + ((t % 2) as i32);
    t = t >> 1;
  }
  return c;
}

/** 32 位字节序交换（CORE-018）。 */
function bswap_u32(x: u32): u32 {
  let b0: u32 = (x >> 24) & 255;
  let b1: u32 = (x >> 16) & 255;
  let b2: u32 = (x >> 8) & 255;
  let b3: u32 = x & 255;
  return (b3 << 24) | (b2 << 16) | (b1 << 8) | b0;
}

/** 32 位循环左移；count 取模 32（CORE-018）。 */
function rotl_u32(x: u32, count: u32): u32 {
  let c: u32 = count % 32;
  if (c == 0) { return x; }
  return (x << c) | (x >> (32 - c));
}

/** 32 位循环右移；count 取模 32（CORE-018）。 */
function rotr_u32(x: u32, count: u32): u32 {
  let c: u32 = count % 32;
  if (c == 0) { return x; }
  return (x >> c) | (x << (32 - c));
}
