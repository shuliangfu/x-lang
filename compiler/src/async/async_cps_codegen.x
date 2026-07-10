// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-18：async_cps_codegen 产品源迁 seeds/async_cps_codegen.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/async_cps_codegen.from_x.c → src/async/async_cps_codegen.o
// G-02f-105：+ emit_hoisted_lets / callee_is_io / future_wait 薄门闩。

extern "C" function emit_hoisted_lets_impl(f: *u8, out: *u8): void;
extern "C" function async_cps_callee_is_io_impl(callee: *u8): i32;
extern "C" function async_cps_callee_is_future_wait_by_name_impl(n: *u8): i32;
extern "C" function async_cps_callee_is_future_wait_impl(callee: *u8): i32;

function async_cps_codegen_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-105：async cps helpers 门闩 ---- */

#[no_mangle]
function emit_hoisted_lets(f: *u8, out: *u8): void {
  unsafe {
    emit_hoisted_lets_impl(f, out);
  }
}

#[no_mangle]
function async_cps_callee_is_io(callee: *u8): i32 {
  unsafe {
    return async_cps_callee_is_io_impl(callee);
  }
  return 0;
}

#[no_mangle]
function async_cps_callee_is_future_wait_by_name(n: *u8): i32 {
  unsafe {
    return async_cps_callee_is_future_wait_by_name_impl(n);
  }
  return 0;
}

#[no_mangle]
function async_cps_callee_is_future_wait(callee: *u8): i32 {
  unsafe {
    return async_cps_callee_is_future_wait_impl(callee);
  }
  return 0;
}
