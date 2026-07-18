// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// lsp_diag_stubs_no_c_x_doc_anchor: see function docblock below.

/** Exported function `lsp_diag_stubs_no_c_x_doc_anchor`.
 * Implements `lsp_diag_stubs_no_c_x_doc_anchor`.
 * @return i32
 */
export function lsp_diag_stubs_no_c_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

// See implementation.
// See implementation.
// See implementation.
// lsp_diag_copy_text_impl: see function docblock below.
/** Exported function `lsp_diag_copy_text_impl`.
 * Implements `lsp_diag_copy_text_impl`.
 * @param dst *u8
 * @param cap i32
 * @param src *u8
 * @return void
 */
#[no_mangle]
export function lsp_diag_copy_text_impl(dst: *u8, cap: i32, src: *u8): void {
  if (dst == 0 || cap <= 0) { return; }
  if (src == 0) { dst[0] = 0; return; }
  let n: i32 = 0;
  while (n + 1 < cap && src[n] != 0) {
    dst[n] = src[n];
    n = n + 1;
  }
  dst[n] = 0;
}

// See implementation.
// See implementation.
// See implementation.
// json_escape_str_impl: see function docblock below.
/** Exported function `json_escape_str_impl`.
 * Implements `json_escape_str_impl`.
 * @param msg *u8
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
#[no_mangle]
export function json_escape_str_impl(msg: *u8, out: *u8, out_cap: i32): i32 {
  let k: i32 = 0;
  if (msg == 0 || out == 0 || out_cap <= 0) { return 0; }
  let i: i32 = 0;
  let bs: u8 = 92;
  let n_ch: u8 = 110;
  let r_ch: u8 = 114;
  let t_ch: u8 = 116;
  while (msg[i] != 0 && k < out_cap - 2) {
    let c: u8 = msg[i];
    if (c == 34 || c == 92) {
      if (k + 2 >= out_cap) { out[k] = 0; return k; }
      out[k] = bs; k = k + 1; out[k] = c; k = k + 1;
    } else if (c == 10) {
      if (k + 2 >= out_cap) { out[k] = 0; return k; }
      out[k] = bs; k = k + 1; out[k] = n_ch; k = k + 1;
    } else if (c == 13) {
      if (k + 2 >= out_cap) { out[k] = 0; return k; }
      out[k] = bs; k = k + 1; out[k] = r_ch; k = k + 1;
    } else if (c == 9) {
      if (k + 2 >= out_cap) { out[k] = 0; return k; }
      out[k] = bs; k = k + 1; out[k] = t_ch; k = k + 1;
    } else {
      out[k] = c; k = k + 1;
    }
    i = i + 1;
  }
  if (k < out_cap) { out[k] = 0; }
  return k;
}

/* See implementation. */

#[no_mangle]
export function lsp_diag_copy_text(dst: *u8, cap: i32, src: *u8): void {
  lsp_diag_copy_text_impl(dst, cap, src);
}

/** Exported function `json_escape_str`.
 * Implements `json_escape_str`.
 * @param msg *u8
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
#[no_mangle]
export function json_escape_str(msg: *u8, out: *u8, out_cap: i32): i32 {
  return json_escape_str_impl(msg, out, out_cap);
}
