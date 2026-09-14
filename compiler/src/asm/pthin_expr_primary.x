// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

/* Primary literal wave: token ordinals (token.h enum, validated
 * ELSE=5/IF=4) and bridges. */
const TOKEN_TRUE: i32 = 75;
const TOKEN_FALSE: i32 = 76;
const TOKEN_NULL: i32 = 132;
const TOKEN_FLOAT: i32 = 134;
const TOKEN_INT: i32 = 133;
const TOKEN_SELF: i32 = 51;
const TOKEN_IDENT: i32 = 59;
const TOKEN_LBRACE: i32 = 84;
const TOKEN_LPAREN: i32 = 82;
const TOKEN_RPAREN: i32 = 83;
const TOKEN_TYPE: i32 = 20;
const EXPR_VAR_LIT: i32 = 3;
export extern "C" function parser_asm_ident_pre_dispatch_ptr_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32;
const EXPR_LIT: i32 = 0;
const EXPR_FLOAT_LIT: i32 = 1;
const EXPR_BOOL_LIT: i32 = 2;

export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_tok_line_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_line_c(lex: *u8): i32;
export extern "C" function parser_asm_lex_col_c(lex: *u8): i32;
export extern "C" function pipeline_expr_set_var_name(a: *u8, er: i32, nm: *u8, nlen: i32): void;
export extern "C" function pipeline_expr_set_field_access_c(a: *u8, er: i32, base_ref: i32, nm: *u8, nlen: i32): void;
export extern "C" function pipeline_expr_set_method_call_c(a: *u8, er: i32, base_ref: i32, nm: *u8, nlen: i32): void;
export extern "C" function pipeline_expr_field_name_len_at(a: *u8, er: i32): i32;
export extern "C" function pipeline_expr_field_name_into(a: *u8, er: i32, dst: *u8): void;
export extern "C" function pipeline_expr_set_struct_lit_finish_c(a: *u8, er: i32, nm: *u8, nlen: i32): void;
export extern "C" function parser_asm_parse_struct_lit_fields_ptr_c(arena: *u8, lit_ref: i32, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): void;
export extern "C" function parser_asm_lex_peek_tok_col_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_float_val_into_c(lex_inout: *u8, source: *u8, out: *f64): void;
export extern "C" function parser_asm_lex_peek_int64_val_into_c(lex_inout: *u8, source: *u8, out: *i64): void;
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function ast_ast_arena_expr_alloc(arena: *u8): i32;
export extern "C" function pipeline_expr_set_kind(a: *u8, er: i32, kind: i32): void;
export extern "C" function pipeline_expr_set_line_col(a: *u8, er: i32, line: i32, col: i32): void;
export extern "C" function pipeline_expr_set_int_val(a: *u8, er: i32, v: i64): void;
export extern "C" function pipeline_expr_set_float_val(a: *u8, er: i32, v: f64): void;
export extern "C" function pipeline_expr_set_common_zeros_c(a: *u8, er: i32): void;
export extern "C" function pipeline_expr_tag_null_keyword_c(arena: *u8, er: i32): void;
export extern "C" function parser_parse_expr_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32;
export extern "C" function parser_finish_struct_lit_ptr_into_c(arena: *u8, lit_ref: i32, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): void;
export extern "C" function pipeline_expr_kind_ord_at(a: *u8, er: i32): i32;
export extern "C" function pipeline_expr_var_name_len(a: *u8, er: i32): i32;
export extern "C" function pipeline_expr_var_name_into(a: *u8, er: i32, dst: *u8): void;
export extern "C" function pipeline_expr_set_index_c(a: *u8, er: i32, base_ref: i32, index_ref: i32, is_slice: i32): void;
export extern "C" function pipeline_expr_set_call_c(a: *u8, er: i32, callee_ref: i32, num_type_args: i32): void;
export extern "C" function pipeline_expr_set_struct_lit_finish_c(a: *u8, er: i32, nm: *u8, nlen: i32): void;
export extern "C" function parser_asm_lbrace_looks_like_block_ptr_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_empty_ident_braces_prefer_block_ptr_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_parse_struct_lit_fields_ptr_c(arena: *u8, lit_ref: i32, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): void;
const EXPR_FIELD_ACCESS: i32 = 44;
export extern "C" function parser_asm_parse_type_ref_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_skip_angle_count_ptr_into_c(lex_inout: *u8, source: *u8, out_count: *i32): void;
export extern "C" function parser_asm_lex_peek_token_start_c(lex_inout: *u8, source: *u8): usize;
export extern "C" function parser_asm_lex_peek_ident_len_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_next_pos_c(lex_inout: *u8, source: *u8): usize;
export extern "C" function parser_asm_lex_pos_c(lex: *u8): usize;
export extern "C" function parser_asm_lex_set_pos_c(lex: *u8, pos: usize): void;
export extern "C" function parser_asm_lex_set_line_c(lex: *u8, line: i32): void;
export extern "C" function parser_asm_lex_set_col_c(lex: *u8, col: i32): void;
export extern "C" function parser_asm_lex_at_token_pos_c(kind: i32, token_start: usize, ident_len: i32, next_pos: usize): usize;
export extern "C" function parser_asm_lex_source_data_c(source: *u8): *u8;
export extern "C" function parser_asm_lex_source_length_c(source: *u8): usize;
export extern "C" function pipeline_expr_append_method_call_arg(a: *u8, er: i32, arg: i32): i32;
export extern "C" function pipeline_expr_append_call_arg(a: *u8, er: i32, arg: i32): i32;
export extern "C" function pipeline_expr_append_call_type_arg(a: *u8, er: i32, tr: i32): i32;
export extern "C" function parser_asm_append_type_inst_mangle_c(arena: *u8, nm: *u8, nlen: i32, refs: *i32, n: i32, out: *u8, cap: i32): i32;
const TOKEN_DOT: i32 = 92;
const TOKEN_LBRACKET: i32 = 86;
const TOKEN_RBRACKET: i32 = 87;
const TOKEN_COMMA: i32 = 90;
const TOKEN_LT: i32 = 120;
const TOKEN_GT: i32 = 121;
const TOKEN_RSHIFT: i32 = 105;
const TOKEN_SOA: i32 = 22;
const TOKEN_PACKED: i32 = 21;
const EXPR_VAR: i32 = 3;
const EXPR_INDEX: i32 = 47;
const EXPR_CALL: i32 = 48;
const EXPR_METHOD_CALL: i32 = 49;
const EXPR_FINISH_STRUCT_LIT: i32 = 45;

// pthin_expr_primary.x — G-02f-282 P4 parser thin primary product bodies.
//
// 7.2.1 P4b Route C productize (2026-09-13): after P19b helpers, primary.inc
// is the next still-host-cc product slice with a portable buf-path region.
// IDENT spelling probes (unsafe/asm/in/out/lateout/options) and the asm!
// options bit table are Route C (*u8 + length + start + ident_len). Arena
// expr alloc, lexer by-value, and parse_primary_into stay C. parse_primary
// already-T AUDIT_CALL padding is gated in the .inc under
// XLANG_PARSER_STRETCH_AUDIT (product AUDIT_CALL is already ((void)0);
// compiling ~770 lexer-init nops is dead preprocess, not combinator logic).
//
// Hybrid P4b: g05_try_x_to_o this file; XLANG_PTHIN_EXPR_PRIMARY_BODIES_FROM_X
// skips the portable .inc region. Cold: no define, full .inc stays.
// Helpers ident_is_unsafe_stmt (by-value lexer_result) stays C this wave
// (different ABI: kind==IDENT plus token_start fallback); do not merge
// into these buf probes as a side effect.
// PLATFORM: SHARED freestanding.

/**
 * Bounds check shared by every IDENT spelling probe.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @param want_len i32 — required spelling length
 * @return i32 — 1 if data is live, ident_len==want_len, and the span fits
 */
function parser_asm_primary_ident_span_ok(data: *u8, length: usize, token_start: usize, ident_len: i32, want_len: i32): i32 {
  if (data == 0 as *u8 || ident_len != want_len || ident_len <= 0) {
    return 0;
  }
  if (token_start + ident_len as usize > length) {
    return 0;
  }
  return 1;
}

/**
 * Read one already-in-span source byte.
 * @param data *u8 — source bytes (non-null; caller checked)
 * @param token_start usize — IDENT start
 * @param i i32 — byte offset within the IDENT
 * @return u8 — data[token_start + i]
 */
function parser_asm_primary_ident_byte(data: *u8, token_start: usize, i: i32): u8 {
  let c: u8 = 0;
  unsafe {
    c = data[token_start + i as usize];
  }
  return c;
}

/**
 * True when IDENT spelling is exactly `unsafe`.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — 1 if the six bytes are `unsafe`; 0 otherwise
 * PLATFORM: SHARED — buf-path authority; slice wrapper stays a C trampoline.
 */
#[no_mangle]
export function parser_asm_primary_ident_is_unsafe_buf_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (parser_asm_primary_ident_span_ok(data, length, token_start, ident_len, 6) == 0) {
    return 0;
  }
  if (parser_asm_primary_ident_byte(data, token_start, 0) == 117 && parser_asm_primary_ident_byte(data, token_start, 1) == 110
      && parser_asm_primary_ident_byte(data, token_start, 2) == 115 && parser_asm_primary_ident_byte(data, token_start, 3) == 97
      && parser_asm_primary_ident_byte(data, token_start, 4) == 102 && parser_asm_primary_ident_byte(data, token_start, 5) == 101) {
    return 1;
  }
  return 0;
}

/**
 * True when IDENT spelling is exactly `asm` (stage10 `asm!(...)`).
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — 1 if the three bytes are `asm`; 0 otherwise
 * PLATFORM: SHARED — G.7 primary authority.
 */
#[no_mangle]
export function parser_asm_primary_ident_is_asm_buf_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (parser_asm_primary_ident_span_ok(data, length, token_start, ident_len, 3) == 0) {
    return 0;
  }
  if (parser_asm_primary_ident_byte(data, token_start, 0) == 97 && parser_asm_primary_ident_byte(data, token_start, 1) == 115
      && parser_asm_primary_ident_byte(data, token_start, 2) == 109) {
    return 1;
  }
  return 0;
}

/**
 * True when IDENT spelling is exactly `in` (asm operand dir).
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — 1 if the two bytes are `in`; 0 otherwise
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_primary_ident_is_in_buf_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (parser_asm_primary_ident_span_ok(data, length, token_start, ident_len, 2) == 0) {
    return 0;
  }
  if (parser_asm_primary_ident_byte(data, token_start, 0) == 105 && parser_asm_primary_ident_byte(data, token_start, 1) == 110) {
    return 1;
  }
  return 0;
}

/**
 * True when IDENT spelling is exactly `out`.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — 1 if the three bytes are `out`; 0 otherwise
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_primary_ident_is_out_buf_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (parser_asm_primary_ident_span_ok(data, length, token_start, ident_len, 3) == 0) {
    return 0;
  }
  if (parser_asm_primary_ident_byte(data, token_start, 0) == 111 && parser_asm_primary_ident_byte(data, token_start, 1) == 117
      && parser_asm_primary_ident_byte(data, token_start, 2) == 116) {
    return 1;
  }
  return 0;
}

/**
 * True when IDENT spelling is exactly `lateout`.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — 1 if the seven bytes are `lateout`; 0 otherwise
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_primary_ident_is_lateout_buf_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (parser_asm_primary_ident_span_ok(data, length, token_start, ident_len, 7) == 0) {
    return 0;
  }
  if (parser_asm_primary_ident_byte(data, token_start, 0) == 108 && parser_asm_primary_ident_byte(data, token_start, 1) == 97
      && parser_asm_primary_ident_byte(data, token_start, 2) == 116 && parser_asm_primary_ident_byte(data, token_start, 3) == 101
      && parser_asm_primary_ident_byte(data, token_start, 4) == 111 && parser_asm_primary_ident_byte(data, token_start, 5) == 117
      && parser_asm_primary_ident_byte(data, token_start, 6) == 116) {
    return 1;
  }
  return 0;
}

/**
 * True when IDENT spelling is exactly `options`.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — 1 if the seven bytes are `options`; 0 otherwise
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_primary_ident_is_options_buf_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (parser_asm_primary_ident_span_ok(data, length, token_start, ident_len, 7) == 0) {
    return 0;
  }
  if (parser_asm_primary_ident_byte(data, token_start, 0) == 111 && parser_asm_primary_ident_byte(data, token_start, 1) == 112
      && parser_asm_primary_ident_byte(data, token_start, 2) == 116 && parser_asm_primary_ident_byte(data, token_start, 3) == 105
      && parser_asm_primary_ident_byte(data, token_start, 4) == 111 && parser_asm_primary_ident_byte(data, token_start, 5) == 110
      && parser_asm_primary_ident_byte(data, token_start, 6) == 115) {
    return 1;
  }
  return 0;
}

/**
 * Map IDENT to an asm! options bit, or 0 if unknown.
 * Bits: nostack=1, preserves_flags=2, nomem=4, readonly=8, pure=16, noreturn=32.
 * Stored on EXPR_ASM.call_num_type_args (ASM has no type-args).
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — option bit, or 0
 * PLATFORM: SHARED — G.7 single bit table for parse+emit.
 */
#[no_mangle]
export function parser_asm_primary_asm_option_bit_buf_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (data == 0 as *u8 || ident_len <= 0) {
    return 0;
  }
  if (token_start + ident_len as usize > length) {
    return 0;
  }
  // nostack = 1
  if (ident_len == 7 && parser_asm_primary_ident_byte(data, token_start, 0) == 110
      && parser_asm_primary_ident_byte(data, token_start, 1) == 111 && parser_asm_primary_ident_byte(data, token_start, 2) == 115
      && parser_asm_primary_ident_byte(data, token_start, 3) == 116 && parser_asm_primary_ident_byte(data, token_start, 4) == 97
      && parser_asm_primary_ident_byte(data, token_start, 5) == 99 && parser_asm_primary_ident_byte(data, token_start, 6) == 107) {
    return 1;
  }
  // preserves_flags = 2
  if (ident_len == 15 && parser_asm_primary_ident_byte(data, token_start, 0) == 112
      && parser_asm_primary_ident_byte(data, token_start, 1) == 114 && parser_asm_primary_ident_byte(data, token_start, 2) == 101
      && parser_asm_primary_ident_byte(data, token_start, 3) == 115 && parser_asm_primary_ident_byte(data, token_start, 4) == 101
      && parser_asm_primary_ident_byte(data, token_start, 5) == 114 && parser_asm_primary_ident_byte(data, token_start, 6) == 118
      && parser_asm_primary_ident_byte(data, token_start, 7) == 101 && parser_asm_primary_ident_byte(data, token_start, 8) == 115
      && parser_asm_primary_ident_byte(data, token_start, 9) == 95 && parser_asm_primary_ident_byte(data, token_start, 10) == 102
      && parser_asm_primary_ident_byte(data, token_start, 11) == 108 && parser_asm_primary_ident_byte(data, token_start, 12) == 97
      && parser_asm_primary_ident_byte(data, token_start, 13) == 103 && parser_asm_primary_ident_byte(data, token_start, 14) == 115) {
    return 2;
  }
  // nomem = 4
  if (ident_len == 5 && parser_asm_primary_ident_byte(data, token_start, 0) == 110
      && parser_asm_primary_ident_byte(data, token_start, 1) == 111 && parser_asm_primary_ident_byte(data, token_start, 2) == 109
      && parser_asm_primary_ident_byte(data, token_start, 3) == 101 && parser_asm_primary_ident_byte(data, token_start, 4) == 109) {
    return 4;
  }
  // readonly = 8
  if (ident_len == 8 && parser_asm_primary_ident_byte(data, token_start, 0) == 114
      && parser_asm_primary_ident_byte(data, token_start, 1) == 101 && parser_asm_primary_ident_byte(data, token_start, 2) == 97
      && parser_asm_primary_ident_byte(data, token_start, 3) == 100 && parser_asm_primary_ident_byte(data, token_start, 4) == 111
      && parser_asm_primary_ident_byte(data, token_start, 5) == 110 && parser_asm_primary_ident_byte(data, token_start, 6) == 108
      && parser_asm_primary_ident_byte(data, token_start, 7) == 121) {
    return 8;
  }
  // pure = 16
  if (ident_len == 4 && parser_asm_primary_ident_byte(data, token_start, 0) == 112
      && parser_asm_primary_ident_byte(data, token_start, 1) == 117 && parser_asm_primary_ident_byte(data, token_start, 2) == 114
      && parser_asm_primary_ident_byte(data, token_start, 3) == 101) {
    return 16;
  }
  // noreturn = 32
  if (ident_len == 8 && parser_asm_primary_ident_byte(data, token_start, 0) == 110
      && parser_asm_primary_ident_byte(data, token_start, 1) == 111 && parser_asm_primary_ident_byte(data, token_start, 2) == 114
      && parser_asm_primary_ident_byte(data, token_start, 3) == 101 && parser_asm_primary_ident_byte(data, token_start, 4) == 116
      && parser_asm_primary_ident_byte(data, token_start, 5) == 117 && parser_asm_primary_ident_byte(data, token_start, 6) == 114
      && parser_asm_primary_ident_byte(data, token_start, 7) == 110) {
    return 32;
  }
  return 0;
}

/**
 * True when IDENT is a known Rust-style asm! option name.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — 1 if option_bit != 0; 0 otherwise
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_primary_ident_is_asm_option_name_buf_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (parser_asm_primary_asm_option_bit_buf_c(data, length, token_start, ident_len) != 0) {
    return 1;
  }
  return 0;
}

/**
 * Literal-arm handler (primary literal wave): FLOAT / TRUE / FALSE / NULL
 * tokens fill a fresh arena Expr through the wave-0 writer family (no Expr
 * by-value). Peeks the next token; when it is one of the four literal kinds
 * the payload is read FIRST, the cursor is then advanced in place (step
 * keeps pos+line+col exact), and the Expr is filled + common-zeroed.
 * The INT arm is NOT handled here (it shares the ident suffix chain and
 * migrates with that wave).
 * @param arena *u8 — opaque ASTArena
 * @param lex_inout *u8 — cursor; advanced only when the token is handled
 * @param source *u8 — opaque slice
 * @param out_ok *i32 — 1 when handled (expr written), 0 otherwise
 * @param out_expr_ref *i32 — fresh Expr ref on success
 * @return i32 — 1 handled (check out_ok for alloc failure); 0 not a
 *   literal token (caller falls through to the C arms)
 * PLATFORM: SHARED — product primary literal wave; dispatched from
 * parser_asm_parse_primary_into_slice_c under
 * XLANG_PTHIN_EXPR_PRIMARY_BODIES_FROM_X. NULL keeps the keyword tag via
 * pipeline_expr_tag_null_keyword_c (G.7 single primary path).
 */
#[no_mangle]
export function parser_asm_primary_literal_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32, out_wants_suffix: *i32): i32 {
  let kind: i32 = 0;
  let ref: i32 = 0;
  let fval: f64 = 0 as f64;
  let tl: i32 = 0;
  let tc: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    out_ok[0] = 0;
    out_expr_ref[0] = 0;
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_FLOAT && kind != TOKEN_TRUE && kind != TOKEN_FALSE && kind != TOKEN_NULL && kind != TOKEN_INT) {
      return 0;
    }
    let iv: i64 = 0;
    if (kind == TOKEN_INT) {
      parser_asm_lex_peek_int64_val_into_c(lex_inout, source, &iv);
    } else if (kind == TOKEN_FLOAT) {
      parser_asm_lex_peek_float_val_into_c(lex_inout, source, &fval);
    }
    tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    ref = ast_ast_arena_expr_alloc(arena);
    if (ref == 0) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    if (kind == TOKEN_INT) {
      /* INT head + suffix chain (`.method()`/`[i]`/`<T>()`) — the C arm
       * steps past the literal then enters the suffix loop; the .x loop
       * re-peeks purely, so just step and call it. */
      parser_asm_lex_step_kind_c(lex_inout, source);
      pipeline_expr_set_kind(arena, ref, EXPR_LIT);
      pipeline_expr_set_line_col(arena, ref, tl, tc);
      pipeline_expr_set_int_val(arena, ref, iv);
      pipeline_expr_set_common_zeros_c(arena, ref);
      out_ok[0] = 1;
      out_expr_ref[0] = ref;
      out_wants_suffix[0] = 1;
      return 1;
    }
    if (kind == TOKEN_FLOAT) {
      pipeline_expr_set_kind(arena, ref, EXPR_FLOAT_LIT);
      pipeline_expr_set_float_val(arena, ref, fval);
      pipeline_expr_set_line_col(arena, ref, 0, 0);
      pipeline_expr_set_common_zeros_c(arena, ref);
    } else if (kind == TOKEN_TRUE || kind == TOKEN_FALSE) {
      pipeline_expr_set_kind(arena, ref, EXPR_BOOL_LIT);
      if (kind == TOKEN_TRUE) {
        pipeline_expr_set_int_val(arena, ref, 1);
      } else {
        pipeline_expr_set_int_val(arena, ref, 0);
      }
      pipeline_expr_set_line_col(arena, ref, 0, 0);
      pipeline_expr_set_common_zeros_c(arena, ref);
    } else {
      pipeline_expr_set_kind(arena, ref, EXPR_LIT);
      pipeline_expr_set_line_col(arena, ref, tl, tc);
      pipeline_expr_set_int_val(arena, ref, 0);
      pipeline_expr_set_common_zeros_c(arena, ref);
      pipeline_expr_tag_null_keyword_c(arena, ref);
    }
    out_ok[0] = 1;
    out_expr_ref[0] = ref;
    return 1;
  }
  return 0;
}

/**
 * Suffix branch: DOT (field access / method call). Split from the
 * monolithic loop — the pure-asm emitter silently drops oversized
 * functions; each branch stays small. Returns 1 continue / 0 stop /
 * -1 hard fail. PLATFORM: SHARED — product primary suffix split.
 */
export function parser_asm_suffix_b_dot(arena: *u8, source: *u8, lex_inout: *u8, out_ok: *i32, out_expr_ref: *i32, mc_arg_buf: *i32, arg_buf: *i32, parsed_refs: *i32, pending_refs: *i32, mangled: *u8, name_buf: *u8, pending_cnt: *i32): i32 {
  let k2: i32 = 0;
  let k3: i32 = 0;
  let mname_len: i32 = 0;
  let mname_start: usize = 0;
  let mc_ref: i32 = 0;
  let fa_ref: i32 = 0;
  let n: i32 = 0;
  let ai: i32 = 0;
  let ok2: i32 = 0;
  let eref2: i32 = 0;
  let data: *u8 = 0 as *u8;
  let ts: usize = 0;
  let il: i32 = 0;
  let np: usize = 0;
  let tl: i32 = 0;
  let tc: i32 = 0;
  unsafe {
    data = parser_asm_lex_source_data_c(source);
    parser_asm_lex_step_kind_c(lex_inout, source);
    k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
    mname_len = -1;
    if (k2 == TOKEN_IDENT) {
      mname_len = parser_asm_lex_peek_ident_len_c(lex_inout, source);
      if (mname_len <= 0) {
        mname_len = -1;
      }
    } else if (k2 == TOKEN_TYPE) {
      mname_len = 4;
    } else if (k2 == TOKEN_SOA) {
      mname_len = 3;
    } else if (k2 == TOKEN_PACKED) {
      mname_len = 6;
    }
    if (mname_len < 0) {
      return 0;
    }
    if (mname_len > 255) {
      mname_len = 127;
    }
    mname_start = parser_asm_lex_peek_token_start_c(lex_inout, source);
    parser_asm_lex_step_kind_c(lex_inout, source);
    k3 = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (k3 == TOKEN_LPAREN) {
      mc_ref = ast_ast_arena_expr_alloc(arena);
      if (mc_ref == 0) {
        out_ok[0] = 0;
        return -1;
      }
      pipeline_expr_set_common_zeros_c(arena, mc_ref);
      pipeline_expr_set_kind(arena, mc_ref, EXPR_METHOD_CALL);
      pipeline_expr_set_method_call_c(arena, mc_ref, out_expr_ref[0], data + mname_start, mname_len);
      pipeline_expr_set_line_col(arena, mc_ref, 0, 0);
      out_expr_ref[0] = mc_ref;
      parser_asm_lex_step_kind_c(lex_inout, source);
      k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (k2 != TOKEN_RPAREN) {
        n = 0;
        while (true) {
          if (n >= 256) {
            out_ok[0] = 0;
            return -1;
          }
          ok2 = 0;
          eref2 = 0;
          if (parser_parse_expr_ptr_into_c(arena, lex_inout, source, &ok2, &eref2) == 0) {
            out_ok[0] = 0;
            return -1;
          }
          if (ok2 == 0) {
            out_ok[0] = 0;
            return -1;
          }
          mc_arg_buf[n] = eref2;
          n = n + 1;
          k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
          if (k2 == TOKEN_COMMA) {
            parser_asm_lex_step_kind_c(lex_inout, source);
            continue;
          }
          if (k2 == TOKEN_RPAREN) {
            parser_asm_lex_step_kind_c(lex_inout, source);
            ai = 0;
            while (ai < n) {
              if (pipeline_expr_append_method_call_arg(arena, mc_ref, mc_arg_buf[ai]) < 0) {
                out_ok[0] = 0;
                return -1;
              }
              ai = ai + 1;
            }
            break;
          }
          out_ok[0] = 0;
          return -1;
        }
      } else {
        parser_asm_lex_step_kind_c(lex_inout, source);
      }
    } else {
      fa_ref = ast_ast_arena_expr_alloc(arena);
      if (fa_ref == 0) {
        out_ok[0] = 0;
        return -1;
      }
      pipeline_expr_set_common_zeros_c(arena, fa_ref);
      pipeline_expr_set_kind(arena, fa_ref, EXPR_FIELD_ACCESS);
      pipeline_expr_set_field_access_c(arena, fa_ref, out_expr_ref[0], data + mname_start, mname_len);
      pipeline_expr_set_line_col(arena, fa_ref, 0, 0);
      out_expr_ref[0] = fa_ref;
      k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
      ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
      il = parser_asm_lex_peek_ident_len_c(lex_inout, source);
      np = parser_asm_lex_peek_next_pos_c(lex_inout, source);
      tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
      tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
      parser_asm_lex_set_pos_c(lex_inout, parser_asm_lex_at_token_pos_c(k2, ts, il, np));
      parser_asm_lex_set_line_c(lex_inout, tl);
      parser_asm_lex_set_col_c(lex_inout, tc);
    }
    return 1;
  }
  return 1;
}

/**
 * Suffix branch: LT turbofish (real type_refs first; count-only fallback
 * leaves the cursor at '<' for relcompare on non-call shapes).
 */
export function parser_asm_suffix_b_lt(arena: *u8, source: *u8, lex_inout: *u8, out_ok: *i32, out_expr_ref: *i32, mc_arg_buf: *i32, arg_buf: *i32, parsed_refs: *i32, pending_refs: *i32, mangled: *u8, name_buf: *u8, pending_cnt: *i32): i32 {
  let k2: i32 = 0;
  let n: i32 = 0;
  let pi: i32 = 0;
  let parse_ok: i32 = 0;
  let tr: i32 = 0;
  let count: i32 = 0;
  let tlen: i32 = 0;
  let mlen: i32 = 0;
  let prefer_block: i32 = 0;
  let pos_lt: usize = 0;
  let ok2: i32 = 0;
  let eref2: i32 = 0;
  unsafe {
    pos_lt = parser_asm_lex_pos_c(lex_inout);
    parse_ok = 1;
    n = 0;
    pi = 0;
    while (pi < 8) {
      parsed_refs[pi] = 0;
      pi = pi + 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (k2 == TOKEN_GT || k2 == TOKEN_RSHIFT) {
      parse_ok = 0;
    }
    if (parse_ok != 0) {
      while (true) {
        if (n >= 8) {
          parse_ok = 0;
          break;
        }
        tr = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
        if (tr <= 0) {
          parse_ok = 0;
          break;
        }
        parsed_refs[n] = tr;
        n = n + 1;
        k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (k2 == TOKEN_COMMA) {
          parser_asm_lex_step_kind_c(lex_inout, source);
          continue;
        }
        if (k2 == TOKEN_GT) {
          parser_asm_lex_step_kind_c(lex_inout, source);
          break;
        }
        if (k2 == TOKEN_RSHIFT) {
          parser_asm_lex_set_pos_c(lex_inout, parser_asm_lex_pos_c(lex_inout) + 1);
          break;
        }
        parse_ok = 0;
        break;
      }
    }
    if (parse_ok != 0) {
      k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (k2 == TOKEN_LBRACE) {
        if (pipeline_expr_kind_ord_at(arena, out_expr_ref[0]) != EXPR_VAR) {
          return 0;
        }
        if (pipeline_expr_var_name_len(arena, out_expr_ref[0]) <= 0) {
          return 0;
        }
        prefer_block = 0;
        if (parser_asm_lbrace_looks_like_block_ptr_c(lex_inout, source) != 0) {
          prefer_block = 1;
        } else if (parser_asm_empty_ident_braces_prefer_block_ptr_c(lex_inout, source) == 1) {
          prefer_block = 1;
        }
        if (prefer_block != 0) {
          return 0;
        }
        tlen = pipeline_expr_var_name_len(arena, out_expr_ref[0]);
        pipeline_expr_var_name_into(arena, out_expr_ref[0], name_buf);
        mlen = parser_asm_append_type_inst_mangle_c(arena, name_buf, tlen, parsed_refs, n, mangled, 128);
        if (mlen <= 0 || mlen > 255) {
          out_ok[0] = 0;
          return -1;
        }
        pipeline_expr_set_var_name(arena, out_expr_ref[0], mangled, mlen);
        parser_asm_lex_step_kind_c(lex_inout, source);
        ok2 = 0;
        eref2 = 0;
        parser_finish_struct_lit_ptr_into_c(arena, out_expr_ref[0], lex_inout, source, &ok2, &eref2);
        if (ok2 == 0) {
          out_ok[0] = 0;
          return -1;
        }
        out_expr_ref[0] = eref2;
        pending_cnt[0] = 0;
        pi = 0;
        while (pi < 8) {
          pending_refs[pi] = 0;
          pi = pi + 1;
        }
        return 1;
      }
      if (k2 != TOKEN_LPAREN) {
        return 0;
      }
      pending_cnt[0] = n;
      pi = 0;
      while (pi < n && pi < 8) {
        pending_refs[pi] = parsed_refs[pi];
        pi = pi + 1;
      }
      while (pi < 8) {
        pending_refs[pi] = 0;
        pi = pi + 1;
      }
      return 1;
    }
    parser_asm_lex_set_pos_c(lex_inout, pos_lt);
    parser_asm_skip_angle_count_ptr_into_c(lex_inout, source, &count);
    k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (k2 != TOKEN_LPAREN) {
      parser_asm_lex_set_pos_c(lex_inout, pos_lt);
      return 0;
    }
    pending_cnt[0] = count;
    pi = 0;
    while (pi < 8) {
      pending_refs[pi] = 0;
      pi = pi + 1;
    }
    return 1;
  }
  return 1;
}

/**
 * Suffix branch: LBRACKET index (`base[idx]`).
 */
export function parser_asm_suffix_b_idx(arena: *u8, source: *u8, lex_inout: *u8, out_ok: *i32, out_expr_ref: *i32, mc_arg_buf: *i32, arg_buf: *i32, parsed_refs: *i32, pending_refs: *i32, mangled: *u8, name_buf: *u8, pending_cnt: *i32): i32 {
  let k2: i32 = 0;
  let base_ref: i32 = 0;
  let idx_ref: i32 = 0;
  let ok2: i32 = 0;
  let eref2: i32 = 0;
  unsafe {
    base_ref = out_expr_ref[0];
    parser_asm_lex_step_kind_c(lex_inout, source);
    ok2 = 0;
    eref2 = 0;
    if (parser_parse_expr_ptr_into_c(arena, lex_inout, source, &ok2, &eref2) == 0) {
      out_ok[0] = 0;
      return -1;
    }
    if (ok2 == 0) {
      out_ok[0] = 0;
      return -1;
    }
    k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (k2 != TOKEN_RBRACKET) {
      out_ok[0] = 0;
      return -1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    idx_ref = ast_ast_arena_expr_alloc(arena);
    if (idx_ref == 0) {
      out_ok[0] = 0;
      return -1;
    }
    pipeline_expr_set_common_zeros_c(arena, idx_ref);
    pipeline_expr_set_kind(arena, idx_ref, EXPR_INDEX);
    pipeline_expr_set_index_c(arena, idx_ref, base_ref, eref2, 0);
    pipeline_expr_set_line_col(arena, idx_ref, 0, 0);
    out_expr_ref[0] = idx_ref;
    return 1;
  }
  return 1;
}

/**
 * Suffix branch: LPAREN call (turbofish type-args from pending; args
 * parse fully into staging THEN append — nested-call slot safety).
 */
export function parser_asm_suffix_b_call(arena: *u8, source: *u8, lex_inout: *u8, out_ok: *i32, out_expr_ref: *i32, mc_arg_buf: *i32, arg_buf: *i32, parsed_refs: *i32, pending_refs: *i32, mangled: *u8, name_buf: *u8, pending_cnt: *i32): i32 {
  let k2: i32 = 0;
  let callee_ref: i32 = 0;
  let call_ref: i32 = 0;
  let n: i32 = 0;
  let ai: i32 = 0;
  let ok2: i32 = 0;
  let eref2: i32 = 0;
  unsafe {
    callee_ref = out_expr_ref[0];
    parser_asm_lex_step_kind_c(lex_inout, source);
    call_ref = ast_ast_arena_expr_alloc(arena);
    if (call_ref == 0) {
      out_ok[0] = 0;
      return -1;
    }
    pipeline_expr_set_common_zeros_c(arena, call_ref);
    pipeline_expr_set_kind(arena, call_ref, EXPR_CALL);
    pipeline_expr_set_line_col(arena, call_ref, 0, 0);
    pipeline_expr_set_call_c(arena, call_ref, callee_ref, pending_cnt[0]);
    if (pending_cnt[0] > 0 && pending_refs[0] > 0) {
      ai = 0;
      while (ai < pending_cnt[0] && ai < 8) {
        if (pending_refs[ai] <= 0) {
          break;
        }
        if (pipeline_expr_append_call_type_arg(arena, call_ref, pending_refs[ai]) < 0) {
          out_ok[0] = 0;
          return -1;
        }
        ai = ai + 1;
      }
    }
    pending_cnt[0] = 0;
    ai = 0;
    while (ai < 8) {
      pending_refs[ai] = 0;
      ai = ai + 1;
    }
    n = 0;
    k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (k2 != TOKEN_RPAREN) {
      while (true) {
        if (n >= 256) {
          out_ok[0] = 0;
          return -1;
        }
        ok2 = 0;
        eref2 = 0;
        if (parser_parse_expr_ptr_into_c(arena, lex_inout, source, &ok2, &eref2) == 0) {
          out_ok[0] = 0;
          return -1;
        }
        if (ok2 == 0) {
          out_ok[0] = 0;
          return -1;
        }
        arg_buf[n] = eref2;
        n = n + 1;
        k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (k2 == TOKEN_COMMA) {
          parser_asm_lex_step_kind_c(lex_inout, source);
          continue;
        }
        if (k2 == TOKEN_RPAREN) {
          parser_asm_lex_step_kind_c(lex_inout, source);
          break;
        }
        out_ok[0] = 0;
        return -1;
      }
    } else {
      parser_asm_lex_step_kind_c(lex_inout, source);
    }
    ai = 0;
    while (ai < n) {
      if (pipeline_expr_append_call_arg(arena, call_ref, arg_buf[ai]) < 0) {
        out_ok[0] = 0;
        return -1;
      }
      ai = ai + 1;
    }
    out_expr_ref[0] = call_ref;
    return 1;
  }
  return 1;
}

/**
 * Suffix branch: LBRACE qualified struct lit (`Mod.Type { ... }`) —
 * FIELD_ACCESS heads only, after the two block-pref authorities;
 * wave607 chain continuation via return 1.
 */
export function parser_asm_suffix_b_lbrace(arena: *u8, source: *u8, lex_inout: *u8, out_ok: *i32, out_expr_ref: *i32, mc_arg_buf: *i32, arg_buf: *i32, parsed_refs: *i32, pending_refs: *i32, mangled: *u8, name_buf: *u8, pending_cnt: *i32): i32 {
  let prefer_block: i32 = 0;
  let pos0: usize = 0;
  let line0: i32 = 0;
  let col0: i32 = 0;
  let tlen: i32 = 0;
  let ok2: i32 = 0;
  let eref2: i32 = 0;
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, out_expr_ref[0]) != EXPR_FIELD_ACCESS) {
      return 0;
    }
    prefer_block = 0;
    if (parser_asm_lbrace_looks_like_block_ptr_c(lex_inout, source) != 0) {
      prefer_block = 1;
    } else if (parser_asm_empty_ident_braces_prefer_block_ptr_c(lex_inout, source) == 1) {
      prefer_block = 1;
    }
    if (prefer_block != 0) {
      return 0;
    }
    tlen = pipeline_expr_field_name_len_at(arena, out_expr_ref[0]);
    if (tlen <= 0 || tlen > 255) {
      out_ok[0] = 0;
      return -1;
    }
    pipeline_expr_field_name_into(arena, out_expr_ref[0], name_buf);
    pos0 = parser_asm_lex_pos_c(lex_inout);
    line0 = parser_asm_lex_line_c(lex_inout);
    col0 = parser_asm_lex_col_c(lex_inout);
    parser_asm_lex_step_kind_c(lex_inout, source);
    pipeline_expr_set_common_zeros_c(arena, out_expr_ref[0]);
    pipeline_expr_set_struct_lit_finish_c(arena, out_expr_ref[0], name_buf, tlen);
    pipeline_expr_set_line_col(arena, out_expr_ref[0], 0, 0);
    ok2 = 0;
    eref2 = 0;
    parser_asm_parse_struct_lit_fields_ptr_c(arena, out_expr_ref[0], lex_inout, source, &ok2, &eref2);
    if (ok2 == 0) {
      out_ok[0] = 0;
      return -1;
    }
    out_expr_ref[0] = eref2;
    return 1;
  }
  return 1;
}

/**
 * The primary suffix chain driver (.x): peek-kind dispatch to the split
 * branch functions (the monolithic body was silently dropped by the
 * pure-asm emitter's large-function table). Stall guard 4096 preserved.
 * pending_cnt is driver-local state shared across LT→CALL iterations.
 */
#[no_mangle]
export function parser_asm_primary_suffix_loop_x_into_c(arena: *u8, source: *u8, lex_inout: *u8, out_ok: *i32, out_expr_ref: *i32, mc_arg_buf: *i32, arg_buf: *i32, parsed_refs: *i32, pending_refs: *i32, mangled: *u8, name_buf: *u8): void {
  let kind: i32 = 0;
  let prev_kind: i32 = -1;
  let prev_pos: usize = 0;
  let stall: i32 = 0;
  let r: i32 = 0;
  let pending_n: i32 = 0;
  unsafe {
    pending_n = 0;
    while (true) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (parser_asm_lex_pos_c(lex_inout) == prev_pos && kind == prev_kind) {
        stall = stall + 1;
        if (stall >= 4096) {
          out_ok[0] = 0;
          return;
        }
      } else {
        stall = 0;
      }
      prev_pos = parser_asm_lex_pos_c(lex_inout);
      prev_kind = kind;
      if (kind == TOKEN_DOT) {
        r = parser_asm_suffix_b_dot(arena, source, lex_inout, out_ok, out_expr_ref, mc_arg_buf, arg_buf, parsed_refs, pending_refs, mangled, name_buf, &pending_n);
      } else if (kind == TOKEN_LT) {
        r = parser_asm_suffix_b_lt(arena, source, lex_inout, out_ok, out_expr_ref, mc_arg_buf, arg_buf, parsed_refs, pending_refs, mangled, name_buf, &pending_n);
      } else if (kind == TOKEN_LBRACKET) {
        r = parser_asm_suffix_b_idx(arena, source, lex_inout, out_ok, out_expr_ref, mc_arg_buf, arg_buf, parsed_refs, pending_refs, mangled, name_buf, &pending_n);
      } else if (kind == TOKEN_LPAREN) {
        r = parser_asm_suffix_b_call(arena, source, lex_inout, out_ok, out_expr_ref, mc_arg_buf, arg_buf, parsed_refs, pending_refs, mangled, name_buf, &pending_n);
      } else if (kind == TOKEN_LBRACE) {
        r = parser_asm_suffix_b_lbrace(arena, source, lex_inout, out_ok, out_expr_ref, mc_arg_buf, arg_buf, parsed_refs, pending_refs, mangled, name_buf, &pending_n);
      } else {
        return;
      }
      if (r < 0) {
        out_ok[0] = 0;
        return;
      }
      if (r == 0) {
        return;
      }
    }
  }
}

/**
 * IDENT/SELF primary head (.x mirror of the IDENT arm): pre-dispatch fat
 * shim (unsafe-expr / asm-bang sub-parsers stay C), then the VAR fill
 * (kind 3 + source name copy + token line/col + zeros), the Type{...}
 * struct-lit LBRACE dance (two block-pref authorities; on prefer-block
 * restore the cursor AT the '{' and stop), and the .x suffix loop
 * (wave607 continuation). Keyword `self` skips the struct-lit path.
 * @param buffers — the six suffix-loop trampoline buffers (dispatcher-owned)
 * @return i32 — 1 handled (check out_ok for inner failures); 0 not IDENT/SELF
 * PLATFORM: SHARED — product primary IDENT arm (EXPR_PRIMARY gate).
 */
#[no_mangle]
export function parser_asm_primary_ident_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32, out_wants_suffix: *i32): i32 {
  let kind: i32 = 0;
  let vlen: i32 = 0;
  let name_was_self: i32 = 0;
  let ref: i32 = 0;
  let ts: usize = 0;
  let tl: i32 = 0;
  let tc: i32 = 0;
  let pos0: usize = 0;
  let line0: i32 = 0;
  let col0: i32 = 0;
  let data: *u8 = 0 as *u8;
  let ok2: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    out_ok[0] = 0;
    out_expr_ref[0] = 0;
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT && kind != TOKEN_SELF) {
      return 0;
    }
    /* unsafe-expr / asm! sub-parsers (whole-sale C via the fat shim). */
    ok2 = 0;
    ref = 0;
    if (parser_asm_ident_pre_dispatch_ptr_c(arena, lex_inout, source, &ok2, &ref) != 0) {
      out_ok[0] = ok2;
      out_expr_ref[0] = ref;
      return 1;
    }
    name_was_self = 0;
    vlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    if (kind == TOKEN_SELF) {
      name_was_self = 1;
      vlen = 4;
    }
    ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
    tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    data = parser_asm_lex_source_data_c(source);
    ref = ast_ast_arena_expr_alloc(arena);
    if (ref == 0) {
      out_ok[0] = 0;
      return 1;
    }
    pipeline_expr_set_kind(arena, ref, EXPR_VAR_LIT);
    pipeline_expr_set_var_name(arena, ref, data + ts, vlen);
    pipeline_expr_set_line_col(arena, ref, tl, tc);
    pipeline_expr_set_common_zeros_c(arena, ref);
    out_ok[0] = 1;
    out_expr_ref[0] = ref;
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_LBRACE && name_was_self == 0) {
      /* Type { ... } struct lit — but bare if/while bodies win per the two
       * authorities. Snapshot, step past '{', predicate on the after-brace
       * cursor; on prefer-block restore AT the '{' and stop (leave it). */
      pos0 = parser_asm_lex_pos_c(lex_inout);
      line0 = parser_asm_lex_line_c(lex_inout);
      col0 = parser_asm_lex_col_c(lex_inout);
      parser_asm_lex_step_kind_c(lex_inout, source);
      if (parser_asm_lbrace_looks_like_block_ptr_c(lex_inout, source) != 0) {
        parser_asm_lex_set_pos_c(lex_inout, pos0);
        parser_asm_lex_set_line_c(lex_inout, line0);
        parser_asm_lex_set_col_c(lex_inout, col0);
        return 1;
      }
      if (parser_asm_empty_ident_braces_prefer_block_ptr_c(lex_inout, source) == 1) {
        parser_asm_lex_set_pos_c(lex_inout, pos0);
        parser_asm_lex_set_line_c(lex_inout, line0);
        parser_asm_lex_set_col_c(lex_inout, col0);
        return 1;
      }
      ok2 = 0;
      ref = 0;
      parser_finish_struct_lit_ptr_into_c(arena, out_expr_ref[0], lex_inout, source, &ok2, &ref);
      if (ok2 == 0) {
        out_ok[0] = 0;
        return 1;
      }
      out_expr_ref[0] = ref;
    }
    out_wants_suffix[0] = 1;
    return 1;
  }
  return 0;
}
