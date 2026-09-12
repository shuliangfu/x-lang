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
// write_try_skip_allow_result (memset pad) and parse_into (by-value
// lexer_result IDENT-len==5 gate) stay C. Product AUDIT_CALL is already
// ((void)0); the C twins keep the huge already-T combinator probes as
// cold fallback only.
// Do not duplicate skip_balanced (authority = pthin_lex_skip.x).
// Do not wrap glue_tail scattered AUDIT as a side effect.
// Do not compile this file as a skip-include stub without bodies.
//
// Hybrid P13b: g05_try_x_to_o this file;
// XLANG_PTHIN_TRY_SKIP_ALLOW_BODIES_FROM_X skips the portable .inc
// region. Requires P9a bridge + P1b skip_balanced (otherwise those
// would UNDEF). token.h remains the TOKEN_* authority via P13 C
// _Static_assert pins. Cold: no define, full .inc. Do not reuse
// XLANG_PTHIN_TRY_SKIP_ALLOW_FROM_X for P13b bodies.
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
