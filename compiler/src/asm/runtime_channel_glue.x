// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-18：runtime_channel_glue 产品源迁 seeds/runtime_channel_glue.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_channel_glue.from_x.c → runtime_channel_glue.o
// G-02f-106：+ sync init/destroy/lock/signal/broadcast 薄门闩。
// G-02f-107：+ wait/timedwait/grow/select 薄门闩。

extern "C" function channel_sync_init_impl(c: *u8): void;
extern "C" function channel_sync_destroy_impl(c: *u8): void;
extern "C" function channel_lock_impl(c: *u8): void;
extern "C" function channel_unlock_impl(c: *u8): void;
extern "C" function channel_signal_not_empty_impl(c: *u8): void;
extern "C" function channel_signal_not_full_impl(c: *u8): void;
extern "C" function channel_broadcast_not_empty_impl(c: *u8): void;
extern "C" function channel_broadcast_not_full_impl(c: *u8): void;

function runtime_channel_glue_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-106：channel sync helpers 门闩 ---- */

#[no_mangle]
function channel_sync_init(c: *u8): void {
  unsafe { channel_sync_init_impl(c); }
}

#[no_mangle]
function channel_sync_destroy(c: *u8): void {
  unsafe { channel_sync_destroy_impl(c); }
}

#[no_mangle]
function channel_lock(c: *u8): void {
  unsafe { channel_lock_impl(c); }
}

#[no_mangle]
function channel_unlock(c: *u8): void {
  unsafe { channel_unlock_impl(c); }
}

#[no_mangle]
function channel_signal_not_empty(c: *u8): void {
  unsafe { channel_signal_not_empty_impl(c); }
}

#[no_mangle]
function channel_signal_not_full(c: *u8): void {
  unsafe { channel_signal_not_full_impl(c); }
}

#[no_mangle]
function channel_broadcast_not_empty(c: *u8): void {
  unsafe { channel_broadcast_not_empty_impl(c); }
}

#[no_mangle]
function channel_broadcast_not_full(c: *u8): void {
  unsafe { channel_broadcast_not_full_impl(c); }
}

extern "C" function channel_wait_not_empty_impl(c: *u8): void;
extern "C" function channel_wait_not_full_impl(c: *u8): void;
extern "C" function channel_timedwait_not_empty_impl(c: *u8, ms: i32): void;
extern "C" function channel_timedwait_not_full_impl(c: *u8, ms: i32): void;
extern "C" function channel_unbounded_grow_impl(c: *u8): i32;
extern "C" function channel_select_recv_case_live_impl(c: *u8): i32;
extern "C" function channel_select_send_case_live_impl(c: *u8): i32;
extern "C" function channel_select_wait_recv_one_impl(cs: *u8, n: i32): i32;
extern "C" function channel_select_wait_send_one_impl(cs: *u8, n: i32): i32;

/* ---- G-02f-107：channel wait/select 门闩 ---- */

#[no_mangle]
function channel_wait_not_empty(c: *u8): void { unsafe { channel_wait_not_empty_impl(c); } }

#[no_mangle]
function channel_wait_not_full(c: *u8): void { unsafe { channel_wait_not_full_impl(c); } }

#[no_mangle]
function channel_timedwait_not_empty(c: *u8, ms: i32): void {
  unsafe { channel_timedwait_not_empty_impl(c, ms); }
}

#[no_mangle]
function channel_timedwait_not_full(c: *u8, ms: i32): void {
  unsafe { channel_timedwait_not_full_impl(c, ms); }
}

#[no_mangle]
function channel_unbounded_grow(c: *u8): i32 {
  unsafe { return channel_unbounded_grow_impl(c); }
  return 0;
}

#[no_mangle]
function channel_select_recv_case_live(c: *u8): i32 {
  unsafe { return channel_select_recv_case_live_impl(c); }
  return 0;
}

#[no_mangle]
function channel_select_send_case_live(c: *u8): i32 {
  unsafe { return channel_select_send_case_live_impl(c); }
  return 0;
}

#[no_mangle]
function channel_select_wait_recv_one(cs: *u8, n: i32): i32 {
  unsafe { return channel_select_wait_recv_one_impl(cs, n); }
  return 0;
}

#[no_mangle]
function channel_select_wait_send_one(cs: *u8, n: i32): i32 {
  unsafe { return channel_select_wait_send_one_impl(cs, n); }
  return 0;
}

