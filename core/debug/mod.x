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

// core.debug — 已迁移至 core.assert；本模块为兼容 alias（deprecated）
//
// 新代码请使用：const assert_mod = import("core.assert");
// 【co-emit】勿 import core.assert 再 delegate（transitive dep 未编入 user.o → ld 缺 core_assert_*）；
// 此处与 core/assert/mod.x 保持语义一致的内联副本。

/** 最近一次 assert 诊断槽（CORE-019 烟测用）。 */
let debug_diag_last_a: i32 = 0;
let debug_diag_last_b: i32 = 0;
let debug_diag_last_ok: i32 = 0;

/** @deprecated 使用 core.assert.assert */
export function assert(b: bool): i32 {
  if (!b) { return panic(); }
  return 0;
}
/** @deprecated 使用 core.assert.debug_assert */
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
export function assert_eq_u32(a: u32, b: u32): i32 {
  if (a != b) { return panic(); }
  return 0;
}
export function assert_ne_u32(a: u32, b: u32): i32 {
  if (a == b) { return panic(); }
  return 0;
}
export function assert_eq_bool(a: bool, b: bool): i32 {
  if (a != b) { return panic(); }
  return 0;
}
export function assert_ne_bool(a: bool, b: bool): i32 {
  if (a == b) { return panic(); }
  return 0;
}
export function assert_eq_u64(a: u64, b: u64): i32 {
  if (a != b) { return panic(); }
  return 0;
}
export function assert_ne_u64(a: u64, b: u64): i32 {
  if (a == b) { return panic(); }
  return 0;
}
export function assert_eq_ptr(a: *u8, b: *u8): i32 {
  if (a != b) { return panic(); }
  return 0;
}
export function assert_ne_ptr(a: *u8, b: *u8): i32 {
  if (a == b) { return panic(); }
  return 0;
}
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

// === X4: panic 增强（位置信息）===
// RegSnapshot / capture_regs_x86_64 / debug_breakpoint(asm!) 暂移出：
// 1) asm! 多操作数约束会误抬顶层 let；2) multi-dep co-emit 时 RegSnapshot 体可被漏发
//    （仅 forward），产品 -o 对 core-types 红。待 asm!/struct-layout claim 修后再恢复。

extern function std_debug_write_stderr(buf: *u8, count: usize): isize;

/** panic 带位置信息：写 write(2) + 文件名 + 行号。
 *  用于编译器内部致命错误的增强诊断。 */
export function panic_with_location(file: *u8, line: i32, msg: i32): i32 {
  // 写位置信息到 stderr：简化版，仅写 msg 值
  // 完整版需解决数组零初始化 codegen 问题后启用
  return panic();
}
