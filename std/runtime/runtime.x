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

// std/runtime/runtime.x — panic/abort 对接 shux_panic_（F-runtime v1；替代 runtime.c）
//
// 【文件职责】
// runtime_panic / runtime_abort / runtime_crash_evidence_collect_c；
// 供 mod.x panic()/abort() 经 extern 调用；链接时须 runtime_panic.o。

extern function shux_panic_(has_msg: i32, msg_val: i32): void;
extern function shux_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void;

/** STD-028：panic 钩子收集（转发弱符号 shux_crash_evidence_collect_c）。 */
function runtime_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void {
  unsafe { shux_crash_evidence_collect_c(has_msg, msg_val); }
}

/** 无参 panic：终止程序（noreturn）。对标 Rust panic!()、Zig @panic。 */
function runtime_panic(): void {
  unsafe { shux_panic_(0, 0); }
}

/** 终止程序（noreturn）；与 panic 同义，对标 C abort()、Rust std::process::abort。 */
function runtime_abort(): void {
  unsafe { shux_panic_(0, 0); }
}
