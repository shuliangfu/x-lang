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

// std.backtrace — 调用栈捕获（对标 Rust std::backtrace）
//
// 【文件职责】capture 将当前栈帧写入 buf（每帧 sizeof(void*)
// 字节），返回帧数；symbolicate 解析符号名。
// 【依赖】core；与 std/backtrace/backtrace.x 同属一模块（F-backtrace v2 / F-ZC）。平台胶层在 runtime_backtrace_platform.o。
extern function backtrace_capture_c(buf: *u8, max_frames: i32): i32;
extern function backtrace_symbolicate_c(buf: *u8, len: i32, out_ptrs: *u8, out_names: *u8, max:
i32): i32;

/** 符号名缓冲区每槽字节数（与 C BACKTRACE_SYM_NAME_LEN 一致）。 */
const SYM_NAME_LEN: i32 = 128;

/** 捕获当前调用栈到 buf；buf 需至少 max_frames * sizeof(void*)
* 字节。返回实际帧数，失败为 0。 */
function capture(buf: *u8, max_frames: i32): i32 {
  unsafe {
    return backtrace_capture_c(buf, max_frames);
  }
}

/** 将 capture 得到的 buf 符号化；len 为帧数；out_names 布局 max × SYM_NAME_LEN。
* 返回成功解析符号的帧数。 */
function symbolicate(buf: *u8, len: i32, out_ptrs: *u8, out_names: *u8, max: i32): i32 {
  unsafe {
    return backtrace_symbolicate_c(buf, len, out_ptrs, out_names, max);
  }
}

/** SAFE-007：收集崩溃证据（须环境变量 SHUX_CRASH_EVIDENCE=1；可选 SHUX_CRASH_EVIDENCE_DIR 落盘）。 */
extern function shux_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void;

/** 手动或 panic 路径登记证据；has_msg 非 0 时 msg_val 为消息码。 */
function collect_crash_evidence(has_msg: i32, msg_val: i32): void {
  unsafe { shux_crash_evidence_collect_c(has_msg, msg_val); }
}

/** 模块尾占位：transitive import 解析时末位 function 会丢失，须保留非 API 锚点。 */
function backtrace_module_anchor(): i32 { return 0; }
