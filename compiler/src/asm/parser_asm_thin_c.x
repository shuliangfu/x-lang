// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function parser_asm_copy_token_bytes_to_buf64_impl(src: *u8, n: i32, dst: *u8): void;
export extern "C" function parser_asm_extern_parse_set_fail_c_impl(of: *u8, code: i32): void;

/** Exported function `parser_asm_thin_c_x_doc_anchor`.
 * Implements `parser_asm_thin_c_x_doc_anchor`.
 * @return i32
 */
export function parser_asm_thin_c_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */



#[no_mangle]
export function parser_asm_copy_token_bytes_to_buf64(src: *u8, n: i32, dst: *u8): void {
  unsafe { parser_asm_copy_token_bytes_to_buf64_impl(src, n, dst); }
}

/** Exported function `parser_asm_extern_parse_set_fail_c`.
 * Implements `parser_asm_extern_parse_set_fail_c`.
 * @param of *u8
 * @param code i32
 * @return void
 */
#[no_mangle]
export function parser_asm_extern_parse_set_fail_c(of: *u8, code: i32): void {
  unsafe { parser_asm_extern_parse_set_fail_c_impl(of, code); }
}

// See implementation.

export extern "C" function parser_asm_skip_trait_impl_block_raw_c_impl(out: *u8, start: *u8, a: i32, b: i32): void;
export extern "C" function parser_asm_skip_one_top_level_let_into_slice_c_impl(out: *u8, src: *u8, lex: *u8): void;
export extern "C" function parser_asm_skip_one_top_level_const_into_slice_c_impl(out: *u8, src: *u8, lex: *u8): void;
export extern "C" function parser_asm_cfg_skip_pending_top_level_into_slice_c_impl(lex: *u8, src: *u8, a: i32): void;

/* See implementation. */

#[no_mangle]
export function parser_asm_skip_trait_impl_block_raw_c(out: *u8, start: *u8, a: i32, b: i32): void { unsafe { parser_asm_skip_trait_impl_block_raw_c_impl(out, start, a, b); } }
/** Exported function `parser_asm_skip_one_top_level_let_into_slice_c`.
 * Implements `parser_asm_skip_one_top_level_let_into_slice_c`.
 * @param out *u8
 * @param src *u8
 * @param lex *u8): void { unsafe { parser_asm_skip_one_top_level_let_into_slice_c_impl(out
 * @param src
 * @param lex
 * @return void
 */
#[no_mangle]
export function parser_asm_skip_one_top_level_let_into_slice_c(out: *u8, src: *u8, lex: *u8): void { unsafe { parser_asm_skip_one_top_level_let_into_slice_c_impl(out, src, lex); } }
/** Exported function `parser_asm_skip_one_top_level_const_into_slice_c`.
 * Implements `parser_asm_skip_one_top_level_const_into_slice_c`.
 * @param out *u8
 * @param src *u8
 * @param lex *u8): void { unsafe { parser_asm_skip_one_top_level_const_into_slice_c_impl(out
 * @param src
 * @param lex
 * @return void
 */
#[no_mangle]
export function parser_asm_skip_one_top_level_const_into_slice_c(out: *u8, src: *u8, lex: *u8): void { unsafe { parser_asm_skip_one_top_level_const_into_slice_c_impl(out, src, lex); } }
/** Exported function `parser_asm_cfg_skip_pending_top_level_into_slice_c`.
 * Implements `parser_asm_cfg_skip_pending_top_level_into_slice_c`.
 * @param lex *u8
 * @param src *u8
 * @param a i32): void { unsafe { parser_asm_cfg_skip_pending_top_level_into_slice_c_impl(lex
 * @param src
 * @param a
 * @return void
 */
#[no_mangle]
export function parser_asm_cfg_skip_pending_top_level_into_slice_c(lex: *u8, src: *u8, a: i32): void { unsafe { parser_asm_cfg_skip_pending_top_level_into_slice_c_impl(lex, src, a); } }

// See implementation.

export extern "C" function parser_asm_try_skip_const_import_stmt_impl(lex: *u8, src: *u8): i32;
export extern "C" function parser_asm_collect_imports_consume_path_impl(out: *u8, src: *u8, a: i32): i32;
export extern "C" function parser_asm_write_try_skip_allow_result_impl(out: *u8, a: i32, b: i32): void;
export extern "C" function parser_asm_lex_from_lr_next_c_impl(lex: *u8, r: *u8): void;

/* See implementation. */

#[no_mangle]
export function parser_asm_try_skip_const_import_stmt(lex: *u8, src: *u8): i32 {
  unsafe { return parser_asm_try_skip_const_import_stmt_impl(lex, src); }
  return 0;
}
/** Exported function `parser_asm_collect_imports_consume_path`.
 * Implements `parser_asm_collect_imports_consume_path`.
 * @param out *u8
 * @param src *u8
 * @param a i32
 * @return i32
 */
#[no_mangle]
export function parser_asm_collect_imports_consume_path(out: *u8, src: *u8, a: i32): i32 {
  unsafe { return parser_asm_collect_imports_consume_path_impl(out, src, a); }
  return 0;
}
/** Exported function `parser_asm_write_try_skip_allow_result`.
 * Write path helper `parser_asm_write_try_skip_allow_result`.
 * @param out *u8
 * @param a i32
 * @param b i32
 * @return void
 */
#[no_mangle]
export function parser_asm_write_try_skip_allow_result(out: *u8, a: i32, b: i32): void {
  unsafe { parser_asm_write_try_skip_allow_result_impl(out, a, b); }
}
/** Exported function `parser_asm_lex_from_lr_next_c`.
 * Implements `parser_asm_lex_from_lr_next_c`.
 * @param lex *u8
 * @param r *u8
 * @return void
 */
#[no_mangle]
export function parser_asm_lex_from_lr_next_c(lex: *u8, r: *u8): void {
  unsafe { parser_asm_lex_from_lr_next_c_impl(lex, r); }
}

// See implementation.
// TokenKind from token.h (cc-verified): IDENT=59 I32=60 BOOL=61 U8=62 U32=63 U64=64 I64=65 USIZE=66 VOID=79

/** Exported function `parser_asm_is_fn_sig_scalar_type_token_c`.
 * Implements `parser_asm_is_fn_sig_scalar_type_token_c`.
 * @param tok i32
 * @return i32
 */
#[no_mangle]
export function parser_asm_is_fn_sig_scalar_type_token_c(tok: i32): i32 {
  if (tok == 60) { return 1; } // I32
  if (tok == 65) { return 1; } // I64
  if (tok == 61) { return 1; } // BOOL
  if (tok == 62) { return 1; } // U8
  if (tok == 63) { return 1; } // U32
  if (tok == 64) { return 1; } // U64
  if (tok == 66) { return 1; } // USIZE
  if (tok == 79) { return 1; } // VOID
  if (tok == 59) { return 1; } // IDENT
  return 0;
}
