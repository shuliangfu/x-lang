// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function backtrace_u8_hex2_impl(b: u8, out: *u8): void;
export extern "C" function backtrace_capture_and_check_gold_c_impl(): i32;

/** Exported function `runtime_backtrace_platform_x_doc_anchor`.
 * Implements `runtime_backtrace_platform_x_doc_anchor`.
 * @return i32
 */
export function runtime_backtrace_platform_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

#[no_mangle]
export function backtrace_u8_hex2(b: u8, out: *u8): void {
  unsafe {
    backtrace_u8_hex2_impl(b, out);
  }
}



/* See implementation. */

#[no_mangle]
export function backtrace_capture_and_check_gold_c(): i32 {
  unsafe {
    return backtrace_capture_and_check_gold_c_impl();
  }
  return 0;
}

// See implementation.

export extern "C" function backtrace_name_has_gold_anchor_c(name: *u8): i32;

#[no_mangle]
/** Exported function `name_has_gold_anchor`.
 * Implements `name_has_gold_anchor`.
 * @param name *u8
 * @return i32
 */
export function name_has_gold_anchor(name: *u8): i32 {
  unsafe {
    return backtrace_name_has_gold_anchor_c(name);
  }
  return 0;
}

