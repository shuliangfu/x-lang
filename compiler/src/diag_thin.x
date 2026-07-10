// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-335 / G-02f-336：diag L2 thin — pure helper + 门闩子集（无字符串字面量，-E 稳定）。
// 产品 PREFER_X_O：g05_try_x_to_o → thin.o + seeds/diag.from_x.c rest
//   （-DSHUX_L2_DIAG_THIN_FROM_X）ld -r → src/diag.o
// 完整逻辑源仍见 src/diag.x（整文件 -E 仍会截断/挂起）。
//
// f-335：line_digits / kind_is_exact / kind_contains / color_prefix
// f-336：+ get_file/source/len / code_is_known/kind/summary/details / set_file / report

extern "C" function diag_ctx_get_use_color(): i32;
extern "C" function diag_ctx_get_file(): *u8;
extern "C" function diag_ctx_get_source(): *u8;
extern "C" function diag_ctx_get_source_len(): i64;
extern "C" function diag_ctx_set_all(path: *u8, source: *u8, source_len: i64, use_color: i32): void;
extern "C" function diag_code_table_has(code: *u8): i32;
extern "C" function diag_entry_kind(code: *u8): *u8;
extern "C" function diag_entry_summary(code: *u8): *u8;
extern "C" function diag_entry_details(code: *u8): *u8;
extern "C" function diag_should_color(): i32;
extern "C" function diag_report_with_code(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;

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
    if (diag_ctx_get_use_color() != 0) {
      return color;
    }
    return plain;
  }
  return plain;
}

// ---- G-02f-336 context / code-table / report gates ----

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
    return diag_code_table_has(code);
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

#[no_mangle]
function diag_set_file(path: *u8, source: *u8, source_len: i64): void {
  unsafe {
    let c: i32 = diag_should_color();
    diag_ctx_set_all(path, source, source_len, c);
  }
}

// report 无 code：转发 with_code（null code 用 *u8 零指针，避免 as *u8 截断风险）
#[no_mangle]
function diag_report(file: *u8, line: i32, col: i32, kind: *u8, msg: *u8, detail: *u8): void {
  unsafe {
    let z: *u8 = 0;
    diag_report_with_code(file, line, col, kind, z, msg, detail);
  }
}
