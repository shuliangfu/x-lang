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

// pthin_diag_late.x — G-02f-326 P17 parser thin diag_late product bodies.
//
// 7.2.1 P17b B-minus productize (2026-09-13): after P15b library_scan,
// diag_late.inc is the next still-host-cc product slice whose walks are
// portable. after_structs is a peek loop over STRUCT calling P12b
// skip_one_struct (plus C stash so generic-bound scan still sees the
// file). fail_at_token_kind is a sequential token walk of one function
// header/body using P18b is_fn_sig_scalar + body_skip and P1b is_pointee.
// Reuse the P9a lexer-step bridge. diag_lex_after_imports stays C
// (lexer_init + skip_imports; language has no struct-by-value init).
// P17c G.7: diag_skip_let_const_buf is a C trampoline over P18b
// diag_skip_let_const_into (same pattern as body_skip_buf). Do not
// add a second .x export for the buf path (would be dual-authority).
// Product AUDIT_CALL is already ((void)0); the C twins keep the
// already-T combinator probes as cold fallback only. Contiguous
// already-T AUDIT prefixes on the buf wrappers are compiled only
// under XLANG_PARSER_STRETCH_AUDIT (same-slice P4ub/P15b pattern).
// Do not duplicate skip_one_struct (authority = pthin_skip_tl.x).
// Do not duplicate body_skip / is_fn_sig_scalar (authority = pthin_body_tl.x).
// Do not duplicate is_pointee (authority = pthin_lex_skip.x).
// Do not wrap leftover scattered AUDIT. Do not wrap skip_one_trait/impl.
// Do not compile this file as a skip-include stub without bodies.
//
// Hybrid P17b: g05_try_x_to_o this file;
// XLANG_PTHIN_DIAG_LATE_BODIES_FROM_X skips the portable .inc region.
// Requires P9a + P1b + P12b + P18b (otherwise peek/step/pointee/
// skip_one_struct/scalar/body_skip would UNDEF). token.h remains the
// TOKEN_* authority via P17 C _Static_assert pins. Cold: no define,
// full .inc. Do not reuse XLANG_PTHIN_DIAG_LATE_FROM_X for P17b bodies.
// PLATFORM: SHARED freestanding.

/** Advance the opaque lexer one token; returns the consumed kind. */
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token kind without advancing. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token's ident_len without advancing. */
export extern "C" function parser_asm_lex_peek_ident_len_c(lex_inout: *u8, source: *u8): i32;
/** P12b authority: skip `struct Name { ... }` from the start of STRUCT. */
export extern "C" function parser_asm_skip_one_struct_into_c(lex_inout: *u8, source: *u8): i32;
/** P12 C authority: stash the file slice for the generic-bound scan. */
export extern "C" function xlang_generic_bound_stash_source_c(source: *u8): void;
/** P18b authority: 1 iff kind is a fn-sig scalar or IDENT. */
export extern "C" function parser_asm_is_fn_sig_scalar_type_token_c(kind: i32): i32;
/** P1b authority: 1 iff kind is a legal `*` pointee token. */
export extern "C" function parser_asm_is_pointee_type_token_c(kind: i32): i32;
/** P18b authority: skip body let/const then if; leaves at the next token. */
export extern "C" function parser_asm_body_skip_let_const_then_if_into_c(lex_inout: *u8, source: *u8): i32;

// TOKEN_* pin copies of include/token.h (133 kinds). P17 C _Static_assert
// fires if the pin drifts; do not treat these as a second enum authority.
const TOKEN_EOF: i32 = 0;
const TOKEN_FUNCTION: i32 = 1;
const TOKEN_RETURN: i32 = 11;
const TOKEN_STRUCT: i32 = 19;
const TOKEN_IDENT: i32 = 59;
const TOKEN_U8: i32 = 62;
const TOKEN_INT: i32 = 80;
const TOKEN_LPAREN: i32 = 82;
const TOKEN_RPAREN: i32 = 83;
const TOKEN_LBRACE: i32 = 84;
const TOKEN_RBRACE: i32 = 85;
const TOKEN_LBRACKET: i32 = 86;
const TOKEN_RBRACKET: i32 = 87;
const TOKEN_COMMA: i32 = 90;
const TOKEN_COLON: i32 = 91;
const TOKEN_SEMICOLON: i32 = 95;
const TOKEN_STAR: i32 = 98;

/**
 * Consume one parameter type: fn-sig scalar/IDENT, `*Pointee`, or `[N]u8`.
 * Fail-leave leaves the lexer at the start of the unexpected token.
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @return i32 — 1 if a type was consumed; 0 on mismatch
 */
function parser_asm_diag_late_skip_param_type(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  let ok: i32 = 0;
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    ok = parser_asm_is_fn_sig_scalar_type_token_c(kind);
    if (ok != 0) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      return 1;
    }
    if (kind == TOKEN_STAR) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      ok = parser_asm_is_pointee_type_token_c(kind);
      if (ok == 0) {
        return 0;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      return 1;
    }
    if (kind == TOKEN_LBRACKET) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind != TOKEN_INT) {
        return 0;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind != TOKEN_RBRACKET) {
        return 0;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind != TOKEN_U8) {
        return 0;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      return 1;
    }
  }
  return 0;
}

/**
 * Consume one return type: fn-sig scalar/IDENT or `*Pointee`.
 * The C twin does not accept `[N]u8` here (that shape is params only).
 * Fail-leave leaves the lexer at the start of the unexpected token.
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @return i32 — 1 if a type was consumed; 0 on mismatch
 */
function parser_asm_diag_late_skip_ret_type(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  let ok: i32 = 0;
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    ok = parser_asm_is_fn_sig_scalar_type_token_c(kind);
    if (ok != 0) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      return 1;
    }
    if (kind == TOKEN_STAR) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      ok = parser_asm_is_pointee_type_token_c(kind);
      if (ok == 0) {
        return 0;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      return 1;
    }
  }
  return 0;
}

/**
 * Skip consecutive top-level `struct` items. Entry is the start of the
 * first token (typically after imports). While the next token is STRUCT,
 * stash the source (C skip_one_struct trampoline always stashes for the
 * generic-bound scan) then P12b skip_one_struct. Leaves the lexer at
 * the start of the first non-STRUCT token. The C trampoline then
 * `lexer_next_into` to fill a by-value LexerResult.
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success path; 0 on null
 * PLATFORM: SHARED — product P17 B-minus; C trampoline keeps
 * `parser_asm_diag_after_imports_then_structs_slice_c`.
 */
#[no_mangle]
export function parser_asm_diag_after_imports_then_structs_into_c(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    while (kind == TOKEN_STRUCT) {
      xlang_generic_bound_stash_source_c(source);
      parser_asm_skip_one_struct_into_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
  }
  return 1;
}

/**
 * Walk one `function` header and a tiny body, returning the first
 * unexpected token kind (or -1 on a successful `return N;` / bare INT
 * body). Entry is the start of the first token after imports (C
 * trampoline runs diag_lex_after_imports first). Calls after_structs
 * then requires FUNCTION IDENT `(` params `)` `:` ret `{` body.
 * Function-name ident_len must be in 1..63. Param types accept
 * scalar/IDENT, `*T`, and `[N]u8`; the return type does not accept
 * `[N]u8` (match the C twin). Body skip is P18b (lets/consts/ifs);
 * then INT `}` or RETURN INT [`;`] `}`.
 * @param lex_inout *u8 — opaque lexer (advanced along the walk; callers
 *   of the C name only consume the returned kind)
 * @param source *u8 — opaque slice
 * @return i32 — first failing TokenKind, TOKEN_EOF on null, or -1 ok
 * PLATFORM: SHARED — product P17 B-minus; C trampoline keeps
 * `parser_asm_diag_fail_at_token_kind_slice_c`.
 */
#[no_mangle]
export function parser_asm_diag_fail_at_token_kind_from_lex_c(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  let nlen: i32 = 0;
  let ok: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return TOKEN_EOF;
  }
  parser_asm_diag_after_imports_then_structs_into_c(lex_inout, source);
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_FUNCTION) {
      return kind;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      return kind;
    }
    nlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    if (nlen <= 0 || nlen > 63) {
      return kind;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LPAREN) {
      return kind;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_RPAREN) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    } else {
      while (kind == TOKEN_IDENT) {
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind != TOKEN_COLON) {
          return kind;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        ok = parser_asm_diag_late_skip_param_type(lex_inout, source);
        if (ok == 0) {
          kind = parser_asm_lex_peek_kind_c(lex_inout, source);
          return kind;
        }
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind == TOKEN_COMMA) {
          parser_asm_lex_step_kind_c(lex_inout, source);
          kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        }
      }
      if (kind != TOKEN_RPAREN) {
        return kind;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
    if (kind != TOKEN_COLON) {
      return kind;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    ok = parser_asm_diag_late_skip_ret_type(lex_inout, source);
    if (ok == 0) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      return kind;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LBRACE) {
      return kind;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    parser_asm_body_skip_let_const_then_if_into_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_INT) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind != TOKEN_RBRACE) {
        return kind;
      }
      return -1;
    }
    if (kind == TOKEN_RETURN) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind != TOKEN_INT) {
        return kind;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind != TOKEN_RBRACE && kind != TOKEN_SEMICOLON) {
        return kind;
      }
      if (kind == TOKEN_SEMICOLON) {
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind != TOKEN_RBRACE) {
          return kind;
        }
      }
      return -1;
    }
  }
  return kind;
}
