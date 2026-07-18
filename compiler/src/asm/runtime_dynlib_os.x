// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// runtime_dynlib_os_x_doc_anchor: see function docblock below.

/** Exported function `runtime_dynlib_os_x_doc_anchor`.
 * Implements `runtime_dynlib_os_x_doc_anchor`.
 * @return i32
 */
export function runtime_dynlib_os_x_doc_anchor(): i32 {
  return 0;
}

// See implementation.

export extern "C" function dynlib_win_load_library_w_utf8_impl(path: *u8): *u8;

/* See implementation. */


#[no_mangle]
export function dynlib_win_load_library_w_utf8(path: *u8): *u8 {
  unsafe { return dynlib_win_load_library_w_utf8_impl(path); }
}

// dynlib_win_normalize_path: see function docblock below.

#[no_mangle]
/** Exported function `dynlib_win_normalize_path`.
 * Implements `dynlib_win_normalize_path`.
 * @param out *u8
 * @param out_cap i32
 * @param path *u8
 * @return i32
 */
export function dynlib_win_normalize_path(out: *u8, out_cap: i32, path: *u8): i32 {
  if (out == 0) { return 0; }
  if (out_cap < 2) { return 0; }
  if (path == 0) { return 0; }
  let i: i32 = 0;
  while (path[i] != 0) {
    if (i + 1 >= out_cap) { break; }
    let c: u8 = path[i];
    if (c == 47) { c = 92; } // '/' -> '\\'
    out[i] = c;
    i = i + 1;
  }
  out[i] = 0;
  return i;
}
