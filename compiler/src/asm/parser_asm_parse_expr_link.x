// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-10：parse_expr_link 产品源迁 seeds/parser_asm_parse_expr_link.from_x.c。
// 产品：cc seed -DPARSER_ASM_LINK_ALIAS_SKIP_X_SYMBOLS → src/asm/parser_asm_parse_expr_link.o
// G-02f-102：+ parse_expr debug helpers 薄门闩。

extern "C" function parser_asm_parse_expr_debug_enabled_impl(): i32;
extern "C" function parser_asm_parse_expr_debug_snippet_c_impl(source: *u8, pos: usize): void;

function parser_asm_parse_expr_link_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-102：parse_expr debug 门闩 ---- */


#[no_mangle]
function parser_asm_parse_expr_debug_snippet_c(source: *u8, pos: usize): void {
  unsafe {
    parser_asm_parse_expr_debug_snippet_c_impl(source, pos);
  }
}

// G-02f-116：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

extern "C" function getenv(name: *u8): *u8;

#[no_mangle]
function parser_asm_parse_expr_debug_enabled(): i32 {
  unsafe {
    let e: *u8 = getenv("SHUX_PARSER_ASM_DEBUG");
    if (e == 0) { return 0; }
    if (e[0] == 0) { return 0; }
    if (e[0] == 48) { return 0; }
    return 1;
  }
  return 0;
}
