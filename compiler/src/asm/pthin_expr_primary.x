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
