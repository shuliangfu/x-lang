// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function lsp_io_lsp_alloc(size: usize): *u8;
export extern "C" function lsp_io_lsp_free(ptr: *u8): void;
export extern "C" function lsp_io_lsp_is_null(ptr: *u8): i32;
export extern "C" function lsp_main_impl(): i32;
export extern "C" function lsp_diag_lsp_build_diagnostics_response(id_val: i32, source: *u8, source_len: i32, out_buf: *u8, out_cap: i32): i32;
export extern "C" function lsp_diag_hover_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_buf: *u8, out_cap: i32): i32;
export extern "C" function lsp_diag_references_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_lines: *i32, out_cols: *i32, max_refs: i32): i32;
export extern "C" function lsp_diag_definition_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_line: *i32, out_col: *i32): i32;
export extern "C" function lsp_io_std_heap_std_heap_alloc(size: usize): *u8;
export extern "C" function lsp_io_std_heap_std_heap_alloc_zeroed(size: usize): *u8;
export extern "C" function lsp_io_std_heap_std_heap_free(ptr: *u8): void;
export extern "C" function std_sys_os_read_file_into(path: *u8, buf: *u8, cap: i32): i32;
export extern "C" function std_heap_free(ptr: *u8): void;
export extern "C" function pipeline_module_struct_layout_set_packed(module: *u8, idx: i32, v: i32): void;

export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_field_access_base_ref(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_var_name_len(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_var_name_into(arena: *u8, er: i32, out: *u8): void;
export extern "C" function pipeline_module_num_funcs(mod: *u8): i32;
export extern "C" function pipeline_asm_module_func_name_len_at(mod: *u8, fi: i32): i32;
export extern "C" function pipeline_asm_module_func_name_copy64(mod: *u8, fi: i32, dst: *u8): void;
export extern "C" function pipeline_module_func_param_name_len_at(mod: *u8, func_idx: i32, param_ix: i32): i32;
export extern "C" function pipeline_module_func_param_name_copy32(mod: *u8, func_idx: i32, param_ix: i32, dst: *u8): void;
export extern "C" function io_read(fd: i32, buf: *u8, count: usize, timeout_ms: u32): i64;
export extern "C" function io_write(fd: i32, buf: *u8, count: usize, timeout_ms: u32): i64;

/* ---- typeck/lsp name bridge ---- */

#[no_mangle]
export function typeck_lsp_alloc(size: usize): *u8 {
  unsafe {
    let r: *u8 = lsp_io_lsp_alloc(size);
    return r;
  }
  return 0 as *u8;
}

/** Exported function `typeck_lsp_free`.
 * Memory management helper `typeck_lsp_free`.
 * @param ptr *u8
 * @return void
 */
#[no_mangle]
export function typeck_lsp_free(ptr: *u8): void {
  unsafe {
    lsp_io_lsp_free(ptr);
  }
}

/** Exported function `typeck_lsp_is_null`.
 * Implements `typeck_lsp_is_null`.
 * @param ptr *u8
 * @return i32
 */
#[no_mangle]
export function typeck_lsp_is_null(ptr: *u8): i32 {
  unsafe {
    let r: i32 = lsp_io_lsp_is_null(ptr);
    return r;
  }
  return 0;
}

/** Exported function `typeck_lsp_main_impl`.
 * Implements `typeck_lsp_main_impl`.
 * @return i32
 */
#[no_mangle]
export function typeck_lsp_main_impl(): i32 {
  unsafe {
    let r: i32 = lsp_main_impl();
    return r;
  }
  return 0;
}

/**
 * Forward a diagnostics-response query to the LSP diagnostic object.
 * Params match lsp_diag_lsp_build_diagnostics_response.
 * Returns that function's result. The cold seed keeps a weak copy of this name.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_lsp_build_diagnostics_response(id_val: i32, source: *u8, source_len: i32, out_buf: *u8, out_cap: i32): i32 {
  unsafe {
    return lsp_diag_lsp_build_diagnostics_response(id_val, source, source_len, out_buf, out_cap);
  }
}

/**
 * Forward a hover query to the LSP diagnostic object.
 * Returns that function's result.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_lsp_diag_hover_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_buf: *u8, out_cap: i32): i32 {
  unsafe {
    return lsp_diag_hover_at(source, source_len, line_0, col_0, out_buf, out_cap);
  }
}

/**
 * Forward a references query to the LSP diagnostic object.
 * out_lines and out_cols receive the matches. max_refs is the capacity.
 * Returns that function's result.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_lsp_diag_references_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_lines: *i32, out_cols: *i32, max_refs: i32): i32 {
  unsafe {
    return lsp_diag_references_at(source, source_len, line_0, col_0, out_lines, out_cols, max_refs);
  }
}

/**
 * Forward a definition query to the LSP diagnostic object.
 * out_line and out_col receive the match.
 * Returns that function's result.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_lsp_diag_definition_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_line: *i32, out_col: *i32): i32 {
  unsafe {
    return lsp_diag_definition_at(source, source_len, line_0, col_0, out_line, out_col);
  }
}

/**
 * Forward the mangled std.io read name to io_read.
 * handle is the file descriptor. ptr/len are the buffer. timeout_ms is ignored by the stub.
 * Returns the byte count, or a negative error, narrowed to i32.
 * The cold seed keeps a weak copy of this name. PLATFORM: SHARED.
 */
#[no_mangle]
export function std_io_read_usize_u8_ptr_usize_u32(handle: usize, ptr: *u8, len: usize, timeout_ms: u32): i32 {
  unsafe {
    let n: i64 = io_read(handle as i32, ptr, len, timeout_ms);
    return n as i32;
  }
}

/**
 * Forward the mangled std.io write name to io_write.
 * handle is the file descriptor. ptr/len are the buffer. timeout_ms is ignored by the stub.
 * Returns the byte count, or a negative error, narrowed to i32.
 * The cold seed keeps a weak copy of this name. PLATFORM: SHARED.
 */
#[no_mangle]
export function std_io_write_usize_u8_ptr_usize_u32(handle: usize, ptr: *u8, len: usize, timeout_ms: u32): i32 {
  unsafe {
    let n: i64 = io_write(handle as i32, ptr, len, timeout_ms);
    return n as i32;
  }
}

/** Exported function `typeck_std_heap_alloc`.
 * Memory management helper `typeck_std_heap_alloc`.
 * @param size usize
 * @return *u8
 */
#[no_mangle]
export function typeck_std_heap_alloc(size: usize): *u8 {
  unsafe {
    let r: *u8 = lsp_io_std_heap_std_heap_alloc(size);
    return r;
  }
  return 0 as *u8;
}

/** Exported function `typeck_std_heap_alloc_zeroed`.
 * Memory management helper `typeck_std_heap_alloc_zeroed`.
 * @param size usize
 * @return *u8
 */
#[no_mangle]
export function typeck_std_heap_alloc_zeroed(size: usize): *u8 {
  unsafe {
    let r: *u8 = lsp_io_std_heap_std_heap_alloc_zeroed(size);
    return r;
  }
  return 0 as *u8;
}

/** Exported function `typeck_std_heap_free`.
 * Memory management helper `typeck_std_heap_free`.
 * @param ptr *u8
 * @return void
 */
#[no_mangle]
export function typeck_std_heap_free(ptr: *u8): void {
  unsafe {
    lsp_io_std_heap_std_heap_free(ptr);
  }
}

/** Exported function `std_sys_read_file_into`.
 * Read path helper `std_sys_read_file_into`.
 * @param path *u8
 * @param buf *u8
 * @param cap i32
 * @return i32
 */
#[no_mangle]
export function std_sys_read_file_into(path: *u8, buf: *u8, cap: i32): i32 {
  unsafe {
    let r: i32 = std_sys_os_read_file_into(path, buf, cap);
    return r;
  }
  return 0;
}

/** Exported function `std_heap_free_u8_ptr`.
 * Memory management helper `std_heap_free_u8_ptr`.
 * @param ptr *u8
 * @return void
 */
#[no_mangle]
export function std_heap_free_u8_ptr(ptr: *u8): void {
  unsafe {
    std_heap_free(ptr);
  }
}

/** Exported function `ast_pipeline_module_struct_layout_set_packed`.
 * Implements `ast_pipeline_module_struct_layout_set_packed`.
 * @param module *u8
 * @param idx i32
 * @param v i32
 * @return void
 */
#[no_mangle]
export function ast_pipeline_module_struct_layout_set_packed(module: *u8, idx: i32, v: i32): void {
  unsafe {
    pipeline_module_struct_layout_set_packed(module, idx, v);
  }
}

// backend.x owns backend_asm_ctx_slot_offset. lsp_diag_x.o owns the five
// lsp_diag_* queries. The copies here were a second strong definition
// (the lsp ones only returned -1).

/* See implementation. */

// xlang_expr_is_func_param_at: see function docblock below.
/** Exported function `xlang_expr_is_func_param_at`.
 * Implements `xlang_expr_is_func_param_at`.
 * @param arena *u8
 * @param mod *u8
 * @param func_idx i32
 * @param expr_ref i32
 * @param param_ix i32
 * @return i32
 */
#[no_mangle]
export function xlang_expr_is_func_param_at(arena: *u8, mod: *u8, func_idx: i32, expr_ref: i32, param_ix: i32): i32 {
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
    if (plen > 255) { return 0; }
    /* Cap 4.2.8: param_name_copy32 writes 256 bytes; pbuf[128] stack-smashed. */
    let pbuf: u8[256] = [];
    let vbuf: u8[256] = [];
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

// xlang_expr_is_param0_field_access: see function docblock below.
/** Exported function `xlang_expr_is_param0_field_access`.
 * Implements `xlang_expr_is_param0_field_access`.
 * @param arena *u8
 * @param mod *u8
 * @param func_idx i32
 * @param expr_ref i32
 * @return i32
 */
#[no_mangle]
export function xlang_expr_is_param0_field_access(arena: *u8, mod: *u8, func_idx: i32, expr_ref: i32): i32 {
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  if (func_idx < 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, expr_ref) != 44) { return 0; }
    let base_ref: i32 = pipeline_expr_field_access_base_ref(arena, expr_ref);
    return xlang_expr_is_func_param_at(arena, mod, func_idx, base_ref, 0);
  }
  return 0;
}

// xlang_module_func_index_by_name: see function docblock below.
/** Exported function `xlang_module_func_index_by_name`.
 * Implements `xlang_module_func_index_by_name`.
 * @param mod *u8
 * @param name *u8
 * @param name_len i32
 * @return i32
 */
#[no_mangle]
export function xlang_module_func_index_by_name(mod: *u8, name: *u8, name_len: i32): i32 {
  if (mod == 0) { return 0 - 1; }
  if (name == 0) { return 0 - 1; }
  if (name_len <= 0) { return 0 - 1; }
  if (name_len > 255) { return 0 - 1; }
  unsafe {
    let nfuncs: i32 = pipeline_module_num_funcs(mod);
    let fi: i32 = 0;
    while (fi < nfuncs) {
      let flen: i32 = pipeline_asm_module_func_name_len_at(mod, fi);
      if (flen == name_len) {
        let fb: u8[256] = [];
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
