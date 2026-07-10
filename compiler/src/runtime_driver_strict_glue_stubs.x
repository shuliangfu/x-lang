// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-32/33：真迁 .x — strict glue 薄转发 / i32 指针 / layout metrics 读侧。
// 产品：./shux-c -E → seeds/runtime_driver_strict_glue_stubs.from_x.c（+ C 尾 + weak 抛光）。
// C 尾：heap_user、static metrics 槽数组、lsp_codegen 文本块、preprocess。
// metrics 槽指针函数仍在 C；.x 只做 init/read/peek 薄逻辑。

extern "C" function driver_skip_codegen_dep_0_get(): i32;
extern "C" function driver_set_current_dep_path_for_codegen(path: *u8): void;
extern "C" function driver_diagnostic_pipe_marker(id: i32): void;
extern "C" function typeck_layout_metrics_sz_slot(): *i32;
extern "C" function typeck_layout_metrics_al_slot(): *i32;
extern "C" function typeck_layout_metrics_sz_slot_depth(depth: i32): *i32;
extern "C" function typeck_layout_metrics_al_slot_depth(depth: i32): *i32;
extern "C" function typeck_call_resolve_dep_idx_slot(): *i32;
extern "C" function typeck_call_resolve_func_idx_slot(): *i32;

/* ---- G-02f-32 ---- */

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

/* ---- G-02f-33：metrics / call_resolve peek ---- */

#[no_mangle]
function typeck_layout_metrics_init_slot(): void {
  unsafe {
    let sz: *i32 = typeck_layout_metrics_sz_slot();
    let al: *i32 = typeck_layout_metrics_al_slot();
    sz[0] = 0;
    al[0] = 1;
  }
}

#[no_mangle]
function typeck_layout_metrics_init_depth(depth: i32): void {
  unsafe {
    let sz: *i32 = typeck_layout_metrics_sz_slot_depth(depth);
    let al: *i32 = typeck_layout_metrics_al_slot_depth(depth);
    sz[0] = 0;
    al[0] = 1;
  }
}

#[no_mangle]
function typeck_layout_metrics_al_read_depth(depth: i32): i32 {
  unsafe {
    let p: *i32 = typeck_layout_metrics_al_slot_depth(depth);
    let r: i32 = p[0];
    return r;
  }
  return 0;
}

#[no_mangle]
function typeck_layout_metrics_sz_read_depth(depth: i32): i32 {
  unsafe {
    let p: *i32 = typeck_layout_metrics_sz_slot_depth(depth);
    let r: i32 = p[0];
    return r;
  }
  return 0;
}

#[no_mangle]
function typeck_call_resolve_dep_idx_peek(): i32 {
  unsafe {
    let p: *i32 = typeck_call_resolve_dep_idx_slot();
    let r: i32 = p[0];
    return r;
  }
  return 0;
}

#[no_mangle]
function typeck_call_resolve_func_idx_peek(): i32 {
  unsafe {
    let p: *i32 = typeck_call_resolve_func_idx_slot();
    let r: i32 = p[0];
    return r;
  }
  return 0;
}
