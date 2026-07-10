// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-30：真迁 .x — 固定措辞 typeck 诊断薄包装 + parse_strict 环境查询 + 空桩。
// 产品：./shux-c -E → seeds/runtime_driver_diagnostic.from_x.c（+ C 尾 + 字符串抛光）。
// C 尾：snprintf 诊断、va_list pipeline 码、scratch 缓冲、debug getenv 详细路径。
// 注意：字符串字面量经 -E 成 slice；seed 抛光为 C 字符串传 lsp_diag_report_typeck。

extern "C" function lsp_diag_report_typeck(line: i32, col: i32, msg: *u8): void;
extern "C" function getenv(name: *u8): *u8;

#[no_mangle]
function driver_diagnostic_typeck_if_condition_not_bool(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "if condition must be bool (no implicit int-to-bool)");
  }
}

#[no_mangle]
function driver_diagnostic_typeck_while_condition_not_bool(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "while condition must be bool (no implicit int-to-bool)");
  }
}

#[no_mangle]
function driver_diagnostic_typeck_for_condition_not_bool(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "for condition must be bool (no implicit int-to-bool)");
  }
}

#[no_mangle]
function driver_diagnostic_typeck_deref_outside_unsafe(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "pointer dereference requires unsafe block");
  }
}

#[no_mangle]
function driver_diagnostic_typeck_extern_call_outside_unsafe(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "extern call requires unsafe block");
  }
}

#[no_mangle]
function driver_diagnostic_typeck_linear_addr_of(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "cannot take address of linear value");
  }
}

#[no_mangle]
function driver_diagnostic_entry_already(v: i32): void {
}

#[no_mangle]
function driver_diagnostic_after_dep_codegen(j: i32, out_len: i32): void {
}

#[no_mangle]
function driver_parse_strict_enabled(): i32 {
  unsafe {
    let e: *u8 = getenv("SHUX_PARSE_STRICT");
    if (e == 0 as *u8) {
      return 0;
    }
    if (e[0] == 0) {
      return 0;
    }
    if (e[0] == 48) {
      return 0;
    }
    return 1;
  }
  return 0;
}
