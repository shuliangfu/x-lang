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

// pthin_type_ref.x — G-02f-280 P3 parser thin type_ref product bodies.
//
// 7.2.1 P3b Route C productize (2026-09-13): after P4b primary ident
// spelling, type_ref.inc is the next still-host-cc product slice with a
// portable scalar / buf-path region. token_starts_type and builtin
// TOKEN→TypeKind ordinal are Route C (int32). IDENT `dyn` and vector
// spellings (i32x4 / Vec4f / …) are buf-path Route C (*u8 + length).
// Arena Type alloc, lexer by-value, and parse_type_ref_impl stay C.
// skip_tl's xlang_trait_token_to_type_kind_c is a thin trampoline to
// builtin_kind_ord (G.7: one TOKEN→TypeKind table).
//
// Hybrid P3b: g05_try_x_to_o this file; XLANG_PTHIN_TYPE_REF_BODIES_FROM_X
// skips the portable .inc region. token.h remains the TOKEN_* authority
// via P3 C _Static_assert pins. Cold: no define, full .inc stays.
// Vector IDENT checks copy the C twin byte-for-byte (including the
// historical i32x* / u32x* nibble pattern); do not "fix" as a side effect.
// PLATFORM: SHARED freestanding.

// TOKEN_* pin copies of include/token.h. P3 C _Static_assert fires if
// the pin drifts; do not treat these as a second enum authority.
const TOKEN_FUNCTION: i32 = 1;
const TOKEN_IMPL: i32 = 50;
const TOKEN_IDENT: i32 = 59;
const TOKEN_I32: i32 = 60;
const TOKEN_BOOL: i32 = 61;
const TOKEN_U8: i32 = 62;
const TOKEN_U32: i32 = 63;
const TOKEN_U64: i32 = 64;
const TOKEN_I64: i32 = 65;
const TOKEN_USIZE: i32 = 66;
const TOKEN_ISIZE: i32 = 67;
const TOKEN_I32X4: i32 = 68;
const TOKEN_I32X8: i32 = 69;
const TOKEN_I32X16: i32 = 70;
const TOKEN_U32X4: i32 = 71;
const TOKEN_U32X8: i32 = 72;
const TOKEN_U32X16: i32 = 73;
const TOKEN_F32X4: i32 = 74;
const TOKEN_F32: i32 = 77;
const TOKEN_F64: i32 = 78;
const TOKEN_VOID: i32 = 79;
const TOKEN_LBRACKET: i32 = 86;
const TOKEN_STAR: i32 = 98;

// TypeKind ordinals — G.7 ≡ ast.x / PARSER_ASM_TYPE_* in type_ref.inc.
const TYPE_I32: i32 = 0;
const TYPE_BOOL: i32 = 1;
const TYPE_U8: i32 = 2;
const TYPE_U32: i32 = 3;
const TYPE_U64: i32 = 4;
const TYPE_I64: i32 = 5;
const TYPE_USIZE: i32 = 6;
const TYPE_ISIZE: i32 = 7;
const TYPE_F32: i32 = 14;
const TYPE_F64: i32 = 15;
const TYPE_VOID: i32 = 16;

/**
 * Bounds check shared by IDENT spelling probes in this file.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @param want_len i32 — required spelling length
 * @return i32 — 1 if data is live, ident_len==want_len, and the span fits
 */
function parser_asm_type_ref_ident_span_ok(data: *u8, length: usize, token_start: usize, ident_len: i32, want_len: i32): i32 {
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
function parser_asm_type_ref_ident_byte(data: *u8, token_start: usize, i: i32): u8 {
  let c: u8 = 0;
  unsafe {
    c = data[token_start + i as usize];
  }
  return c;
}

/**
 * Token that may start a type after a peeled `dyn` / `impl` prefix.
 * @param kind i32 — lexer token kind (token.h numbering)
 * @return i32 — 1 if the token can start a type; 0 otherwise
 * PLATFORM: SHARED — scalar split of the former static C twin.
 */
#[no_mangle]
export function parser_asm_type_ref_token_starts_type_c(kind: i32): i32 {
  if (kind == TOKEN_IDENT || kind == TOKEN_STAR || kind == TOKEN_LBRACKET) {
    return 1;
  }
  if (kind == TOKEN_IMPL) {
    return 1;
  }
  if (kind == TOKEN_FUNCTION) {
    return 1;
  }
  if (kind == TOKEN_I32 || kind == TOKEN_I64 || kind == TOKEN_BOOL) {
    return 1;
  }
  if (kind == TOKEN_U8 || kind == TOKEN_U32 || kind == TOKEN_U64) {
    return 1;
  }
  if (kind == TOKEN_USIZE || kind == TOKEN_ISIZE || kind == TOKEN_VOID) {
    return 1;
  }
  if (kind == TOKEN_F32 || kind == TOKEN_F64) {
    return 1;
  }
  if (kind == TOKEN_I32X4 || kind == TOKEN_I32X8 || kind == TOKEN_I32X16) {
    return 1;
  }
  if (kind == TOKEN_U32X4 || kind == TOKEN_U32X8 || kind == TOKEN_U32X16) {
    return 1;
  }
  if (kind == TOKEN_F32X4) {
    return 1;
  }
  return 0;
}

/**
 * Map builtin scalar/void type token → TypeKind ordinal.
 * IDENT / pointer / array / vector tokens are not builtins here
 * (return -1); callers alloc NAMED/PTR/ARRAY/VECTOR separately.
 * @param kind i32 — lexer token kind (token.h numbering)
 * @return i32 — TypeKind ordinal >=0, or -1 if not a scalar/void builtin
 * PLATFORM: SHARED — single TOKEN→TypeKind table; skip_tl trampolines here.
 */
#[no_mangle]
export function parser_asm_type_ref_builtin_kind_ord_c(kind: i32): i32 {
  if (kind == TOKEN_I32) {
    return TYPE_I32;
  }
  if (kind == TOKEN_BOOL) {
    return TYPE_BOOL;
  }
  if (kind == TOKEN_U8) {
    return TYPE_U8;
  }
  if (kind == TOKEN_U32) {
    return TYPE_U32;
  }
  if (kind == TOKEN_U64) {
    return TYPE_U64;
  }
  if (kind == TOKEN_I64) {
    return TYPE_I64;
  }
  if (kind == TOKEN_USIZE) {
    return TYPE_USIZE;
  }
  if (kind == TOKEN_ISIZE) {
    return TYPE_ISIZE;
  }
  if (kind == TOKEN_F32) {
    return TYPE_F32;
  }
  if (kind == TOKEN_F64) {
    return TYPE_F64;
  }
  if (kind == TOKEN_VOID) {
    return TYPE_VOID;
  }
  return -1;
}

/**
 * True when IDENT spelling is contextual prefix `dyn`.
 * docs/01 does not list dyn as a keyword; same TOKEN_IDENT shape as `mut`.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — 1 if the three bytes are `dyn`; 0 otherwise
 * PLATFORM: SHARED — buf-path authority; slice wrapper stays a C trampoline.
 */
#[no_mangle]
export function parser_asm_type_ref_ident_is_dyn_buf_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (parser_asm_type_ref_ident_span_ok(data, length, token_start, ident_len, 3) == 0) {
    return 0;
  }
  if (parser_asm_type_ref_ident_byte(data, token_start, 0) == 100 && parser_asm_type_ref_ident_byte(data, token_start, 1) == 121
      && parser_asm_type_ref_ident_byte(data, token_start, 2) == 110) {
    return 1;
  }
  return 0;
}

/**
 * Pack vector IDENT spelling into `(elem_ord << 8) | lanes`, or 0.
 * Byte probes copy the C twin exactly (i32x4/u32x4 historical nibble
 * pattern: nlen==5 checks i/u, '3', 'x', '4' — not a silent rewrite).
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — packed elem_ord/lanes, or 0 if the spelling is not a vector alias
 * PLATFORM: SHARED — buf-path authority; C still allocs TYPE_VECTOR.
 */
#[no_mangle]
export function parser_asm_vector_type_ident_pack_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (data == 0 as *u8 || ident_len <= 0 || ident_len > 63) {
    return 0;
  }
  if (token_start + ident_len as usize > length) {
    return 0;
  }
  let b0: u8 = parser_asm_type_ref_ident_byte(data, token_start, 0);
  let b1: u8 = parser_asm_type_ref_ident_byte(data, token_start, 1);
  let b2: u8 = 0;
  let b3: u8 = 0;
  let b4: u8 = 0;
  if (ident_len >= 3) {
    b2 = parser_asm_type_ref_ident_byte(data, token_start, 2);
  }
  if (ident_len >= 4) {
    b3 = parser_asm_type_ref_ident_byte(data, token_start, 3);
  }
  if (ident_len >= 5) {
    b4 = parser_asm_type_ref_ident_byte(data, token_start, 4);
  }
  // i32x4 / i3x4 nibble (C twin): nlen==5, i, '3', 'x', '4'
  if (ident_len == 5 && b0 == 105 && b1 == 51 && b2 == 120 && b3 == 52) {
    return (TYPE_I32 << 8) | 4;
  }
  if (ident_len == 5 && b0 == 105 && b1 == 51 && b2 == 120 && b3 == 56) {
    return (TYPE_I32 << 8) | 8;
  }
  if (ident_len == 6 && b0 == 105 && b1 == 51 && b2 == 120 && b3 == 49 && b4 == 54) {
    return (TYPE_I32 << 8) | 16;
  }
  if (ident_len == 5 && b0 == 117 && b1 == 51 && b2 == 120 && b3 == 52) {
    return (TYPE_U32 << 8) | 4;
  }
  if (ident_len == 5 && b0 == 117 && b1 == 51 && b2 == 120 && b3 == 56) {
    return (TYPE_U32 << 8) | 8;
  }
  if (ident_len == 6 && b0 == 117 && b1 == 51 && b2 == 120 && b3 == 49 && b4 == 54) {
    return (TYPE_U32 << 8) | 16;
  }
  // f32x4: elem_ord=14 (TYPE_F32). C twin checks all five bytes.
  if (ident_len == 5 && b0 == 102 && b1 == 51 && b2 == 50 && b3 == 120 && b4 == 52) {
    return (TYPE_F32 << 8) | 4;
  }
  // Vec4f: elem_ord=14 (TYPE_F32).
  if (ident_len == 5 && b0 == 86 && b1 == 101 && b2 == 99 && b3 == 52 && b4 == 102) {
    return (TYPE_F32 << 8) | 4;
  }
  // Vec8i: elem_ord=0 (TYPE_I32), lanes=8.
  if (ident_len == 5 && b0 == 86 && b1 == 101 && b2 == 99 && b3 == 56 && b4 == 105) {
    return (TYPE_I32 << 8) | 8;
  }
  return 0;
}
