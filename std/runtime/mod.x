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
/** 无参 panic：终止程序（noreturn）。用于断言失败、不可达分支等。对标
* Rust panic!()、Zig @panic、Go panic()。 */
export function panic(): void {
  unsafe { runtime_panic(); }
}
/** 终止程序（noreturn）；与 panic 同义。对标 C abort()、Rust std::process::abort。
*/
export function abort(): void {
  unsafe { runtime_abort(); }
}
/** 运行时已就绪（占位）；返回 0。可用于初始化检查。对标 Go runtime
* 初始化语义。 */
export function ready(): i32 { return 0; }

/** 运行时诊断是否启用；当前恒为 1（STD-159）。 */
export function diag_enabled(): i32 { return 1; }

/** 收集运行时诊断事件（占位；code/detail 保留扩展）。 */
export function diag_collect(code: i32, detail: i32): void {
  let _c: i32 = code;
  let _d: i32 = detail;
}

/** runtime.x 实现：转发到 shux_crash_evidence_collect_c C 桩（须在 use 前声明）。 */
extern function runtime_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void;

/** 用户/测试可调用：登记 panic 钩子参数（has_msg/msg_val 透传 runtime）。 */
export function panic_hook_collect(has_msg: i32, msg_val: i32): void {
  unsafe { runtime_crash_evidence_collect_c(has_msg, msg_val); }
}

/** 模块尾占位：transitive import 解析时末位 function 会丢失，须保留非 API 锚点。 */
export function runtime_module_anchor(): i32 { return 0; }
