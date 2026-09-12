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

// pthin_helpers.x — G-02f-328 P19 parser thin helpers product bodies.
//
// 7.2.1 Route C productize (2026-09-12): after P1b lex_skip, the helpers
// .inc is the next still-host-cc product slice with a portable scalar /
// buf-copy region. Kind predicates and pos-before-run are Route C
// (int32 / usize). Import-path copy and "match " byte-probe are buf-path
// Route C (*u8 + length). By-value token / lexer_result / Lexer returns
// stay as C trampolines in seeds/pthin_helpers.from_x.c (language has no
// struct-by-value). Rewind / advance / align_lex / first_token_kind_slice
// stay C (lexer_init + lexer_next_into). first_token_kind_buf's already-T
// AUDIT_CALL padding is gated in the .inc under XLANG_PARSER_STRETCH_AUDIT
// (product AUDIT_CALL is already ((void)0); compiling 50 lexer_init nops
// is not a host-cc reduction of combinators — it is dead preprocess).
//
// Hybrid P19b: g05_try_x_to_o this file; XLANG_PTHIN_HELPERS_BODIES_FROM_X
// skips the portable .inc region. token.h remains the TOKEN_* authority
// via P19 C _Static_assert pins. Cold: no define, full .inc stays.
// Stretch field-name/continues tables live in pthin_stretch.x (P9b);
// this file wraps them and adds token.h IDENT/SOA/PACKED/TYPE/LET/CONST.
// PLATFORM: SHARED freestanding.

/** Stretch table: compact/mixed kind check for struct field-name start. */
export extern "C" function parser_asm_stretch_struct_field_name_kind_c(kind: i32): i32;
/** Stretch table: compact/mixed kind check for field-list continuation. */
export extern "C" function parser_asm_stretch_struct_field_continues_kind_c(kind: i32): i32;

// TOKEN_* pin copies of include/token.h. P19 C _Static_assert fires if
// the pin drifts; do not treat these as a second enum authority.
const TOKEN_LET: i32 = 2;
const TOKEN_CONST: i32 = 3;
const TOKEN_TYPE: i32 = 20;
const TOKEN_PACKED: i32 = 21;
const TOKEN_SOA: i32 = 22;
const TOKEN_ALIGN: i32 = 46;
const TOKEN_ASYNC: i32 = 55;
const TOKEN_IDENT: i32 = 59;
const TOKEN_I32: i32 = 60;

/**
 * Import-path segment length from token kind + ident_len.
 * IDENT with ident_len>0 returns ident_len; I32 is 3 (`i32`); ASYNC is 5
 * (`async`); anything else is -1 (illegal path segment).
 * @param kind i32 — lexer token kind (token.h numbering)
 * @param ident_len i32 — IDENT payload length; ignored unless kind is IDENT
 * @return i32 — segment byte length, or -1 if the token cannot be a segment
 * PLATFORM: SHARED — scalar split of the by-value token C twin.
 */
#[no_mangle]
export function parser_asm_import_path_dot_segment_len_kind_c(kind: i32, ident_len: i32): i32 {
  if (kind == TOKEN_IDENT && ident_len > 0) {
    return ident_len;
  }
  if (kind == TOKEN_I32) {
    return 3;
  }
  if (kind == TOKEN_ASYNC) {
    return 5;
  }
  return -1;
}

/**
 * Copy `seg_len` bytes from `data[token_start..)` into
 * `path_buf[path_len..)`. Bytes past `length` are skipped (not zero-filled).
 * @param data *u8 — source bytes; null skips every store
 * @param length usize — source length
 * @param token_start usize — first source byte
 * @param seg_len i32 — byte count; <= 0 is a no-op
 * @param path_buf *u8 — destination; null is a no-op
 * @param path_len i32 — destination write offset
 * PLATFORM: SHARED — buf-path authority; slice wrapper stays a C trampoline.
 */
#[no_mangle]
export function parser_asm_import_path_dot_segment_copy_buf_c(data: *u8, length: usize, token_start: usize, seg_len: i32, path_buf: *u8, path_len: i32): void {
  let i: i32 = 0;
  let off: usize = 0;
  let dst: usize = 0;
  let c: u8 = 0;
  if (path_buf == 0 as *u8 || seg_len <= 0) {
    return;
  }
  while (i < seg_len) {
    off = token_start + i as usize;
    if (data != 0 as *u8 && off < length) {
      dst = (path_len + i) as usize;
      unsafe {
        c = data[off];
        path_buf[dst] = c;
      }
    }
    i = i + 1;
  }
}

/**
 * True when `k` can start a struct field name (ident / keyword-as-ident).
 * Stretch table is consulted first (P9b); token.h IDENT/SOA/PACKED/TYPE
 * are then accepted so product kinds (not compact STRETCH_TOKEN_*) work.
 * @param k i32 — lexer token kind
 * @return i32 — 1 if a field-name start; 0 otherwise
 * PLATFORM: SHARED — include TOKEN_TYPE (std/schema `type: i32` field).
 */
#[no_mangle]
export function parser_asm_struct_field_name_tok_kind_c(k: i32): i32 {
  let stretch: i32 = 0;
  unsafe {
    stretch = parser_asm_stretch_struct_field_name_kind_c(k);
  }
  if (stretch != 0) {
    return 1;
  }
  if (k == TOKEN_IDENT || k == TOKEN_SOA || k == TOKEN_PACKED || k == TOKEN_TYPE) {
    return 1;
  }
  return 0;
}

/**
 * True when a struct field list can continue after `;` (name kind, `let` /
 * `const` field prefix, or `align(N)`).
 * @param k i32 — lexer token kind
 * @return i32 — 1 if the list continues; 0 otherwise
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_struct_field_continues_tok_kind_c(k: i32): i32 {
  let stretch: i32 = 0;
  unsafe {
    stretch = parser_asm_stretch_struct_field_continues_kind_c(k);
  }
  if (stretch != 0) {
    return 1;
  }
  if (k == TOKEN_LET || k == TOKEN_CONST) {
    return 1;
  }
  if (parser_asm_struct_field_name_tok_kind_c(k) != 0) {
    return 1;
  }
  if (k == TOKEN_ALIGN) {
    return 1;
  }
  return 0;
}

/**
 * Back up from a token end position by `run_len` bytes (token_start==0
 * reconstruction). Unsigned wrap matches the C twin if run_len > end_pos.
 * @param end_pos usize — lexer pos after the token
 * @param run_len i32 — reconstructed token byte length
 * @return usize — start pos (`end_pos - run_len`)
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lexer_pos_before_run_c(end_pos: usize, run_len: i32): usize {
  return end_pos - run_len as usize;
}

/**
 * True when `data[ident_start-6 .. ident_start)` is the six bytes `match `.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length (unused; C also did not bound-check
 *   the 6-byte window against length, only ident_start >= 6)
 * @param ident_start usize — byte index of the IDENT that follows `match `
 * @return i32 — 1 if the six bytes match; 0 otherwise
 * PLATFORM: SHARED — buf-path authority; slice wrapper stays a C trampoline.
 */
#[no_mangle]
export function parser_asm_parser_match_kw_immediately_before_buf_c(data: *u8, length: usize, ident_start: usize): i32 {
  let p: usize = 0;
  let c0: u8 = 0;
  let c1: u8 = 0;
  let c2: u8 = 0;
  let c3: u8 = 0;
  let c4: u8 = 0;
  let c5: u8 = 0;
  if (data == 0 as *u8 || ident_start < 6) {
    return 0;
  }
  // `length` is the C slice ABI width. The C twin never compared p+6
  // against source->length (only ident_start >= 6 and non-null data),
  // so this body does the same and does not read `length`.
  p = ident_start - 6;
  unsafe {
    c0 = data[p];
    c1 = data[p + 1];
    c2 = data[p + 2];
    c3 = data[p + 3];
    c4 = data[p + 4];
    c5 = data[p + 5];
  }
  if (c0 == 109 && c1 == 97 && c2 == 116 && c3 == 99 && c4 == 104 && c5 == 32) {
    return 1;
  }
  return 0;
}
