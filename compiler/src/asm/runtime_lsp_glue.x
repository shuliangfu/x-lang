// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// G-02f-253：line_char_to_offset + lsp_doc_line_count pure。
// G-02f-254：lsp_find_text_value / _from pure。
// runtime_lsp_glue_x_doc_anchor: see function docblock below.

/** Exported function `runtime_lsp_glue_x_doc_anchor`.
 * Implements `runtime_lsp_glue_x_doc_anchor`.
 * @return i32
 */
export function runtime_lsp_glue_x_doc_anchor(): i32 {
  return 0;
}

// See implementation.

export extern "C" function lsp_free_import_cache_impl(): void;
/* See implementation. */
export extern "C" function lsp_entry_dir_set_dot(): void;
export extern "C" function lsp_entry_fs_path_store(path: *u8): void;
export extern "C" function lsp_entry_dir_store_prefix(path: *u8, n: i32): void;
export extern "C" function lsp_init_lib_roots_once_impl(): void;
export extern "C" function lsp_diag_x_ctx_alloc_size_impl(): i64;
/* See implementation. */
export extern "C" function build_line_index_impl(mod: *u8): void;
export extern "C" function line_index_of_func_impl(f: *u8): i32;

/* ---- G-02f-109 / G-02f-251：lsp glue helpers ---- */

#[no_mangle]
export function lsp_free_import_cache(): void {
  unsafe {
    lsp_free_import_cache_impl();
  }
}

// lsp_hex_nibble: see function docblock below.
/** Exported function `lsp_hex_nibble`.
 * Implements `lsp_hex_nibble`.
 * @param c i32
 * @return i32
 */
export function lsp_hex_nibble(c: i32): i32 {
  if (c >= 48) {
    if (c <= 57) {
      return c - 48;
    }
  }
  if (c >= 97) {
    if (c <= 102) {
      return c - 97 + 10;
    }
  }
  if (c >= 65) {
    if (c <= 70) {
      return c - 65 + 10;
    }
  }
  return 0 - 1;
}

// lsp_uri_has_file_scheme: see function docblock below.
/** Exported function `lsp_uri_has_file_scheme`.
 * Implements `lsp_uri_has_file_scheme`.
 * @param uri *u8
 * @return i32
 */
export function lsp_uri_has_file_scheme(uri: *u8): i32 {
  if (uri == 0 as *u8) {
    return 0;
  }
  unsafe {
    // file://
    if (uri[0] != 102) {
      return 0;
    }
    if (uri[1] != 105) {
      return 0;
    }
    if (uri[2] != 108) {
      return 0;
    }
    if (uri[3] != 101) {
      return 0;
    }
    if (uri[4] != 58) {
      return 0;
    }
    if (uri[5] != 47) {
      return 0;
    }
    if (uri[6] != 47) {
      return 0;
    }
  }
  return 1;
}

// lsp_uri_to_fs_path: see function docblock below.
#[no_mangle]
/** Exported function `lsp_uri_to_fs_path`.
 * Implements `lsp_uri_to_fs_path`.
 * @param uri *u8
 * @param out *u8
 * @param cap i64
 * @return void
 */
export function lsp_uri_to_fs_path(uri: *u8, out: *u8, cap: i64): void {
  if (uri == 0 as *u8) {
    return;
  }
  if (out == 0 as *u8) {
    return;
  }
  if (cap <= 0) {
    return;
  }
  unsafe {
    out[0] = 0;
    if (lsp_uri_has_file_scheme(uri) == 0) {
      return;
    }
    let p: i64 = 7;
    let k: i64 = 0;
    while (k + 1 < cap) {
      let c: u8 = uri[p];
      if (c == 0) {
        break;
      }
      if (c == 37) {
        // See implementation.
        let hi: i32 = uri[p + 1] as i32;
        let lo: i32 = uri[p + 2] as i32;
        if (hi == 0) {
          break;
        }
        if (lo == 0) {
          break;
        }
        let vh: i32 = lsp_hex_nibble(hi);
        let vl: i32 = lsp_hex_nibble(lo);
        let v: i32 = 0;
        if (vh >= 0) {
          v = vh * 16;
        }
        if (vl >= 0) {
          v = v + vl;
        }
        out[k] = v as u8;
        k = k + 1;
        p = p + 3;
      } else {
        out[k] = c;
        k = k + 1;
        p = p + 1;
      }
    }
    out[k] = 0;
  }
}

// lsp_fs_path_to_uri: see function docblock below.
#[no_mangle]
/** Exported function `lsp_fs_path_to_uri`.
 * Implements `lsp_fs_path_to_uri`.
 * @param path *u8
 * @param uri *u8
 * @param cap i32
 * @return void
 */
export function lsp_fs_path_to_uri(path: *u8, uri: *u8, cap: i32): void {
  if (path == 0 as *u8) {
    return;
  }
  if (uri == 0 as *u8) {
    return;
  }
  if (cap < 8) {
    return;
  }
  let k: i32 = 0;
  // file://
  uri[k] = 102 as u8;
  k = k + 1;
  uri[k] = 105 as u8;
  k = k + 1;
  uri[k] = 108 as u8;
  k = k + 1;
  uri[k] = 101 as u8;
  k = k + 1;
  uri[k] = 58 as u8;
  k = k + 1;
  uri[k] = 47 as u8;
  k = k + 1;
  uri[k] = 47 as u8;
  k = k + 1;
  let p: i32 = 0;
  while (k + 4 < cap) {
    let c: u8 = path[p];
    if (c == 0) {
      break;
    }
    if (c == 32) {
      // space
      uri[k] = 37 as u8;
      k = k + 1;
      uri[k] = 50 as u8;
      k = k + 1;
      uri[k] = 48 as u8;
      k = k + 1;
    } else {
      uri[k] = c;
      k = k + 1;
    }
    p = p + 1;
  }
  uri[k] = 0 as u8;
}

// lsp_path_last_slash: see function docblock below.
#[no_mangle]
/** Exported function `lsp_path_last_slash`.
 * Implements `lsp_path_last_slash`.
 * @param path *u8
 * @return i32
 */
export function lsp_path_last_slash(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    let last: i32 = 0 - 1;
    let i: i32 = 0;
    while (i < 4096) {
      if (path[i] == 0) {
        break;
      }
      if (path[i] == 47) {
        last = i;
      }
      i = i + 1;
    }
    return last;
  }
  return 0 - 1;
}

// lsp_update_entry_dir: see function docblock below.
#[no_mangle]
/** Exported function `lsp_update_entry_dir`.
 * Implements `lsp_update_entry_dir`.
 * @param path *u8
 * @return void
 */
export function lsp_update_entry_dir(path: *u8): void {
  unsafe {
    if (path == 0 as *u8) {
      lsp_entry_dir_set_dot();
      return;
    }
    if (path[0] == 0) {
      lsp_entry_dir_set_dot();
      return;
    }
    lsp_entry_fs_path_store(path);
    let last: i32 = lsp_path_last_slash(path);
    if (last < 0) {
      lsp_entry_dir_set_dot();
      return;
    }
    // See implementation.
    let n: i32 = last;
    if (n > 511) {
      n = 511;
    }
    lsp_entry_dir_store_prefix(path, n);
  }
}

#[no_mangle]
/** Exported function `lsp_init_lib_roots_once`.
 * Implements `lsp_init_lib_roots_once`.
 * @return void
 */
export function lsp_init_lib_roots_once(): void {
  unsafe {
    lsp_init_lib_roots_once_impl();
  }
}

// lsp_diag_copy_text: see function docblock below.
#[no_mangle]
/** Exported function `lsp_diag_copy_text`.
 * Implements `lsp_diag_copy_text`.
 * @param dst *u8
 * @param cap i32
 * @param src *u8
 * @return void
 */
export function lsp_diag_copy_text(dst: *u8, cap: i32, src: *u8): void {
  if (dst == 0 as *u8) {
    return;
  }
  if (cap <= 0) {
    return;
  }
  unsafe {
    if (src == 0 as *u8) {
      dst[0] = 0;
      return;
    }
    let n: i32 = 0;
    while (n + 1 < cap) {
      let c: u8 = src[n];
      if (c == 0) {
        break;
      }
      dst[n] = c;
      n = n + 1;
    }
    dst[n] = 0;
  }
}

#[no_mangle]
/** Exported function `lsp_diag_x_ctx_alloc_size`.
 * Memory management helper `lsp_diag_x_ctx_alloc_size`.
 * @return i64
 */
export function lsp_diag_x_ctx_alloc_size(): i64 {
  unsafe {
    return lsp_diag_x_ctx_alloc_size_impl();
  }
  return 0;
}

// json_escape_str: see function docblock below.
#[no_mangle]
/** Exported function `json_escape_str`.
 * Implements `json_escape_str`.
 * @param msg *u8
 * @param out *u8
 * @param cap i32
 * @return i32
 */
export function json_escape_str(msg: *u8, out: *u8, cap: i32): i32 {
  if (out == 0 as *u8) {
    return 0;
  }
  if (cap <= 0) {
    return 0;
  }
  if (msg == 0 as *u8) {
    unsafe {
      out[0] = 0;
    }
    return 0;
  }
  unsafe {
    let k: i32 = 0;
    let i: i32 = 0;
    while (k < cap - 1) {
      let c: u8 = msg[i];
      if (c == 0) {
        break;
      }
      if (c == 34) {
        // "
        if (k + 2 > cap - 1) {
          break;
        }
        out[k] = 92;
        k = k + 1;
        out[k] = 34;
        k = k + 1;
      } else {
        if (c == 92) {
          // \\
          if (k + 2 > cap - 1) {
            break;
          }
          out[k] = 92;
          k = k + 1;
          out[k] = 92;
          k = k + 1;
        } else {
          if (c == 10) {
            // \n
            if (k + 2 > cap - 1) {
              break;
            }
            out[k] = 92;
            k = k + 1;
            out[k] = 110;
            k = k + 1;
          } else {
            if (c == 13) {
              // \r
              if (k + 2 > cap - 1) {
                break;
              }
              out[k] = 92;
              k = k + 1;
              out[k] = 114;
              k = k + 1;
            } else {
              if (c == 9) {
                // \t
                if (k + 2 > cap - 1) {
                  break;
                }
                out[k] = 92;
                k = k + 1;
                out[k] = 116;
                k = k + 1;
              } else {
                out[k] = c;
                k = k + 1;
              }
            }
          }
        }
      }
      i = i + 1;
    }
    out[k] = 0;
    return k;
  }
  return 0;
}


// build_line_index: see function docblock below.
#[no_mangle]
/** Exported function `build_line_index`.
 * Implements `build_line_index`.
 * @param mod *u8): void { unsafe { build_line_index_impl(mod
 * @return void
 */
export function build_line_index(mod: *u8): void { unsafe { build_line_index_impl(mod); } }
#[no_mangle]
/** Exported function `line_index_of_func`.
 * Implements `line_index_of_func`.
 * @param f *u8): i32 { unsafe { return line_index_of_func_impl(f
 * @return void
 */
export function line_index_of_func(f: *u8): i32 { unsafe { return line_index_of_func_impl(f); } return 0; }

// See implementation.

export extern "C" function expr_at_impl(e: *u8, line: i32, col: i32): i32;
export extern "C" function expr_max_line_impl(e: *u8): i32;
export extern "C" function block_max_line_impl(b: *u8): i32;
export extern "C" function add_ref_for_func_impl(f: *u8, line: i32, col: i32): void;
export extern "C" function build_refs_index_impl(mod: *u8): void;
export extern "C" function find_def_in_module_impl(mod: *u8, line: i32, col: i32, ol: *i32, oc: *i32): i32;
export extern "C" function lsp_typeck_entry_module_impl(mod: *u8, only: i32): void;
export extern "C" function collect_refs_index_in_expr_impl(e: *u8): void;
export extern "C" function collect_refs_index_in_block_impl(b: *u8): void;
export extern "C" function find_def_in_expr_impl(mod: *u8, e: *u8, line: i32, col: i32, ol: *i32, oc: *i32): i32;
export extern "C" function find_def_in_block_impl(mod: *u8, b: *u8, line: i32, col: i32, ol: *i32, oc: *i32): i32;
export extern "C" function collect_refs_add_impl(name: *u8, line: i32, col: i32): void;
export extern "C" function collect_refs_in_expr_impl(e: *u8): void;
export extern "C" function collect_refs_in_block_impl(b: *u8): void;
export extern "C" function collect_refs_to_func_impl(f: *u8): void;
export extern "C" function type_to_string_impl(ty: *u8, buf: *u8, cap: i32): i32;

/* See implementation. */

#[no_mangle]
export function expr_at(e: *u8, line: i32, col: i32): i32 { unsafe { return expr_at_impl(e, line, col); } return 0; }
#[no_mangle]
/** Exported function `expr_max_line`.
 * Implements `expr_max_line`.
 * @param e *u8): i32 { unsafe { return expr_max_line_impl(e
 * @return void
 */
export function expr_max_line(e: *u8): i32 { unsafe { return expr_max_line_impl(e); } return 0; }
#[no_mangle]
/** Exported function `block_max_line`.
 * Implements `block_max_line`.
 * @param b *u8): i32 { unsafe { return block_max_line_impl(b
 * @return void
 */
export function block_max_line(b: *u8): i32 { unsafe { return block_max_line_impl(b); } return 0; }
#[no_mangle]
/** Exported function `add_ref_for_func`.
 * Implements `add_ref_for_func`.
 * @param f *u8
 * @param line i32
 * @param col i32): void { unsafe { add_ref_for_func_impl(f
 * @param line
 * @param col
 * @return void
 */
export function add_ref_for_func(f: *u8, line: i32, col: i32): void { unsafe { add_ref_for_func_impl(f, line, col); } }
#[no_mangle]
/** Exported function `build_refs_index`.
 * Implements `build_refs_index`.
 * @param mod *u8): void { unsafe { build_refs_index_impl(mod
 * @return void
 */
export function build_refs_index(mod: *u8): void { unsafe { build_refs_index_impl(mod); } }
#[no_mangle]
/** Exported function `find_def_in_module`.
 * Implements `find_def_in_module`.
 * @param mod *u8
 * @param line i32
 * @param col i32
 * @param ol *i32
 * @param oc *i32): i32 { unsafe { return find_def_in_module_impl(mod
 * @param line
 * @param col
 * @param ol
 * @param oc
 * @return void
 */
export function find_def_in_module(mod: *u8, line: i32, col: i32, ol: *i32, oc: *i32): i32 { unsafe { return find_def_in_module_impl(mod, line, col, ol, oc); } return 0; }
#[no_mangle]
/** Exported function `lsp_typeck_entry_module`.
 * Implements `lsp_typeck_entry_module`.
 * @param mod *u8
 * @param only i32): void { unsafe { lsp_typeck_entry_module_impl(mod
 * @param only
 * @return void
 */
export function lsp_typeck_entry_module(mod: *u8, only: i32): void { unsafe { lsp_typeck_entry_module_impl(mod, only); } }
#[no_mangle]
/** Exported function `collect_refs_index_in_expr`.
 * Implements `collect_refs_index_in_expr`.
 * @param e *u8): void { unsafe { collect_refs_index_in_expr_impl(e
 * @return void
 */
export function collect_refs_index_in_expr(e: *u8): void { unsafe { collect_refs_index_in_expr_impl(e); } }
#[no_mangle]
/** Exported function `collect_refs_index_in_block`.
 * Implements `collect_refs_index_in_block`.
 * @param b *u8): void { unsafe { collect_refs_index_in_block_impl(b
 * @return void
 */
export function collect_refs_index_in_block(b: *u8): void { unsafe { collect_refs_index_in_block_impl(b); } }
#[no_mangle]
/** Exported function `find_def_in_expr`.
 * Implements `find_def_in_expr`.
 * @param mod *u8
 * @param e *u8
 * @param line i32
 * @param col i32
 * @param ol *i32
 * @param oc *i32): i32 { unsafe { return find_def_in_expr_impl(mod
 * @param e
 * @param line
 * @param col
 * @param ol
 * @param oc
 * @return void
 */
export function find_def_in_expr(mod: *u8, e: *u8, line: i32, col: i32, ol: *i32, oc: *i32): i32 { unsafe { return find_def_in_expr_impl(mod, e, line, col, ol, oc); } return 0; }
#[no_mangle]
/** Exported function `find_def_in_block`.
 * Implements `find_def_in_block`.
 * @param mod *u8
 * @param b *u8
 * @param line i32
 * @param col i32
 * @param ol *i32
 * @param oc *i32): i32 { unsafe { return find_def_in_block_impl(mod
 * @param b
 * @param line
 * @param col
 * @param ol
 * @param oc
 * @return void
 */
export function find_def_in_block(mod: *u8, b: *u8, line: i32, col: i32, ol: *i32, oc: *i32): i32 { unsafe { return find_def_in_block_impl(mod, b, line, col, ol, oc); } return 0; }
#[no_mangle]
/** Exported function `collect_refs_add`.
 * Implements `collect_refs_add`.
 * @param name *u8
 * @param line i32
 * @param col i32): void { unsafe { collect_refs_add_impl(name
 * @param line
 * @param col
 * @return void
 */
export function collect_refs_add(name: *u8, line: i32, col: i32): void { unsafe { collect_refs_add_impl(name, line, col); } }
#[no_mangle]
/** Exported function `collect_refs_in_expr`.
 * Implements `collect_refs_in_expr`.
 * @param e *u8): void { unsafe { collect_refs_in_expr_impl(e
 * @return void
 */
export function collect_refs_in_expr(e: *u8): void { unsafe { collect_refs_in_expr_impl(e); } }
#[no_mangle]
/** Exported function `collect_refs_in_block`.
 * Implements `collect_refs_in_block`.
 * @param b *u8): void { unsafe { collect_refs_in_block_impl(b
 * @return void
 */
export function collect_refs_in_block(b: *u8): void { unsafe { collect_refs_in_block_impl(b); } }
#[no_mangle]
/** Exported function `collect_refs_to_func`.
 * Implements `collect_refs_to_func`.
 * @param f *u8): void { unsafe { collect_refs_to_func_impl(f
 * @return void
 */
export function collect_refs_to_func(f: *u8): void { unsafe { collect_refs_to_func_impl(f); } }
#[no_mangle]
/** Exported function `type_to_string`.
 * Implements `type_to_string`.
 * @param ty *u8
 * @param buf *u8
 * @param cap i32): i32 { unsafe { return type_to_string_impl(ty
 * @param buf
 * @param cap
 * @return void
 */
export function type_to_string(ty: *u8, buf: *u8, cap: i32): i32 { unsafe { return type_to_string_impl(ty, buf, cap); } return 0; }

// G-02f-111 / G-02f-253：JSON/offset/format document helpers。

export extern "C" function try_apply_content_changes_impl(doc: *u8, json: *u8): i32;
/* line_char_to_offset / lsp_doc_line_count：G-02f-253 pure */
/* find_text_value：G-02f-254 pure */
export extern "C" function parse_first_content_change_impl(json: *u8, out: *u8): i32;
export extern "C" function lsp_extract_formatting_options_impl(json: *u8, out: *u8): i32;
export extern "C" function lsp_format_line_update_depth_impl(line: *u8, depth: *i32): void;
export extern "C" function lsp_fmt_try_emit_op_impl(ctx: *u8): i32;
export extern "C" function lsp_format_emit_segment_impl(ctx: *u8): i32;
export extern "C" function lsp_fmt_comma_expand_extra_impl(ctx: *u8): i32;
export extern "C" function lsp_format_find_break_impl(ctx: *u8): i32;
export extern "C" function lsp_format_document_impl(src: *u8, out: *u8, cap: i32): i32;
export extern "C" function lsp_extract_string_value_impl(s: *u8, from: i32, out: *u8, cap: i32): i32;

/* ---- G-02f-111 / G-02f-253：lsp JSON/format ---- */

#[no_mangle]
export function try_apply_content_changes(doc: *u8, json: *u8): i32 {
  if (doc == 0 as *u8) {
    return 0;
  }
  unsafe {
    return try_apply_content_changes_impl(doc, json);
  }
  return 0;
}

// line_char_to_offset: see function docblock below.
#[no_mangle]
/** Exported function `line_char_to_offset`.
 * Implements `line_char_to_offset`.
 * @param doc *u8
 * @param len i32
 * @param line i32
 * @param character i32
 * @return i32
 */
export function line_char_to_offset(doc: *u8, len: i32, line: i32, character: i32): i32 {
  if (doc == 0 as *u8) {
    return 0 - 1;
  }
  if (len < 0) {
    return 0 - 1;
  }
  if (line < 0) {
    return 0 - 1;
  }
  if (character < 0) {
    return 0 - 1;
  }
  unsafe {
    let cur_line: i32 = 0;
    let i: i32 = 0;
    while (i < len) {
      if (cur_line >= line) {
        break;
      }
      if (doc[i] == 10) {
        cur_line = cur_line + 1;
      }
      i = i + 1;
    }
    if (cur_line != line) {
      return 0 - 1;
    }
    let col: i32 = 0;
    while (col < character) {
      if (i >= len) {
        break;
      }
      if (doc[i] == 10) {
        break;
      }
      col = col + 1;
      i = i + 1;
    }
    if (col != character) {
      return 0 - 1;
    }
    return i;
  }
  return 0 - 1;
}

// lsp_doc_line_count: see function docblock below.
#[no_mangle]
/** Exported function `lsp_doc_line_count`.
 * Implements `lsp_doc_line_count`.
 * @param doc *u8
 * @param len i32
 * @param out_last_line *i32
 * @param out_last_line_char *i32
 * @return void
 */
export function lsp_doc_line_count(doc: *u8, len: i32, out_last_line: *i32, out_last_line_char: *i32): void {
  if (out_last_line == 0 as *i32) {
    return;
  }
  if (out_last_line_char == 0 as *i32) {
    return;
  }
  unsafe {
    if (doc == 0 as *u8) {
      out_last_line[0] = 0;
      out_last_line_char[0] = 0;
      return;
    }
    if (len < 0) {
      out_last_line[0] = 0;
      out_last_line_char[0] = 0;
      return;
    }
    let lines: i32 = 0;
    let last_char: i32 = 0;
    let i: i32 = 0;
    while (i < len) {
      if (doc[i] == 10) {
        lines = lines + 1;
        last_char = 0;
      } else {
        last_char = last_char + 1;
      }
      i = i + 1;
    }
    if (lines > 0) {
      out_last_line[0] = lines - 1;
    } else {
      out_last_line[0] = 0;
    }
    out_last_line_char[0] = last_char;
  }
}

#[no_mangle]
/** Exported function `parse_first_content_change`.
 * Implements `parse_first_content_change`.
 * @param json *u8
 * @param out *u8
 * @return i32
 */
export function parse_first_content_change(json: *u8, out: *u8): i32 {
  unsafe {
    return parse_first_content_change_impl(json, out);
  }
  return 0;
}

// lsp_json_is_ws: see function docblock below.
/** Exported function `lsp_json_is_ws`.
 * Implements `lsp_json_is_ws`.
 * @param c u8
 * @return i32
 */
export function lsp_json_is_ws(c: u8): i32 {
  if (c == 32) {
    return 1;
  }
  if (c == 9) {
    return 1;
  }
  if (c == 10) {
    return 1;
  }
  if (c == 13) {
    return 1;
  }
  return 0;
}

// lsp_match_quote_text_quote: see function docblock below.
/** Exported function `lsp_match_quote_text_quote`.
 * Implements `lsp_match_quote_text_quote`.
 * @param body *u8
 * @param i i32
 * @return i32
 */
export function lsp_match_quote_text_quote(body: *u8, i: i32): i32 {
  unsafe {
    // "text"
    if (body[i] != 34) {
      return 0;
    }
    if (body[i + 1] != 116) {
      return 0;
    }
    if (body[i + 2] != 101) {
      return 0;
    }
    if (body[i + 3] != 120) {
      return 0;
    }
    if (body[i + 4] != 116) {
      return 0;
    }
    if (body[i + 5] != 34) {
      return 0;
    }
  }
  return 1;
}

// lsp_match_quote_textdocument_quote: see function docblock below.
/** Exported function `lsp_match_quote_textdocument_quote`.
 * Implements `lsp_match_quote_textdocument_quote`.
 * @param body *u8
 * @param i i32
 * @return i32
 */
export function lsp_match_quote_textdocument_quote(body: *u8, i: i32): i32 {
  unsafe {
    // "textDocument" = 14 bytes
    if (body[i] != 34) {
      return 0;
    }
    if (body[i + 1] != 116) {
      return 0;
    }
    if (body[i + 2] != 101) {
      return 0;
    }
    if (body[i + 3] != 120) {
      return 0;
    }
    if (body[i + 4] != 116) {
      return 0;
    }
    if (body[i + 5] != 68) {
      return 0;
    }
    if (body[i + 6] != 111) {
      return 0;
    }
    if (body[i + 7] != 99) {
      return 0;
    }
    if (body[i + 8] != 117) {
      return 0;
    }
    if (body[i + 9] != 109) {
      return 0;
    }
    if (body[i + 10] != 101) {
      return 0;
    }
    if (body[i + 11] != 110) {
      return 0;
    }
    if (body[i + 12] != 116) {
      return 0;
    }
    if (body[i + 13] != 34) {
      return 0;
    }
  }
  return 1;
}

// lsp_find_text_value_from: see function docblock below.
#[no_mangle]
/** Exported function `lsp_find_text_value_from`.
 * Implements `lsp_find_text_value_from`.
 * @param body *u8
 * @param len i32
 * @param search_start i32
 * @param out_buf *u8
 * @param out_cap i32
 * @return i32
 */
export function lsp_find_text_value_from(body: *u8, len: i32, search_start: i32, out_buf: *u8, out_cap: i32): i32 {
  if (body == 0 as *u8) {
    return 0 - 1;
  }
  if (out_buf == 0 as *u8) {
    return 0 - 1;
  }
  if (out_cap <= 0) {
    return 0 - 1;
  }
  if (len < 0) {
    return 0 - 1;
  }
  if (search_start < 0) {
    return 0 - 1;
  }
  unsafe {
    let i: i32 = search_start;
    while (i + 6 <= len) {
      if (lsp_match_quote_text_quote(body, i) == 0) {
        i = i + 1;
      } else {
        let s: i32 = i + 6;
        while (s < len) {
          if (lsp_json_is_ws(body[s]) == 0) {
            break;
          }
          s = s + 1;
        }
        if (s >= len) {
          i = i + 1;
        } else {
          if (body[s] != 58) {
            // :
            i = i + 1;
          } else {
            s = s + 1;
            while (s < len) {
              if (lsp_json_is_ws(body[s]) == 0) {
                break;
              }
              s = s + 1;
            }
            if (s >= len) {
              i = i + 1;
            } else {
              if (body[s] != 34) {
                i = i + 1;
              } else {
                let start: i32 = s + 1;
                let out_len: i32 = 0;
                while (start < len) {
                  if (out_len >= out_cap - 1) {
                    break;
                  }
                  let c: u8 = body[start];
                  // See implementation.
                  if (c == 34) {
                    if (start == 0) {
                      break;
                    }
                    if (body[start - 1] != 92) {
                      break;
                    }
                  }
                  if (c == 92) {
                    if (start + 1 >= len) {
                      break;
                    }
                    start = start + 1;
                    let e: u8 = body[start];
                    if (e == 110) {
                      out_buf[out_len] = 10;
                    } else {
                      if (e == 114) {
                        out_buf[out_len] = 13;
                      } else {
                        if (e == 116) {
                          out_buf[out_len] = 9;
                        } else {
                          out_buf[out_len] = e;
                        }
                      }
                    }
                    out_len = out_len + 1;
                    start = start + 1;
                  } else {
                    out_buf[out_len] = c;
                    out_len = out_len + 1;
                    start = start + 1;
                  }
                }
                out_buf[out_len] = 0;
                return out_len;
              }
            }
          }
        }
      }
    }
  }
  return 0 - 1;
}

// lsp_find_text_value: see function docblock below.
#[no_mangle]
/** Exported function `lsp_find_text_value`.
 * Implements `lsp_find_text_value`.
 * @param body *u8
 * @param len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @return i32
 */
export function lsp_find_text_value(body: *u8, len: i32, out_buf: *u8, out_cap: i32): i32 {
  if (body == 0 as *u8) {
    return 0 - 1;
  }
  if (out_buf == 0 as *u8) {
    return 0 - 1;
  }
  if (out_cap <= 0) {
    return 0 - 1;
  }
  if (len < 0) {
    return 0 - 1;
  }
  unsafe {
    let i: i32 = 0;
    while (i + 14 <= len) {
      if (lsp_match_quote_textdocument_quote(body, i) != 0) {
        let n: i32 = lsp_find_text_value_from(body, len, i + 14, out_buf, out_cap);
        if (n >= 0) {
          return n;
        }
      }
      i = i + 1;
    }
  }
  return lsp_find_text_value_from(body, len, 0, out_buf, out_cap);
}

#[no_mangle]
/** Exported function `lsp_extract_formatting_options`.
 * Implements `lsp_extract_formatting_options`.
 * @param json *u8
 * @param out *u8
 * @return i32
 */
export function lsp_extract_formatting_options(json: *u8, out: *u8): i32 {
  unsafe {
    return lsp_extract_formatting_options_impl(json, out);
  }
  return 0;
}

#[no_mangle]
/** Exported function `lsp_format_line_update_depth`.
 * Implements `lsp_format_line_update_depth`.
 * @param line *u8
 * @param depth *i32
 * @return void
 */
export function lsp_format_line_update_depth(line: *u8, depth: *i32): void {
  if (depth == 0 as *i32) {
    return;
  }
  unsafe {
    lsp_format_line_update_depth_impl(line, depth);
  }
}

#[no_mangle]
/** Exported function `lsp_fmt_try_emit_op`.
 * Implements `lsp_fmt_try_emit_op`.
 * @param ctx *u8
 * @return i32
 */
export function lsp_fmt_try_emit_op(ctx: *u8): i32 {
  unsafe {
    return lsp_fmt_try_emit_op_impl(ctx);
  }
  return 0;
}

#[no_mangle]
/** Exported function `lsp_format_emit_segment`.
 * Implements `lsp_format_emit_segment`.
 * @param ctx *u8
 * @return i32
 */
export function lsp_format_emit_segment(ctx: *u8): i32 {
  unsafe {
    return lsp_format_emit_segment_impl(ctx);
  }
  return 0;
}

#[no_mangle]
/** Exported function `lsp_fmt_comma_expand_extra`.
 * Implements `lsp_fmt_comma_expand_extra`.
 * @param ctx *u8
 * @return i32
 */
export function lsp_fmt_comma_expand_extra(ctx: *u8): i32 {
  unsafe {
    return lsp_fmt_comma_expand_extra_impl(ctx);
  }
  return 0;
}

#[no_mangle]
/** Exported function `lsp_format_find_break`.
 * Implements `lsp_format_find_break`.
 * @param ctx *u8
 * @return i32
 */
export function lsp_format_find_break(ctx: *u8): i32 {
  unsafe {
    return lsp_format_find_break_impl(ctx);
  }
  return 0;
}

#[no_mangle]
/** Exported function `lsp_format_document`.
 * Implements `lsp_format_document`.
 * @param src *u8
 * @param out *u8
 * @param cap i32
 * @return i32
 */
export function lsp_format_document(src: *u8, out: *u8, cap: i32): i32 {
  unsafe {
    return lsp_format_document_impl(src, out, cap);
  }
  return 0;
}

#[no_mangle]
/** Exported function `lsp_extract_string_value`.
 * Implements `lsp_extract_string_value`.
 * @param s *u8
 * @param from i32
 * @param out *u8
 * @param cap i32
 * @return i32
 */
export function lsp_extract_string_value(s: *u8, from: i32, out: *u8, cap: i32): i32 {
  unsafe {
    return lsp_extract_string_value_impl(s, from, out, cap);
  }
  return 0;
}

// lsp_fmt_is_atom_tail: see function docblock below.

#[no_mangle]
/** Exported function `lsp_fmt_is_atom_tail`.
 * Implements `lsp_fmt_is_atom_tail`.
 * @param c u8
 * @return i32
 */
export function lsp_fmt_is_atom_tail(c: u8): i32 {
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
/** Exported function `lsp_fmt_is_atom_head`.
 * Implements `lsp_fmt_is_atom_head`.
 * @param c u8
 * @return i32
 */
export function lsp_fmt_is_atom_head(c: u8): i32 {
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
/** Exported function `lsp_fmt_unary_lhs`.
 * Implements `lsp_fmt_unary_lhs`.
 * @param prev u8
 * @return i32
 */
export function lsp_fmt_unary_lhs(prev: u8): i32 {
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

// col_in_ident_span: see function docblock below.

#[no_mangle]
/** Exported function `col_in_ident_span`.
 * Implements `col_in_ident_span`.
 * @param line i32
 * @param col i32
 * @param sl i32
 * @param sc i32
 * @param name *u8
 * @return i32
 */
export function col_in_ident_span(line: i32, col: i32, sl: i32, sc: i32, name: *u8): i32 {
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

// G-02f-133：ASTFunc line@0 col@4 name@+8
/** Exported function `lsp_load_i32_at`.
 * Implements `lsp_load_i32_at`.
 * @param p *u8
 * @param off i32
 * @return i32
 */
export function lsp_load_i32_at(p: *u8, off: i32): i32 {
  let m: i32 = 256;
  let a: i32 = p[off] as i32;
  a = a + (p[off + 1] as i32) * m;
  a = a + (p[off + 2] as i32) * (m * m);
  a = a + (p[off + 3] as i32) * (m * m * m);
  return a;
}

/** Exported function `lsp_load_ptr_at`.
 * Implements `lsp_load_ptr_at`.
 * @param p *u8
 * @param off i32
 * @return *u8
 */
export function lsp_load_ptr_at(p: *u8, off: i32): *u8 {
  if (p == 0) { return 0 as *u8; }
  let m: usize = 256;
  let m2: usize = m * m;
  let m4: usize = m2 * m2;
  let a: usize = p[off] as usize;
  a = a + (p[off + 1] as usize) * m;
  a = a + (p[off + 2] as usize) * m2;
  a = a + (p[off + 3] as usize) * (m2 * m);
  a = a + (p[off + 4] as usize) * m4;
  a = a + (p[off + 5] as usize) * (m4 * m);
  a = a + (p[off + 6] as usize) * (m4 * m2);
  a = a + (p[off + 7] as usize) * (m4 * m2 * m);
  return a as *u8;
}

#[no_mangle]
/** Exported function `func_name_covers`.
 * Implements `func_name_covers`.
 * @param f *u8
 * @param line i32
 * @param col i32
 * @return i32
 */
export function func_name_covers(f: *u8, line: i32, col: i32): i32 {
  if (f == 0) { return 0; }
  let name: *u8 = lsp_load_ptr_at(f, 8);
  if (name == 0) { return 0; }
  let sl: i32 = lsp_load_i32_at(f, 0);
  let sc: i32 = lsp_load_i32_at(f, 4);
  return col_in_ident_span(line, col, sl, sc, name);
}

// lsp_parse_int: see function docblock below.
#[no_mangle]
/** Exported function `lsp_parse_int`.
 * Implements `lsp_parse_int`.
 * @param body *u8
 * @param len i32
 * @param offset i32
 * @param out *i32
 * @return i32
 */
export function lsp_parse_int(body: *u8, len: i32, offset: i32, out: *i32): i32 {
  if (body == 0 as *u8) {
    return 0 - 1;
  }
  if (out == 0 as *i32) {
    return 0 - 1;
  }
  if (len < 0) {
    return 0 - 1;
  }
  if (offset < 0) {
    return 0 - 1;
  }
  if (offset >= len) {
    return 0 - 1;
  }
  unsafe {
    out[0] = 0;
    while (offset < len) {
      let c: u8 = body[offset];
      if (c < 48) {
        break;
      }
      if (c > 57) {
        break;
      }
      let v: i32 = out[0];
      out[0] = v * 10 + ((c as i32) - 48);
      offset = offset + 1;
    }
  }
  return offset;
}

#[no_mangle]
/** Exported function `lsp_line_has_block_comment_end`.
 * Implements `lsp_line_has_block_comment_end`.
 * @param doc *u8
 * @param start i32
 * @param len i32
 * @return i32
 */
export function lsp_line_has_block_comment_end(doc: *u8, start: i32, len: i32): i32 {
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
/** Exported function `lsp_fmt_last_out`.
 * Implements `lsp_fmt_last_out`.
 * @param out_buf *u8
 * @param out_len i32
 * @return u8
 */
export function lsp_fmt_last_out(out_buf: *u8, out_len: i32): u8 {
  let k: i32 = out_len - 1;
  while (k >= 0) {
    let c: u8 = out_buf[k];
    if (c != 32) {
      if (c != 9) { return c; }
    }
    k = k - 1;
  }
  return 0 as u8;
}

#[no_mangle]
/** Exported function `lsp_fmt_prev_src`.
 * Implements `lsp_fmt_prev_src`.
 * @param doc *u8
 * @param start i32
 * @param j i32
 * @return u8
 */
export function lsp_fmt_prev_src(doc: *u8, start: i32, j: i32): u8 {
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
  return 0 as u8;
}

#[no_mangle]
/** Exported function `lsp_fmt_src_ws_before`.
 * Implements `lsp_fmt_src_ws_before`.
 * @param doc *u8
 * @param start i32
 * @param j i32
 * @return i32
 */
export function lsp_fmt_src_ws_before(doc: *u8, start: i32, j: i32): i32 {
  let k: i32 = j - 1;
  if (k < 0) { return 0; }
  let c: u8 = doc[start + k];
  if (c == 32) { return 1; }
  if (c == 9) { return 1; }
  return 0;
}

#[no_mangle]
/** Exported function `lsp_fmt_src_ws_after`.
 * Implements `lsp_fmt_src_ws_after`.
 * @param doc *u8
 * @param start i32
 * @param len i32
 * @param j i32
 * @return i32
 */
export function lsp_fmt_src_ws_after(doc: *u8, start: i32, len: i32, j: i32): i32 {
  let k: i32 = j + 1;
  if (k >= len) { return 0; }
  let c: u8 = doc[start + k];
  if (c == 32) { return 1; }
  if (c == 9) { return 1; }
  return 0;
}

// See implementation.

// See implementation.
export extern "C" function lsp_json_key_position(): *u8;
export extern "C" function lsp_json_key_line(): *u8;
export extern "C" function lsp_json_key_character(): *u8;

#[no_mangle]
/** Exported function `lsp_find_key_after`.
 * Implements `lsp_find_key_after`.
 * @param body *u8
 * @param len i32
 * @param start i32
 * @param key *u8
 * @return i32
 */
export function lsp_find_key_after(body: *u8, len: i32, start: i32, key: *u8): i32 {
  if (body == 0 as *u8) {
    return 0 - 1;
  }
  if (key == 0 as *u8) {
    return 0 - 1;
  }
  if (len < 0) {
    return 0 - 1;
  }
  if (start < 0) {
    return 0 - 1;
  }
  unsafe {
    let key_len: i32 = 0;
    while (key_len < 256) {
      if (key[key_len] == 0) {
        break;
      }
      key_len = key_len + 1;
    }
    if (key_len <= 0) {
      return 0 - 1;
    }
    let s: i32 = start;
    while (s + key_len <= len) {
      let matched: i32 = 1;
      let j: i32 = 0;
      while (j < key_len) {
        if (body[s + j] != key[j]) {
          matched = 0;
          break;
        }
        j = j + 1;
      }
      if (matched != 0) {
        return s + key_len;
      }
      s = s + 1;
    }
  }
  return 0 - 1;
}

// lsp_extract_position_from_params: see function docblock below.
#[no_mangle]
/** Exported function `lsp_extract_position_from_params`.
 * Implements `lsp_extract_position_from_params`.
 * @param body *u8
 * @param len i32
 * @param out_line *i32
 * @param out_character *i32
 * @return i32
 */
export function lsp_extract_position_from_params(body: *u8, len: i32, out_line: *i32, out_character: *i32): i32 {
  if (body == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  if (out_line == 0 as *i32) {
    return 0 - 1;
  }
  if (out_character == 0 as *i32) {
    return 0 - 1;
  }
  unsafe {
    let pos: i32 = lsp_find_key_after(body, len, 0, lsp_json_key_position());
    if (pos < 0) {
      return 0 - 1;
    }
    let line_start: i32 = lsp_find_key_after(body, len, pos, lsp_json_key_line());
    if (line_start < 0) {
      return 0 - 1;
    }
    let char_start: i32 = lsp_find_key_after(body, len, pos, lsp_json_key_character());
    if (char_start < 0) {
      return 0 - 1;
    }
    let line_end: i32 = lsp_parse_int(body, len, line_start, out_line);
    if (line_end < 0) {
      return 0 - 1;
    }
    let char_end: i32 = lsp_parse_int(body, len, char_start, out_character);
    if (char_end < 0) {
      return 0 - 1;
    }
  }
  return 0;
}

#[no_mangle]
/** Exported function `lsp_line_is_block_comment`.
 * Implements `lsp_line_is_block_comment`.
 * @param doc *u8
 * @param content_start i32
 * @param content_len i32
 * @param in_block i32
 * @return i32
 */
export function lsp_line_is_block_comment(doc: *u8, content_start: i32, content_len: i32, in_block: i32): i32 {
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
/** Exported function `lsp_parse_bool_after`.
 * Implements `lsp_parse_bool_after`.
 * @param body *u8
 * @param len i32
 * @param start i32
 * @param key *u8
 * @param out_val *i32
 * @return i32
 */
export function lsp_parse_bool_after(body: *u8, len: i32, start: i32, key: *u8, out_val: *i32): i32 {
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
/** Exported function `lsp_fmt_space_before`.
 * Implements `lsp_fmt_space_before`.
 * @param doc *u8
 * @param start i32
 * @param j i32
 * @param out_buf *u8
 * @param out_len *i32
 * @param out_cap i32
 * @return i32
 */
export function lsp_fmt_space_before(doc: *u8, start: i32, j: i32, out_buf: *u8, out_len: *i32, out_cap: i32): i32 {
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

// lsp_fmt_space_after: see function docblock below.

#[no_mangle]
/** Exported function `lsp_fmt_space_after`.
 * Implements `lsp_fmt_space_after`.
 * @param doc *u8
 * @param start i32
 * @param len i32
 * @param j i32
 * @param out_buf *u8
 * @param out_len *i32
 * @param out_cap i32
 * @return i32
 */
export function lsp_fmt_space_after(doc: *u8, start: i32, len: i32, j: i32, out_buf: *u8, out_len: *i32, out_cap: i32): i32 {
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
/** Exported function `lsp_json_escape_ident`.
 * Implements `lsp_json_escape_ident`.
 * @param s *u8
 * @param esc *u8
 * @param esc_cap i32
 * @return i32
 */
export function lsp_json_escape_ident(s: *u8, esc: *u8, esc_cap: i32): i32 {
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
/** Exported function `lsp_hash_source`.
 * Implements `lsp_hash_source`.
 * @param src *u8
 * @param len i32
 * @return u32
 */
export function lsp_hash_source(src: *u8, len: i32): u32 {
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
