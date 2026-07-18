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
// runtime_panic / runtime_abort / runtime_crash_evidence_collect_c；
// See implementation.

extern function shux_panic_(has_msg: i32, msg_val: i32): void;
extern function shux_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void;

/** Exported function `runtime_crash_evidence_collect_c`.
 * Implements `runtime_crash_evidence_collect_c`.
 * @param has_msg i32
 * @param msg_val i32
 * @return void
 */
export function runtime_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void {
  unsafe { shux_crash_evidence_collect_c(has_msg, msg_val); }
}

/** Exported function `runtime_panic`.
 * Implements `runtime_panic`.
 * @return void
 */
export function runtime_panic(): void {
  unsafe { shux_panic_(0, 0); }
}

/** Exported function `runtime_abort`.
 * Implements `runtime_abort`.
 * @return void
 */
export function runtime_abort(): void {
  unsafe { shux_panic_(0, 0); }
}
