// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-28：真迁 .x — seed 链接兼容：LSP/heap 名桥 + 简单 weak 转发/回退桩。
// 产品：./shux-c -E → seeds/seed_link_compat.from_x.c（+ C 尾段 + weak 抛光）。
// C 尾：weak 空指针守卫调用、backend_fold 表达式分析、x86/arm/riscv emit、va_list asmf。

extern "C" function lsp_io_lsp_alloc(size: usize): *u8;
extern "C" function lsp_io_lsp_free(ptr: *u8): void;
extern "C" function lsp_io_lsp_is_null(ptr: *u8): i32;
extern "C" function lsp_main_impl(): i32;
extern "C" function lsp_io_std_heap_std_heap_alloc(size: usize): *u8;
extern "C" function lsp_io_std_heap_std_heap_alloc_zeroed(size: usize): *u8;
extern "C" function lsp_io_std_heap_std_heap_free(ptr: *u8): void;
extern "C" function std_sys_os_read_file_into(path: *u8, buf: *u8, cap: i32): i32;
extern "C" function std_heap_free(ptr: *u8): void;
extern "C" function pipeline_module_struct_layout_set_packed(module: *u8, idx: i32, v: i32): void;
extern "C" function asm_ctx_local_offset_at(ctx: *u8, idx: i32): i32;

/* ---- typeck/lsp name bridge ---- */

#[no_mangle]
function typeck_lsp_alloc(size: usize): *u8 {
  unsafe {
    let r: *u8 = lsp_io_lsp_alloc(size);
    return r;
  }
  return 0 as *u8;
}

#[no_mangle]
function typeck_lsp_free(ptr: *u8): void {
  unsafe {
    lsp_io_lsp_free(ptr);
  }
}

#[no_mangle]
function typeck_lsp_is_null(ptr: *u8): i32 {
  unsafe {
    let r: i32 = lsp_io_lsp_is_null(ptr);
    return r;
  }
  return 0;
}

#[no_mangle]
function typeck_lsp_main_impl(): i32 {
  unsafe {
    let r: i32 = lsp_main_impl();
    return r;
  }
  return 0;
}

#[no_mangle]
function typeck_std_heap_alloc(size: usize): *u8 {
  unsafe {
    let r: *u8 = lsp_io_std_heap_std_heap_alloc(size);
    return r;
  }
  return 0 as *u8;
}

#[no_mangle]
function typeck_std_heap_alloc_zeroed(size: usize): *u8 {
  unsafe {
    let r: *u8 = lsp_io_std_heap_std_heap_alloc_zeroed(size);
    return r;
  }
  return 0 as *u8;
}

#[no_mangle]
function typeck_std_heap_free(ptr: *u8): void {
  unsafe {
    lsp_io_std_heap_std_heap_free(ptr);
  }
}

#[no_mangle]
function std_sys_read_file_into(path: *u8, buf: *u8, cap: i32): i32 {
  unsafe {
    let r: i32 = std_sys_os_read_file_into(path, buf, cap);
    return r;
  }
  return 0;
}

#[no_mangle]
function std_heap_free_u8_ptr(ptr: *u8): void {
  unsafe {
    std_heap_free(ptr);
  }
}

#[no_mangle]
function ast_pipeline_module_struct_layout_set_packed(module: *u8, idx: i32, v: i32): void {
  unsafe {
    pipeline_module_struct_layout_set_packed(module, idx, v);
  }
}

#[no_mangle]
function backend_asm_ctx_slot_offset(ctx: *u8, slot_idx: i32): i32 {
  unsafe {
    let r: i32 = asm_ctx_local_offset_at(ctx, slot_idx);
    return r;
  }
  return 0;
}

/* ---- weak fallback stubs for optional lsp_diag symbols (seed 抛光 weak) ---- */

#[no_mangle]
function lsp_diag_lsp_build_diagnostics_response(id_val: i32, source: *u8, source_len: i32, out_buf: *u8,
                                                  out_cap: i32): i32 {
  return 0 - 1;
}

#[no_mangle]
function lsp_diag_lsp_build_semantic_tokens_response(id_val: i32, doc_buf: *u8, doc_len: i32, out_buf: *u8,
                                                     out_cap: i32): i32 {
  return 0 - 1;
}

#[no_mangle]
function lsp_diag_hover_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_buf: *u8,
                           out_cap: i32): i32 {
  return 0 - 1;
}

#[no_mangle]
function lsp_diag_references_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_lines: *i32,
                                out_cols: *i32, max_refs: i32): i32 {
  return 0 - 1;
}

#[no_mangle]
function lsp_diag_definition_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_line: *i32,
                                out_col: *i32): i32 {
  return 0 - 1;
}
