// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-23：真迁 .x — std.runtime panic/abort/evidence 薄转发。
// 产品：./shux-c -E → seeds/runtime_std_runtime_fast.from_x.c

extern "C" function shux_panic_(has_msg: i32, msg_val: i32): void;
extern "C" function shux_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void;

#[no_mangle]
function std_runtime_crash_evidence_collect(has_msg: i32, msg_val: i32): void {
  unsafe {
    shux_crash_evidence_collect_c(has_msg, msg_val);
  }
}

#[no_mangle]
function runtime_crash_evidence_collect_c(has_msg: i32, msg_val: i32): void {
  std_runtime_crash_evidence_collect(has_msg, msg_val);
}

#[no_mangle]
function std_runtime_runtime_panic(): void {
  unsafe {
    shux_panic_(0, 0);
  }
}

#[no_mangle]
function runtime_panic(): void {
  unsafe {
    shux_panic_(0, 0);
  }
}

#[no_mangle]
function std_runtime_runtime_abort(): void {
  unsafe {
    shux_panic_(0, 0);
  }
}

#[no_mangle]
function runtime_abort(): void {
  unsafe {
    shux_panic_(0, 0);
  }
}
