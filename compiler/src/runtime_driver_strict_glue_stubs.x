// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-32：真迁 .x — strict glue 薄转发 / weak 指针读写桩。
// 产品：./shux-c -E → seeds/runtime_driver_strict_glue_stubs.from_x.c（+ C 尾 + weak 抛光）。
// C 尾：heap_user include、layout metrics 槽、lsp_codegen 文本块、preprocess 等。

extern "C" function driver_skip_codegen_dep_0_get(): i32;
extern "C" function driver_set_current_dep_path_for_codegen(path: *u8): void;
extern "C" function driver_diagnostic_pipe_marker(id: i32): void;

#[no_mangle]
function asm_driver_skip_codegen_dep_0_get(): i32 {
  unsafe {
    let r: i32 = driver_skip_codegen_dep_0_get();
    return r;
  }
  return 0;
}

#[no_mangle]
function asm_driver_set_current_dep_path_for_codegen(path: *u8): void {
  unsafe {
    driver_set_current_dep_path_for_codegen(path);
  }
}

#[no_mangle]
function typeck_driver_diagnostic_pipe_marker(id: i32): void {
  unsafe {
    driver_diagnostic_pipe_marker(id);
  }
}

#[no_mangle]
function typeck_i32_ptr_store(p: *i32, v: i32): void {
  if (p == 0 as *i32) {
    return;
  }
  unsafe {
    p[0] = v;
  }
}

#[no_mangle]
function typeck_i32_ptr_read(p: *i32): i32 {
  if (p == 0 as *i32) {
    return 0;
  }
  unsafe {
    let r: i32 = p[0];
    return r;
  }
  return 0;
}
