// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-335～338/342/346/386/415：diag L2 thin — pure helper + 门闩子集（无字符串字面量，-E 稳定）。
// 产品 PREFER_X_O：g05_try_x_to_o → thin.o + seeds/diag.from_x.c rest
//   （-DSHUX_L2_DIAG_THIN_FROM_X）ld -r → src/diag.o
// 完整逻辑源仍见 src/diag.x（整文件 -E 仍会截断/挂起）。
//
// f-335：line_digits / kind_is_exact / kind_contains / color_prefix
// f-336：get_file/source/len / code_* / set_file / report
// f-337：push_file / restore → _impl
// f-338：should_color / color_reset / json_mode / extract_line / print_* /
// f-342：code_eq / levenshtein / json_write/report/severity / code_suggest
// f-338 cont：
//        report_with_code / report_human → _impl（共 32）
// f-346：snap pure（store/load ptr/usize/i32 + le 写；定义在 push 前）→ 共 40
// f-347：push = snap_save + apply_impl；restore = snap_load + ctx_set_all → 共 41
// f-386：get_use_color / code_table_has / json_get|set_state → _impl 门闩
// f-415：diag_io_* stdio/fprint + code_table_len → _impl 门闩（共 62）

// ---- rest / libc 提供的符号（勿与下方 thin public 同名，以免 -E 改名）----
extern "C" function diag_ctx_get_use_color_impl(): i32;
extern "C" function diag_ctx_get_file(): *u8;
extern "C" function diag_ctx_get_source(): *u8;
extern "C" function diag_ctx_get_source_len(): i64;
extern "C" function diag_ctx_set_all(path: *u8, source: *u8, source_len: i64, use_color: i32): void;
extern "C" function diag_code_table_has_impl(code: *u8): i32;
extern "C" function diag_entry_kind(code: *u8): *u8;
extern "C" function diag_entry_summary(code: *u8): *u8;
extern "C" function diag_entry_details(code: *u8): *u8;
extern "C" function diag_push_file_apply_impl(path: *u8, source: *u8, source_len: i64): void;
extern "C" function diag_should_color_impl(): i32;
extern "C" function diag_color_reset_impl(): *u8;
extern "C" function diag_set_json_mode_impl(enable: i32): void;
extern "C" function diag_json_enabled_impl(): i32;
extern "C" function diag_extract_line_impl(line_no: i32, line_start_out: *u8, line_len_out: *u8): i32;
extern "C" function diag_print_header_impl(kind: *u8, code: *u8, msg: *u8, kind_color: *u8, reset: *u8): void;
extern "C" function diag_print_code_table_impl(out: *u8): void;
extern "C" function diag_print_known_codes_impl(out: *u8): void;
extern "C" function diag_print_code_explain_impl(out: *u8, code: *u8): void;
extern "C" function diag_report_with_code_impl(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;
extern "C" function diag_report_human_impl(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;

// ---- G-02f-335 pure helpers ----

#[no_mangle]
function diag_line_digits(line: i32): i32 {
  let width: i32 = 1;
  while (line >= 10) {
    line = line / 10;
    width = width + 1;
  }
  return width;
}

#[no_mangle]
function diag_kind_is_exact(kind: *u8, needle: *u8): i32 {
  if (kind == 0) {
    return 0;
  }
  if (needle == 0) {
    return 0;
  }
  let i: i32 = 0;
  while (i < 4096) {
    let a: u8 = kind[i];
    let b: u8 = needle[i];
    if (a != b) {
      return 0;
    }
    if (a == 0) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

#[no_mangle]
function diag_kind_contains(kind: *u8, needle: *u8): i32 {
  if (kind == 0) {
    return 0;
  }
  if (needle == 0) {
    return 0;
  }
  if (needle[0] == 0) {
    return 0;
  }
  let nlen: i32 = 0;
  while (nlen < 4096) {
    if (needle[nlen] == 0) {
      break;
    }
    nlen = nlen + 1;
  }
  if (nlen <= 0) {
    return 0;
  }
  let klen: i32 = 0;
  while (klen < 4096) {
    if (kind[klen] == 0) {
      break;
    }
    klen = klen + 1;
  }
  if (klen < nlen) {
    return 0;
  }
  let s: i32 = 0;
  while (s + nlen <= klen) {
    let j: i32 = 0;
    let ok: i32 = 1;
    while (j < nlen) {
      if (kind[s + j] != needle[j]) {
        ok = 0;
        break;
      }
      j = j + 1;
    }
    if (ok != 0) {
      return 1;
    }
    s = s + 1;
  }
  return 0;
}

#[no_mangle]
function diag_color_prefix(plain: *u8, color: *u8): *u8 {
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
function diag_get_file(): *u8 {
  unsafe {
    return diag_ctx_get_file();
  }
  return 0;
}

#[no_mangle]
function diag_get_source(): *u8 {
  unsafe {
    return diag_ctx_get_source();
  }
  return 0;
}

#[no_mangle]
function diag_get_source_len(): i64 {
  unsafe {
    return diag_ctx_get_source_len();
  }
  return 0;
}

#[no_mangle]
function diag_code_is_known(code: *u8): i32 {
  unsafe {
    return diag_code_table_has_impl(code);
  }
  return 0;
}

#[no_mangle]
function diag_code_kind(code: *u8): *u8 {
  unsafe {
    return diag_entry_kind(code);
  }
  return 0;
}

#[no_mangle]
function diag_code_summary(code: *u8): *u8 {
  unsafe {
    return diag_entry_summary(code);
  }
  return 0;
}

#[no_mangle]
function diag_code_details(code: *u8): *u8 {
  unsafe {
    return diag_entry_details(code);
  }
  return 0;
}

// set_file 直接调 should_color_impl（勿依赖同文件 public，避免 -E 符号冲突）
#[no_mangle]
function diag_set_file(path: *u8, source: *u8, source_len: i64): void {
  unsafe {
    let c: i32 = diag_should_color_impl();
    diag_ctx_set_all(path, source, source_len, c);
  }
}

// report 无 code：直接 with_code_impl
#[no_mangle]
function diag_report(file: *u8, line: i32, col: i32, kind: *u8, msg: *u8, detail: *u8): void {
  unsafe {
    let z: *u8 = 0;
    diag_report_with_code_impl(file, line, col, kind, z, msg, detail);
  }
}

// ---- G-02f-346：diag snap pure（-E：无 let 再赋值；snap+off 指针算术）----
// 布局与 DiagContextSnapshot 一致：file@0 source@8 len@16 color@24

#[no_mangle]
function diag_store_ptr_le(p: *u8, val: *u8): void {
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
function diag_store_usize_le(p: *u8, val: usize): void {
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
function diag_snap_store_ptr(snap: *u8, off: i32, val: *u8): void {
  if (snap == 0 as *u8) {
    return;
  }
  unsafe {
    let q: *u8 = snap + off;
    diag_store_ptr_le(q, val);
  }
}

#[no_mangle]
function diag_snap_store_usize(snap: *u8, off: i32, val: usize): void {
  if (snap == 0 as *u8) {
    return;
  }
  unsafe {
    let q: *u8 = snap + off;
    diag_store_usize_le(q, val);
  }
}

#[no_mangle]
function diag_snap_store_i32(snap: *u8, off: i32, val: i32): void {
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
function diag_snap_load_ptr(snap: *u8, off: i32): *u8 {
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
function diag_snap_load_usize(snap: *u8, off: i32): usize {
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
function diag_snap_load_i32(snap: *u8, off: i32): i32 {
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


// ---- G-02f-337/347：snapshot push/restore（snap pure orch；apply 指针三元仍 seed）----

// -E：嵌套 path/source null if 会丢整函数；snap 保存用早退 helper
#[no_mangle]
function diag_push_snap_save(snapshot: *u8): void {
  if (snapshot == 0 as *u8) {
    return;
  }
  unsafe {
    diag_snap_store_ptr(snapshot, 0, diag_ctx_get_file());
    diag_snap_store_ptr(snapshot, 8, diag_ctx_get_source());
    diag_snap_store_usize(snapshot, 16, diag_ctx_get_source_len() as usize);
    diag_snap_store_i32(snapshot, 24, diag_ctx_get_use_color_impl());
  }
}

#[no_mangle]
function diag_push_file(snapshot: *u8, path: *u8, source: *u8, source_len: i64): void {
  diag_push_snap_save(snapshot);
  unsafe {
    diag_push_file_apply_impl(path, source, source_len);
  }
}

#[no_mangle]
function diag_restore(snapshot: *u8): void {
  if (snapshot == 0 as *u8) {
    return;
  }
  unsafe {
    let p: *u8 = diag_snap_load_ptr(snapshot, 0);
    let s: *u8 = diag_snap_load_ptr(snapshot, 8);
    let sl: usize = diag_snap_load_usize(snapshot, 16);
    let c: i32 = diag_snap_load_i32(snapshot, 24);
    diag_ctx_set_all(p, s, sl as i64, c);
  }
}

// ---- G-02f-338：color / json / print / report 门闩 ----

#[no_mangle]
function diag_should_color(): i32 {
  unsafe {
    return diag_should_color_impl();
  }
  return 0;
}

#[no_mangle]
function diag_color_reset(): *u8 {
  unsafe {
    return diag_color_reset_impl();
  }
  return 0;
}

#[no_mangle]
function diag_set_json_mode(enable: i32): void {
  unsafe {
    diag_set_json_mode_impl(enable);
  }
}

#[no_mangle]
function diag_json_enabled(): i32 {
  unsafe {
    return diag_json_enabled_impl();
  }
  return 0;
}

#[no_mangle]
function diag_extract_line(line_no: i32, line_start_out: *u8, line_len_out: *u8): i32 {
  unsafe {
    return diag_extract_line_impl(line_no, line_start_out, line_len_out);
  }
  return 0 - 1;
}

#[no_mangle]
function diag_print_header(kind: *u8, code: *u8, msg: *u8, kind_color: *u8, reset: *u8): void {
  unsafe {
    diag_print_header_impl(kind, code, msg, kind_color, reset);
  }
}

#[no_mangle]
function diag_print_code_table(out: *u8): void {
  unsafe {
    diag_print_code_table_impl(out);
  }
}

#[no_mangle]
function diag_print_known_codes(out: *u8): void {
  unsafe {
    diag_print_known_codes_impl(out);
  }
}

#[no_mangle]
function diag_print_code_explain(out: *u8, code: *u8): void {
  unsafe {
    diag_print_code_explain_impl(out, code);
  }
}

#[no_mangle]
function diag_report_with_code(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void {
  unsafe {
    diag_report_with_code_impl(file, line, col, kind, code, msg, detail);
  }
}

#[no_mangle]
function diag_report_human(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void {
  unsafe {
    diag_report_human_impl(file, line, col, kind, code, msg, detail);
  }
}

// ---- G-02f-342：code/json 残余门闩 ----
extern "C" function diag_code_eq_impl(lhs: *u8, rhs: *u8): i32;
extern "C" function diag_levenshtein_ci_impl(a: *u8, b: *u8): i32;
extern "C" function diag_json_write_str_impl(out: *u8, s: *u8): void;
extern "C" function diag_report_json_impl(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8): void;
extern "C" function diag_json_severity_impl(kind: *u8): *u8;
extern "C" function diag_code_suggest_impl(code: *u8, out: *u8, out_cap: i64): *u8;

#[no_mangle]
function diag_code_eq(lhs: *u8, rhs: *u8): i32 {
  unsafe {
    return diag_code_eq_impl(lhs, rhs);
  }
  return 0;
}

#[no_mangle]
function diag_levenshtein_ci(a: *u8, b: *u8): i32 {
  unsafe {
    return diag_levenshtein_ci_impl(a, b);
  }
  return 0;
}

#[no_mangle]
function diag_json_write_str(out: *u8, s: *u8): void {
  unsafe {
    diag_json_write_str_impl(out, s);
  }
}

#[no_mangle]
function diag_report_json(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8): void {
  unsafe {
    diag_report_json_impl(file, line, col, kind, code, msg);
  }
}

#[no_mangle]
function diag_json_severity(kind: *u8): *u8 {
  unsafe {
    return diag_json_severity_impl(kind);
  }
  return 0;
}

#[no_mangle]
function diag_code_suggest(code: *u8, out: *u8, out_cap: i64): *u8 {
  unsafe {
    return diag_code_suggest_impl(code, out, out_cap);
  }
  return 0;
}

// ---- G-02f-386：ctx color / code_table_has / json state → seed impl ----
extern "C" function diag_json_get_state_impl(): i32;
extern "C" function diag_json_set_state_impl(v: i32): i32;

#[no_mangle]
function diag_ctx_get_use_color(): i32 {
  unsafe {
    return diag_ctx_get_use_color_impl();
  }
  return 0;
}

#[no_mangle]
function diag_code_table_has(code: *u8): i32 {
  unsafe {
    return diag_code_table_has_impl(code);
  }
  return 0;
}

#[no_mangle]
function diag_json_get_state(): i32 {
  unsafe {
    return diag_json_get_state_impl();
  }
  return 0 - 2;
}

#[no_mangle]
function diag_json_set_state(v: i32): i32 {
  unsafe {
    return diag_json_set_state_impl(v);
  }
  return 0;
}

// ---- G-02f-415：stdio / fprint 冷路径 + code_table_len → seed impl ----
extern "C" function diag_io_fputc_impl(o: *u8, c: i32): i32;
extern "C" function diag_io_fputs_impl(s: *u8, o: *u8): i32;
extern "C" function diag_io_fputs_u04x_impl(o: *u8, c: u32): void;
extern "C" function diag_io_fflush_impl(o: *u8): void;
extern "C" function diag_io_fprint_line_col_impl(o: *u8, line: i32, col: i32): void;
extern "C" function diag_io_fprint_loc_file_line_col_impl(o: *u8, pc: *u8, file: *u8, line: i32, col: i32, rs: *u8): void;
extern "C" function diag_io_fprint_loc_file_line_impl(o: *u8, pc: *u8, file: *u8, line: i32, rs: *u8): void;
extern "C" function diag_io_fprint_loc_file_impl(o: *u8, pc: *u8, file: *u8, rs: *u8): void;
extern "C" function diag_io_fprint_loc_line_col_impl(o: *u8, pc: *u8, line: i32, col: i32, rs: *u8): void;
extern "C" function diag_io_fprint_gutter_blank_impl(o: *u8, width: i32): void;
extern "C" function diag_io_fprint_src_line_impl(o: *u8, line: i32, start: *u8, len: i32): void;
extern "C" function diag_io_fprint_gutter_bar_impl(o: *u8, width: i32): void;
extern "C" function diag_io_fprint_caret_mark_impl(o: *u8, cc: *u8, rs: *u8, detail: *u8): void;
extern "C" function diag_code_table_len_impl(): i64;
extern "C" function diag_io_fprint_unknown_code_impl(out: *u8, code: *u8): void;
extern "C" function diag_io_fprint_code_table_hdr_impl(out: *u8): void;
extern "C" function diag_io_fprint_code_table_row_impl(out: *u8, code: *u8, kind: *u8, summary: *u8): void;

#[no_mangle]
function diag_io_fputc(o: *u8, c: i32): i32 {
  unsafe { return diag_io_fputc_impl(o, c); }
  return 0;
}

#[no_mangle]
function diag_io_fputs(s: *u8, o: *u8): i32 {
  unsafe { return diag_io_fputs_impl(s, o); }
  return 0;
}

#[no_mangle]
function diag_io_fputs_u04x(o: *u8, c: u32): void {
  unsafe { diag_io_fputs_u04x_impl(o, c); }
}

#[no_mangle]
function diag_io_fflush(o: *u8): void {
  unsafe { diag_io_fflush_impl(o); }
}

#[no_mangle]
function diag_io_fprint_line_col(o: *u8, line: i32, col: i32): void {
  unsafe { diag_io_fprint_line_col_impl(o, line, col); }
}

#[no_mangle]
function diag_io_fprint_loc_file_line_col(o: *u8, pc: *u8, file: *u8, line: i32, col: i32, rs: *u8): void {
  unsafe { diag_io_fprint_loc_file_line_col_impl(o, pc, file, line, col, rs); }
}

#[no_mangle]
function diag_io_fprint_loc_file_line(o: *u8, pc: *u8, file: *u8, line: i32, rs: *u8): void {
  unsafe { diag_io_fprint_loc_file_line_impl(o, pc, file, line, rs); }
}

#[no_mangle]
function diag_io_fprint_loc_file(o: *u8, pc: *u8, file: *u8, rs: *u8): void {
  unsafe { diag_io_fprint_loc_file_impl(o, pc, file, rs); }
}

#[no_mangle]
function diag_io_fprint_loc_line_col(o: *u8, pc: *u8, line: i32, col: i32, rs: *u8): void {
  unsafe { diag_io_fprint_loc_line_col_impl(o, pc, line, col, rs); }
}

#[no_mangle]
function diag_io_fprint_gutter_blank(o: *u8, width: i32): void {
  unsafe { diag_io_fprint_gutter_blank_impl(o, width); }
}

#[no_mangle]
function diag_io_fprint_src_line(o: *u8, line: i32, start: *u8, len: i32): void {
  unsafe { diag_io_fprint_src_line_impl(o, line, start, len); }
}

#[no_mangle]
function diag_io_fprint_gutter_bar(o: *u8, width: i32): void {
  unsafe { diag_io_fprint_gutter_bar_impl(o, width); }
}

#[no_mangle]
function diag_io_fprint_caret_mark(o: *u8, cc: *u8, rs: *u8, detail: *u8): void {
  unsafe { diag_io_fprint_caret_mark_impl(o, cc, rs, detail); }
}

#[no_mangle]
function diag_code_table_len(): i64 {
  unsafe { return diag_code_table_len_impl(); }
  return 0;
}

#[no_mangle]
function diag_io_fprint_unknown_code(out: *u8, code: *u8): void {
  unsafe { diag_io_fprint_unknown_code_impl(out, code); }
}

#[no_mangle]
function diag_io_fprint_code_table_hdr(out: *u8): void {
  unsafe { diag_io_fprint_code_table_hdr_impl(out); }
}

#[no_mangle]
function diag_io_fprint_code_table_row(out: *u8, code: *u8, kind: *u8, summary: *u8): void {
  unsafe { diag_io_fprint_code_table_row_impl(out, code, kind, summary); }
}
