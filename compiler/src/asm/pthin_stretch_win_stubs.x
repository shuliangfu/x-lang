// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Win tip_l4 DIG: xlang_bi CG002 on pthin_stretch.x (17-fn) and most one-fn
// TUs; G05_X_O_WEAK -E→host-cc XLANG_WEAK fails MinGW. P9 C twin is hollow
// (867B) without LITE_FROM_X. Stubs + any green one-fns ld -r past the
// stretch U hole PTHIN_FULL omit-rest surfaces after tramp was cleared.
// Safe defaults: skip/validate return identity/0; stores are no-ops.
// PLATFORM: WINDOWS. Not used on Darwin/Linux (real stretch.x stays).

export function parser_asm_stretch_token_run_len_c(kind: i32): i32 {
  return 0;
}

export function parser_asm_stretch_import_path_validate_c(path: *u8, path_len: i32): i32 {
  return 0;
}

export function parser_asm_stretch_struct_field_name_kind_c(kind: i32): i32 {
  return 0;
}

export function parser_asm_stretch_struct_field_continues_kind_c(kind: i32): i32 {
  return 0;
}

export function parser_asm_stretch_token_is_label_start_c(cur_kind: i32, next_kind: i32): i32 {
  return 0;
}

export function parser_asm_stretch_import_path_normalize_c(path_buf: *u8, path_len: i32): i32 {
  return path_len;
}

export function parser_asm_stretch_skip_ws_and_comments_c(data: *u8, len: usize, pos: usize): usize {
  return pos;
}

export function parser_asm_stretch_import_path_finalize_c(path_buf: *u8, path_len: i32, source: *u8, source_len: usize): i32 {
  return path_len;
}

export function parser_asm_stretch_is_type_start_kind_c(kind: i32): i32 {
  return 0;
}

export function parser_asm_stretch_skip_balanced_brackets_into_c(lex_inout: *u8, source: *u8): i32 {
  return 0;
}

export function parser_asm_stretch_skip_type_suffix_c(lex_inout: *u8, source: *u8): i32 {
  return 0;
}

export function parser_asm_stretch_skip_one_param_type_c(lex_inout: *u8, source: *u8): i32 {
  return 0;
}

export function lexer_src_data_store(out: *u8): void {
  return;
}

export function lexer_src_len_store(out: *u8): void {
  return;
}
