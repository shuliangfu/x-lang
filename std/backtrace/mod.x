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

// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
extern function backtrace_capture_c(buf: *u8, max_frames: i32): i32;
extern function backtrace_symbolicate_c(buf: *u8, len: i32, out_ptrs: *u8, out_names: *u8, max:
i32): i32;

/* See implementation. */
export const SYM_NAME_LEN: i32 = 128;

/** Exported function `capture`.
 * Implements `capture`.
 * @param buf *u8
 * @param max_frames i32
 * @return i32
 */
export function capture(buf: *u8, max_frames: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = backtrace_capture_c(buf, max_frames); }
  return _rc;
}

/** Exported function `symbolicate`.
 * Implements `symbolicate`.
 * @param buf *u8
 * @param len i32
 * @param out_ptrs *u8
 * @param out_names *u8
 * @param max i32
 * @return i32
 */
export function symbolicate(buf: *u8, len: i32, out_ptrs: *u8, out_names: *u8, max: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = backtrace_symbolicate_c(buf, len, out_ptrs, out_names, max); }
  return _rc;
}

/* See implementation. */
extern function shux_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void;

/** Exported function `collect_crash_evidence`.
 * Implements `collect_crash_evidence`.
 * @param has_msg i32
 * @param msg_val i32
 * @return void
 */
export function collect_crash_evidence(has_msg: i32, msg_val: i32): void {
  unsafe { shux_crash_evidence_collect_c(has_msg, msg_val); }
}

/** Exported function `backtrace_module_anchor`.
 * Implements `backtrace_module_anchor`.
 * @return i32
 */
export function backtrace_module_anchor(): i32 { return 0; }
