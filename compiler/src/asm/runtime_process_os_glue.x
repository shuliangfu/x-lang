// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function process_nop_sigchld_impl(sig: i32): void;
export extern "C" function process_dup_stdio_posix_impl(fd: i32, slot: i32): i32;

/** Exported function `runtime_process_os_glue_x_doc_anchor`.
 * Implements `runtime_process_os_glue_x_doc_anchor`.
 * @return i32
 */
export function runtime_process_os_glue_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

#[no_mangle]
export function process_nop_sigchld(sig: i32): void {
  unsafe {
    process_nop_sigchld_impl(sig);
  }
}

/** Exported function `process_dup_stdio_posix`.
 * Implements `process_dup_stdio_posix`.
 * @param fd i32
 * @param slot i32
 * @return i32
 */
#[no_mangle]
export function process_dup_stdio_posix(fd: i32, slot: i32): i32 {
  unsafe {
    return process_dup_stdio_posix_impl(fd, slot);
  }
  return 0 - 1;
}
