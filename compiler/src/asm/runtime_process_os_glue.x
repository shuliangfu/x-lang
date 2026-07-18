// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-18：runtime_process_os_glue 产品源迁 seeds/runtime_process_os_glue.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_process_os_glue.from_x.c → runtime_process_os_glue.o
// G-02f-103：+ nop_sigchld / dup_stdio_posix 薄门闩。

export extern "C" function process_nop_sigchld_impl(sig: i32): void;
export extern "C" function process_dup_stdio_posix_impl(fd: i32, slot: i32): i32;

export function runtime_process_os_glue_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-103：process helpers 门闩 ---- */

#[no_mangle]
export function process_nop_sigchld(sig: i32): void {
  unsafe {
    process_nop_sigchld_impl(sig);
  }
}

#[no_mangle]
export function process_dup_stdio_posix(fd: i32, slot: i32): i32 {
  unsafe {
    return process_dup_stdio_posix_impl(fd, slot);
  }
  return 0 - 1;
}
