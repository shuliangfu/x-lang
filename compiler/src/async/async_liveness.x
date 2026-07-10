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

// G-02f-110：+ expr await/refs + frame analyze 薄门闩。

extern "C" function expr_has_await_impl(e: *u8): i32;
extern "C" function expr_count_await_impl(e: *u8): i32;
extern "C" function expr_has_io_read_await_impl(e: *u8): i32;
extern "C" function expr_has_io_write_await_impl(e: *u8): i32;
extern "C" function expr_refs_var_impl(e: *u8, name: *u8): i32;
extern "C" function frame_live_at_await_impl(b: *u8, idx: i32, defs: *u8, nd: i32, out: *u8): void;
extern "C" function live_name_cmp_impl(a: *u8, b: *u8): i32;
extern "C" function analyze_block_linear_impl(b: *u8, out: *u8): void;
extern "C" function frame_mangle_ident_impl(in_name: *u8, out: *u8, cap: i32): void;
extern "C" function frame_build_tag_impl(name: *u8, out: *u8, cap: i32): void;

/* ---- G-02f-110：async_liveness expr/frame 门闩 ---- */

#[no_mangle]
function expr_has_await(e: *u8): i32 { unsafe { return expr_has_await_impl(e); } return 0; }
#[no_mangle]
function expr_count_await(e: *u8): i32 { unsafe { return expr_count_await_impl(e); } return 0; }
#[no_mangle]
function expr_has_io_read_await(e: *u8): i32 { unsafe { return expr_has_io_read_await_impl(e); } return 0; }
#[no_mangle]
function expr_has_io_write_await(e: *u8): i32 { unsafe { return expr_has_io_write_await_impl(e); } return 0; }
#[no_mangle]
function expr_refs_var(e: *u8, name: *u8): i32 { unsafe { return expr_refs_var_impl(e, name); } return 0; }
#[no_mangle]
function frame_live_at_await(b: *u8, idx: i32, defs: *u8, nd: i32, out: *u8): void { unsafe { frame_live_at_await_impl(b, idx, defs, nd, out); } }
#[no_mangle]
function live_name_cmp(a: *u8, b: *u8): i32 { unsafe { return live_name_cmp_impl(a, b); } return 0; }
#[no_mangle]
function analyze_block_linear(b: *u8, out: *u8): void { unsafe { analyze_block_linear_impl(b, out); } }
#[no_mangle]
function frame_mangle_ident(in_name: *u8, out: *u8, cap: i32): void { unsafe { frame_mangle_ident_impl(in_name, out, cap); } }
#[no_mangle]
function frame_build_tag(name: *u8, out: *u8, cap: i32): void { unsafe { frame_build_tag_impl(name, out, cap); } }
