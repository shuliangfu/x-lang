// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function random_get_alg_impl(): *u8;

/** Exported function `runtime_random_fill_x_doc_anchor`.
 * Implements `runtime_random_fill_x_doc_anchor`.
 * @return i32
 */
export function runtime_random_fill_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

#[no_mangle]
export function random_get_alg(): *u8 {
  unsafe {
    return random_get_alg_impl();
  }
  return 0 as *u8;
}
