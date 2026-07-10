// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-18：runtime_thread_glue 产品源迁 seeds/runtime_thread_glue.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_thread_glue.from_x.c → runtime_thread_glue.o
// G-02f-102：+ cpu_zero / cpu_set 薄门闩。

extern "C" function shu_cpu_zero_impl(set: *u8): void;
extern "C" function shu_cpu_set_impl(cpu: u32, set: *u8): void;

function runtime_thread_glue_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-102：cpu set helpers 门闩 ---- */

#[no_mangle]
function shu_cpu_zero(set: *u8): void {
  unsafe {
    shu_cpu_zero_impl(set);
  }
}

#[no_mangle]
function shu_cpu_set(cpu: u32, set: *u8): void {
  unsafe {
    shu_cpu_set_impl(cpu, set);
  }
}
