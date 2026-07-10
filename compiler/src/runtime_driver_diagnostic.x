// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-30/31：真迁 .x — 固定措辞 typeck 诊断薄包装 + parse_strict + 空桩。
// 产品：./shux-c -E → seeds/runtime_driver_diagnostic.from_x.c（+ C 尾 + 字符串抛光）。
// C 尾：snprintf 诊断、va_list pipeline 码、scratch 缓冲、debug getenv 详细路径。
// 注意：字符串字面量经 -E 成 slice；seed 抛光为 C 字符串传 lsp_diag_report_typeck。
// G-02f-31：+ fail/break-continue/enum/subscript/try 固定消息。

extern "C" function lsp_diag_report_typeck(line: i32, col: i32, msg: *u8): void;
extern "C" function getenv(name: *u8): *u8;
extern "C" function driver_check_only_get(): i32;
extern "C" function driver_check_diag_emitted_get(): i32;

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
function driver_diagnostic_typeck_break_continue_outside(line: i32, col: i32, is_break: i32): void {
  unsafe {
    if (is_break != 0) {
      lsp_diag_report_typeck(line, col, "break only allowed inside a loop");
    } else {
      lsp_diag_report_typeck(line, col, "continue only allowed inside a loop");
    }
  }
}

#[no_mangle]
function driver_diagnostic_typeck_enum_no_variant(line: i32, col: i32): void {
  unsafe {
    // 经 lsp_diag_report_typeck：LSP 模式带 T001，与产品 typeck 码口径一致。
    lsp_diag_report_typeck(line, col, "enum has no variant");
  }
}

#[no_mangle]
function driver_diagnostic_typeck_subscript_base(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col, "subscript base must be array, slice or pointer");
  }
}

#[no_mangle]
function driver_diagnostic_typeck_try_propagate_bad_enclosing(line: i32, col: i32): void {
  unsafe {
    lsp_diag_report_typeck(line, col,
                           "`?` requires the enclosing function to return the same Result type");
  }
}

#[no_mangle]
function driver_diagnostic_typeck_fail(): void {
  // 具体 XT001 已由其它路径发出；保留对 check-only 标志的副作用读取（与历史 C 一致）。
  unsafe {
    let _a: i32 = driver_check_only_get();
    let _b: i32 = driver_check_diag_emitted_get();
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
