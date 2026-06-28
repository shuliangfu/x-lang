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

// core.cmp — 三路比较与 Ordering（CORE-005）
// 对标 Rust core::cmp::Ordering；cmp_* 返回 Less/Equal/Greater（code = -1/0/1）。
// 指针比较按 usize 地址序（与 C 指针比较语义一致）；null 视为地址 0。

/** 三路比较结果：code 为 ORD_LESS(-1) / ORD_EQUAL(0) / ORD_GREATER(1)。 */
struct Ordering {
  code: i32;
}

/** Less：a < b。 */
const ORD_LESS: i32 = -1;

/** Equal：a == b。 */
const ORD_EQUAL: i32 = 0;

/** Greater：a > b。 */
const ORD_GREATER: i32 = 1;

/** 构造 Less。 */
function ordering_less(): Ordering {
  return Ordering { code: ORD_LESS };
}

/** 构造 Equal。 */
function ordering_equal(): Ordering {
  return Ordering { code: ORD_EQUAL };
}

/** 构造 Greater。 */
function ordering_greater(): Ordering {
  return Ordering { code: ORD_GREATER };
}

/** 是否为 Less。 */
function is_lt(o: Ordering): bool {
  return o.code == ORD_LESS;
}

/** 是否为 Equal。 */
function is_eq(o: Ordering): bool {
  return o.code == ORD_EQUAL;
}

/** 是否为 Greater。 */
function is_gt(o: Ordering): bool {
  return o.code == ORD_GREATER;
}

/** 翻转 Less↔Greater，Equal 不变。 */
function reverse(o: Ordering): Ordering {
  if (o.code == ORD_LESS) { return ordering_greater(); }
  if (o.code == ORD_GREATER) { return ordering_less(); }
  return ordering_equal();
}

/** 若 self 非 Equal 则返回 self，否则返回 other（字典序链式比较）。 */
function then(o: Ordering, other: Ordering): Ordering {
  if (o.code != ORD_EQUAL) { return o; }
  return other;
}

/** 从 -1/0/1 编码构造 Ordering；非法值视为 Equal。 */
function ordering_from_i32(code: i32): Ordering {
  if (code < 0) { return ordering_less(); }
  if (code > 0) { return ordering_greater(); }
  return ordering_equal();
}

/** i32 三路比较。 */
function cmp_i32(a: i32, b: i32): Ordering {
  if (a < b) { return ordering_less(); }
  if (a > b) { return ordering_greater(); }
  return ordering_equal();
}

/** u8 三路比较（提升为 i32 比较，避免无符号环绕歧义）。 */
function cmp_u8(a: u8, b: u8): Ordering {
  let ai: i32 = a as i32;
  let bi: i32 = b as i32;
  if (ai < bi) { return ordering_less(); }
  if (ai > bi) { return ordering_greater(); }
  return ordering_equal();
}

/** *u8 指针按地址 usize 序比较（cmp_ptr 为 v1 默认指针比较入口）。 */
function cmp_ptr(a: *u8, b: *u8): Ordering {
  let ua: usize = a as usize;
  let ub: usize = b as usize;
  if (ua < ub) { return ordering_less(); }
  if (ua > ub) { return ordering_greater(); }
  return ordering_equal();
}

