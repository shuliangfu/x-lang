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

// pthin_glue.x — G-02f-319 P10 parser thin glue_tail product bodies.
//
// 7.2.1 P10b B-minus productize (2026-09-13): after P18b body_tl skip
// walks, glue_tail.inc is the largest still-host-cc product slice.
// skip_one_function_full is ~870 lines of already-T AUDIT nops
// (including HARD BAN summit/peak/zenith/vx names) around a short
// async/export/function/IDENT/(…)/:Ret/{…} walk, plus a cfg-skip
// EXTERN delegate. Reuse P1b skip_balanced and P12b skip_one_extern
// and the P9a lexer-step bridge. By-value lexer returns stay as C
// trampolines in seeds/pthin_glue.from_x.c. getenv debug prints
// (XLANG_DEBUG_SKIP_FUNC) stay on the C twin (cold fallback only).
// Remaining glue_tail wrappers / parse glue stay C.
// Product AUDIT_CALL is already ((void)0); the C twin keeps the huge
// already-T combinator probes as cold fallback only.
// Do not duplicate skip_balanced (authority = pthin_lex_skip.x).
// Do not duplicate skip_one_extern (authority = pthin_skip_tl.x).
// Do not wrap glue_tail scattered AUDIT as a side effect.
// Do not compile this file as a skip-include stub without bodies.
//
// Hybrid P10b: g05_try_x_to_o this file; XLANG_PTHIN_GLUE_BODIES_FROM_X
// skips the portable .inc region. Requires P9a bridge + P1b skip
// walks + P12b skip_one_extern (otherwise those would UNDEF). token.h
// remains the TOKEN_* authority via P10 C _Static_assert pins. Cold:
// no define, full .inc. Do not reuse XLANG_PTHIN_GLUE_FROM_X for P10b
// bodies.
// PLATFORM: SHARED freestanding.

/** Advance the opaque lexer one token; returns the consumed kind. */
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token kind without advancing. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
/** P1b authority: in-place skip of a balanced group (caller consumed opener). */
export extern "C" function parser_asm_skip_balanced_parens_into_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_skip_balanced_braces_into_c(lex_inout: *u8, source: *u8): i32;
/** P12b authority: skip `extern ["ABI"] function name(…): Ret;`. */
export extern "C" function parser_asm_skip_one_extern_into_c(lex_inout: *u8, source: *u8): i32;

// TOKEN_* pin copies of include/token.h (133 kinds). P10 C _Static_assert
// fires if the pin drifts; do not treat these as a second enum authority.
const TOKEN_EOF: i32 = 0;
const TOKEN_FUNCTION: i32 = 1;
const TOKEN_EXTERN: i32 = 54;
const TOKEN_ASYNC: i32 = 55;
const TOKEN_IDENT: i32 = 59;
const TOKEN_LPAREN: i32 = 82;
const TOKEN_LBRACE: i32 = 84;
const TOKEN_COLON: i32 = 91;
const TOKEN_EXPORT: i32 = 131;

/**
 * Skip a top-level `function` (optional `async` / `export` prefix, or
 * `extern` delegated to P12b) through the matching body `}`.
 * Entry cursor is one of three shapes (same as the C twin):
 *   (1) at `function`;
 *   (2) already past the keyword at the IDENT name (host parse residual);
 *   (3) at `export` before `function`.
 * Optional leading `async` is consumed. A leading `extern` calls P12b
 * skip_one_extern (entry is the start of `extern`) and returns.
 * After the name IDENT, matching `(` is consumed then skip_balanced_parens
 * (P1b). After `:`, tokens are stepped until LBRACE / EOF; matching `{`
 * is consumed then skip_balanced_braces. Fail-leave leaves the lexer
 * after the last successfully consumed token (the failed token is peeked
 * but not consumed), matching the C twin.
 * @param lex_inout *u8 — opaque lexer (advanced past `}`, or left on the
 *   fail cursor described above)
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success / fail-leave path; 0 on null
 * PLATFORM: SHARED — product P10 B-minus; C trampoline keeps
 * `parser_asm_skip_one_function_full_into_slice_c`. getenv debug
 * prints stay on the C twin.
 */
#[no_mangle]
export function parser_asm_skip_one_function_full_into_c(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_ASYNC) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
    // #[cfg] prune of a top-level extern: parse_into and cfg_skip both
    // enter skip_one_function_full; delegate to P12b (do not copy).
    if (kind == TOKEN_EXTERN) {
      parser_asm_skip_one_extern_into_c(lex_inout, source);
      return 1;
    }
    if (kind == TOKEN_EXPORT) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
    if (kind == TOKEN_FUNCTION) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    } else if (kind != TOKEN_IDENT) {
      return 1;
    }
    // kind is the function-name IDENT (either after consuming FUNCTION,
    // or the entry cursor was already the name).
    if (kind != TOKEN_IDENT) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LPAREN) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    parser_asm_skip_balanced_parens_into_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_COLON) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    while (kind != TOKEN_LBRACE && kind != TOKEN_EOF) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
    if (kind != TOKEN_LBRACE) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    parser_asm_skip_balanced_braces_into_c(lex_inout, source);
  }
  return 1;
}
