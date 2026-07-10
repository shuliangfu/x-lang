// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-22：runtime_panic_arm64 产品源迁 seeds/runtime_panic_arm64.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// G-02f-107：+ crash_evidence_minimal 薄门闩。

extern "C" function shux_crash_evidence_minimal_impl(has_msg: i32, msg_val: i32): void;

function runtime_panic_arm64_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-107：arm64 crash evidence 门闩 ---- */

#[no_mangle]
function shux_crash_evidence_minimal(has_msg: i32, msg_val: i32): void {
  unsafe {
    shux_crash_evidence_minimal_impl(has_msg, msg_val);
  }
}
