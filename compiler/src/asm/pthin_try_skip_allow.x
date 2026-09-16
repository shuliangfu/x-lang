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

// pthin_try_skip_allow.x — G-02f-322 P13 parser thin try_skip_allow product
// bodies.
//
// 7.2.1 P13b B-minus productize (2026-09-13): after P10b glue skip_one
// function_full, try_skip_allow.inc is the next still-host-cc product
// slice whose skip walk is portable. The two padding_struct twins are
// ~1500 lines of already-T AUDIT nops (including HARD BAN summit/peak/
// zenith/vx names) around a short peek-LPAREN then skip_balanced_parens
// walk. Reuse P1b skip_balanced and the P9a lexer-step bridge. By-value
// TrySkipAllowResult returns stay as C trampolines in
// seeds/pthin_try_skip_allow.from_x.c (language has no struct-by-value).
// Product AUDIT_CALL is already ((void)0); the C twins keep the huge
// already-T combinator probes as cold fallback only.
//
// 7.2.1 P13c B-minus (2026-09-13): 有则补全 the last two product C bodies
// so the P13 domain has no host-cc walk left. write_result becomes
// write_fields_c (byte-wise LE store of the 24-byte TrySkipAllowResult;
// offsets pinned by C offsetof _Static_asserts in the seed TU — do not
// treat these copies as a second layout authority). parse_into becomes
// core_c over the pointer ABI: tri-state return keeps the C twin's exact
// cursor semantics (gate reject writes the entry lex; gate pass with no
// group writes r.next_lex; success writes past `)`).
// Do not duplicate skip_balanced (authority = pthin_lex_skip.x).
// Do not wrap glue_tail scattered AUDIT as a side effect.
// Do not compile this file as a skip-include stub without bodies.
//
// Hybrid P13b/P13c: g05_try_x_to_o this file;
// XLANG_PTHIN_TRY_SKIP_ALLOW_BODIES_FROM_X skips the portable .inc
// region (padding walk + write_result + parse_into). Requires P9a
// bridge + P1b skip_balanced (otherwise those would UNDEF). token.h
// remains the TOKEN_* authority via P13 C _Static_assert pins. Cold: no
// define, full .inc. Do not reuse XLANG_PTHIN_TRY_SKIP_ALLOW_FROM_X.
// PLATFORM: SHARED freestanding.

/** Advance the opaque lexer one token; returns the consumed kind. */
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token kind without advancing. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
/** P1b authority: in-place skip of a balanced group (caller consumed opener). */
export extern "C" function parser_asm_skip_balanced_parens_into_c(lex_inout: *u8, source: *u8): i32;

// TOKEN_* pin copies of include/token.h (133 kinds). P13 C _Static_assert
// fires if the pin drifts; do not treat these as a second enum authority.
const TOKEN_LPAREN: i32 = 82;
const TOKEN_IDENT: i32 = 59;

/**
 * Skip an `allow(padding)` argument list `( ... )` after the IDENT.
 * Entry cursor is the start of the token after `allow` (the C twin's
 * `r.next_lex`). Peek LPAREN; if not, the lexer is unmoved and the
 * return is 0 (not skipped). Matching `(` is consumed then
 * skip_balanced_parens (P1b; caller consumed opener). Success leaves
 * the lexer after `)` and returns 1, matching the C twin's
 * `skipped` field. The C trampoline writes TrySkipAllowResult
 * (`lex` + `skipped` + zero pad) under the original by-value names.
 * @param lex_inout *u8 — opaque lexer (advanced past `)`, or left
 *   unmoved when the next token is not `(`)
 * @param source *u8 — opaque slice
 * @return i32 — 1 if the paren group was skipped; 0 on null or non-LPAREN
 * PLATFORM: SHARED — product P13 B-minus; C trampoline keeps
 * `parser_asm_try_skip_allow_padding_struct_slice_c` and the buf twin.
 */
#[no_mangle]
export function parser_asm_try_skip_allow_padding_into_c(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LPAREN) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    parser_asm_skip_balanced_parens_into_c(lex_inout, source);
  }
  return 1;
}

/**
 * Store a 24-byte TrySkipAllowResult: the lexer cursor (pos/line/col),
 * the skipped flag, and a zeroed 4-byte tail pad. Byte-wise little-endian
 * stores via mask/shift only (no div/mod — pure-asm sdiv miscompile ban,
 * same authority as g02f_store_ptr_at). Layout is the C struct
 * `struct parser_asm_try_skip_allow_result { lexer lex; int32_t skipped;
 * uint8_t _pad[4]; }` — offsets 0/8/12/16/20 are pinned by _Static_assert
 * offsetof pins in seeds/pthin_try_skip_allow.from_x.c; do not treat the
 * constants here as a second layout authority. Null `out` is a no-op
 * (the C twin's `if (!out) return;`). line/col/skipped are always
 * non-negative in product use, so the usize widening below is exact.
 * @param out *u8 — destination; caller owns the 24-byte result
 * @param pos usize — lexer byte offset (field lex.pos @0)
 * @param line i32 — lexer line (field lex.line @8)
 * @param col i32 — lexer column (field lex.col @12)
 * @param skipped i32 — 1 when the allow(...) group was consumed (@16)
 * @return void
 * PLATFORM: SHARED — product P13c B-minus; the C name
 * `parser_asm_write_try_skip_allow_result` stays on the .inc trampoline.
 */
#[no_mangle]
export function parser_asm_write_try_skip_allow_result_fields_c(out: *u8, pos: usize, line: i32, col: i32, skipped: i32): void {
  let a: usize = 0;
  if (out == 0 as *u8) {
    return;
  }
  unsafe {
    // lex.pos @0..8 (usize LE)
    a = pos;
    out[0] = (a & 255) as u8;
    a = a >> 8;
    out[1] = (a & 255) as u8;
    a = a >> 8;
    out[2] = (a & 255) as u8;
    a = a >> 8;
    out[3] = (a & 255) as u8;
    a = a >> 8;
    out[4] = (a & 255) as u8;
    a = a >> 8;
    out[5] = (a & 255) as u8;
    a = a >> 8;
    out[6] = (a & 255) as u8;
    a = a >> 8;
    out[7] = (a & 255) as u8;
    // lex.line @8..12 (i32 LE; non-negative in product use)
    a = line as usize;
    out[8] = (a & 255) as u8;
    a = a >> 8;
    out[9] = (a & 255) as u8;
    a = a >> 8;
    out[10] = (a & 255) as u8;
    a = a >> 8;
    out[11] = (a & 255) as u8;
    // lex.col @12..16 (i32 LE; non-negative in product use)
    a = col as usize;
    out[12] = (a & 255) as u8;
    a = a >> 8;
    out[13] = (a & 255) as u8;
    a = a >> 8;
    out[14] = (a & 255) as u8;
    a = a >> 8;
    out[15] = (a & 255) as u8;
    // skipped @16..20 (i32 LE; 0 or 1)
    a = skipped as usize;
    out[16] = (a & 255) as u8;
    a = a >> 8;
    out[17] = (a & 255) as u8;
    a = a >> 8;
    out[18] = (a & 255) as u8;
    a = a >> 8;
    out[19] = (a & 255) as u8;
    // _pad[4] @20..24 zeroed (the C twin's memset)
    out[20] = 0;
    out[21] = 0;
    out[22] = 0;
    out[23] = 0;
  }
}

/**
 * parse_into core over the pointer ABI: the `allow` keyword gate plus the
 * P13b padding walk, with the C twin's exact cursor semantics preserved
 * by a tri-state return:
 *   -1 — gate rejected (tok is not the 5-byte IDENT `allow`); the cursor
 *        is untouched and the caller must write its entry lex with
 *        skipped=0 (the C twin's early write of the original lex);
 *    0 — gate passed but no `( ... )` group followed (or null inputs);
 *        the cursor still holds r.next_lex, which the caller writes with
 *        skipped=0;
 *    1 — the group was consumed; the cursor is past `)`, written with
 *        skipped=1.
 * @param lex_inout *u8 — cursor initialized to r.next_lex (the token
 *   after `allow`); only moved on the success path
 * @param source *u8 — opaque slice; null keeps the cursor and returns 0
 * @param tok_kind i32 — r.tok.kind of the by-value lexer_result
 * @param tok_ident_len i32 — r.tok.ident_len of the by-value lexer_result
 * @return i32 — -1 gate reject / 0 no group / 1 group skipped
 * PLATFORM: SHARED — product P13c B-minus; the by-value C names
 * `parser_asm_parse_into_try_skip_allow_into_slice_c` / `_buf_c` stay on
 * the .inc trampolines.
 */
#[no_mangle]
export function parser_asm_parse_into_try_skip_allow_core_c(lex_inout: *u8, source: *u8, tok_kind: i32, tok_ident_len: i32): i32 {
  if (tok_kind != TOKEN_IDENT || tok_ident_len != 5) {
    return -1;
  }
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    return parser_asm_try_skip_allow_padding_into_c(lex_inout, source);
  }
  return 0;
}
