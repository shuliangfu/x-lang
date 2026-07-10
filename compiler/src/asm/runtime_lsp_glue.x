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
extern "C" function lsp_extract_formatting_options_impl(json: *u8, out: *u8): i32;
extern "C" function lsp_format_line_update_depth_impl(line: *u8, depth: *i32): void;
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
function lsp_extract_formatting_options(json: *u8, out: *u8): i32 { unsafe { return lsp_extract_formatting_options_impl(json, out); } return 0; }
#[no_mangle]
function lsp_format_line_update_depth(line: *u8, depth: *i32): void { unsafe { lsp_format_line_update_depth_impl(line, depth); } }








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

// G-02f-118：以下 LSP pure helper 真迁 .x（签名与产品 seed C 对齐）

#[no_mangle]
function col_in_ident_span(line: i32, col: i32, sl: i32, sc: i32, name: *u8): i32 {
  if (name == 0) { return 0; }
  if (sl != line) { return 0; }
  if (sc <= 0) { return 0; }
  let len: i32 = 0;
  while (len < 512) {
    if (name[len] == 0) { break; }
    len = len + 1;
  }
  if (len <= 0) { return 0; }
  if (col < sc) { return 0; }
  if (col >= sc + len) { return 0; }
  return 1;
}

#[no_mangle]
function lsp_parse_int(body: *u8, len: i32, offset: i32, out: *i32): i32 {
  if (offset >= len) { return 0 - 1; }
  if (out == 0) { return 0 - 1; }
  unsafe { out[0] = 0; }
  while (offset < len) {
    let c: u8 = body[offset];
    if (c < 48) { break; }
    if (c > 57) { break; }
    unsafe {
      let v: i32 = out[0];
      out[0] = v * 10 + (c - 48);
    }
    offset = offset + 1;
  }
  return offset;
}

#[no_mangle]
function lsp_line_has_block_comment_end(doc: *u8, start: i32, len: i32): i32 {
  let i: i32 = 0;
  while (i + 1 < len) {
    if (doc[start + i] == 42) { // '*'
      if (doc[start + i + 1] == 47) { return 1; } // '/'
    }
    i = i + 1;
  }
  return 0;
}

#[no_mangle]
function lsp_fmt_last_out(out_buf: *u8, out_len: i32): u8 {
  let k: i32 = out_len - 1;
  while (k >= 0) {
    let c: u8 = out_buf[k];
    if (c != 32) {
      if (c != 9) { return c; }
    }
    k = k - 1;
  }
  return 0;
}

#[no_mangle]
function lsp_fmt_prev_src(doc: *u8, start: i32, j: i32): u8 {
  let k: i32 = j - 1;
  while (k >= 0) {
    let c: u8 = doc[start + k];
    if (c != 32) {
      if (c != 9) {
        if (c != 13) { return c; }
      }
    }
    k = k - 1;
  }
  return 0;
}

#[no_mangle]
function lsp_fmt_src_ws_before(doc: *u8, start: i32, j: i32): i32 {
  let k: i32 = j - 1;
  if (k < 0) { return 0; }
  let c: u8 = doc[start + k];
  if (c == 32) { return 1; }
  if (c == 9) { return 1; }
  return 0;
}

#[no_mangle]
function lsp_fmt_src_ws_after(doc: *u8, start: i32, len: i32, j: i32): i32 {
  let k: i32 = j + 1;
  if (k >= len) { return 0; }
  let c: u8 = doc[start + k];
  if (c == 32) { return 1; }
  if (c == 9) { return 1; }
  return 0;
}

// G-02f-122：LSP pure helpers 真迁 .x（签名与产品 seed C 对齐）

#[no_mangle]
function lsp_find_key_after(body: *u8, len: i32, start: i32, key: *u8): i32 {
  if (body == 0) { return 0 - 1; }
  if (key == 0) { return 0 - 1; }
  let key_len: i32 = 0;
  while (key_len < 256) {
    if (key[key_len] == 0) { break; }
    key_len = key_len + 1;
  }
  while (start + key_len <= len) {
    let match: i32 = 1;
    let j: i32 = 0;
    while (j < key_len) {
      if (body[start + j] != key[j]) { match = 0; break; }
      j = j + 1;
    }
    if (match != 0) { return start + key_len; }
    start = start + 1;
  }
  return 0 - 1;
}

#[no_mangle]
function lsp_line_is_block_comment(doc: *u8, content_start: i32, content_len: i32, in_block: i32): i32 {
  if (doc == 0) { return 0; }
  if (content_len >= 2) {
    if (doc[content_start] == 47) { // '/'
      if (doc[content_start + 1] == 42) { return 1; } // '*'
    }
  }
  if (in_block != 0) {
    if (content_len >= 1) {
      if (doc[content_start] == 42) { return 1; }
    }
  }
  return 0;
}

#[no_mangle]
function lsp_parse_bool_after(body: *u8, len: i32, start: i32, key: *u8, out_val: *i32): i32 {
  if (out_val == 0) { return 0 - 1; }
  let k: i32 = lsp_find_key_after(body, len, start, key);
  if (k < 0) { return 0 - 1; }
  // true
  if (k + 4 <= len) {
    if (body[k]==116 && body[k+1]==114 && body[k+2]==117 && body[k+3]==101) {
      unsafe { out_val[0] = 1; }
      return 0;
    }
  }
  // false
  if (k + 5 <= len) {
    if (body[k]==102 && body[k+1]==97 && body[k+2]==108 && body[k+3]==115 && body[k+4]==101) {
      unsafe { out_val[0] = 0; }
      return 0;
    }
  }
  return 0 - 1;
}

#[no_mangle]
function lsp_fmt_space_before(doc: *u8, start: i32, j: i32, out_buf: *u8, out_len: *i32, out_cap: i32): i32 {
  if (out_buf == 0) { return 0; }
  if (out_len == 0) { return 0; }
  if (lsp_fmt_src_ws_before(doc, start, j) != 0) { return 0; }
  unsafe {
    let olen: i32 = out_len[0];
    let last: u8 = lsp_fmt_last_out(out_buf, olen);
    if (last != 0) {
      if (last != 32) {
        if (last != 9) {
          if (olen < out_cap - 1) {
            out_buf[olen] = 32;
            out_len[0] = olen + 1;
            return 1;
          }
        }
      }
    }
  }
  return 0;
}

// G-02f-123：LSP pure helpers 真迁 .x（签名与产品 seed C 对齐）

#[no_mangle]
function lsp_fmt_space_after(doc: *u8, start: i32, len: i32, j: i32, out_buf: *u8, out_len: *i32, out_cap: i32): i32 {
  if (out_buf == 0) { return 0; }
  if (out_len == 0) { return 0; }
  if (lsp_fmt_src_ws_after(doc, start, len, j) != 0) { return 0; }
  let k: i32 = j + 1;
  while (k < len) {
    let n: u8 = doc[start + k];
    if (n == 32) { k = k + 1; continue; }
    if (n == 9) { k = k + 1; continue; }
    if (n == 13) { k = k + 1; continue; }
    if (lsp_fmt_is_atom_head(n) != 0) {
      unsafe {
        let olen: i32 = out_len[0];
        if (olen < out_cap - 1) {
          out_buf[olen] = 32;
          out_len[0] = olen + 1;
          return 1;
        }
      }
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function lsp_json_escape_ident(s: *u8, esc: *u8, esc_cap: i32): i32 {
  if (s == 0) { return 0; }
  if (esc == 0) { return 0; }
  if (esc_cap < 4) { return 0; }
  let e: i32 = 0;
  let i: i32 = 0;
  while (s[i] != 0) {
    if (e >= esc_cap - 3) { break; }
    let c: u8 = s[i];
    if (c == 34) { // '"'
      esc[e] = 92;
      e = e + 1;
      if (e >= esc_cap - 1) { break; }
      esc[e] = c;
      e = e + 1;
    } else if (c == 92) { // '\\'
      esc[e] = 92;
      e = e + 1;
      if (e >= esc_cap - 1) { break; }
      esc[e] = c;
      e = e + 1;
    } else {
      esc[e] = c;
      e = e + 1;
    }
    i = i + 1;
  }
  esc[e] = 0;
  return e;
}


#[no_mangle]
function lsp_hash_source(src: *u8, len: i32): u32 {
  if (src == 0) { return 0; }
  let h: u64 = len as u64;
  let i: i32 = 0;
  while (i + 8 <= len) {
    let x: u64 = 0;
    let k: i32 = 0;
    while (k < 8) {
      let b: u64 = src[i + k] as u64;
      // little-endian pack
      let shift: u64 = 1;
      let s: i32 = 0;
      while (s < k) { shift = shift * 256; s = s + 1; }
      x = x + b * shift;
      k = k + 1;
    }
    h = h * 11400714819323198485 + x; // 0x9e3779b97f4a7c15
    i = i + 8;
  }
  while (i < len) {
    h = h * 11400714819323198485 + (src[i] as u64);
    i = i + 1;
  }
  return (h ^ (h / 4294967296)) as u32;
}
