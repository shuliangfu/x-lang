// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f：async_asm_pool 产品源迁 seeds/async_asm_pool.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// G-02f-104：+ await/var/live helpers 薄门闩。

extern "C" function asm_pool_expr_is_await_impl(a: *u8, er: i32): i32;
extern "C" function asm_pool_expr_has_await_impl(a: *u8, er: i32): i32;
extern "C" function asm_pool_expr_is_var_named_impl(a: *u8, er: i32, name: *u8, nlen: i32): i32;
extern "C" function asm_pool_expr_refs_name_impl(a: *u8, er: i32, name: *u8, nlen: i32): i32;
extern "C" function asm_pool_block_rest_refs_name_impl(a: *u8, br: i32, from_exclusive: i32, name: *u8,
                                                      nlen: i32): i32;
extern "C" function asm_pool_type_size_bytes_impl(a: *u8, m: *u8, type_ref: i32): i32;
extern "C" function asm_pool_live_add_impl(lay: *u8, name: *u8, nlen: i32, sz: i32): void;

function async_asm_pool_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-104：async asm pool helpers 门闩 ---- */

#[no_mangle]
function asm_pool_expr_is_await(a: *u8, er: i32): i32 {
  unsafe {
    return asm_pool_expr_is_await_impl(a, er);
  }
  return 0;
}

#[no_mangle]
function asm_pool_expr_has_await(a: *u8, er: i32): i32 {
  unsafe {
    return asm_pool_expr_has_await_impl(a, er);
  }
  return 0;
}

#[no_mangle]
function asm_pool_expr_is_var_named(a: *u8, er: i32, name: *u8, nlen: i32): i32 {
  unsafe {
    return asm_pool_expr_is_var_named_impl(a, er, name, nlen);
  }
  return 0;
}

#[no_mangle]
function asm_pool_expr_refs_name(a: *u8, er: i32, name: *u8, nlen: i32): i32 {
  unsafe {
    return asm_pool_expr_refs_name_impl(a, er, name, nlen);
  }
  return 0;
}

#[no_mangle]
function asm_pool_block_rest_refs_name(a: *u8, br: i32, from_exclusive: i32, name: *u8, nlen: i32): i32 {
  unsafe {
    return asm_pool_block_rest_refs_name_impl(a, br, from_exclusive, name, nlen);
  }
  return 0;
}

#[no_mangle]
function asm_pool_type_size_bytes(a: *u8, m: *u8, type_ref: i32): i32 {
  unsafe {
    return asm_pool_type_size_bytes_impl(a, m, type_ref);
  }
  return 0;
}

#[no_mangle]
function asm_pool_live_add(lay: *u8, name: *u8, nlen: i32, sz: i32): void {
  unsafe {
    asm_pool_live_add_impl(lay, name, nlen, sz);
  }
}
