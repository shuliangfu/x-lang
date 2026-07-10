// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-28：真迁 .x — LSP pipeline ctx 尺寸桥 + typeck_ 前缀去前缀别名。
// G-02f-74：+ remaining lsp_diag_pipeline_ctx gates.
// 产品：./shux-c -E → seeds/lsp_diag_pipeline_ctx.from_x.c（+ C 尾段 + weak 抛光）。
// C 尾：fill_paths（struct memset/strlen）、g_lsp_state_buf 静态、typeck_lsp_main 大栈、
//       lsp_write_all（EINTR/write）、lsp_definition_at 出参逻辑。

extern "C" function pipeline_sizeof_dep_ctx(): usize;
extern "C" function typeck_lsp_build_diagnostics_response(id_val: i32, source: *u8, source_len: i32,
                                                          out_buf: *u8, out_cap: i32): i32;
extern "C" function typeck_lsp_diag_hover_at(source: *u8, source_len: i32, line_0: i32, col_0: i32,
                                             out_buf: *u8, out_cap: i32): i32;
extern "C" function typeck_lsp_diag_references_at(source: *u8, source_len: i32, line_0: i32, col_0: i32,
                                                  out_lines: *i32, out_cols: *i32, max_refs: i32): i32;
extern "C" function typeck_lsp_diag_definition_at(source: *u8, source_len: i32, line_0: i32, col_0: i32,
                                                  out_line: *i32, out_col: *i32): i32;
extern "C" function typeck_lsp_build_semantic_tokens_response(id_val: i32, doc_buf: *u8, doc_len: i32,
                                                              out_buf: *u8, out_cap: i32): i32;
extern "C" function lsp_diag_invalidate_cache(): void;

extern "C" function lsp_diag_pipeline_ctx_fill_paths_impl(ctx_void: *u8, entry_dir: *u8, lib_roots: *u8, n_lib_roots: i32): void;
extern "C" function typeck_lsp_main_impl(): i32;
extern "C" function lsp_write_all_impl(fd: i32, buf: *u8, len: i32): i32;

#[no_mangle]
function lsp_diag_x_alloc_dep_ctx_size(): usize {
  unsafe {
    let r: usize = pipeline_sizeof_dep_ctx();
    return r;
  }
  return 0;
}

#[no_mangle]
function lsp_build_diagnostics_response(id_val: i32, source: *u8, source_len: i32, out_buf: *u8,
                                        out_cap: i32): i32 {
  unsafe {
    let r: i32 = typeck_lsp_build_diagnostics_response(id_val, source, source_len, out_buf, out_cap);
    return r;
  }
  return 0;
}

#[no_mangle]
function lsp_diag_hover_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_buf: *u8,
                           out_cap: i32): i32 {
  unsafe {
    let r: i32 = typeck_lsp_diag_hover_at(source, source_len, line_0, col_0, out_buf, out_cap);
    return r;
  }
  return 0;
}

#[no_mangle]
function lsp_diag_references_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_lines: *i32,
                                out_cols: *i32, max_refs: i32): i32 {
  unsafe {
    let r: i32 = typeck_lsp_diag_references_at(source, source_len, line_0, col_0, out_lines, out_cols,
                                               max_refs);
    return r;
  }
  return 0;
}

#[no_mangle]
function lsp_hover_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_buf: *u8,
                      out_cap: i32): i32 {
  unsafe {
    let r: i32 = typeck_lsp_diag_hover_at(source, source_len, line_0, col_0, out_buf, out_cap);
    return r;
  }
  return 0;
}

#[no_mangle]
function lsp_references_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_lines: *i32,
                           out_cols: *i32, max_refs: i32): i32 {
  unsafe {
    let r: i32 = typeck_lsp_diag_references_at(source, source_len, line_0, col_0, out_lines, out_cols,
                                               max_refs);
    return r;
  }
  return 0;
}

#[no_mangle]
function lsp_diag_definition_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_line: *i32,
                                out_col: *i32): i32 {
  unsafe {
    let r: i32 = typeck_lsp_diag_definition_at(source, source_len, line_0, col_0, out_line, out_col);
    return r;
  }
  return 0;
}

#[no_mangle]
function lsp_build_semantic_tokens_response(id_val: i32, doc_buf: *u8, doc_len: i32, out_buf: *u8,
                                            out_cap: i32): i32 {
  unsafe {
    let r: i32 = typeck_lsp_build_semantic_tokens_response(id_val, doc_buf, doc_len, out_buf, out_cap);
    return r;
  }
  return 0;
}

#[no_mangle]
function lsp_io_lsp_diag_invalidate_cache(): void {
  unsafe {
    lsp_diag_invalidate_cache();
  }
}

/* ---- G-02f-74 lsp ctx gates ---- */

#[no_mangle]
function lsp_diag_pipeline_ctx_fill_paths(ctx_void: *u8, entry_dir: *u8, lib_roots: *u8, n_lib_roots: i32): void {
  unsafe {
    lsp_diag_pipeline_ctx_fill_paths_impl(ctx_void, entry_dir, lib_roots, n_lib_roots);
  }
}

#[no_mangle]
function typeck_lsp_main(): i32 {
  unsafe {
    return typeck_lsp_main_impl();
  }
  return 0 - 1;
}

#[no_mangle]
function lsp_write_all(fd: i32, buf: *u8, len: i32): i32 {
  unsafe {
    return lsp_write_all_impl(fd, buf, len);
  }
  return 0 - 1;
}
