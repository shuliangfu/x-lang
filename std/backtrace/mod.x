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

// std.backtrace — 调用栈捕获（对标 Rust std::backtrace）
//
// 【文件职责】capture 将当前栈帧写入 buf（每帧 sizeof(void*)
// 字节），返回帧数；symbolicate 解析符号名。
// 【依赖】core；与 std/backtrace/backtrace.x 同属一模块（F-backtrace v2 / F-ZC）。平台胶层在 runtime_backtrace_platform.o。
extern function backtrace_capture_c(buf: *u8, max_frames: i32): i32;
extern function backtrace_symbolicate_c(buf: *u8, len: i32, out_ptrs: *u8, out_names: *u8, max:
i32): i32;

/** 符号名缓冲区每槽字节数（与 C BACKTRACE_SYM_NAME_LEN 一致）。 */
export const SYM_NAME_LEN: i32 = 128;

/** 捕获当前调用栈到 buf；buf 需至少 max_frames * sizeof(void*)
* 字节。返回实际帧数，失败为 0。 */
export function capture(buf: *u8, max_frames: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = backtrace_capture_c(buf, max_frames); }
  return _rc;
}

/** 将 capture 得到的 buf 符号化；len 为帧数；out_names 布局 max × SYM_NAME_LEN。
* 返回成功解析符号的帧数。 */
export function symbolicate(buf: *u8, len: i32, out_ptrs: *u8, out_names: *u8, max: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = backtrace_symbolicate_c(buf, len, out_ptrs, out_names, max); }
  return _rc;
}

/** SAFE-007：收集崩溃证据（须环境变量 SHUX_CRASH_EVIDENCE=1；可选 SHUX_CRASH_EVIDENCE_DIR 落盘）。 */
extern function shux_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void;

/** 手动或 panic 路径登记证据；has_msg 非 0 时 msg_val 为消息码。 */
export function collect_crash_evidence(has_msg: i32, msg_val: i32): void {
  unsafe { shux_crash_evidence_collect_c(has_msg, msg_val); }
}

/** 模块尾占位：transitive import 解析时末位 function 会丢失，须保留非 API 锚点。 */
export function backtrace_module_anchor(): i32 { return 0; }
