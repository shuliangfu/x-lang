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
// std::panic/process::abort、Go runtime）
//
// See implementation.
// See implementation.
// shux_panic_，
// See implementation.
//
// See implementation.
// See implementation.
// std::panic::panic!、std::process::abort、panic::set_hook；
// Go: panic()、recover()、runtime.Goexit、runtime.NumCPU
// See implementation.
extern function runtime_panic(): void;
extern function runtime_abort(): void;
/** Exported function `panic`.
 * Implements `panic`.
 * @return void
 */
export function panic(): void {
  unsafe { runtime_panic(); }
}
/** Exported function `abort`.
 * Implements `abort`.
 * @return void
 */
export function abort(): void {
  unsafe { runtime_abort(); }
}
/** Exported function `ready`.
 * Read path helper `ready`.
 * @return i32
 */
export function ready(): i32 { return 0; }

/** Exported function `diag_enabled`.
 * Implements `diag_enabled`.
 * @return i32
 */
export function diag_enabled(): i32 { return 1; }

/** Exported function `diag_collect`.
 * Implements `diag_collect`.
 * @param code i32
 * @param detail i32
 * @return void
 */
export function diag_collect(code: i32, detail: i32): void {
  let _c: i32 = code;
  let _d: i32 = detail;
}

/* See implementation. */
extern function runtime_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void;

/** Exported function `panic_hook_collect`.
 * Implements `panic_hook_collect`.
 * @param has_msg i32
 * @param msg_val i32
 * @return void
 */
export function panic_hook_collect(has_msg: i32, msg_val: i32): void {
  unsafe { runtime_crash_evidence_collect_c(has_msg, msg_val); }
}

/** Exported function `runtime_module_anchor`.
 * Implements `runtime_module_anchor`.
 * @return i32
 */
export function runtime_module_anchor(): i32 { return 0; }
