// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-10：parse_expr_link 产品源迁 seeds/parser_asm_parse_expr_link.from_x.c。
// 产品：cc seed -DPARSER_ASM_LINK_ALIAS_SKIP_X_SYMBOLS → src/asm/parser_asm_parse_expr_link.o
// G-02f-102：+ parse_expr debug helpers 薄门闩。
// G-02f-333：debug_enabled 走 _impl（避免 -E 路径 getenv 字符串截断/坏类型）；
//           snippet 实现仍在 seed C（slice ABI）。

export extern "C" function parser_asm_parse_expr_debug_enabled_impl(): i32;

export function parser_asm_parse_expr_link_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-102 / G-02f-333：parse_expr debug 门闩 ---- */

#[no_mangle]
export function parser_asm_parse_expr_debug_enabled(): i32 {
  unsafe {
    return parser_asm_parse_expr_debug_enabled_impl();
  }
  return 0;
}
