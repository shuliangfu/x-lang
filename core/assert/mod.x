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

// core.assert — 逻辑不变量断言（无 I/O，freestanding 可用）
// 条件为假时 panic；返回 0 便于在表达式中使用。
// 调试打印见 std.debug；程序正常输出见 std.fmt。

/** 最近一次 assert 诊断槽（CORE-019 烟测用）。 */
let debug_diag_last_a: i32 = 0;
let debug_diag_last_b: i32 = 0;
let debug_diag_last_ok: i32 = 0;

/** 条件为假时终止程序（调用 panic）；条件为真时返回 0。 */
function assert(b: bool): i32 {
  if (!b) { return panic(); }
  return 0;
}

/** 与 assert 同义；可约定仅在 debug 构建生效，当前实现与 assert 一致。 */
function debug_assert(b: bool): i32 {
  if (!b) { return panic(); }
  return 0;
}

/** 断言 a == b，否则 panic；返回 0。 */
function assert_eq_i32(a: i32, b: i32): i32 {
  if (a != b) { return panic(); }
  return 0;
}

/** 断言 a != b，否则 panic；返回 0。 */
function assert_ne_i32(a: i32, b: i32): i32 {
  if (a == b) { return panic(); }
  return 0;
}

/** 断言 a == b（u32），否则 panic；返回 0。 */
function assert_eq_u32(a: u32, b: u32): i32 {
  if (a != b) { return panic(); }
  return 0;
}

/** 断言 a != b（u32），否则 panic；返回 0。 */
function assert_ne_u32(a: u32, b: u32): i32 {
  if (a == b) { return panic(); }
  return 0;
}

/** 断言 a == b（bool），否则 panic；返回 0。 */
function assert_eq_bool(a: bool, b: bool): i32 {
  if (a != b) { return panic(); }
  return 0;
}

/** 断言 a != b（bool），否则 panic；返回 0。 */
function assert_ne_bool(a: bool, b: bool): i32 {
  if (a == b) { return panic(); }
  return 0;
}

/** 断言 a == b（u64），否则 panic；返回 0。 */
function assert_eq_u64(a: u64, b: u64): i32 {
  if (a != b) { return panic(); }
  return 0;
}

/** 断言 a != b（u64），否则 panic；返回 0。 */
function assert_ne_u64(a: u64, b: u64): i32 {
  if (a == b) { return panic(); }
  return 0;
}

/** 断言指针 a == b（按地址），否则 panic；返回 0。 */
function assert_eq_ptr(a: *u8, b: *u8): i32 {
  if (a != b) { return panic(); }
  return 0;
}

/** 断言指针 a != b（按地址），否则 panic；返回 0。 */
function assert_ne_ptr(a: *u8, b: *u8): i32 {
  if (a == b) { return panic(); }
  return 0;
}

/** 断言 a == b 并记录 tag；不等时 panic，相等返回 0（CORE-019）。 */
function debug_assert_eq_i32_diag(a: i32, b: i32, tag: i32): i32 {
  debug_diag_store(a, b, if (a == b) { 1 } else { 0 });
  if (a != b) { return panic(); }
  return 0;
}

/** 存储最近一次诊断三元组（烟测 / 调试器读取）。 */
function debug_diag_store(a: i32, b: i32, ok: i32): void {
  debug_diag_last_a = a;
  debug_diag_last_b = b;
  debug_diag_last_ok = ok;
}
