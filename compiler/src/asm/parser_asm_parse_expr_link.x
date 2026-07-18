// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function parser_asm_parse_expr_debug_enabled_impl(): i32;

/** Exported function `parser_asm_parse_expr_link_x_doc_anchor`.
 * Implements `parser_asm_parse_expr_link_x_doc_anchor`.
 * @return i32
 */
export function parser_asm_parse_expr_link_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */

#[no_mangle]
export function parser_asm_parse_expr_debug_enabled(): i32 {
  unsafe {
    return parser_asm_parse_expr_debug_enabled_impl();
  }
  return 0;
}
