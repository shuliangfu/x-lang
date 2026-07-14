// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-28：真迁 .x — seed 链接兼容：LSP/heap 名桥 + 简单 weak 转发/回退桩。
// G-02f-99：+ expr/param/func-index helpers 薄门闩。
// 产品：./shux-c -E → seeds/seed_link_compat.from_x.c（+ C 尾段 + weak 抛光）。
// C 尾：weak 空指针守卫调用、backend_fold 表达式分析、x86/arm/riscv emit、va_list asmf。

export extern "C" function lsp_io_lsp_alloc(size: usize): *u8;
export extern "C" function lsp_io_lsp_free(ptr: *u8): void;
export extern "C" function lsp_io_lsp_is_null(ptr: *u8): i32;
export extern "C" function lsp_main_impl(): i32;
export extern "C" function lsp_io_std_heap_std_heap_alloc(size: usize): *u8;
export extern "C" function lsp_io_std_heap_std_heap_alloc_zeroed(size: usize): *u8;
export extern "C" function lsp_io_std_heap_std_heap_free(ptr: *u8): void;
export extern "C" function std_sys_os_read_file_into(path: *u8, buf: *u8, cap: i32): i32;
export extern "C" function std_heap_free(ptr: *u8): void;
export extern "C" function pipeline_module_struct_layout_set_packed(module: *u8, idx: i32, v: i32): void;
export extern "C" function asm_ctx_local_offset_at(ctx: *u8, idx: i32): i32;

export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_field_access_base_ref(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_var_name_len(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_var_name_into(arena: *u8, er: i32, out: *u8): void;
export extern "C" function pipeline_module_num_funcs(mod: *u8): i32;
export extern "C" function pipeline_asm_module_func_name_len_at(mod: *u8, fi: i32): i32;
export extern "C" function pipeline_asm_module_func_name_copy64(mod: *u8, fi: i32, dst: *u8): void;
export extern "C" function pipeline_module_func_param_name_len_at(mod: *u8, func_idx: i32, param_ix: i32): i32;
export extern "C" function pipeline_module_func_param_name_copy32(mod: *u8, func_idx: i32, param_ix: i32, dst: *u8): void;

/* ---- typeck/lsp name bridge ---- */

#[no_mangle]
export function typeck_lsp_alloc(size: usize): *u8 {
  unsafe {
    let r: *u8 = lsp_io_lsp_alloc(size);
    return r;
  }
  return 0 as *u8;
}

#[no_mangle]
export function typeck_lsp_free(ptr: *u8): void {
  unsafe {
    lsp_io_lsp_free(ptr);
  }
}

#[no_mangle]
export function typeck_lsp_is_null(ptr: *u8): i32 {
  unsafe {
    let r: i32 = lsp_io_lsp_is_null(ptr);
    return r;
  }
  return 0;
}

#[no_mangle]
export function typeck_lsp_main_impl(): i32 {
  unsafe {
    let r: i32 = lsp_main_impl();
    return r;
  }
  return 0;
}

#[no_mangle]
export function typeck_std_heap_alloc(size: usize): *u8 {
  unsafe {
    let r: *u8 = lsp_io_std_heap_std_heap_alloc(size);
    return r;
  }
  return 0 as *u8;
}

#[no_mangle]
export function typeck_std_heap_alloc_zeroed(size: usize): *u8 {
  unsafe {
    let r: *u8 = lsp_io_std_heap_std_heap_alloc_zeroed(size);
    return r;
  }
  return 0 as *u8;
}

#[no_mangle]
export function typeck_std_heap_free(ptr: *u8): void {
  unsafe {
    lsp_io_std_heap_std_heap_free(ptr);
  }
}

#[no_mangle]
export function std_sys_read_file_into(path: *u8, buf: *u8, cap: i32): i32 {
  unsafe {
    let r: i32 = std_sys_os_read_file_into(path, buf, cap);
    return r;
  }
  return 0;
}

#[no_mangle]
export function std_heap_free_u8_ptr(ptr: *u8): void {
  unsafe {
    std_heap_free(ptr);
  }
}

#[no_mangle]
export function ast_pipeline_module_struct_layout_set_packed(module: *u8, idx: i32, v: i32): void {
  unsafe {
    pipeline_module_struct_layout_set_packed(module, idx, v);
  }
}

#[no_mangle]
export function backend_asm_ctx_slot_offset(ctx: *u8, slot_idx: i32): i32 {
  unsafe {
    let r: i32 = asm_ctx_local_offset_at(ctx, slot_idx);
    return r;
  }
  return 0;
}

/* ---- weak fallback stubs for optional lsp_diag symbols (seed 抛光 weak) ---- */

#[no_mangle]
export function lsp_diag_lsp_build_diagnostics_response(id_val: i32, source: *u8, source_len: i32, out_buf: *u8,
                                                  out_cap: i32): i32 {
  return 0 - 1;
}

#[no_mangle]
export function lsp_diag_lsp_build_semantic_tokens_response(id_val: i32, doc_buf: *u8, doc_len: i32, out_buf: *u8,
                                                     out_cap: i32): i32 {
  return 0 - 1;
}

#[no_mangle]
export function lsp_diag_hover_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_buf: *u8,
                           out_cap: i32): i32 {
  return 0 - 1;
}

#[no_mangle]
export function lsp_diag_references_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_lines: *i32,
                                out_cols: *i32, max_refs: i32): i32 {
  return 0 - 1;
}

#[no_mangle]
export function lsp_diag_definition_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_line: *i32,
                                out_col: *i32): i32 {
  return 0 - 1;
}

/* ---- G-02f-99：expr/param/func-index 门闩 ---- */

#[no_mangle]
// G-02f-132：VAR 是否为指定形参名
#[no_mangle]
export function shux_expr_is_func_param_at(arena: *u8, mod: *u8, func_idx: i32, expr_ref: i32, param_ix: i32): i32 {
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  if (param_ix < 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, expr_ref) != 3) { return 0; }
    let plen: i32 = pipeline_module_func_param_name_len_at(mod, func_idx, param_ix);
    let vlen: i32 = pipeline_expr_var_name_len(arena, expr_ref);
    if (plen <= 0) { return 0; }
    if (plen != vlen) { return 0; }
    if (plen > 31) { return 0; }
    let pbuf: u8[32] = [];
    let vbuf: u8[64] = [];
    pipeline_module_func_param_name_copy32(mod, func_idx, param_ix, &pbuf[0]);
    pipeline_expr_var_name_into(arena, expr_ref, &vbuf[0]);
    let k: i32 = 0;
    while (k < plen) {
      if (pbuf[k] != vbuf[k]) { return 0; }
      k = k + 1;
    }
    return 1;
  }
  return 0;
}

// G-02f-131：FIELD_ACCESS base 是否为 param0（kind 44）
#[no_mangle]
export function shux_expr_is_param0_field_access(arena: *u8, mod: *u8, func_idx: i32, expr_ref: i32): i32 {
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  if (func_idx < 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, expr_ref) != 44) { return 0; }
    let base_ref: i32 = pipeline_expr_field_access_base_ref(arena, expr_ref);
    return shux_expr_is_func_param_at(arena, mod, func_idx, base_ref, 0);
  }
  return 0;
}

// G-02f-131：按名查找 module 函数下标
#[no_mangle]
export function shux_module_func_index_by_name(mod: *u8, name: *u8, name_len: i32): i32 {
  if (mod == 0) { return 0 - 1; }
  if (name == 0) { return 0 - 1; }
  if (name_len <= 0) { return 0 - 1; }
  if (name_len > 63) { return 0 - 1; }
  unsafe {
    let nfuncs: i32 = pipeline_module_num_funcs(mod);
    let fi: i32 = 0;
    while (fi < nfuncs) {
      let flen: i32 = pipeline_asm_module_func_name_len_at(mod, fi);
      if (flen == name_len) {
        let fb: u8[64] = [];
        pipeline_asm_module_func_name_copy64(mod, fi, &fb[0]);
        let k: i32 = 0;
        let ok: i32 = 1;
        while (k < name_len) {
          if (fb[k] != name[k]) { ok = 0; break; }
          k = k + 1;
        }
        if (ok != 0) { return fi; }
      }
      fi = fi + 1;
    }
  }
  return 0 - 1;
}
