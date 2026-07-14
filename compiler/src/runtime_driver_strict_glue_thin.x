// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-258 / L2-4 第 3 TU：strict glue 纯薄转发子集（无 OS / 无大 C 尾）。
// 产品默认仍链 seeds/runtime_driver_strict_glue_stubs.from_x.c 整文件。
// SHUX_G05_PREFER_X_O=1 时：本 TU .x→-E→.o + seed 残体（-DSHUX_L2_STRICT_GLUE_THIN_FROM_X）ld -r。
//
// 故意不含 append_text_to_codegen_buf（.x 侧依赖 _impl；seed 内为整函数体）。
// 槽指针 typeck_*_slot* 仍 🔒 seed。

export extern "C" function driver_skip_codegen_dep_0_get(): i32;
export extern "C" function driver_set_current_dep_path_for_codegen(path: *u8): void;
export extern "C" function driver_diagnostic_pipe_marker(id: i32): void;
export extern "C" function typeck_layout_metrics_sz_slot(): *i32;
export extern "C" function typeck_layout_metrics_al_slot(): *i32;
export extern "C" function typeck_layout_metrics_sz_slot_depth(depth: i32): *i32;
export extern "C" function typeck_layout_metrics_al_slot_depth(depth: i32): *i32;
export extern "C" function typeck_call_resolve_dep_idx_slot(): *i32;
export extern "C" function typeck_call_resolve_func_idx_slot(): *i32;

#[no_mangle]
export function asm_driver_skip_codegen_dep_0_get(): i32 {
  unsafe {
    let r: i32 = driver_skip_codegen_dep_0_get();
    return r;
  }
  return 0;
}

#[no_mangle]
export function asm_driver_set_current_dep_path_for_codegen(path: *u8): void {
  unsafe {
    driver_set_current_dep_path_for_codegen(path);
  }
}

#[no_mangle]
export function typeck_driver_diagnostic_pipe_marker(id: i32): void {
  unsafe {
    driver_diagnostic_pipe_marker(id);
  }
}

#[no_mangle]
export function typeck_i32_ptr_store(p: *i32, v: i32): void {
  if (p == 0 as *i32) {
    return;
  }
  unsafe {
    p[0] = v;
  }
}

#[no_mangle]
export function typeck_i32_ptr_read(p: *i32): i32 {
  if (p == 0 as *i32) {
    return 0;
  }
  unsafe {
    let r: i32 = p[0];
    return r;
  }
  return 0;
}

#[no_mangle]
export function typeck_layout_metrics_init_slot(): void {
  unsafe {
    let sz: *i32 = typeck_layout_metrics_sz_slot();
    let al: *i32 = typeck_layout_metrics_al_slot();
    sz[0] = 0;
    al[0] = 1;
  }
}

#[no_mangle]
export function typeck_layout_metrics_init_depth(depth: i32): void {
  unsafe {
    let sz: *i32 = typeck_layout_metrics_sz_slot_depth(depth);
    let al: *i32 = typeck_layout_metrics_al_slot_depth(depth);
    sz[0] = 0;
    al[0] = 1;
  }
}

#[no_mangle]
export function typeck_layout_metrics_al_read_depth(depth: i32): i32 {
  unsafe {
    let p: *i32 = typeck_layout_metrics_al_slot_depth(depth);
    let r: i32 = p[0];
    return r;
  }
  return 0;
}

#[no_mangle]
export function typeck_layout_metrics_sz_read_depth(depth: i32): i32 {
  unsafe {
    let p: *i32 = typeck_layout_metrics_sz_slot_depth(depth);
    let r: i32 = p[0];
    return r;
  }
  return 0;
}

#[no_mangle]
export function typeck_call_resolve_dep_idx_peek(): i32 {
  unsafe {
    let p: *i32 = typeck_call_resolve_dep_idx_slot();
    let r: i32 = p[0];
    return r;
  }
  return 0;
}

#[no_mangle]
export function typeck_call_resolve_func_idx_peek(): i32 {
  unsafe {
    let p: *i32 = typeck_call_resolve_func_idx_slot();
    let r: i32 = p[0];
    return r;
  }
  return 0;
}
