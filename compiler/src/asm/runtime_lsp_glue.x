// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-15：runtime_lsp_glue 产品源迁 seeds/runtime_lsp_glue.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 锚点；实现仍在 seed C。
// 产品：cc seeds/runtime_lsp_glue.from_x.c → src/lsp/lsp_diag.o

function runtime_lsp_glue_x_doc_anchor(): i32 {
  return 0;
}

// G-02f-109：+ uri/path/json/hash/line_index 薄门闩。

extern "C" function lsp_free_import_cache_impl(): void;
extern "C" function lsp_uri_to_fs_path_impl(uri: *u8, out: *u8, cap: i64): void;
extern "C" function lsp_fs_path_to_uri_impl(path: *u8, uri: *u8, cap: i64): void;
extern "C" function lsp_update_entry_dir_impl(path: *u8): void;
extern "C" function lsp_init_lib_roots_once_impl(): void;
extern "C" function lsp_diag_copy_text_impl(dst: *u8, cap: i32, src: *u8): void;
extern "C" function lsp_diag_x_ctx_alloc_size_impl(): i64;
extern "C" function json_escape_str_impl(msg: *u8, out: *u8, cap: i32): i32;
extern "C" function lsp_hash_source_impl(src: *u8, len: i32): u32;
extern "C" function col_in_ident_span_impl(line: i32, col: i32, sl: i32, sc: i32, name: *u8): i32;
extern "C" function func_name_covers_impl(f: *u8, line: i32, col: i32): i32;
extern "C" function build_line_index_impl(mod: *u8): void;
extern "C" function line_index_of_func_impl(f: *u8): i32;

/* ---- G-02f-109：lsp glue helpers 门闩 ---- */

#[no_mangle]
function lsp_free_import_cache(): void { unsafe { lsp_free_import_cache_impl(); } }
#[no_mangle]
function lsp_uri_to_fs_path(uri: *u8, out: *u8, cap: i64): void { unsafe { lsp_uri_to_fs_path_impl(uri, out, cap); } }
#[no_mangle]
function lsp_fs_path_to_uri(path: *u8, uri: *u8, cap: i64): void { unsafe { lsp_fs_path_to_uri_impl(path, uri, cap); } }
#[no_mangle]
function lsp_update_entry_dir(path: *u8): void { unsafe { lsp_update_entry_dir_impl(path); } }
#[no_mangle]
function lsp_init_lib_roots_once(): void { unsafe { lsp_init_lib_roots_once_impl(); } }
#[no_mangle]
function lsp_diag_copy_text(dst: *u8, cap: i32, src: *u8): void { unsafe { lsp_diag_copy_text_impl(dst, cap, src); } }
#[no_mangle]
function lsp_diag_x_ctx_alloc_size(): i64 { unsafe { return lsp_diag_x_ctx_alloc_size_impl(); } return 0; }
#[no_mangle]
function json_escape_str(msg: *u8, out: *u8, cap: i32): i32 { unsafe { return json_escape_str_impl(msg, out, cap); } return 0; }
#[no_mangle]
function lsp_hash_source(src: *u8, len: i32): u32 { unsafe { return lsp_hash_source_impl(src, len); } return 0; }
#[no_mangle]
function col_in_ident_span(line: i32, col: i32, sl: i32, sc: i32, name: *u8): i32 { unsafe { return col_in_ident_span_impl(line, col, sl, sc, name); } return 0; }
#[no_mangle]
function func_name_covers(f: *u8, line: i32, col: i32): i32 { unsafe { return func_name_covers_impl(f, line, col); } return 0; }
#[no_mangle]
function build_line_index(mod: *u8): void { unsafe { build_line_index_impl(mod); } }
#[no_mangle]
function line_index_of_func(f: *u8): i32 { unsafe { return line_index_of_func_impl(f); } return 0; }
