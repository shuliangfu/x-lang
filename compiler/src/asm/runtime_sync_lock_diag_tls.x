// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-19：runtime_sync_lock_diag_tls 产品源迁 seeds/runtime_sync_lock_diag_tls.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_sync_lock_diag_tls.from_x.c → runtime_sync_lock_diag_tls.o
// G-02f-101：+ append_byte / append_lit / append_i32 薄门闩。
// G-02f-102：+ find_meta_idx / get_order 薄门闩。

extern "C" function sync_lock_diag_append_byte_impl(out: *u8, pos: i32, cap: i32, b: u8): i32;
extern "C" function sync_lock_diag_append_lit_impl(out: *u8, pos: i32, cap: i32, s: *u8, n: i32): i32;
extern "C" function sync_lock_diag_append_i32_impl(out: *u8, pos: i32, cap: i32, v: i32): i32;
extern "C" function sync_lock_diag_find_meta_idx_impl(m: *u8): i32;
extern "C" function sync_lock_diag_get_order_impl(m: *u8): i32;

function runtime_sync_lock_diag_tls_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-101：sync lock diag append 门闩 ---- */

#[no_mangle]
function sync_lock_diag_append_byte(out: *u8, pos: i32, cap: i32, b: u8): i32 {
  unsafe {
    return sync_lock_diag_append_byte_impl(out, pos, cap, b);
  }
  return 0 - 1;
}

#[no_mangle]
function sync_lock_diag_append_lit(out: *u8, pos: i32, cap: i32, s: *u8, n: i32): i32 {
  unsafe {
    return sync_lock_diag_append_lit_impl(out, pos, cap, s, n);
  }
  return 0 - 1;
}

#[no_mangle]
function sync_lock_diag_append_i32(out: *u8, pos: i32, cap: i32, v: i32): i32 {
  unsafe {
    return sync_lock_diag_append_i32_impl(out, pos, cap, v);
  }
  return 0 - 1;
}

/* ---- G-02f-102：meta/order 门闩 ---- */

#[no_mangle]
function sync_lock_diag_find_meta_idx(m: *u8): i32 {
  unsafe {
    return sync_lock_diag_find_meta_idx_impl(m);
  }
  return 0 - 1;
}

#[no_mangle]
function sync_lock_diag_get_order(m: *u8): i32 {
  unsafe {
    return sync_lock_diag_get_order_impl(m);
  }
  return 0;
}
