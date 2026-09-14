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
const EXPR_LIT: i32 = 0;
const EXPR_FLOAT_LIT: i32 = 1;
const EXPR_BOOL_LIT: i32 = 2;

export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_tok_line_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_tok_col_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_float_val_into_c(lex_inout: *u8, source: *u8, out: *f64): void;
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
export function parser_asm_primary_literal_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
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
    if (kind != TOKEN_FLOAT && kind != TOKEN_TRUE && kind != TOKEN_FALSE && kind != TOKEN_NULL) {
      return 0;
    }
    if (kind == TOKEN_FLOAT) {
      parser_asm_lex_peek_float_val_into_c(lex_inout, source, &fval);
    }
    tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    ref = ast_ast_arena_expr_alloc(arena);
    if (ref == 0) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
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
