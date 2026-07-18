// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
//   （-DSHUX_L2_DIAG_THIN_FROM_X）ld -r → src/diag.o
// See implementation.
//
// f-335：line_digits / kind_is_exact / kind_contains / color_prefix
// f-336：get_file/source/len / code_* / set_file / report
// f-337：push_file / restore → _impl
// f-338：should_color / color_reset / json_mode / extract_line / print_* /
// f-342：code_eq / levenshtein / json_write/report/severity / code_suggest
// f-338 cont：
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

// See implementation.
export extern "C" function diag_ctx_get_use_color_impl(): i32;
export extern "C" function diag_ctx_get_file_impl(): *u8;
export extern "C" function diag_ctx_get_source_impl(): *u8;
export extern "C" function diag_ctx_get_source_len_impl(): i64;
export extern "C" function diag_ctx_set_all_impl(path: *u8, source: *u8, source_len: i64, use_color: i32): void;
export extern "C" function diag_code_table_has_impl(code: *u8): i32;
export extern "C" function diag_entry_kind_impl(code: *u8): *u8;
export extern "C" function diag_entry_summary_impl(code: *u8): *u8;
export extern "C" function diag_entry_details_impl(code: *u8): *u8;
export extern "C" function diag_push_file_apply_impl(path: *u8, source: *u8, source_len: i64): void;
export extern "C" function diag_should_color_impl(): i32;
export extern "C" function diag_color_reset_impl(): *u8;
export extern "C" function diag_set_json_mode_impl(enable: i32): void;
export extern "C" function diag_json_enabled_impl(): i32;
export extern "C" function diag_extract_line_impl(line_no: i32, line_start_out: *u8, line_len_out: *u8): i32;
export extern "C" function diag_print_header_impl(kind: *u8, code: *u8, msg: *u8, kind_color: *u8, reset: *u8): void;
export extern "C" function diag_print_code_table_impl(out: *u8): void;
export extern "C" function diag_print_known_codes_impl(out: *u8): void;
export extern "C" function diag_print_code_explain_impl(out: *u8, code: *u8): void;
export extern "C" function diag_report_with_code_impl(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;
export extern "C" function diag_report_human_impl(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;

// ---- G-02f-335 pure helpers ----

#[no_mangle]
/** Exported function `diag_line_digits`.
 * Implements `diag_line_digits`.
 * @param line i32
 * @return i32
 */
export function diag_line_digits(line: i32): i32 {
  let width: i32 = 1;
  while (line >= 10) {
    line = line / 10;
    width = width + 1;
  }
  return width;
}

/** Exported function `diag_cstr_len_bounded`.
 * Implements `diag_cstr_len_bounded`.
 * @param s *u8
 * @return i32
 */
export function diag_cstr_len_bounded(s: *u8): i32 {
  if (s == 0) {
    return 0;
  }
  let n: i32 = 0;
  while (n < 4096) {
    if (s[n] == 0) {
      return n;
    }
    n = n + 1;
  }
  return 4096;
}

/** Exported function `diag_bytes_match_at`.
 * Implements `diag_bytes_match_at`.
 * @param hay *u8
 * @param needle *u8
 * @param off i32
 * @param nlen i32
 * @return i32
 */
export function diag_bytes_match_at(hay: *u8, needle: *u8, off: i32, nlen: i32): i32 {
  let j: i32 = 0;
  while (j < nlen) {
    if (hay[off + j] != needle[j]) {
      return 0;
    }
    j = j + 1;
  }
  return 1;
}

#[no_mangle]
/** Exported function `diag_kind_is_exact`.
 * Implements `diag_kind_is_exact`.
 * @param kind *u8
 * @param needle *u8
 * @return i32
 */
export function diag_kind_is_exact(kind: *u8, needle: *u8): i32 {
  if (kind == 0) {
    return 0;
  }
  if (needle == 0) {
    return 0;
  }
  let klen: i32 = diag_cstr_len_bounded(kind);
  let nlen: i32 = diag_cstr_len_bounded(needle);
  if (klen != nlen) {
    return 0;
  }
  return diag_bytes_match_at(kind, needle, 0, nlen);
}

#[no_mangle]
/** Exported function `diag_kind_contains`.
 * Implements `diag_kind_contains`.
 * @param kind *u8
 * @param needle *u8
 * @return i32
 */
export function diag_kind_contains(kind: *u8, needle: *u8): i32 {
  if (kind == 0) {
    return 0;
  }
  if (needle == 0) {
    return 0;
  }
  if (needle[0] == 0) {
    return 0;
  }
  let nlen: i32 = diag_cstr_len_bounded(needle);
  if (nlen <= 0) {
    return 0;
  }
  let klen: i32 = diag_cstr_len_bounded(kind);
  if (klen < nlen) {
    return 0;
  }
  let s: i32 = 0;
  while (s + nlen <= klen) {
    if (diag_bytes_match_at(kind, needle, s, nlen) != 0) {
      return 1;
    }
    s = s + 1;
  }
  return 0;
}

#[no_mangle]
/** Exported function `diag_color_prefix`.
 * Implements `diag_color_prefix`.
 * @param plain *u8
 * @param color *u8
 * @return *u8
 */
export function diag_color_prefix(plain: *u8, color: *u8): *u8 {
  unsafe {
    if (diag_ctx_get_use_color_impl() != 0) {
      return color;
    }
    return plain;
  }
  return plain;
}

// ---- G-02f-336 context / code-table gates ----

#[no_mangle]
/** Exported function `diag_get_file`.
 * Implements `diag_get_file`.
 * @return *u8
 */
export function diag_get_file(): *u8 {
  unsafe {
    return diag_ctx_get_file_impl();
  }
}

#[no_mangle]
/** Exported function `diag_get_source`.
 * Implements `diag_get_source`.
 * @return *u8
 */
export function diag_get_source(): *u8 {
  unsafe {
    return diag_ctx_get_source_impl();
  }
}

#[no_mangle]
/** Exported function `diag_get_source_len`.
 * Query helper `diag_get_source_len`.
 * @return i64
 */
export function diag_get_source_len(): i64 {
  unsafe {
    return diag_ctx_get_source_len_impl();
  }
}

#[no_mangle]
/** Exported function `diag_code_is_known`.
 * Implements `diag_code_is_known`.
 * @param code *u8
 * @return i32
 */
export function diag_code_is_known(code: *u8): i32 {
  unsafe {
    return diag_code_table_has_impl(code);
  }
}

#[no_mangle]
/** Exported function `diag_code_kind`.
 * Implements `diag_code_kind`.
 * @param code *u8
 * @return *u8
 */
export function diag_code_kind(code: *u8): *u8 {
  unsafe {
    return diag_entry_kind_impl(code);
  }
}

#[no_mangle]
/** Exported function `diag_code_summary`.
 * Implements `diag_code_summary`.
 * @param code *u8
 * @return *u8
 */
export function diag_code_summary(code: *u8): *u8 {
  unsafe {
    return diag_entry_summary_impl(code);
  }
}

#[no_mangle]
/** Exported function `diag_code_details`.
 * Implements `diag_code_details`.
 * @param code *u8
 * @return *u8
 */
export function diag_code_details(code: *u8): *u8 {
  unsafe {
    return diag_entry_details_impl(code);
  }
}

// diag_set_file: see function docblock below.
#[no_mangle]
/** Exported function `diag_set_file`.
 * Implements `diag_set_file`.
 * @param path *u8
 * @param source *u8
 * @param source_len i64
 * @return void
 */
export function diag_set_file(path: *u8, source: *u8, source_len: i64): void {
  unsafe {
    let c: i32 = diag_should_color_impl();
    diag_ctx_set_all_impl(path, source, source_len, c);
  }
}

// diag_report: see function docblock below.
#[no_mangle]
/** Exported function `diag_report`.
 * Implements `diag_report`.
 * @param file *u8
 * @param line i32
 * @param col i32
 * @param kind *u8
 * @param msg *u8
 * @param detail *u8
 * @return void
 */
export function diag_report(file: *u8, line: i32, col: i32, kind: *u8, msg: *u8, detail: *u8): void {
  unsafe {
    let z: *u8 = 0;
    diag_report_with_code_impl(file, line, col, kind, z, msg, detail);
  }
}

// See implementation.
// diag_store_ptr_le: see function docblock below.

#[no_mangle]
/** Exported function `diag_store_ptr_le`.
 * Implements `diag_store_ptr_le`.
 * @param p *u8
 * @param val *u8
 * @return void
 */
export function diag_store_ptr_le(p: *u8, val: *u8): void {
  if (p == 0 as *u8) {
    return;
  }
  unsafe {
    let a: usize = val as usize;
    let m: usize = 256;
    let b0: usize = a % m;
    let a1: usize = a / m;
    let b1: usize = a1 % m;
    let a2: usize = a1 / m;
    let b2: usize = a2 % m;
    let a3: usize = a2 / m;
    let b3: usize = a3 % m;
    let a4: usize = a3 / m;
    let b4: usize = a4 % m;
    let a5: usize = a4 / m;
    let b5: usize = a5 % m;
    let a6: usize = a5 / m;
    let b6: usize = a6 % m;
    let a7: usize = a6 / m;
    let b7: usize = a7 % m;
    p[0] = b0 as u8;
    p[1] = b1 as u8;
    p[2] = b2 as u8;
    p[3] = b3 as u8;
    p[4] = b4 as u8;
    p[5] = b5 as u8;
    p[6] = b6 as u8;
    p[7] = b7 as u8;
  }
}

#[no_mangle]
/** Exported function `diag_store_usize_le`.
 * Implements `diag_store_usize_le`.
 * @param p *u8
 * @param val usize
 * @return void
 */
export function diag_store_usize_le(p: *u8, val: usize): void {
  if (p == 0 as *u8) {
    return;
  }
  unsafe {
    let a: usize = val;
    let m: usize = 256;
    let b0: usize = a % m;
    let a1: usize = a / m;
    let b1: usize = a1 % m;
    let a2: usize = a1 / m;
    let b2: usize = a2 % m;
    let a3: usize = a2 / m;
    let b3: usize = a3 % m;
    let a4: usize = a3 / m;
    let b4: usize = a4 % m;
    let a5: usize = a4 / m;
    let b5: usize = a5 % m;
    let a6: usize = a5 / m;
    let b6: usize = a6 % m;
    let a7: usize = a6 / m;
    let b7: usize = a7 % m;
    p[0] = b0 as u8;
    p[1] = b1 as u8;
    p[2] = b2 as u8;
    p[3] = b3 as u8;
    p[4] = b4 as u8;
    p[5] = b5 as u8;
    p[6] = b6 as u8;
    p[7] = b7 as u8;
  }
}

#[no_mangle]
/** Exported function `diag_snap_store_ptr`.
 * Implements `diag_snap_store_ptr`.
 * @param snap *u8
 * @param off i32
 * @param val *u8
 * @return void
 */
export function diag_snap_store_ptr(snap: *u8, off: i32, val: *u8): void {
  if (snap == 0 as *u8) {
    return;
  }
  unsafe {
    let q: *u8 = snap + off;
    diag_store_ptr_le(q, val);
  }
}

#[no_mangle]
/** Exported function `diag_snap_store_usize`.
 * Implements `diag_snap_store_usize`.
 * @param snap *u8
 * @param off i32
 * @param val usize
 * @return void
 */
export function diag_snap_store_usize(snap: *u8, off: i32, val: usize): void {
  if (snap == 0 as *u8) {
    return;
  }
  unsafe {
    let q: *u8 = snap + off;
    diag_store_usize_le(q, val);
  }
}

#[no_mangle]
/** Exported function `diag_snap_store_i32`.
 * Implements `diag_snap_store_i32`.
 * @param snap *u8
 * @param off i32
 * @param val i32
 * @return void
 */
export function diag_snap_store_i32(snap: *u8, off: i32, val: i32): void {
  if (snap == 0 as *u8) {
    return;
  }
  if (val < 0) {
    unsafe {
      let q: *u8 = snap + off;
      q[0] = 0;
      q[1] = 0;
      q[2] = 0;
      q[3] = 0;
    }
    return;
  }
  unsafe {
    let q: *u8 = snap + off;
    let a: i32 = val;
    let b0: i32 = a % 256;
    let a1: i32 = a / 256;
    let b1: i32 = a1 % 256;
    let a2: i32 = a1 / 256;
    let b2: i32 = a2 % 256;
    let a3: i32 = a2 / 256;
    let b3: i32 = a3 % 256;
    q[0] = b0 as u8;
    q[1] = b1 as u8;
    q[2] = b2 as u8;
    q[3] = b3 as u8;
  }
}

#[no_mangle]
/** Exported function `diag_snap_load_ptr`.
 * Implements `diag_snap_load_ptr`.
 * @param snap *u8
 * @param off i32
 * @return *u8
 */
export function diag_snap_load_ptr(snap: *u8, off: i32): *u8 {
  if (snap == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    let q: *u8 = snap + off;
    let m: usize = 256;
    let m2: usize = m * m;
    let m4: usize = m2 * m2;
    let a0: usize = q[0] as usize;
    let a1: usize = a0 + (q[1] as usize) * m;
    let a2: usize = a1 + (q[2] as usize) * m2;
    let a3: usize = a2 + (q[3] as usize) * (m2 * m);
    let a4: usize = a3 + (q[4] as usize) * m4;
    let a5: usize = a4 + (q[5] as usize) * (m4 * m);
    let a6: usize = a5 + (q[6] as usize) * (m4 * m2);
    let a7: usize = a6 + (q[7] as usize) * (m4 * m2 * m);
    return a7 as *u8;
  }
  return 0 as *u8;
}

#[no_mangle]
/** Exported function `diag_snap_load_usize`.
 * Implements `diag_snap_load_usize`.
 * @param snap *u8
 * @param off i32
 * @return usize
 */
export function diag_snap_load_usize(snap: *u8, off: i32): usize {
  if (snap == 0 as *u8) {
    return 0;
  }
  unsafe {
    let q: *u8 = snap + off;
    let m: usize = 256;
    let m2: usize = m * m;
    let m4: usize = m2 * m2;
    let a0: usize = q[0] as usize;
    let a1: usize = a0 + (q[1] as usize) * m;
    let a2: usize = a1 + (q[2] as usize) * m2;
    let a3: usize = a2 + (q[3] as usize) * (m2 * m);
    let a4: usize = a3 + (q[4] as usize) * m4;
    let a5: usize = a4 + (q[5] as usize) * (m4 * m);
    let a6: usize = a5 + (q[6] as usize) * (m4 * m2);
    let a7: usize = a6 + (q[7] as usize) * (m4 * m2 * m);
    return a7;
  }
  return 0;
}

#[no_mangle]
/** Exported function `diag_snap_load_i32`.
 * Implements `diag_snap_load_i32`.
 * @param snap *u8
 * @param off i32
 * @return i32
 */
export function diag_snap_load_i32(snap: *u8, off: i32): i32 {
  if (snap == 0 as *u8) {
    return 0;
  }
  unsafe {
    let q: *u8 = snap + off;
    let m: i32 = 256;
    let a0: i32 = q[0] as i32;
    let a1: i32 = a0 + (q[1] as i32) * m;
    let a2: i32 = a1 + (q[2] as i32) * m * m;
    let a3: i32 = a2 + (q[3] as i32) * m * m * m;
    return a3;
  }
  return 0;
}


// See implementation.

// diag_push_snap_save: see function docblock below.
#[no_mangle]
/** Exported function `diag_push_snap_save`.
 * Implements `diag_push_snap_save`.
 * @param snapshot *u8
 * @return void
 */
export function diag_push_snap_save(snapshot: *u8): void {
  if (snapshot == 0 as *u8) {
    return;
  }
  unsafe {
    diag_snap_store_ptr(snapshot, 0, diag_ctx_get_file_impl());
    diag_snap_store_ptr(snapshot, 8, diag_ctx_get_source_impl());
    diag_snap_store_usize(snapshot, 16, diag_ctx_get_source_len_impl() as usize);
    diag_snap_store_i32(snapshot, 24, diag_ctx_get_use_color_impl());
  }
}

#[no_mangle]
/** Exported function `diag_push_file`.
 * Implements `diag_push_file`.
 * @param snapshot *u8
 * @param path *u8
 * @param source *u8
 * @param source_len i64
 * @return void
 */
export function diag_push_file(snapshot: *u8, path: *u8, source: *u8, source_len: i64): void {
  diag_push_snap_save(snapshot);
  unsafe {
    diag_push_file_apply_impl(path, source, source_len);
  }
}

#[no_mangle]
/** Exported function `diag_restore`.
 * Implements `diag_restore`.
 * @param snapshot *u8
 * @return void
 */
export function diag_restore(snapshot: *u8): void {
  if (snapshot == 0 as *u8) {
    return;
  }
  unsafe {
    let p: *u8 = diag_snap_load_ptr(snapshot, 0);
    let s: *u8 = diag_snap_load_ptr(snapshot, 8);
    let sl: usize = diag_snap_load_usize(snapshot, 16);
    let c: i32 = diag_snap_load_i32(snapshot, 24);
    diag_ctx_set_all_impl(p, s, sl as i64, c);
  }
}

// diag_should_color: see function docblock below.

#[no_mangle]
/** Exported function `diag_should_color`.
 * Implements `diag_should_color`.
 * @return i32
 */
export function diag_should_color(): i32 {
  unsafe {
    return diag_should_color_impl();
  }
}

#[no_mangle]
/** Exported function `diag_color_reset`.
 * Implements `diag_color_reset`.
 * @return *u8
 */
export function diag_color_reset(): *u8 {
  unsafe {
    return diag_color_reset_impl();
  }
}

#[no_mangle]
/** Exported function `diag_set_json_mode`.
 * Implements `diag_set_json_mode`.
 * @param enable i32
 * @return void
 */
export function diag_set_json_mode(enable: i32): void {
  unsafe {
    diag_set_json_mode_impl(enable);
  }
}

#[no_mangle]
/** Exported function `diag_json_enabled`.
 * Implements `diag_json_enabled`.
 * @return i32
 */
export function diag_json_enabled(): i32 {
  unsafe {
    return diag_json_enabled_impl();
  }
}

#[no_mangle]
/** Exported function `diag_extract_line`.
 * Implements `diag_extract_line`.
 * @param line_no i32
 * @param line_start_out *u8
 * @param line_len_out *u8
 * @return i32
 */
export function diag_extract_line(line_no: i32, line_start_out: *u8, line_len_out: *u8): i32 {
  unsafe {
    return diag_extract_line_impl(line_no, line_start_out, line_len_out);
  }
  return 0 - 1;
}

#[no_mangle]
/** Exported function `diag_print_header`.
 * Implements `diag_print_header`.
 * @param kind *u8
 * @param code *u8
 * @param msg *u8
 * @param kind_color *u8
 * @param reset *u8
 * @return void
 */
export function diag_print_header(kind: *u8, code: *u8, msg: *u8, kind_color: *u8, reset: *u8): void {
  unsafe {
    diag_print_header_impl(kind, code, msg, kind_color, reset);
  }
}

#[no_mangle]
/** Exported function `diag_print_code_table`.
 * Implements `diag_print_code_table`.
 * @param out *u8
 * @return void
 */
export function diag_print_code_table(out: *u8): void {
  unsafe {
    diag_print_code_table_impl(out);
  }
}

#[no_mangle]
/** Exported function `diag_print_known_codes`.
 * Implements `diag_print_known_codes`.
 * @param out *u8
 * @return void
 */
export function diag_print_known_codes(out: *u8): void {
  unsafe {
    diag_print_known_codes_impl(out);
  }
}

#[no_mangle]
/** Exported function `diag_print_code_explain`.
 * Implements `diag_print_code_explain`.
 * @param out *u8
 * @param code *u8
 * @return void
 */
export function diag_print_code_explain(out: *u8, code: *u8): void {
  unsafe {
    diag_print_code_explain_impl(out, code);
  }
}

#[no_mangle]
/** Exported function `diag_report_with_code`.
 * Implements `diag_report_with_code`.
 * @param file *u8
 * @param line i32
 * @param col i32
 * @param kind *u8
 * @param code *u8
 * @param msg *u8
 * @param detail *u8
 * @return void
 */
export function diag_report_with_code(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void {
  unsafe {
    diag_report_with_code_impl(file, line, col, kind, code, msg, detail);
  }
}

#[no_mangle]
/** Exported function `diag_report_human`.
 * Implements `diag_report_human`.
 * @param file *u8
 * @param line i32
 * @param col i32
 * @param kind *u8
 * @param code *u8
 * @param msg *u8
 * @param detail *u8
 * @return void
 */
export function diag_report_human(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void {
  unsafe {
    diag_report_human_impl(file, line, col, kind, code, msg, detail);
  }
}

// See implementation.
export extern "C" function diag_code_eq_impl(lhs: *u8, rhs: *u8): i32;
export extern "C" function diag_levenshtein_ci_impl(a: *u8, b: *u8): i32;
export extern "C" function diag_json_write_str_impl(out: *u8, s: *u8): void;
export extern "C" function diag_report_json_impl(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8): void;
export extern "C" function diag_json_severity_impl(kind: *u8): *u8;
export extern "C" function diag_code_suggest_impl(code: *u8, out: *u8, out_cap: i64): *u8;

#[no_mangle]
/** Exported function `diag_code_eq`.
 * Implements `diag_code_eq`.
 * @param lhs *u8
 * @param rhs *u8
 * @return i32
 */
export function diag_code_eq(lhs: *u8, rhs: *u8): i32 {
  unsafe {
    return diag_code_eq_impl(lhs, rhs);
  }
}

#[no_mangle]
/** Exported function `diag_levenshtein_ci`.
 * Implements `diag_levenshtein_ci`.
 * @param a *u8
 * @param b *u8
 * @return i32
 */
export function diag_levenshtein_ci(a: *u8, b: *u8): i32 {
  unsafe {
    return diag_levenshtein_ci_impl(a, b);
  }
}

#[no_mangle]
/** Exported function `diag_json_write_str`.
 * Write path helper `diag_json_write_str`.
 * @param out *u8
 * @param s *u8
 * @return void
 */
export function diag_json_write_str(out: *u8, s: *u8): void {
  unsafe {
    diag_json_write_str_impl(out, s);
  }
}

#[no_mangle]
/** Exported function `diag_report_json`.
 * Implements `diag_report_json`.
 * @param file *u8
 * @param line i32
 * @param col i32
 * @param kind *u8
 * @param code *u8
 * @param msg *u8
 * @return void
 */
export function diag_report_json(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8): void {
  unsafe {
    diag_report_json_impl(file, line, col, kind, code, msg);
  }
}

#[no_mangle]
/** Exported function `diag_json_severity`.
 * Implements `diag_json_severity`.
 * @param kind *u8
 * @return *u8
 */
export function diag_json_severity(kind: *u8): *u8 {
  unsafe {
    return diag_json_severity_impl(kind);
  }
}

#[no_mangle]
/** Exported function `diag_code_suggest`.
 * Implements `diag_code_suggest`.
 * @param code *u8
 * @param out *u8
 * @param out_cap i64
 * @return *u8
 */
export function diag_code_suggest(code: *u8, out: *u8, out_cap: i64): *u8 {
  unsafe {
    return diag_code_suggest_impl(code, out, out_cap);
  }
}

// ---- G-02f-386：ctx color / code_table_has / json state → seed impl ----
export extern "C" function diag_json_get_state_impl(): i32;
export extern "C" function diag_json_set_state_impl(v: i32): i32;

#[no_mangle]
/** Exported function `diag_ctx_get_use_color`.
 * Implements `diag_ctx_get_use_color`.
 * @return i32
 */
export function diag_ctx_get_use_color(): i32 {
  unsafe {
    return diag_ctx_get_use_color_impl();
  }
}

#[no_mangle]
/** Exported function `diag_code_table_has`.
 * Implements `diag_code_table_has`.
 * @param code *u8
 * @return i32
 */
export function diag_code_table_has(code: *u8): i32 {
  unsafe {
    return diag_code_table_has_impl(code);
  }
}

#[no_mangle]
/** Exported function `diag_json_get_state`.
 * Implements `diag_json_get_state`.
 * @return i32
 */
export function diag_json_get_state(): i32 {
  unsafe {
    return diag_json_get_state_impl();
  }
  return 0 - 2;
}

#[no_mangle]
/** Exported function `diag_json_set_state`.
 * Implements `diag_json_set_state`.
 * @param v i32
 * @return i32
 */
export function diag_json_set_state(v: i32): i32 {
  unsafe {
    return diag_json_set_state_impl(v);
  }
}

// See implementation.
export extern "C" function diag_io_fputc_impl(o: *u8, c: i32): i32;
export extern "C" function diag_io_fputs_impl(s: *u8, o: *u8): i32;
export extern "C" function diag_io_fputs_u04x_impl(o: *u8, c: u32): void;
export extern "C" function diag_io_fflush_impl(o: *u8): void;
export extern "C" function diag_io_fprint_line_col_impl(o: *u8, line: i32, col: i32): void;
export extern "C" function diag_io_fprint_loc_file_line_col_impl(o: *u8, pc: *u8, file: *u8, line: i32, col: i32, rs: *u8): void;
export extern "C" function diag_io_fprint_loc_file_line_impl(o: *u8, pc: *u8, file: *u8, line: i32, rs: *u8): void;
export extern "C" function diag_io_fprint_loc_file_impl(o: *u8, pc: *u8, file: *u8, rs: *u8): void;
export extern "C" function diag_io_fprint_loc_line_col_impl(o: *u8, pc: *u8, line: i32, col: i32, rs: *u8): void;
export extern "C" function diag_io_fprint_gutter_blank_impl(o: *u8, width: i32): void;
export extern "C" function diag_io_fprint_src_line_impl(o: *u8, line: i32, start: *u8, len: i32): void;
export extern "C" function diag_io_fprint_gutter_bar_impl(o: *u8, width: i32): void;
export extern "C" function diag_io_fprint_caret_mark_impl(o: *u8, cc: *u8, rs: *u8, detail: *u8): void;
export extern "C" function diag_code_table_len_impl(): i64;
export extern "C" function diag_io_fprint_unknown_code_impl(out: *u8, code: *u8): void;
export extern "C" function diag_io_fprint_code_table_hdr_impl(out: *u8): void;
export extern "C" function diag_io_fprint_code_table_row_impl(out: *u8, code: *u8, kind: *u8, summary: *u8): void;

#[no_mangle]
/** Exported function `diag_io_fputc`.
 * Implements `diag_io_fputc`.
 * @param o *u8
 * @param c i32
 * @return i32
 */
export function diag_io_fputc(o: *u8, c: i32): i32 {
  unsafe { return diag_io_fputc_impl(o, c); }
}

#[no_mangle]
/** Exported function `diag_io_fputs`.
 * Implements `diag_io_fputs`.
 * @param s *u8
 * @param o *u8
 * @return i32
 */
export function diag_io_fputs(s: *u8, o: *u8): i32 {
  unsafe { return diag_io_fputs_impl(s, o); }
}

#[no_mangle]
/** Exported function `diag_io_fputs_u04x`.
 * Implements `diag_io_fputs_u04x`.
 * @param o *u8
 * @param c u32
 * @return void
 */
export function diag_io_fputs_u04x(o: *u8, c: u32): void {
  unsafe { diag_io_fputs_u04x_impl(o, c); }
}

#[no_mangle]
/** Exported function `diag_io_fflush`.
 * Implements `diag_io_fflush`.
 * @param o *u8
 * @return void
 */
export function diag_io_fflush(o: *u8): void {
  unsafe { diag_io_fflush_impl(o); }
}

#[no_mangle]
/** Exported function `diag_io_fprint_line_col`.
 * Implements `diag_io_fprint_line_col`.
 * @param o *u8
 * @param line i32
 * @param col i32
 * @return void
 */
export function diag_io_fprint_line_col(o: *u8, line: i32, col: i32): void {
  unsafe { diag_io_fprint_line_col_impl(o, line, col); }
}

#[no_mangle]
/** Exported function `diag_io_fprint_loc_file_line_col`.
 * Implements `diag_io_fprint_loc_file_line_col`.
 * @param o *u8
 * @param pc *u8
 * @param file *u8
 * @param line i32
 * @param col i32
 * @param rs *u8
 * @return void
 */
export function diag_io_fprint_loc_file_line_col(o: *u8, pc: *u8, file: *u8, line: i32, col: i32, rs: *u8): void {
  unsafe { diag_io_fprint_loc_file_line_col_impl(o, pc, file, line, col, rs); }
}

#[no_mangle]
/** Exported function `diag_io_fprint_loc_file_line`.
 * Implements `diag_io_fprint_loc_file_line`.
 * @param o *u8
 * @param pc *u8
 * @param file *u8
 * @param line i32
 * @param rs *u8
 * @return void
 */
export function diag_io_fprint_loc_file_line(o: *u8, pc: *u8, file: *u8, line: i32, rs: *u8): void {
  unsafe { diag_io_fprint_loc_file_line_impl(o, pc, file, line, rs); }
}

#[no_mangle]
/** Exported function `diag_io_fprint_loc_file`.
 * Implements `diag_io_fprint_loc_file`.
 * @param o *u8
 * @param pc *u8
 * @param file *u8
 * @param rs *u8
 * @return void
 */
export function diag_io_fprint_loc_file(o: *u8, pc: *u8, file: *u8, rs: *u8): void {
  unsafe { diag_io_fprint_loc_file_impl(o, pc, file, rs); }
}

#[no_mangle]
/** Exported function `diag_io_fprint_loc_line_col`.
 * Implements `diag_io_fprint_loc_line_col`.
 * @param o *u8
 * @param pc *u8
 * @param line i32
 * @param col i32
 * @param rs *u8
 * @return void
 */
export function diag_io_fprint_loc_line_col(o: *u8, pc: *u8, line: i32, col: i32, rs: *u8): void {
  unsafe { diag_io_fprint_loc_line_col_impl(o, pc, line, col, rs); }
}

#[no_mangle]
/** Exported function `diag_io_fprint_gutter_blank`.
 * Implements `diag_io_fprint_gutter_blank`.
 * @param o *u8
 * @param width i32
 * @return void
 */
export function diag_io_fprint_gutter_blank(o: *u8, width: i32): void {
  unsafe { diag_io_fprint_gutter_blank_impl(o, width); }
}

#[no_mangle]
/** Exported function `diag_io_fprint_src_line`.
 * Implements `diag_io_fprint_src_line`.
 * @param o *u8
 * @param line i32
 * @param start *u8
 * @param len i32
 * @return void
 */
export function diag_io_fprint_src_line(o: *u8, line: i32, start: *u8, len: i32): void {
  unsafe { diag_io_fprint_src_line_impl(o, line, start, len); }
}

#[no_mangle]
/** Exported function `diag_io_fprint_gutter_bar`.
 * Implements `diag_io_fprint_gutter_bar`.
 * @param o *u8
 * @param width i32
 * @return void
 */
export function diag_io_fprint_gutter_bar(o: *u8, width: i32): void {
  unsafe { diag_io_fprint_gutter_bar_impl(o, width); }
}

#[no_mangle]
/** Exported function `diag_io_fprint_caret_mark`.
 * Implements `diag_io_fprint_caret_mark`.
 * @param o *u8
 * @param cc *u8
 * @param rs *u8
 * @param detail *u8
 * @return void
 */
export function diag_io_fprint_caret_mark(o: *u8, cc: *u8, rs: *u8, detail: *u8): void {
  unsafe { diag_io_fprint_caret_mark_impl(o, cc, rs, detail); }
}

#[no_mangle]
/** Exported function `diag_code_table_len`.
 * Query helper `diag_code_table_len`.
 * @return i64
 */
export function diag_code_table_len(): i64 {
  unsafe { return diag_code_table_len_impl(); }
}

#[no_mangle]
/** Exported function `diag_io_fprint_unknown_code`.
 * Implements `diag_io_fprint_unknown_code`.
 * @param out *u8
 * @param code *u8
 * @return void
 */
export function diag_io_fprint_unknown_code(out: *u8, code: *u8): void {
  unsafe { diag_io_fprint_unknown_code_impl(out, code); }
}

#[no_mangle]
/** Exported function `diag_io_fprint_code_table_hdr`.
 * Implements `diag_io_fprint_code_table_hdr`.
 * @param out *u8
 * @return void
 */
export function diag_io_fprint_code_table_hdr(out: *u8): void {
  unsafe { diag_io_fprint_code_table_hdr_impl(out); }
}

#[no_mangle]
/** Exported function `diag_io_fprint_code_table_row`.
 * Implements `diag_io_fprint_code_table_row`.
 * @param out *u8
 * @param code *u8
 * @param kind *u8
 * @param summary *u8
 * @return void
 */
export function diag_io_fprint_code_table_row(out: *u8, code: *u8, kind: *u8, summary: *u8): void {
  unsafe { diag_io_fprint_code_table_row_impl(out, code, kind, summary); }
}

// ---- G-02f-420：ctx field get/set → seed impl pure forward ----
#[no_mangle]
/** Exported function `diag_ctx_get_file`.
 * Implements `diag_ctx_get_file`.
 * @return *u8
 */
export function diag_ctx_get_file(): *u8 {
  unsafe { return diag_ctx_get_file_impl(); }
}

#[no_mangle]
/** Exported function `diag_ctx_get_source`.
 * Implements `diag_ctx_get_source`.
 * @return *u8
 */
export function diag_ctx_get_source(): *u8 {
  unsafe { return diag_ctx_get_source_impl(); }
}

#[no_mangle]
/** Exported function `diag_ctx_get_source_len`.
 * Query helper `diag_ctx_get_source_len`.
 * @return i64
 */
export function diag_ctx_get_source_len(): i64 {
  unsafe { return diag_ctx_get_source_len_impl(); }
}

#[no_mangle]
/** Exported function `diag_ctx_set_all`.
 * Implements `diag_ctx_set_all`.
 * @param path *u8
 * @param source *u8
 * @param source_len i64
 * @param use_color i32
 * @return void
 */
export function diag_ctx_set_all(path: *u8, source: *u8, source_len: i64, use_color: i32): void {
  unsafe { diag_ctx_set_all_impl(path, source, source_len, use_color); }
}

// ---- G-02f-421：code table / entry / stdio handles → seed impl ----
export extern "C" function diag_code_table_code_at_impl(i: i64): *u8;
export extern "C" function diag_code_table_kind_at_impl(i: i64): *u8;
export extern "C" function diag_code_table_summary_at_impl(i: i64): *u8;
export extern "C" function diag_code_table_details_at_impl(i: i64): *u8;
export extern "C" function diag_entry_code_impl(code: *u8): *u8;
export extern "C" function diag_stderr_impl(): *u8;
export extern "C" function diag_stdout_impl(): *u8;

#[no_mangle]
/** Exported function `diag_code_table_code_at`.
 * Implements `diag_code_table_code_at`.
 * @param i i64
 * @return *u8
 */
export function diag_code_table_code_at(i: i64): *u8 {
  unsafe { return diag_code_table_code_at_impl(i); }
}

#[no_mangle]
/** Exported function `diag_code_table_kind_at`.
 * Implements `diag_code_table_kind_at`.
 * @param i i64
 * @return *u8
 */
export function diag_code_table_kind_at(i: i64): *u8 {
  unsafe { return diag_code_table_kind_at_impl(i); }
}

#[no_mangle]
/** Exported function `diag_code_table_summary_at`.
 * Implements `diag_code_table_summary_at`.
 * @param i i64
 * @return *u8
 */
export function diag_code_table_summary_at(i: i64): *u8 {
  unsafe { return diag_code_table_summary_at_impl(i); }
}

#[no_mangle]
/** Exported function `diag_code_table_details_at`.
 * Implements `diag_code_table_details_at`.
 * @param i i64
 * @return *u8
 */
export function diag_code_table_details_at(i: i64): *u8 {
  unsafe { return diag_code_table_details_at_impl(i); }
}

#[no_mangle]
/** Exported function `diag_entry_code`.
 * Implements `diag_entry_code`.
 * @param code *u8
 * @return *u8
 */
export function diag_entry_code(code: *u8): *u8 {
  unsafe { return diag_entry_code_impl(code); }
}

#[no_mangle]
/** Exported function `diag_entry_kind`.
 * Implements `diag_entry_kind`.
 * @param code *u8
 * @return *u8
 */
export function diag_entry_kind(code: *u8): *u8 {
  unsafe { return diag_entry_kind_impl(code); }
}

#[no_mangle]
/** Exported function `diag_entry_summary`.
 * Implements `diag_entry_summary`.
 * @param code *u8
 * @return *u8
 */
export function diag_entry_summary(code: *u8): *u8 {
  unsafe { return diag_entry_summary_impl(code); }
}

#[no_mangle]
/** Exported function `diag_entry_details`.
 * Implements `diag_entry_details`.
 * @param code *u8
 * @return *u8
 */
export function diag_entry_details(code: *u8): *u8 {
  unsafe { return diag_entry_details_impl(code); }
}

#[no_mangle]
/** Exported function `diag_stderr`.
 * Implements `diag_stderr`.
 * @return *u8
 */
export function diag_stderr(): *u8 {
  unsafe { return diag_stderr_impl(); }
}

#[no_mangle]
/** Exported function `diag_stdout`.
 * Implements `diag_stdout`.
 * @return *u8
 */
export function diag_stdout(): *u8 {
  unsafe { return diag_stdout_impl(); }
}
