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

// pthin_skip_tl.x — G-02f-321 P12 parser thin skip top-level product bodies.
//
// 7.2.1 P12b B-minus productize (2026-09-13): after P14b skip_if walks,
// skip_tl.inc is the largest still-host-cc product slice. skip_one_struct
// is ~800 lines of already-T AUDIT nops around a short STRUCT/IDENT/angles
// /braces walk; skip_one_enum and skip_one_extern are the sibling walks
// (no trait-reg, no module). Reuse P1b skip_balanced + skip_generic_angle
// and the P9a lexer-step bridge. By-value lexer returns stay as C
// trampolines in seeds/pthin_skip_tl.from_x.c. stash_source (file-global
// generic-bound scan) stays in those trampolines. skip_one_trait / impl
// (trait-reg globals), enum_register (void* module), parse_one_extern
// (arena), and generic_bound_* stay C.
// Product AUDIT_CALL is already ((void)0); the C twins keep the huge
// already-T combinator probes as cold fallback only.
// Do not duplicate skip_balanced / skip_generic_angle_list (authority =
// pthin_lex_skip.x). Do not wrap glue_tail scattered AUDIT as a side
// effect. Do not compile this file as a skip-include stub without bodies.
//
// Hybrid P12b: g05_try_x_to_o this file; XLANG_PTHIN_SKIP_TL_BODIES_FROM_X
// skips the portable .inc region. Requires P9a bridge + P1b skip walks
// (otherwise skip_balanced / skip_generic_angle would UNDEF). token.h
// remains the TOKEN_* authority via P12 C _Static_assert pins. Cold: no
// define, full .inc. Do not reuse XLANG_PTHIN_SKIP_TL_FROM_X for P12b
// bodies.
// PLATFORM: SHARED freestanding.

/** Advance the opaque lexer one token; returns the consumed kind. */
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token kind without advancing. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
/** P1b authority: in-place skip of a balanced group (caller consumed opener). */
export extern "C" function parser_asm_skip_balanced_parens_into_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_skip_balanced_braces_into_c(lex_inout: *u8, source: *u8): i32;
/** P1b authority: skip `<T, E, ...>`; entry is the start of `<`. */
export extern "C" function parser_asm_skip_generic_angle_list_into_c(lex_inout: *u8, source: *u8): i32;

// TOKEN_* pin copies of include/token.h (133 kinds). P12 C _Static_assert
// fires if the pin drifts; do not treat these as a second enum authority.
const TOKEN_EOF: i32 = 0;
const TOKEN_FUNCTION: i32 = 1;
const TOKEN_STRUCT: i32 = 19;
const TOKEN_ENUM: i32 = 47;
const TOKEN_EXTERN: i32 = 54;
const TOKEN_IDENT: i32 = 59;
const TOKEN_LPAREN: i32 = 82;
const TOKEN_LBRACE: i32 = 84;
const TOKEN_COLON: i32 = 91;
const TOKEN_SEMICOLON: i32 = 95;
const TOKEN_LT: i32 = 120;
const TOKEN_STRING: i32 = 130;

/**
 * Skip a top-level `struct Name[<T…>] { … }` to just after the matching `}`.
 * Entry cursor is the start of `struct`. Non-STRUCT first token: lexer
 * unmoved (C wrote `*out = lex`). After consuming STRUCT, a non-IDENT
 * leaves the lexer after `struct`. Optional `<…>` uses P1b
 * skip_generic_angle_list (entry is the start of `<`). Matching `{` is
 * consumed then skip_balanced_braces (P1b) walks the body.
 * @param lex_inout *u8 — opaque lexer (advanced past `}`, or left on the
 *   fail cursor described above)
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success / fail-leave path; 0 on null
 * PLATFORM: SHARED — product P12 B-minus; C trampoline keeps
 * `parser_asm_skip_one_struct_into_slice_c` and stashes the source for
 * the generic-bound scan before calling this.
 */
#[no_mangle]
export function parser_asm_skip_one_struct_into_c(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_STRUCT) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_LT) {
      parser_asm_skip_generic_angle_list_into_c(lex_inout, source);
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

/**
 * Skip a top-level `enum Name { … }` to just after the matching `}`.
 * Entry cursor is the start of `enum`. Non-ENUM first token: lexer
 * unmoved. After consuming ENUM, a non-IDENT leaves the lexer after
 * `enum`. Matching `{` is consumed then skip_balanced_braces.
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success / fail-leave path; 0 on null
 * PLATFORM: SHARED — product P12 B-minus; C trampoline stashes source
 * then calls this. enum_register (void* module) stays C.
 */
#[no_mangle]
export function parser_asm_skip_one_enum_into_c(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_ENUM) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LBRACE) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    parser_asm_skip_balanced_braces_into_c(lex_inout, source);
  }
  return 1;
}

/**
 * Skip a top-level `extern ["ABI"] function name(…) : Ret;` declaration.
 * Entry cursor is the start of `extern`. Optional STRING ABI marker is
 * consumed without recording abi_kind (same as the C twin). Matching
 * `(` is consumed then skip_balanced_parens (P1b). After `:`, tokens
 * are stepped until SEMICOLON / EOF; SEMICOLON is consumed. Leaves the
 * lexer after `;` (or at EOF without consuming it).
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success / fail-leave path; 0 on null
 * PLATFORM: SHARED — product P12 B-minus; parse_one_extern (arena) stays C.
 */
#[no_mangle]
export function parser_asm_skip_one_extern_into_c(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_EXTERN) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_STRING) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
    if (kind != TOKEN_FUNCTION) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
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
    while (kind != TOKEN_SEMICOLON && kind != TOKEN_EOF) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
    if (kind == TOKEN_SEMICOLON) {
      parser_asm_lex_step_kind_c(lex_inout, source);
    }
  }
  return 1;
}
