// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
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

/* ---- G-02f-32 ---- */

#[no_mangle]
export function asm_driver_skip_codegen_dep_0_get(): i32 {
  unsafe {
    let r: i32 = driver_skip_codegen_dep_0_get();
    return r;
  }
  return 0;
}

/** Exported function `asm_driver_set_current_dep_path_for_codegen`.
 * Implements `asm_driver_set_current_dep_path_for_codegen`.
 * @param path *u8
 * @return void
 */
#[no_mangle]
export function asm_driver_set_current_dep_path_for_codegen(path: *u8): void {
  unsafe {
    driver_set_current_dep_path_for_codegen(path);
  }
}

/** Exported function `typeck_driver_diagnostic_pipe_marker`.
 * Implements `typeck_driver_diagnostic_pipe_marker`.
 * @param id i32
 * @return void
 */
#[no_mangle]
export function typeck_driver_diagnostic_pipe_marker(id: i32): void {
  unsafe {
    driver_diagnostic_pipe_marker(id);
  }
}

/** Exported function `typeck_i32_ptr_store`.
 * Implements `typeck_i32_ptr_store`.
 * @param p *i32
 * @param v i32
 * @return void
 */
#[no_mangle]
export function typeck_i32_ptr_store(p: *i32, v: i32): void {
  if (p == 0 as *i32) {
    return;
  }
  unsafe {
    p[0] = v;
  }
}

/** Exported function `typeck_i32_ptr_read`.
 * Read path helper `typeck_i32_ptr_read`.
 * @param p *i32
 * @return i32
 */
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

/* ---- G-02f-33：metrics / call_resolve peek ---- */

#[no_mangle]
export function typeck_layout_metrics_init_slot(): void {
  unsafe {
    let sz: *i32 = typeck_layout_metrics_sz_slot();
    let al: *i32 = typeck_layout_metrics_al_slot();
    sz[0] = 0;
    al[0] = 1;
  }
}

/** Exported function `typeck_layout_metrics_init_depth`.
 * Implements `typeck_layout_metrics_init_depth`.
 * @param depth i32
 * @return void
 */
#[no_mangle]
export function typeck_layout_metrics_init_depth(depth: i32): void {
  unsafe {
    let sz: *i32 = typeck_layout_metrics_sz_slot_depth(depth);
    let al: *i32 = typeck_layout_metrics_al_slot_depth(depth);
    sz[0] = 0;
    al[0] = 1;
  }
}

/** Exported function `typeck_layout_metrics_al_read_depth`.
 * Read path helper `typeck_layout_metrics_al_read_depth`.
 * @param depth i32
 * @return i32
 */
#[no_mangle]
export function typeck_layout_metrics_al_read_depth(depth: i32): i32 {
  unsafe {
    let p: *i32 = typeck_layout_metrics_al_slot_depth(depth);
    let r: i32 = p[0];
    return r;
  }
  return 0;
}

/** Exported function `typeck_layout_metrics_sz_read_depth`.
 * Read path helper `typeck_layout_metrics_sz_read_depth`.
 * @param depth i32
 * @return i32
 */
#[no_mangle]
export function typeck_layout_metrics_sz_read_depth(depth: i32): i32 {
  unsafe {
    let p: *i32 = typeck_layout_metrics_sz_slot_depth(depth);
    let r: i32 = p[0];
    return r;
  }
  return 0;
}

/** Exported function `typeck_call_resolve_dep_idx_peek`.
 * Implements `typeck_call_resolve_dep_idx_peek`.
 * @return i32
 */
#[no_mangle]
export function typeck_call_resolve_dep_idx_peek(): i32 {
  unsafe {
    let p: *i32 = typeck_call_resolve_dep_idx_slot();
    let r: i32 = p[0];
    return r;
  }
  return 0;
}

/** Exported function `typeck_call_resolve_func_idx_peek`.
 * Implements `typeck_call_resolve_func_idx_peek`.
 * @return i32
 */
#[no_mangle]
export function typeck_call_resolve_func_idx_peek(): i32 {
  unsafe {
    let p: *i32 = typeck_call_resolve_func_idx_slot();
    let r: i32 = p[0];
    return r;
  }
  return 0;
}

/* See implementation. */

export extern "C" function append_text_to_codegen_buf_impl(out: *u8, text: *u8): i32;

/** Exported function `append_text_to_codegen_buf`.
 * Implements `append_text_to_codegen_buf`.
 * @param out *u8
 * @param text *u8
 * @return i32
 */
#[no_mangle]
export function append_text_to_codegen_buf(out: *u8, text: *u8): i32 {
  unsafe {
    return append_text_to_codegen_buf_impl(out, text);
  }
  return 0 - 1;
}
