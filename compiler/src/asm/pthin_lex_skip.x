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

// pthin_lex_skip.x — G-02f-281 P1 parser thin lex/skip product bodies.
//
// 7.2.1 Route C + B-minus productize (2026-09-12): the lex_skip .inc is
// the next still-host-cc product slice after stretch lite. Kind predicates
// and buf-path copies are Route C (scalar / *u8). Balanced-delim and
// generic-angle walks are B-minus (opaque lexer + lexer-step bridge),
// matching leftover skip_balanced_brackets_into. By-value lexer returns
// stay as C trampolines in seeds/pthin_lex_skip.from_x.c (language has
// no struct-by-value). skip_generic_angle_list_count (static pending-name
// tables) stays C in the .inc.
//
// Hybrid P1b: g05_try_x_to_o this file; XLANG_PTHIN_LEX_SKIP_BODIES_FROM_X
// skips the portable .inc region. token.h remains the TOKEN_* authority
// via P1 C _Static_assert pins. Cold: no define, full .inc stays.
// PLATFORM: SHARED freestanding.

/** Advance the opaque lexer one token; returns the consumed kind. */
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token kind without advancing. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
/** Read / write the restore trio (pos, line, col). */
export extern "C" function parser_asm_lex_pos_c(lex: *u8): usize;
export extern "C" function parser_asm_lex_set_pos_c(lex: *u8, pos: usize): void;
export extern "C" function parser_asm_lex_line_c(lex: *u8): i32;
export extern "C" function parser_asm_lex_set_line_c(lex: *u8, line: i32): void;
export extern "C" function parser_asm_lex_col_c(lex: *u8): i32;
export extern "C" function parser_asm_lex_set_col_c(lex: *u8, col: i32): void;

// TOKEN_* pin copies of include/token.h (133 kinds). P1 C _Static_assert
// fires if the pin drifts; do not treat these as a second enum authority.
const TOKEN_EOF: i32 = 0;
const TOKEN_FUNCTION: i32 = 1;
const TOKEN_LET: i32 = 2;
const TOKEN_CONST: i32 = 3;
const TOKEN_IF: i32 = 4;
const TOKEN_ELSE: i32 = 5;
const TOKEN_WHILE: i32 = 6;
const TOKEN_LOOP: i32 = 7;
const TOKEN_FOR: i32 = 8;
const TOKEN_BREAK: i32 = 9;
const TOKEN_CONTINUE: i32 = 10;
const TOKEN_RETURN: i32 = 11;
const TOKEN_MATCH: i32 = 18;
const TOKEN_STRUCT: i32 = 19;
const TOKEN_TYPE: i32 = 20;
const TOKEN_ENUM: i32 = 47;
const TOKEN_GOTO: i32 = 48;
const TOKEN_TRAIT: i32 = 49;
const TOKEN_IMPL: i32 = 50;
const TOKEN_IMPORT: i32 = 53;
const TOKEN_EXTERN: i32 = 54;
const TOKEN_IDENT: i32 = 59;
const TOKEN_I32: i32 = 60;
const TOKEN_BOOL: i32 = 61;
const TOKEN_U8: i32 = 62;
const TOKEN_U32: i32 = 63;
const TOKEN_U64: i32 = 64;
const TOKEN_I64: i32 = 65;
const TOKEN_USIZE: i32 = 66;
const TOKEN_ISIZE: i32 = 67;
const TOKEN_F32: i32 = 77;
const TOKEN_F64: i32 = 78;
const TOKEN_VOID: i32 = 79;
const TOKEN_LPAREN: i32 = 82;
const TOKEN_RPAREN: i32 = 83;
const TOKEN_LBRACE: i32 = 84;
const TOKEN_RBRACE: i32 = 85;
const TOKEN_COMMA: i32 = 90;
const TOKEN_COLON: i32 = 91;
const TOKEN_SEMICOLON: i32 = 95;
const TOKEN_PLUS_EQ: i32 = 106;
const TOKEN_MINUS_EQ: i32 = 107;
const TOKEN_STAR_EQ: i32 = 108;
const TOKEN_SLASH_EQ: i32 = 109;
const TOKEN_PERCENT_EQ: i32 = 110;
const TOKEN_AMP_EQ: i32 = 111;
const TOKEN_PIPE_EQ: i32 = 112;
const TOKEN_CARET_EQ: i32 = 113;
const TOKEN_LSHIFT_EQ: i32 = 114;
const TOKEN_RSHIFT_EQ: i32 = 115;
const TOKEN_LT: i32 = 120;
const TOKEN_GT: i32 = 121;
const TOKEN_EXPORT: i32 = 131;

/**
 * True when `kind` is a compound-assign token (`+=` … `>>=`).
 * @param kind i32 — lexer token kind
 * @return i32 — 1 if compound-assign; 0 otherwise
 * PLATFORM: SHARED — product P1; TOKEN_* pins gated by P1 C asserts.
 */
#[no_mangle]
export function parser_asm_is_compound_assign_token_c(kind: i32): i32 {
  if (kind == TOKEN_PLUS_EQ || kind == TOKEN_MINUS_EQ || kind == TOKEN_STAR_EQ) {
    return 1;
  }
  if (kind == TOKEN_SLASH_EQ || kind == TOKEN_PERCENT_EQ || kind == TOKEN_AMP_EQ) {
    return 1;
  }
  if (kind == TOKEN_PIPE_EQ || kind == TOKEN_CARET_EQ) {
    return 1;
  }
  if (kind == TOKEN_LSHIFT_EQ || kind == TOKEN_RSHIFT_EQ) {
    return 1;
  }
  return 0;
}

/**
 * True when `kind` can follow `*` as a pointee type token.
 * @param kind i32 — lexer token kind
 * @return i32 — 1 if pointee type; 0 otherwise
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_is_pointee_type_token_c(kind: i32): i32 {
  if (kind == TOKEN_IDENT) {
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
  return 0;
}

/**
 * Tokens that cannot appear inside a type-argument list `<...>` at any
 * depth. Without this gate, skip_generic_angle_list is greedy across
 * statement boundaries (wave446: `if (pos < n)` walked to a later `>`).
 * @param k i32 — lexer token kind
 * @return i32 — 1 if a statement boundary; 0 otherwise
 * PLATFORM: SHARED — was `static` in the C slice; hybrid exports so the
 * remaining count walk in the .inc calls this one authority.
 */
#[no_mangle]
export function parser_asm_angle_list_token_is_stmt_boundary_c(k: i32): i32 {
  if (k == TOKEN_LBRACE || k == TOKEN_RBRACE) {
    return 1;
  }
  if (k == TOKEN_SEMICOLON) {
    return 1;
  }
  if (k == TOKEN_IF || k == TOKEN_ELSE || k == TOKEN_WHILE || k == TOKEN_LOOP) {
    return 1;
  }
  if (k == TOKEN_FOR || k == TOKEN_MATCH) {
    return 1;
  }
  if (k == TOKEN_RETURN || k == TOKEN_LET || k == TOKEN_CONST) {
    return 1;
  }
  if (k == TOKEN_BREAK || k == TOKEN_CONTINUE || k == TOKEN_GOTO) {
    return 1;
  }
  if (k == TOKEN_FUNCTION || k == TOKEN_STRUCT || k == TOKEN_ENUM) {
    return 1;
  }
  if (k == TOKEN_TRAIT || k == TOKEN_IMPL || k == TOKEN_TYPE) {
    return 1;
  }
  if (k == TOKEN_IMPORT || k == TOKEN_EXTERN || k == TOKEN_EXPORT) {
    return 1;
  }
  return 0;
}

/**
 * Copy `nlen` bytes from `source[start..)` into `out`. Bytes past
 * `source_len` are skipped (not zero-filled).
 * @param source *u8 — source bytes; null is a no-op
 * @param source_len i32 — source length; compared as usize against start+i
 * @param start usize — first source byte
 * @param nlen i32 — byte count; <= 0 is a no-op
 * @param out *u8 — destination; null is a no-op
 * PLATFORM: SHARED — buf-path authority; slice wrappers stay C trampolines.
 */
#[no_mangle]
export function parser_asm_copy_slice_to_name64_buf_c(source: *u8, source_len: i32, start: usize, nlen: i32, out: *u8): void {
  let i: i32 = 0;
  let off: usize = 0;
  let slen: usize = 0;
  let c: u8 = 0;
  if (source == 0 as *u8 || out == 0 as *u8 || nlen <= 0) {
    return;
  }
  slen = source_len as usize;
  while (i < nlen) {
    off = start + i as usize;
    if (off < slen) {
      unsafe {
        c = source[off];
        out[i] = c;
      }
    }
    i = i + 1;
  }
}

/**
 * Copy `nlen` bytes ending at `end_pos` into `out` (name64 buf path).
 * Unsigned `end_pos - nlen` matches the C wrap if end_pos < nlen.
 * @param source *u8 — source bytes
 * @param source_len i32 — source length
 * @param end_pos usize — one-past-last source byte
 * @param nlen i32 — byte count; <= 0 is a no-op
 * @param out *u8 — destination
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_copy_slice_to_name64_at_end_buf_c(source: *u8, source_len: i32, end_pos: usize, nlen: i32, out: *u8): void {
  if (source == 0 as *u8 || out == 0 as *u8 || nlen <= 0) {
    return;
  }
  parser_asm_copy_slice_to_name64_buf_c(source, source_len, end_pos - nlen as usize, nlen, out);
}

/**
 * Fill a 256-byte param/name row from `source[start..)`. Bytes past
 * `nlen` or `source_len` are written as 0 (Cap 4.2.8 row width).
 * @param source *u8 — source bytes; null zeros the row
 * @param source_len i32 — source length
 * @param start usize — first source byte
 * @param nlen i32 — payload length
 * @param out *u8 — destination; must be >= 256 bytes; null is a no-op
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_copy_slice_to_param32_buf_c(source: *u8, source_len: i32, start: usize, nlen: i32, out: *u8): void {
  let i: i32 = 0;
  let off: usize = 0;
  let slen: usize = 0;
  let c: u8 = 0;
  if (out == 0 as *u8) {
    return;
  }
  slen = source_len as usize;
  while (i < 256) {
    if (i < nlen && source != 0 as *u8) {
      off = start + i as usize;
      if (off < slen) {
        unsafe {
          c = source[off];
          out[i] = c;
        }
        i = i + 1;
        continue;
      }
    }
    unsafe { out[i] = 0; }
    i = i + 1;
  }
}

/**
 * Fill a 256-byte param/name row from the `nlen` bytes ending at `end_pos`.
 * @param source *u8 — source bytes
 * @param source_len i32 — source length
 * @param end_pos usize — one-past-last source byte
 * @param nlen i32 — payload length
 * @param out *u8 — destination; null is a no-op
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_copy_slice_to_param32_at_end_buf_c(source: *u8, source_len: i32, end_pos: usize, nlen: i32, out: *u8): void {
  if (out == 0 as *u8) {
    return;
  }
  parser_asm_copy_slice_to_param32_buf_c(source, source_len, end_pos - nlen as usize, nlen, out);
}

/**
 * In-place skip of a balanced `(..)` group. Caller has already consumed
 * the opening '(' (depth starts at 1). Peek+step matches leftover
 * skip_balanced_brackets_into. Matching ')' leaves the lexer after that
 * token; EOF leaves the cursor unmoved from the EOF peek (C twin wrote
 * the pre-next lex, which is the same when next_into does not advance
 * past EOF). Product AUDIT_CALL is already `((void)0)` so this body does
 * not emit audit probes.
 * @param lex_inout *u8 — opaque lexer (advanced past the matching ')')
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success path (including EOF); 0 on null
 * PLATFORM: SHARED — product P1 B-minus.
 */
#[no_mangle]
export function parser_asm_skip_balanced_parens_into_c(lex_inout: *u8, source: *u8): i32 {
  let depth: i32 = 0;
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    depth = 1;
    while (depth > 0) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_LPAREN) {
        depth = depth + 1;
        parser_asm_lex_step_kind_c(lex_inout, source);
        continue;
      }
      if (kind == TOKEN_RPAREN) {
        depth = depth - 1;
        parser_asm_lex_step_kind_c(lex_inout, source);
        if (depth == 0) {
          return 1;
        }
        continue;
      }
      if (kind == TOKEN_EOF) {
        return 1;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
    }
  }
  return 1;
}

/**
 * In-place skip of a balanced `{..}` group. Caller has already consumed
 * the opening '{' (depth starts at 1). Same peek+step contract as parens.
 * @param lex_inout *u8 — opaque lexer (advanced past the matching '}')
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success path (including EOF); 0 on null
 * PLATFORM: SHARED — product P1 B-minus.
 */
#[no_mangle]
export function parser_asm_skip_balanced_braces_into_c(lex_inout: *u8, source: *u8): i32 {
  let depth: i32 = 0;
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    depth = 1;
    while (depth > 0) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_LBRACE) {
        depth = depth + 1;
        parser_asm_lex_step_kind_c(lex_inout, source);
        continue;
      }
      if (kind == TOKEN_RBRACE) {
        depth = depth - 1;
        parser_asm_lex_step_kind_c(lex_inout, source);
        if (depth == 0) {
          return 1;
        }
        continue;
      }
      if (kind == TOKEN_EOF) {
        return 1;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
    }
  }
  return 1;
}

/**
 * Skip `<T>` / `<T,E,...>` generic type-arg lists (nested `<>` ok).
 * On success the lexer is past the matching `>`. On EOF / statement
 * boundary / depth-1 `)` the restore trio snaps back to the entry
 * cursor so the caller leaves `<` for relcompare (wave446).
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @return i32 — 1 on either success or restore; 0 on null
 * PLATFORM: SHARED — product P1 B-minus; count+pending capture stays C.
 */
#[no_mangle]
export function parser_asm_skip_generic_angle_list_into_c(lex_inout: *u8, source: *u8): i32 {
  let pos0: usize = 0;
  let line0: i32 = 0;
  let col0: i32 = 0;
  let depth: i32 = 0;
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    pos0 = parser_asm_lex_pos_c(lex_inout);
    line0 = parser_asm_lex_line_c(lex_inout);
    col0 = parser_asm_lex_col_c(lex_inout);
    depth = 0;
    while (true) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_LT) {
        depth = depth + 1;
        parser_asm_lex_step_kind_c(lex_inout, source);
        continue;
      }
      if (kind == TOKEN_GT) {
        depth = depth - 1;
        parser_asm_lex_step_kind_c(lex_inout, source);
        if (depth <= 0) {
          return 1;
        }
        continue;
      }
      if (kind == TOKEN_EOF) {
        parser_asm_lex_set_pos_c(lex_inout, pos0);
        parser_asm_lex_set_line_c(lex_inout, line0);
        parser_asm_lex_set_col_c(lex_inout, col0);
        return 1;
      }
      if (parser_asm_angle_list_token_is_stmt_boundary_c(kind) != 0) {
        parser_asm_lex_set_pos_c(lex_inout, pos0);
        parser_asm_lex_set_line_c(lex_inout, line0);
        parser_asm_lex_set_col_c(lex_inout, col0);
        return 1;
      }
      if (depth == 1 && kind == TOKEN_RPAREN) {
        parser_asm_lex_set_pos_c(lex_inout, pos0);
        parser_asm_lex_set_line_c(lex_inout, line0);
        parser_asm_lex_set_col_c(lex_inout, col0);
        return 1;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
    }
  }
  return 1;
}
