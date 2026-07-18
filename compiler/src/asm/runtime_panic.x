// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.

export extern "C" function shux_crash_evidence_minimal_impl(has_msg: i32, msg_val: i32): void;

/** Exported function `runtime_panic_x_doc_anchor`.
 * Implements `runtime_panic_x_doc_anchor`.
 * @return i32
 */
export function runtime_panic_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

#[no_mangle]
export function shux_crash_evidence_minimal(has_msg: i32, msg_val: i32): void {
  unsafe {
    shux_crash_evidence_minimal_impl(has_msg, msg_val);
  }
}
