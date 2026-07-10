// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-18：runtime_channel_glue 产品源迁 seeds/runtime_channel_glue.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_channel_glue.from_x.c → runtime_channel_glue.o
// G-02f-106：+ sync init/destroy/lock/signal/broadcast 薄门闩。

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
