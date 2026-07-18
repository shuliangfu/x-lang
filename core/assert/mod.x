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

// core.assert — 逻辑不变量断言（无 I/O，freestanding 可用）
// 条件为假时 panic；返回 0 便于在表达式中使用。
// 调试打印见 std.debug；程序正常输出见 std.fmt。

/** 最近一次 assert 诊断槽（CORE-019 烟测用）。 */
let debug_diag_last_a: i32 = 0;
let debug_diag_last_b: i32 = 0;
let debug_diag_last_ok: i32 = 0;

/** 条件为假时终止程序（调用 panic）；条件为真时返回 0。 */
export function assert(b: bool): i32 {
  if (!b) { return panic(); }
  return 0;
}

/** 与 assert 同义；可约定仅在 debug 构建生效，当前实现与 assert 一致。 */
export function debug_assert(b: bool): i32 {
  if (!b) { return panic(); }
  return 0;
}

/** 断言 a == b，否则 panic；返回 0。 */
export function assert_eq_i32(a: i32, b: i32): i32 {
  if (a != b) { return panic(); }
  return 0;
}

/** 断言 a != b，否则 panic；返回 0。 */
export function assert_ne_i32(a: i32, b: i32): i32 {
  if (a == b) { return panic(); }
  return 0;
}

/** 断言 a == b（u32），否则 panic；返回 0。 */
export function assert_eq_u32(a: u32, b: u32): i32 {
  if (a != b) { return panic(); }
  return 0;
}

/** 断言 a != b（u32），否则 panic；返回 0。 */
export function assert_ne_u32(a: u32, b: u32): i32 {
  if (a == b) { return panic(); }
  return 0;
}

/** 断言 a == b（bool），否则 panic；返回 0。 */
export function assert_eq_bool(a: bool, b: bool): i32 {
  if (a != b) { return panic(); }
  return 0;
}

/** 断言 a != b（bool），否则 panic；返回 0。 */
export function assert_ne_bool(a: bool, b: bool): i32 {
  if (a == b) { return panic(); }
  return 0;
}

/** 断言 a == b（u64），否则 panic；返回 0。 */
export function assert_eq_u64(a: u64, b: u64): i32 {
  if (a != b) { return panic(); }
  return 0;
}

/** 断言 a != b（u64），否则 panic；返回 0。 */
export function assert_ne_u64(a: u64, b: u64): i32 {
  if (a == b) { return panic(); }
  return 0;
}

/** 断言指针 a == b（按地址），否则 panic；返回 0。 */
export function assert_eq_ptr(a: *u8, b: *u8): i32 {
  if (a != b) { return panic(); }
  return 0;
}

/** 断言指针 a != b（按地址），否则 panic；返回 0。 */
export function assert_ne_ptr(a: *u8, b: *u8): i32 {
  if (a == b) { return panic(); }
  return 0;
}

/** 断言 a == b 并记录 tag；不等时 panic，相等返回 0（CORE-019）。 */
export function debug_assert_eq_i32_diag(a: i32, b: i32, tag: i32): i32 {
  debug_diag_store(a, b, if (a == b) { 1 } else { 0 });
  if (a != b) { return panic(); }
  return 0;
}

/** 存储最近一次诊断三元组（烟测 / 调试器读取）。 */
export function debug_diag_store(a: i32, b: i32, ok: i32): void {
  debug_diag_last_a = a;
  debug_diag_last_b = b;
  debug_diag_last_ok = ok;
}
