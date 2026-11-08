// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Win tip_l4 DIG: xlang_bi CG002/SEGV on these primary tramp faces even as
// one-fn TUs (empty_ident_braces, string_lit_append_byte, struct_lit
// append_field/shorthand/parse_field_value). Full tramp is 59-fn CG002.
// nowrap split + these stubs ld -r past the U hole that L4 ld hits from
// parser_asm_thin_glue.o. Stub returns match seed null/overflow guards
// (0 / -1); Win product degrades those paths until bi grows. PLATFORM:
// WINDOWS. Not used on Darwin/Linux (real faces stay in tramp.x).

export function parser_asm_empty_ident_braces_prefer_block_ptr_c(lex_inout: *u8, source: *u8): i32 {
  return 0;
}

export function parser_asm_string_lit_append_byte_ptr_c(arena: *u8, head_ref: i32, b: i32, line: i32, col: i32): i32 {
  return -1;
}

export function parser_asm_struct_lit_append_field_src_c(arena: *u8, lit_ref: i32, source: *u8, start: usize, nlen: i32, init_ref: i32): i32 {
  return -1;
}

export function parser_asm_struct_lit_append_shorthand_src_c(arena: *u8, lit_ref: i32, source: *u8, start: usize, nlen: i32): i32 {
  return -1;
}

export function parser_asm_struct_lit_parse_field_value_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  return 0;
}
