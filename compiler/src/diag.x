// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-30：真迁 .x — diag_report 无 code 入口薄转发到 with_code。
// 产品：./shux-c -E → seeds/diag.from_x.c（+ C 尾段）。
// C 尾：上下文静态、code 表、JSON/颜色、va_list reportf/vreportf、lookup。
// 注意：va_list 入口仍留 C（语言/ABI 限制）。

extern "C" function diag_report_with_code(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8,
                                          detail: *u8): void;

#[no_mangle]
function diag_report(file: *u8, line: i32, col: i32, kind: *u8, msg: *u8, detail: *u8): void {
  unsafe {
    diag_report_with_code(file, line, col, kind, 0 as *u8, msg, detail);
  }
}
