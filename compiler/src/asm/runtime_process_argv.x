// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function xlang_process_argv_bind_from_crt_impl(): void;

/** Exported function `runtime_process_argv_x_doc_anchor`.
 * Implements `runtime_process_argv_x_doc_anchor`.
 * @return i32
 */
export function runtime_process_argv_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

#[no_mangle]
export function xlang_process_argv_bind_from_crt(): void {
  unsafe {
    xlang_process_argv_bind_from_crt_impl();
  }
}
