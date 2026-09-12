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

// pthin_body_tl.x — G-02f-327 P18 parser thin body_tl product bodies.
//
// 7.2.1 P18b Route C + B-minus productize (2026-09-13): after P12b
// skip_tl struct/enum/extern walks, body_tl.inc is the next still-host-cc
// product slice with a portable region. is_fn_sig_scalar is Route C
// (int32 TOKEN table). diag_skip_let_const, body_skip_let_const_then_if
// (huge already-T AUDIT nops including HARD BAN names), and
// skip_one_top_level_{let,const} are B-minus (opaque lexer + P9a
// lexer-step). body_skip reuses P14b skip_one_if_statement; do not
// duplicate that walk. By-value lexer_result returns stay as C
// trampolines in seeds/pthin_body_tl.from_x.c. P010–P014 diag reports,
// sticky globals, onefunc_param_name_dup, diag_first_ident_len
// (lexer_init + ident_len), and cfg_skip_pending (calls glue_tail
// skip_one_function_full) stay C.
// Product AUDIT_CALL is already ((void)0); the C twins keep the huge
// already-T combinator probes as cold fallback only.
// Do not wrap glue_tail scattered AUDIT as a side effect.
// Do not compile this file as a skip-include stub without bodies.
//
// Hybrid P18b: g05_try_x_to_o this file; XLANG_PTHIN_BODY_TL_BODIES_FROM_X
// skips the portable .inc region. Requires P9a bridge + P14b
// skip_one_if_statement (otherwise that would UNDEF). token.h remains
// the TOKEN_* authority via P18 C _Static_assert pins. Cold: no define,
// full .inc. Do not reuse XLANG_PTHIN_BODY_TL_FROM_X for P18b bodies.
// G.7: hybrid authority for is_fn_sig_scalar is this file; mega rest
// (parser_asm_thin_c.x) is omitted on full hybrid (G-02f-330); cold
// authority is the .inc twin. Do not compile thin_c.x as a second table.
// PLATFORM: SHARED freestanding.

/** Advance the opaque lexer one token; returns the consumed kind. */
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token kind without advancing. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
/** P14b authority: skip `if` / `else if` / `else`; entry is the `(` after `if`. */
export extern "C" function parser_asm_skip_one_if_statement_into_c(lex_inout: *u8, source: *u8): i32;

// TOKEN_* pin copies of include/token.h (133 kinds). P18 C _Static_assert
// fires if the pin drifts; do not treat these as a second enum authority.
const TOKEN_EOF: i32 = 0;
const TOKEN_LET: i32 = 2;
const TOKEN_CONST: i32 = 3;
const TOKEN_IF: i32 = 4;
const TOKEN_IDENT: i32 = 59;
const TOKEN_I32: i32 = 60;
const TOKEN_BOOL: i32 = 61;
const TOKEN_U8: i32 = 62;
const TOKEN_U32: i32 = 63;
const TOKEN_U64: i32 = 64;
const TOKEN_I64: i32 = 65;
const TOKEN_USIZE: i32 = 66;
const TOKEN_VOID: i32 = 79;
const TOKEN_LBRACKET: i32 = 86;
const TOKEN_RBRACKET: i32 = 87;
const TOKEN_COLON: i32 = 91;
const TOKEN_SEMICOLON: i32 = 95;
const TOKEN_STAR: i32 = 98;
const TOKEN_ASSIGN: i32 = 117;
const TOKEN_STRING: i32 = 130;

/**
 * True when `kind` is a function-signature scalar type token (i32/i64/
 * bool/u8/u32/u64/usize/void) or IDENT (named type in a skip walk).
 * @param kind i32 — TokenKind ordinal (token.h)
 * @return i32 — 1 if scalar-or-IDENT, 0 otherwise
 * PLATFORM: SHARED — product P18 Route C; same C name as the .inc twin.
 */
#[no_mangle]
export function parser_asm_is_fn_sig_scalar_type_token_c(kind: i32): i32 {
  if (kind == TOKEN_I32) {
    return 1;
  }
  if (kind == TOKEN_I64) {
    return 1;
  }
  if (kind == TOKEN_BOOL) {
    return 1;
  }
  if (kind == TOKEN_U8) {
    return 1;
  }
  if (kind == TOKEN_U32) {
    return 1;
  }
  if (kind == TOKEN_U64) {
    return 1;
  }
  if (kind == TOKEN_USIZE) {
    return 1;
  }
  if (kind == TOKEN_VOID) {
    return 1;
  }
  if (kind == TOKEN_IDENT) {
    return 1;
  }
  return 0;
}

/**
 * Skip consecutive `let` / `const` declarations from the first body
 * token. Entry is the start of that token. Fail-leave leaves the lexer
 * at the start of the unexpected token (IDENT/COLON/type/ASSIGN/
 * STRING/SEMICOLON). Success leaves the lexer at the start of the
 * token after the last skipped declaration so the C trampoline can
 * `lexer_next_into` to fill *out.
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success / fail-leave path; 0 on null
 * PLATFORM: SHARED — product P18 B-minus.
 */
#[no_mangle]
export function parser_asm_diag_skip_let_const_into_c(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    while (kind == TOKEN_LET || kind == TOKEN_CONST) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind != TOKEN_IDENT) {
        return 1;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind != TOKEN_COLON) {
        return 1;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_STAR) {
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind != TOKEN_IDENT) {
          return 1;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      } else if (parser_asm_is_fn_sig_scalar_type_token_c(kind) != 0) {
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind == TOKEN_LBRACKET) {
          parser_asm_lex_step_kind_c(lex_inout, source);
          kind = parser_asm_lex_peek_kind_c(lex_inout, source);
          if (kind != TOKEN_RBRACKET) {
            return 1;
          }
          parser_asm_lex_step_kind_c(lex_inout, source);
          kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        }
      } else {
        return 1;
      }
      if (kind != TOKEN_ASSIGN) {
        return 1;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      while (kind != TOKEN_SEMICOLON && kind != TOKEN_EOF) {
        if (kind == TOKEN_STRING) {
          return 1;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      }
      if (kind != TOKEN_SEMICOLON) {
        return 1;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
  }
  return 1;
}

/**
 * Skip body `let`/`const` declarations then consecutive `if` statements.
 * Calls diag_skip_let_const then, while the next token is IF, consumes
 * `if` and P14b skip_one_if_statement (entry is the `(` after `if`).
 * Leaves the lexer at the start of the token after the last skipped
 * construct (C trampoline materializes *out).
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success / fail-leave path; 0 on null
 * PLATFORM: SHARED — product P18 B-minus; do not duplicate skip_one_if.
 */
#[no_mangle]
export function parser_asm_body_skip_let_const_then_if_into_c(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  parser_asm_diag_skip_let_const_into_c(lex_inout, source);
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    while (kind == TOKEN_IF) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      parser_asm_skip_one_if_statement_into_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
  }
  return 1;
}

/**
 * Skip one top-level `let ... ;`. Entry is the start of `let`. Non-LET
 * first token: lexer unmoved (C wrote `*out = lex`). SEMICOLON is
 * consumed; EOF is not. Leaves the lexer after `;` or at EOF.
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success / fail-leave path; 0 on null
 * PLATFORM: SHARED — product P18 B-minus; C trampoline `*out = cur`.
 */
#[no_mangle]
export function parser_asm_skip_one_top_level_let_into_c(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LET) {
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

/**
 * Skip one top-level `const ... ;` (including `const x = import("path");`).
 * Same fail-leave as skip_one_top_level_let, with CONST as the keyword.
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success / fail-leave path; 0 on null
 * PLATFORM: SHARED — product P18 B-minus; C trampoline `*out = cur`.
 */
#[no_mangle]
export function parser_asm_skip_one_top_level_const_into_c(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_CONST) {
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
