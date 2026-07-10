// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-18：async_liveness 产品源迁 seeds/async_liveness.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/async_liveness.from_x.c → src/async/async_liveness.o

function async_liveness_x_doc_anchor(): i32 {
  return 0;
}

// G-02f-108：+ await/io/block/frame helpers 薄门闩。

extern "C" function async_liveness_callee_is_io_read_impl(f: *u8): i32;
extern "C" function async_liveness_callee_is_io_write_impl(f: *u8): i32;
extern "C" function block_has_await_impl(b: *u8): i32;
extern "C" function block_count_await_impl(b: *u8): i32;
extern "C" function block_has_io_read_await_impl(b: *u8): i32;
extern "C" function block_has_io_write_await_impl(b: *u8): i32;
extern "C" function block_refs_var_impl(b: *u8, name: *u8): i32;
extern "C" function block_rest_refs_var_impl(b: *u8, from: i32, name: *u8): i32;
extern "C" function frame_live_add_impl(out: *u8, name: *u8): void;

/* ---- G-02f-108：async_liveness helpers 门闩 ---- */

#[no_mangle]
function async_liveness_callee_is_io_read(f: *u8): i32 {
  unsafe { return async_liveness_callee_is_io_read_impl(f); }
  return 0;
}

#[no_mangle]
function async_liveness_callee_is_io_write(f: *u8): i32 {
  unsafe { return async_liveness_callee_is_io_write_impl(f); }
  return 0;
}

#[no_mangle]
function block_has_await(b: *u8): i32 {
  unsafe { return block_has_await_impl(b); }
  return 0;
}

#[no_mangle]
function block_count_await(b: *u8): i32 {
  unsafe { return block_count_await_impl(b); }
  return 0;
}

#[no_mangle]
function block_has_io_read_await(b: *u8): i32 {
  unsafe { return block_has_io_read_await_impl(b); }
  return 0;
}

#[no_mangle]
function block_has_io_write_await(b: *u8): i32 {
  unsafe { return block_has_io_write_await_impl(b); }
  return 0;
}

#[no_mangle]
function block_refs_var(b: *u8, name: *u8): i32 {
  unsafe { return block_refs_var_impl(b, name); }
  return 0;
}

#[no_mangle]
function block_rest_refs_var(b: *u8, from: i32, name: *u8): i32 {
  unsafe { return block_rest_refs_var_impl(b, from, name); }
  return 0;
}

#[no_mangle]
function frame_live_add(out: *u8, name: *u8): void {
  unsafe { frame_live_add_impl(out, name); }
}
