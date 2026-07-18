// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function sync_lock_diag_find_meta_idx_impl(m: *u8): i32;
export extern "C" function sync_lock_diag_get_order_impl(m: *u8): i32;

/** Exported function `runtime_sync_lock_diag_tls_x_doc_anchor`.
 * Implements `runtime_sync_lock_diag_tls_x_doc_anchor`.
 * @return i32
 */
export function runtime_sync_lock_diag_tls_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */







/* See implementation. */

#[no_mangle]
export function sync_lock_diag_find_meta_idx(m: *u8): i32 {
  unsafe {
    return sync_lock_diag_find_meta_idx_impl(m);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `sync_lock_diag_get_order`.
 * Implements `sync_lock_diag_get_order`.
 * @param m *u8
 * @return i32
 */
export function sync_lock_diag_get_order(m: *u8): i32 {
  unsafe {
    return sync_lock_diag_get_order_impl(m);
  }
  return 0;
}

// sync_lock_diag_append_byte: see function docblock below.

#[no_mangle]
/** Exported function `sync_lock_diag_append_byte`.
 * Implements `sync_lock_diag_append_byte`.
 * @param out *u8
 * @param pos i32
 * @param cap i32
 * @param b u8
 * @return i32
 */
export function sync_lock_diag_append_byte(out: *u8, pos: i32, cap: i32, b: u8): i32 {
  if (out == 0) { return 0 - 1; }
  if (pos < 0) { return 0 - 1; }
  if (pos >= cap) { return 0 - 1; }
  out[pos] = b;
  return pos + 1;
}

#[no_mangle]
/** Exported function `sync_lock_diag_append_lit`.
 * Implements `sync_lock_diag_append_lit`.
 * @param out *u8
 * @param pos i32
 * @param cap i32
 * @param s *u8
 * @param n i32
 * @return i32
 */
export function sync_lock_diag_append_lit(out: *u8, pos: i32, cap: i32, s: *u8, n: i32): i32 {
  let i: i32 = 0;
  while (i < n) {
    pos = sync_lock_diag_append_byte(out, pos, cap, s[i]);
    if (pos < 0) { return 0 - 1; }
    i = i + 1;
  }
  return pos;
}

#[no_mangle]
/** Exported function `sync_lock_diag_append_i32`.
 * Implements `sync_lock_diag_append_i32`.
 * @param out *u8
 * @param pos i32
 * @param cap i32
 * @param v i32
 * @return i32
 */
export function sync_lock_diag_append_i32(out: *u8, pos: i32, cap: i32, v: i32): i32 {
  if (out == 0) { return 0 - 1; }
  if (pos < 0) { return 0 - 1; }
  if (cap <= pos) { return 0 - 1; }
  if (v == 0) {
    return sync_lock_diag_append_byte(out, pos, cap, 48);
  }
  let x: i32 = v;
  if (x < 0) {
    pos = sync_lock_diag_append_byte(out, pos, cap, 45);
    if (pos < 0) { return 0 - 1; }
    x = 0 - x;
  }
  let d0: i32 = 0;
  let d1: i32 = 0;
  let d2: i32 = 0;
  let d3: i32 = 0;
  let d4: i32 = 0;
  let d5: i32 = 0;
  let d6: i32 = 0;
  let d7: i32 = 0;
  let d8: i32 = 0;
  let d9: i32 = 0;
  let n: i32 = 0;
  while (x > 0) {
    let dig: i32 = x - (x / 10) * 10;
    if (n == 0) { d0 = dig; }
    if (n == 1) { d1 = dig; }
    if (n == 2) { d2 = dig; }
    if (n == 3) { d3 = dig; }
    if (n == 4) { d4 = dig; }
    if (n == 5) { d5 = dig; }
    if (n == 6) { d6 = dig; }
    if (n == 7) { d7 = dig; }
    if (n == 8) { d8 = dig; }
    if (n == 9) { d9 = dig; }
    n = n + 1;
    x = x / 10;
  }
  while (n > 0) {
    n = n - 1;
    let dig: i32 = 0;
    if (n == 0) { dig = d0; }
    if (n == 1) { dig = d1; }
    if (n == 2) { dig = d2; }
    if (n == 3) { dig = d3; }
    if (n == 4) { dig = d4; }
    if (n == 5) { dig = d5; }
    if (n == 6) { dig = d6; }
    if (n == 7) { dig = d7; }
    if (n == 8) { dig = d8; }
    if (n == 9) { dig = d9; }
    let ch: u8 = (dig + 48) as u8;
    pos = sync_lock_diag_append_byte(out, pos, cap, ch);
    if (pos < 0) { return 0 - 1; }
  }
  return pos;
}

