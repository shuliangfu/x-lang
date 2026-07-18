// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.

export extern "C" function shux_panic_(has_msg: i32, msg_val: i32): void;
export extern "C" function shux_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void;

#[no_mangle]
/** Exported function `std_runtime_crash_evidence_collect`.
 * Implements `std_runtime_crash_evidence_collect`.
 * @param has_msg i32
 * @param msg_val i32
 * @return void
 */
export function std_runtime_crash_evidence_collect(has_msg: i32, msg_val: i32): void {
  unsafe {
    shux_crash_evidence_collect_c(has_msg, msg_val);
  }
}

#[no_mangle]
/** Exported function `runtime_crash_evidence_collect_c`.
 * Implements `runtime_crash_evidence_collect_c`.
 * @param has_msg i32
 * @param msg_val i32
 * @return void
 */
export function runtime_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void {
  std_runtime_crash_evidence_collect(has_msg, msg_val);
}

#[no_mangle]
/** Exported function `std_runtime_runtime_panic`.
 * Implements `std_runtime_runtime_panic`.
 * @return void
 */
export function std_runtime_runtime_panic(): void {
  unsafe {
    shux_panic_(0, 0);
  }
}

#[no_mangle]
/** Exported function `runtime_panic`.
 * Implements `runtime_panic`.
 * @return void
 */
export function runtime_panic(): void {
  unsafe {
    shux_panic_(0, 0);
  }
}

#[no_mangle]
/** Exported function `std_runtime_runtime_abort`.
 * Implements `std_runtime_runtime_abort`.
 * @return void
 */
export function std_runtime_runtime_abort(): void {
  unsafe {
    shux_panic_(0, 0);
  }
}

#[no_mangle]
/** Exported function `runtime_abort`.
 * Implements `runtime_abort`.
 * @return void
 */
export function runtime_abort(): void {
  unsafe {
    shux_panic_(0, 0);
  }
}
