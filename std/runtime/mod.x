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

// std.runtime — 运行时初始化、panic/abort（对标 Zig @panic、Rust
// std::panic/process::abort、Go runtime）
//
// 【文件职责】
// 提供 panic()、abort()、ready()；panic/abort 经 std/runtime/runtime.x 对接
// shux_panic_，
// 链接时需提供 runtime_panic.o（或 libc abort）及 std/runtime/runtime.o。
//
// 【对标】
// Zig: @panic 内建、无独立 runtime 模块；Rust:
// std::panic::panic!、std::process::abort、panic::set_hook；
// Go: panic()、recover()、runtime.Goexit、runtime.NumCPU
// 等。我们提供最小集：panic/abort/ready。
extern function runtime_panic(): void;
extern function runtime_abort(): void;
extern function crash_evidence_collect(has_msg: i32, msg_val: i32): void;
/** 无参 panic：终止程序（noreturn）。用于断言失败、不可达分支等。对标
* Rust panic!()、Zig @panic、Go panic()。 */
function panic(): void {
  unsafe { runtime_panic(); }
}
/** 终止程序（noreturn）；与 panic 同义。对标 C abort()、Rust std::process::abort。
*/
function abort(): void {
  unsafe { runtime_abort(); }
}
/** 运行时已就绪（占位）；返回 0。可用于初始化检查。对标 Go runtime
* 初始化语义。 */
function ready(): i32 { return 0; }

/** 运行时诊断是否启用；当前恒为 1（STD-159）。 */
function diag_enabled(): i32 { return 1; }

/** 收集运行时诊断事件（占位；code/detail 保留扩展）。 */
function diag_collect(code: i32, detail: i32): void {
  let _c: i32 = code;
  let _d: i32 = detail;
}

/** 用户/测试可调用：登记 panic 钩子参数（has_msg/msg_val 透传 runtime）。 */
function panic_hook_collect(has_msg: i32, msg_val: i32): void {
  unsafe { crash_evidence_collect(has_msg, msg_val); }
}

extern function runtime_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void;
/** 模块尾占位：transitive import 解析时末位 function 会丢失，须保留非 API 锚点。 */
function runtime_module_anchor(): i32 { return 0; }
