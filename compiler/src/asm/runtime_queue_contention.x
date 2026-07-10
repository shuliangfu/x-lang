// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-21：runtime_queue_contention 产品源迁 seeds/runtime_queue_contention.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// G-02f-102：+ queue_smoke / worker_trampoline 薄门闩。

extern "C" function queue_smoke_at_impl(q: *u8, i: i32): i32;
extern "C" function queue_smoke_push_back_impl(q: *u8, x: i32): i32;
extern "C" function queue_os_worker_trampoline_impl(arg: *u8): *u8;

function runtime_queue_contention_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-102：queue smoke / trampoline 门闩 ---- */

#[no_mangle]
function queue_smoke_at(q: *u8, i: i32): i32 {
  unsafe {
    return queue_smoke_at_impl(q, i);
  }
  return 0;
}

#[no_mangle]
function queue_smoke_push_back(q: *u8, x: i32): i32 {
  unsafe {
    return queue_smoke_push_back_impl(q, x);
  }
  return 0;
}

#[no_mangle]
function queue_os_worker_trampoline(arg: *u8): *u8 {
  unsafe {
    return queue_os_worker_trampoline_impl(arg);
  }
  return 0 as *u8;
}
