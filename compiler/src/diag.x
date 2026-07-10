// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-30：真迁 .x — diag_report 无 code 入口薄转发到 with_code。
// G-02f-74：+ remaining diag_* gates.
// G-02f-82：+ diag_get_source / diag_get_source_len / diag_report_with_code 门闩。
// G-02f-96：+ color/kind/code_eq/line_digits 薄 helper 门闩。
// G-02f-97：+ print_header / extract_line / json_write_str / json_severity 门闩。
// G-02f-98：+ diag_levenshtein_ci 门闩。
// 产品：./shux-c -E → seeds/diag.from_x.c（+ C 尾段）。
// C 尾：上下文静态、code 表、JSON/颜色、va_list reportf/vreportf、lookup。
// 注意：va_list 入口仍留 C（语言/ABI 限制）。

extern "C" function diag_report_with_code_impl(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8,
                                          detail: *u8): void;
extern "C" function diag_get_source_impl(): *u8;
extern "C" function diag_get_source_len_impl(): i64;

extern "C" function diag_set_file_impl(path: *u8, source: *u8, source_len: i64): void;
extern "C" function diag_push_file_impl(snapshot: *u8, path: *u8, source: *u8, source_len: i64): void;
extern "C" function diag_restore_impl(snapshot: *u8): void;
extern "C" function diag_code_is_known_impl(code: *u8): i32;
extern "C" function diag_print_known_codes_impl(out: *u8): void;
extern "C" function diag_print_code_explain_impl(out: *u8, code: *u8): void;
extern "C" function diag_print_code_table_impl(out: *u8): void;
extern "C" function diag_set_json_mode_impl(enable: i32): void;
extern "C" function diag_json_enabled_impl(): i32;

extern "C" function diag_should_color_impl(): i32;
extern "C" function diag_color_prefix_impl(plain: *u8, color: *u8): *u8;
extern "C" function diag_color_reset_impl(): *u8;
extern "C" function diag_code_eq_impl(lhs: *u8, rhs: *u8): i32;
extern "C" function diag_kind_is_exact_impl(kind: *u8, needle: *u8): i32;
extern "C" function diag_line_digits_impl(line: i32): i32;

extern "C" function diag_print_header_impl(kind: *u8, code: *u8, msg: *u8, kind_color: *u8, reset: *u8): void;
extern "C" function diag_extract_line_impl(line_no: i32, line_start_out: *u8, line_len_out: *u8): i32;
extern "C" function diag_json_write_str_impl(out: *u8, s: *u8): void;
extern "C" function diag_levenshtein_ci_impl(a: *u8, b: *u8): i32;

#[no_mangle]
function diag_report(file: *u8, line: i32, col: i32, kind: *u8, msg: *u8, detail: *u8): void {
  unsafe {
    diag_report_with_code_impl(file, line, col, kind, 0 as *u8, msg, detail);
  }
}

/* ---- G-02f-74 / G-02f-82 diag gates ---- */

#[no_mangle]
function diag_report_with_code(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void {
  unsafe {
    diag_report_with_code_impl(file, line, col, kind, code, msg, detail);
  }
}

#[no_mangle]
function diag_get_source(): *u8 {
  unsafe {
    return diag_get_source_impl();
  }
  return 0 as *u8;
}

#[no_mangle]
function diag_get_source_len(): i64 {
  unsafe {
    return diag_get_source_len_impl();
  }
  return 0;
}

#[no_mangle]
function diag_set_file(path: *u8, source: *u8, source_len: i64): void {
  unsafe {
    diag_set_file_impl(path, source, source_len);
  }
}

#[no_mangle]
function diag_push_file(snapshot: *u8, path: *u8, source: *u8, source_len: i64): void {
  unsafe {
    diag_push_file_impl(snapshot, path, source, source_len);
  }
}

#[no_mangle]
function diag_restore(snapshot: *u8): void {
  unsafe {
    diag_restore_impl(snapshot);
  }
}

#[no_mangle]
function diag_code_is_known(code: *u8): i32 {
  unsafe {
    return diag_code_is_known_impl(code);
  }
  return 0 - 1;
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
function diag_print_code_table(out: *u8): void {
  unsafe {
    diag_print_code_table_impl(out);
  }
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
  return 0 - 1;
}

/* ---- G-02f-96：color / kind / code_eq / line_digits 门闩 ---- */

#[no_mangle]
function diag_should_color(): i32 {
  unsafe {
    return diag_should_color_impl();
  }
  return 0;
}

#[no_mangle]
function diag_color_prefix(plain: *u8, color: *u8): *u8 {
  unsafe {
    return diag_color_prefix_impl(plain, color);
  }
  return 0 as *u8;
}

#[no_mangle]
function diag_color_reset(): *u8 {
  unsafe {
    return diag_color_reset_impl();
  }
  return 0 as *u8;
}





/* ---- G-02f-97：print_header / extract_line / json 门闩 ---- */

#[no_mangle]
function diag_print_header(kind: *u8, code: *u8, msg: *u8, kind_color: *u8, reset: *u8): void {
  unsafe {
    diag_print_header_impl(kind, code, msg, kind_color, reset);
  }
}

#[no_mangle]
function diag_extract_line(line_no: i32, line_start_out: *u8, line_len_out: *u8): i32 {
  unsafe {
    return diag_extract_line_impl(line_no, line_start_out, line_len_out);
  }
  return 0 - 1;
}

#[no_mangle]
function diag_json_write_str(out: *u8, s: *u8): void {
  unsafe {
    diag_json_write_str_impl(out, s);
  }
}



/* ---- G-02f-98：levenshtein 门闩 ---- */

#[no_mangle]
function diag_levenshtein_ci(a: *u8, b: *u8): i32 {
  unsafe {
    return diag_levenshtein_ci_impl(a, b);
  }
  return 999;
}

// G-02f-109：+ diag_report_json 薄门闩。

extern "C" function diag_report_json_impl(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8): void;

/* ---- G-02f-109：diag JSON report 门闩 ---- */

#[no_mangle]
function diag_report_json(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8): void {
  unsafe { diag_report_json_impl(file, line, col, kind, code, msg); }
}

// G-02f-116：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

// G-02f-130：diag_kind_contains 真迁 .x（子串探测）
#[no_mangle]
function diag_kind_contains(kind: *u8, needle: *u8): i32 {
  if (kind == 0) { return 0; }
  if (needle == 0) { return 0; }
  if (needle[0] == 0) { return 0; }
  let nlen: i32 = 0;
  while (nlen < 4096) {
    if (needle[nlen] == 0) { break; }
    nlen = nlen + 1;
  }
  if (nlen <= 0) { return 0; }
  let klen: i32 = 0;
  while (klen < 4096) {
    if (kind[klen] == 0) { break; }
    klen = klen + 1;
  }
  if (klen < nlen) { return 0; }
  let s: i32 = 0;
  while (s + nlen <= klen) {
    let j: i32 = 0;
    let ok: i32 = 1;
    while (j < nlen) {
      if (kind[s + j] != needle[j]) { ok = 0; break; }
      j = j + 1;
    }
    if (ok != 0) { return 1; }
    s = s + 1;
  }
  return 0;
}

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
  if (kind == 0) { return 0; }
  if (needle == 0) { return 0; }
  let i: i32 = 0;
  while (i < 4096) {
    let a: u8 = kind[i];
    let b: u8 = needle[i];
    if (a != b) { return 0; }
    if (a == 0) { return 1; }
    i = i + 1;
  }
  return 0;
}

// Case-insensitive code equality (ASCII a-z).
#[no_mangle]
function diag_code_eq(lhs: *u8, rhs: *u8): i32 {
  if (lhs == 0) { return 0; }
  if (rhs == 0) { return 0; }
  let i: i32 = 0;
  while (i < 4096) {
    let a: u8 = lhs[i];
    let b: u8 = rhs[i];
    if (a >= 97) {
      if (a <= 122) { a = a - 32; }
    }
    if (b >= 97) {
      if (b <= 122) { b = b - 32; }
    }
    if (a != b) { return 0; }
    if (a == 0) { return 1; }
    i = i + 1;
  }
  return 0;
}

// G-02f-124：diag_json_severity 真迁 .x

#[no_mangle]
function diag_json_severity(kind: *u8): *u8 {
  if (kind == 0) { return "error"; }
  if (kind[0] == 0) { return "error"; }
  // contains "warning"
  let i: i32 = 0;
  while (i < 256) {
    if (kind[i] == 0) { break; }
    if (kind[i]==119 && kind[i+1]==97 && kind[i+2]==114 && kind[i+3]==110 && kind[i+4]==105 && kind[i+5]==110 && kind[i+6]==103) {
      return "warning";
    }
    i = i + 1;
  }
  // exact info
  if (kind[0]==105 && kind[1]==110 && kind[2]==102 && kind[3]==111 && kind[4]==0) { return "info"; }
  if (kind[0]==110 && kind[1]==111 && kind[2]==116 && kind[3]==101 && kind[4]==0) { return "note"; }
  if (kind[0]==104 && kind[1]==101 && kind[2]==108 && kind[3]==112 && kind[4]==0) { return "help"; }
  if (kind[0]==104 && kind[1]==105 && kind[2]==110 && kind[3]==116 && kind[4]==0) { return "help"; }
  return "error";
}

