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

// std/runtime/runtime.x — panic/abort 对接 shux_panic_（F-runtime v1；替代 runtime.c）
//
// 【文件职责】
// runtime_panic / runtime_abort / runtime_crash_evidence_collect_c；
// 供 mod.x panic()/abort() 经 extern 调用；链接时须 runtime_panic.o。

extern function shux_panic_(has_msg: i32, msg_val: i32): void;
extern function shux_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void;

/** STD-028：panic 钩子收集（转发弱符号 shux_crash_evidence_collect_c）。 */
export function runtime_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void {
  unsafe { shux_crash_evidence_collect_c(has_msg, msg_val); }
}

/** 无参 panic：终止程序（noreturn）。对标 Rust panic!()、Zig @panic。 */
export function runtime_panic(): void {
  unsafe { shux_panic_(0, 0); }
}

/** 终止程序（noreturn）；与 panic 同义，对标 C abort()、Rust std::process::abort。 */
export function runtime_abort(): void {
  unsafe { shux_panic_(0, 0); }
}
