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

// G-02f-110：+ expr_at/max_line/refs/def/type_to_string 薄门闩。

extern "C" function expr_at_impl(e: *u8, line: i32, col: i32): i32;
extern "C" function expr_max_line_impl(e: *u8): i32;
extern "C" function block_max_line_impl(b: *u8): i32;
extern "C" function add_ref_for_func_impl(f: *u8, line: i32, col: i32): void;
extern "C" function build_refs_index_impl(mod: *u8): void;
extern "C" function find_def_in_module_impl(mod: *u8, line: i32, col: i32, ol: *i32, oc: *i32): i32;
extern "C" function lsp_typeck_entry_module_impl(mod: *u8, only: i32): void;
extern "C" function collect_refs_index_in_expr_impl(e: *u8): void;
extern "C" function collect_refs_index_in_block_impl(b: *u8): void;
extern "C" function find_def_in_expr_impl(mod: *u8, e: *u8, line: i32, col: i32, ol: *i32, oc: *i32): i32;
extern "C" function find_def_in_block_impl(mod: *u8, b: *u8, line: i32, col: i32, ol: *i32, oc: *i32): i32;
extern "C" function collect_refs_add_impl(name: *u8, line: i32, col: i32): void;
extern "C" function collect_refs_in_expr_impl(e: *u8): void;
extern "C" function collect_refs_in_block_impl(b: *u8): void;
extern "C" function collect_refs_to_func_impl(f: *u8): void;
extern "C" function type_to_string_impl(ty: *u8, buf: *u8, cap: i32): i32;

/* ---- G-02f-110：lsp refs/def helpers 门闩 ---- */

#[no_mangle]
function expr_at(e: *u8, line: i32, col: i32): i32 { unsafe { return expr_at_impl(e, line, col); } return 0; }
#[no_mangle]
function expr_max_line(e: *u8): i32 { unsafe { return expr_max_line_impl(e); } return 0; }
#[no_mangle]
function block_max_line(b: *u8): i32 { unsafe { return block_max_line_impl(b); } return 0; }
#[no_mangle]
function add_ref_for_func(f: *u8, line: i32, col: i32): void { unsafe { add_ref_for_func_impl(f, line, col); } }
#[no_mangle]
function build_refs_index(mod: *u8): void { unsafe { build_refs_index_impl(mod); } }
#[no_mangle]
function find_def_in_module(mod: *u8, line: i32, col: i32, ol: *i32, oc: *i32): i32 { unsafe { return find_def_in_module_impl(mod, line, col, ol, oc); } return 0; }
#[no_mangle]
function lsp_typeck_entry_module(mod: *u8, only: i32): void { unsafe { lsp_typeck_entry_module_impl(mod, only); } }
#[no_mangle]
function collect_refs_index_in_expr(e: *u8): void { unsafe { collect_refs_index_in_expr_impl(e); } }
#[no_mangle]
function collect_refs_index_in_block(b: *u8): void { unsafe { collect_refs_index_in_block_impl(b); } }
#[no_mangle]
function find_def_in_expr(mod: *u8, e: *u8, line: i32, col: i32, ol: *i32, oc: *i32): i32 { unsafe { return find_def_in_expr_impl(mod, e, line, col, ol, oc); } return 0; }
#[no_mangle]
function find_def_in_block(mod: *u8, b: *u8, line: i32, col: i32, ol: *i32, oc: *i32): i32 { unsafe { return find_def_in_block_impl(mod, b, line, col, ol, oc); } return 0; }
#[no_mangle]
function collect_refs_add(name: *u8, line: i32, col: i32): void { unsafe { collect_refs_add_impl(name, line, col); } }
#[no_mangle]
function collect_refs_in_expr(e: *u8): void { unsafe { collect_refs_in_expr_impl(e); } }
#[no_mangle]
function collect_refs_in_block(b: *u8): void { unsafe { collect_refs_in_block_impl(b); } }
#[no_mangle]
function collect_refs_to_func(f: *u8): void { unsafe { collect_refs_to_func_impl(f); } }
#[no_mangle]
function type_to_string(ty: *u8, buf: *u8, cap: i32): i32 { unsafe { return type_to_string_impl(ty, buf, cap); } return 0; }

// G-02f-111：+ JSON/offset/format document helpers 薄门闩。

extern "C" function try_apply_content_changes_impl(doc: *u8, json: *u8): i32;
extern "C" function line_char_to_offset_impl(doc: *u8, line: i32, ch: i32): i32;
extern "C" function parse_first_content_change_impl(json: *u8, out: *u8): i32;
extern "C" function lsp_find_text_value_from_impl(s: *u8, from: i32, out: *u8, cap: i32): i32;
extern "C" function lsp_find_text_value_impl(s: *u8, out: *u8, cap: i32): i32;
extern "C" function lsp_find_key_after_impl(s: *u8, key: *u8, from: i32): i32;
extern "C" function lsp_parse_int_impl(s: *u8, from: i32, out: *i32): i32;
extern "C" function lsp_json_escape_ident_impl(src: *u8, dst: *u8, cap: i32): i32;
extern "C" function lsp_parse_bool_after_impl(s: *u8, from: i32, out: *i32): i32;
extern "C" function lsp_extract_formatting_options_impl(json: *u8, out: *u8): i32;
extern "C" function lsp_format_line_update_depth_impl(line: *u8, depth: *i32): void;
extern "C" function lsp_line_has_block_comment_end_impl(line: *u8): i32;
extern "C" function lsp_line_is_block_comment_impl(line: *u8, in_block: i32): i32;
extern "C" function lsp_fmt_last_out_impl(out: *u8, n: i32): u8;
extern "C" function lsp_fmt_prev_src_impl(doc: *u8, i: i32, j: i32): u8;
extern "C" function lsp_fmt_src_ws_before_impl(doc: *u8, i: i32): i32;
extern "C" function lsp_fmt_src_ws_after_impl(doc: *u8, i: i32): i32;
extern "C" function lsp_fmt_space_before_impl(a: u8, b: u8): i32;
extern "C" function lsp_fmt_space_after_impl(a: u8, b: u8): i32;
extern "C" function lsp_fmt_try_emit_op_impl(ctx: *u8): i32;
extern "C" function lsp_format_emit_segment_impl(ctx: *u8): i32;
extern "C" function lsp_fmt_comma_expand_extra_impl(ctx: *u8): i32;
extern "C" function lsp_format_find_break_impl(ctx: *u8): i32;
extern "C" function lsp_format_document_impl(src: *u8, out: *u8, cap: i32): i32;
extern "C" function lsp_doc_line_count_impl(doc: *u8, out: *i32): void;
extern "C" function lsp_extract_string_value_impl(s: *u8, from: i32, out: *u8, cap: i32): i32;

/* ---- G-02f-111：lsp JSON/format 门闩 ---- */

#[no_mangle]
function try_apply_content_changes(doc: *u8, json: *u8): i32 { unsafe { return try_apply_content_changes_impl(doc, json); } return 0; }
#[no_mangle]
function line_char_to_offset(doc: *u8, line: i32, ch: i32): i32 { unsafe { return line_char_to_offset_impl(doc, line, ch); } return 0; }
#[no_mangle]
function parse_first_content_change(json: *u8, out: *u8): i32 { unsafe { return parse_first_content_change_impl(json, out); } return 0; }
#[no_mangle]
function lsp_find_text_value_from(s: *u8, from: i32, out: *u8, cap: i32): i32 { unsafe { return lsp_find_text_value_from_impl(s, from, out, cap); } return 0; }
#[no_mangle]
function lsp_find_text_value(s: *u8, out: *u8, cap: i32): i32 { unsafe { return lsp_find_text_value_impl(s, out, cap); } return 0; }
#[no_mangle]
function lsp_find_key_after(s: *u8, key: *u8, from: i32): i32 { unsafe { return lsp_find_key_after_impl(s, key, from); } return 0; }
#[no_mangle]
function lsp_parse_int(s: *u8, from: i32, out: *i32): i32 { unsafe { return lsp_parse_int_impl(s, from, out); } return 0; }
#[no_mangle]
function lsp_json_escape_ident(src: *u8, dst: *u8, cap: i32): i32 { unsafe { return lsp_json_escape_ident_impl(src, dst, cap); } return 0; }
#[no_mangle]
function lsp_parse_bool_after(s: *u8, from: i32, out: *i32): i32 { unsafe { return lsp_parse_bool_after_impl(s, from, out); } return 0; }
#[no_mangle]
function lsp_extract_formatting_options(json: *u8, out: *u8): i32 { unsafe { return lsp_extract_formatting_options_impl(json, out); } return 0; }
#[no_mangle]
function lsp_format_line_update_depth(line: *u8, depth: *i32): void { unsafe { lsp_format_line_update_depth_impl(line, depth); } }
#[no_mangle]
function lsp_line_has_block_comment_end(line: *u8): i32 { unsafe { return lsp_line_has_block_comment_end_impl(line); } return 0; }
#[no_mangle]
function lsp_line_is_block_comment(line: *u8, in_block: i32): i32 { unsafe { return lsp_line_is_block_comment_impl(line, in_block); } return 0; }
#[no_mangle]
function lsp_fmt_last_out(out: *u8, n: i32): u8 { unsafe { return lsp_fmt_last_out_impl(out, n); } return 0; }
#[no_mangle]
function lsp_fmt_prev_src(doc: *u8, i: i32, j: i32): u8 { unsafe { return lsp_fmt_prev_src_impl(doc, i, j); } return 0; }
#[no_mangle]
function lsp_fmt_src_ws_before(doc: *u8, i: i32): i32 { unsafe { return lsp_fmt_src_ws_before_impl(doc, i); } return 0; }
#[no_mangle]
function lsp_fmt_src_ws_after(doc: *u8, i: i32): i32 { unsafe { return lsp_fmt_src_ws_after_impl(doc, i); } return 0; }
#[no_mangle]
function lsp_fmt_space_before(a: u8, b: u8): i32 { unsafe { return lsp_fmt_space_before_impl(a, b); } return 0; }
#[no_mangle]
function lsp_fmt_space_after(a: u8, b: u8): i32 { unsafe { return lsp_fmt_space_after_impl(a, b); } return 0; }
#[no_mangle]
function lsp_fmt_try_emit_op(ctx: *u8): i32 { unsafe { return lsp_fmt_try_emit_op_impl(ctx); } return 0; }
#[no_mangle]
function lsp_format_emit_segment(ctx: *u8): i32 { unsafe { return lsp_format_emit_segment_impl(ctx); } return 0; }
#[no_mangle]
function lsp_fmt_comma_expand_extra(ctx: *u8): i32 { unsafe { return lsp_fmt_comma_expand_extra_impl(ctx); } return 0; }
#[no_mangle]
function lsp_format_find_break(ctx: *u8): i32 { unsafe { return lsp_format_find_break_impl(ctx); } return 0; }
#[no_mangle]
function lsp_format_document(src: *u8, out: *u8, cap: i32): i32 { unsafe { return lsp_format_document_impl(src, out, cap); } return 0; }
#[no_mangle]
function lsp_doc_line_count(doc: *u8, out: *i32): void { unsafe { lsp_doc_line_count_impl(doc, out); } }
#[no_mangle]
function lsp_extract_string_value(s: *u8, from: i32, out: *u8, cap: i32): i32 { unsafe { return lsp_extract_string_value_impl(s, from, out, cap); } return 0; }

// G-02f-113：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

#[no_mangle]
function lsp_fmt_is_atom_tail(c: u8): i32 {
  if (c >= 97) {
    if (c <= 122) { return 1; }
  }
  if (c >= 65) {
    if (c <= 90) { return 1; }
  }
  if (c >= 48) {
    if (c <= 57) { return 1; }
  }
  if (c == 95) { return 1; }
  if (c == 41) { return 1; }
  if (c == 93) { return 1; }
  if (c == 125) { return 1; }
  return 0;
}

#[no_mangle]
function lsp_fmt_is_atom_head(c: u8): i32 {
  if (c >= 97) {
    if (c <= 122) { return 1; }
  }
  if (c >= 65) {
    if (c <= 90) { return 1; }
  }
  if (c >= 48) {
    if (c <= 57) { return 1; }
  }
  if (c == 95) { return 1; }
  if (c == 40) { return 1; }
  if (c == 91) { return 1; }
  if (c == 123) { return 1; }
  return 0;
}

#[no_mangle]
function lsp_fmt_unary_lhs(prev: u8): i32 {
  if (prev == 0) { return 1; }
  if (prev == 40) { return 1; }
  if (prev == 91) { return 1; }
  if (prev == 123) { return 1; }
  if (prev == 44) { return 1; }
  if (prev == 58) { return 1; }
  if (prev == 59) { return 1; }
  if (prev == 61) { return 1; }
  if (prev == 43) { return 1; }
  if (prev == 45) { return 1; }
  if (prev == 42) { return 1; }
  if (prev == 47) { return 1; }
  if (prev == 37) { return 1; }
  if (prev == 38) { return 1; }
  if (prev == 124) { return 1; }
  if (prev == 94) { return 1; }
  if (prev == 33) { return 1; }
  if (prev == 126) { return 1; }
  if (prev == 60) { return 1; }
  if (prev == 62) { return 1; }
  return 0;
}
