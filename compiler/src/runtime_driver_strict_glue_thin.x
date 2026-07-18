// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.

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
/** Exported function `asm_driver_skip_codegen_dep_0_get`.
 * Implements `asm_driver_skip_codegen_dep_0_get`.
 * @return i32
 */
export function asm_driver_skip_codegen_dep_0_get(): i32 {
  unsafe {
    let r: i32 = driver_skip_codegen_dep_0_get();
    return r;
  }
  return 0;
}

#[no_mangle]
/** Exported function `asm_driver_set_current_dep_path_for_codegen`.
 * Implements `asm_driver_set_current_dep_path_for_codegen`.
 * @param path *u8
 * @return void
 */
export function asm_driver_set_current_dep_path_for_codegen(path: *u8): void {
  unsafe {
    driver_set_current_dep_path_for_codegen(path);
  }
}

#[no_mangle]
/** Exported function `typeck_driver_diagnostic_pipe_marker`.
 * Implements `typeck_driver_diagnostic_pipe_marker`.
 * @param id i32
 * @return void
 */
export function typeck_driver_diagnostic_pipe_marker(id: i32): void {
  unsafe {
    driver_diagnostic_pipe_marker(id);
  }
}

#[no_mangle]
/** Exported function `typeck_i32_ptr_store`.
 * Implements `typeck_i32_ptr_store`.
 * @param p *i32
 * @param v i32
 * @return void
 */
export function typeck_i32_ptr_store(p: *i32, v: i32): void {
  if (p == 0 as *i32) {
    return;
  }
  unsafe {
    p[0] = v;
  }
}

#[no_mangle]
/** Exported function `typeck_i32_ptr_read`.
 * Read path helper `typeck_i32_ptr_read`.
 * @param p *i32
 * @return i32
 */
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
/** Exported function `typeck_layout_metrics_init_slot`.
 * Implements `typeck_layout_metrics_init_slot`.
 * @return void
 */
export function typeck_layout_metrics_init_slot(): void {
  unsafe {
    let sz: *i32 = typeck_layout_metrics_sz_slot();
    let al: *i32 = typeck_layout_metrics_al_slot();
    sz[0] = 0;
    al[0] = 1;
  }
}

#[no_mangle]
/** Exported function `typeck_layout_metrics_init_depth`.
 * Implements `typeck_layout_metrics_init_depth`.
 * @param depth i32
 * @return void
 */
export function typeck_layout_metrics_init_depth(depth: i32): void {
  unsafe {
    let sz: *i32 = typeck_layout_metrics_sz_slot_depth(depth);
    let al: *i32 = typeck_layout_metrics_al_slot_depth(depth);
    sz[0] = 0;
    al[0] = 1;
  }
}

#[no_mangle]
/** Exported function `typeck_layout_metrics_al_read_depth`.
 * Read path helper `typeck_layout_metrics_al_read_depth`.
 * @param depth i32
 * @return i32
 */
export function typeck_layout_metrics_al_read_depth(depth: i32): i32 {
  unsafe {
    let p: *i32 = typeck_layout_metrics_al_slot_depth(depth);
    let r: i32 = p[0];
    return r;
  }
  return 0;
}

#[no_mangle]
/** Exported function `typeck_layout_metrics_sz_read_depth`.
 * Read path helper `typeck_layout_metrics_sz_read_depth`.
 * @param depth i32
 * @return i32
 */
export function typeck_layout_metrics_sz_read_depth(depth: i32): i32 {
  unsafe {
    let p: *i32 = typeck_layout_metrics_sz_slot_depth(depth);
    let r: i32 = p[0];
    return r;
  }
  return 0;
}

#[no_mangle]
/** Exported function `typeck_call_resolve_dep_idx_peek`.
 * Implements `typeck_call_resolve_dep_idx_peek`.
 * @return i32
 */
export function typeck_call_resolve_dep_idx_peek(): i32 {
  unsafe {
    let p: *i32 = typeck_call_resolve_dep_idx_slot();
    let r: i32 = p[0];
    return r;
  }
  return 0;
}

#[no_mangle]
/** Exported function `typeck_call_resolve_func_idx_peek`.
 * Implements `typeck_call_resolve_func_idx_peek`.
 * @return i32
 */
export function typeck_call_resolve_func_idx_peek(): i32 {
  unsafe {
    let p: *i32 = typeck_call_resolve_func_idx_slot();
    let r: i32 = p[0];
    return r;
  }
  return 0;
}
