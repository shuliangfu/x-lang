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
// no struct-by-value).
//
// 7.2.1 P1c B-minus (2026-09-13): 有则补全 this file with
// skip_generic_angle_list_count. The walk is the into skip plus
// top-level arg counting and IDENT capture at declaration position.
// Language has no global u8[8][64]; dest buffers carry the 8 name
// rows and lens, and the C trampoline writes g_gp_pending_*.
// register_pending stays C (reads those statics). Do not duplicate
// skip_generic_angle_list_into (this export inspects tokens the
// into skip does not). Do not open a new P-lane.
//
// 7.2.1 P1d B-minus (2026-09-13): 有则补全 this file with
// advance_past_stmt_semicolon + advance_past_cond_rparen. The C
// twins live in helpers.inc (P19); this file is the skip/ASI
// authority (P1 already has the P9a lexer-step bridge). Do not add
// P9a as a hard gate to P19 (portable kind/copy stay independent).
// Do not merge helpers ident_is_unsafe_stmt into P4b buf probes
// (by-value lexer_result vs buf-path); the 6-byte `unsafe` check
// here is file-local for ASI only. Do not open a new P-lane.
// C trampolines in helpers.inc replay lexer_next_into to fill
// *r_out (language has no struct-by-value lexer_result).
//
// 7.2.1 P1e B-minus (2026-09-13): 有则补全 this file with
// parse_peek_function_name + first_token_kind. Both are helpers.inc
// leftovers (buf peek-name dest-buffer; init+one-step kind). Do not
// add P9a as a hard gate to P19. Do not wrap leftover peek-name
// AUDIT (stays in the cold twin). Do not open a new P-lane.
// Language has no lexer_init; the first_token C trampoline inits
// then calls .x. parse_peek dest `out` is C-owned (no local u8[N]).
// SPAWN writes four bytes `spaw` and returns 5 (match the C twin).
//
// Hybrid P1b/P1c/P1d/P1e: g05_try_x_to_o this file; XLANG_PTHIN_LEX_SKIP_BODIES_FROM_X
// skips the portable .inc region and the helpers.inc ASI/peek twins.
// token.h remains the TOKEN_* authority via P1 C _Static_assert pins.
// Cold: no define, full .inc stays. Do not reuse
// XLANG_PTHIN_LEX_SKIP_FROM_X for P1b/P1c/P1d/P1e bodies.
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
/** Peek the next token's ident_len without advancing. */
export extern "C" function parser_asm_lex_peek_ident_len_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token's token_start without advancing. */
export extern "C" function parser_asm_lex_peek_token_start_c(lex_inout: *u8, source: *u8): usize;
/** Source slice data pointer (for IDENT capture copy). */
export extern "C" function parser_asm_lex_source_data_c(source: *u8): *u8;
/** Source slice length. */
export extern "C" function parser_asm_lex_source_length_c(source: *u8): usize;

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
const TOKEN_PANIC: i32 = 12;
const TOKEN_DEFER: i32 = 13;
const TOKEN_MATCH: i32 = 18;
const TOKEN_STRUCT: i32 = 19;
const TOKEN_TYPE: i32 = 20;
const TOKEN_ENUM: i32 = 47;
const TOKEN_GOTO: i32 = 48;
const TOKEN_TRAIT: i32 = 49;
const TOKEN_IMPL: i32 = 50;
const TOKEN_SELF: i32 = 51;
const TOKEN_IMPORT: i32 = 53;
const TOKEN_EXTERN: i32 = 54;
const TOKEN_SPAWN: i32 = 58;
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
const TOKEN_STAR: i32 = 98;
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
const GP_PENDING_MAX: i32 = 8;
const GP_NAME_CAP: i32 = 64;

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
 * PLATFORM: SHARED — product P1 B-minus; P1c count is a sibling export.
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

/**
 * Skip `<T>` / `<T, E, ...>` and count top-level type args, capturing
 * declaration-position IDENT names into dest buffers (wave455).
 * Entry is the start of `<`. Success leaves the lexer past the matching
 * `>`. Abort (EOF / statement boundary / depth-1 `)`) restores the
 * entry cursor, writes count=0 and pending_n=0, so the caller leaves
 * `<` for relcompare. count is 0 for empty `<>`; otherwise top-level
 * comma-count plus one. IDENT at depth 1 while expecting a type-param
 * name is copied (cap 63) into names[i*64..]; a following `:` bound
 * clears the expect flag so the trait name is not captured.
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @param count *i32 — out slot; 0 on abort / empty list
 * @param names *u8 — dest 8*64 name rows; trampoline owns the buffer
 * @param lenses *i32 — dest 8 lens slots
 * @param pending_n *i32 — out slot; number of captured names (0..8)
 * @return i32 — 1 on success or restore; 0 on null
 * PLATFORM: SHARED — product P1c B-minus; C trampoline keeps
 * `parser_asm_skip_generic_angle_list_count_into_slice_c` and writes
 * g_gp_pending_*. Do not duplicate skip_generic_angle_list_into_c.
 */
#[no_mangle]
export function parser_asm_skip_generic_angle_list_count_into_c(lex_inout: *u8, source: *u8, count: *i32, names: *u8, lenses: *i32, pending_n: *i32): i32 {
  let pos0: usize = 0;
  let line0: i32 = 0;
  let col0: i32 = 0;
  let depth: i32 = 0;
  let kind: i32 = 0;
  let top_count: i32 = 0;
  let saw_any: i32 = 0;
  let expect_tp: i32 = 0;
  let pn: i32 = 0;
  let pl: i32 = 0;
  let ts: usize = 0;
  let data: *u8 = 0 as *u8;
  let slen_us: usize = 0;
  let slen: i32 = 0;
  let zi: i32 = 0;
  let slot_off: usize = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8 || count == 0 as *i32 || names == 0 as *u8 || lenses == 0 as *i32 || pending_n == 0 as *i32) {
    return 0;
  }
  unsafe {
    count[0] = 0;
    pending_n[0] = 0;
    pos0 = parser_asm_lex_pos_c(lex_inout);
    line0 = parser_asm_lex_line_c(lex_inout);
    col0 = parser_asm_lex_col_c(lex_inout);
    data = parser_asm_lex_source_data_c(source);
    slen_us = parser_asm_lex_source_length_c(source);
    if (slen_us > 2147483647 as usize) {
      slen = 2147483647;
    } else {
      slen = slen_us as i32;
    }
    depth = 0;
    top_count = 0;
    saw_any = 0;
    expect_tp = 0;
    pn = 0;
    while (true) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_LT) {
        depth = depth + 1;
        if (depth == 1) {
          expect_tp = 1;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        continue;
      }
      if (kind == TOKEN_GT) {
        depth = depth - 1;
        parser_asm_lex_step_kind_c(lex_inout, source);
        if (depth <= 0) {
          if (saw_any != 0) {
            count[0] = top_count + 1;
          } else {
            count[0] = 0;
          }
          pending_n[0] = pn;
          return 1;
        }
        continue;
      }
      if (kind == TOKEN_COMMA) {
        if (depth == 1) {
          top_count = top_count + 1;
          expect_tp = 1;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        continue;
      }
      if (kind == TOKEN_COLON) {
        if (depth == 1) {
          expect_tp = 0;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        continue;
      }
      if (kind == TOKEN_IDENT && depth == 1 && expect_tp != 0) {
        if (pn < GP_PENDING_MAX) {
          pl = parser_asm_lex_peek_ident_len_c(lex_inout, source);
          if (pl > 63) {
            pl = 63;
          }
          ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
          if (ts == 0 as usize) {
            ts = parser_asm_lex_pos_c(lex_inout);
          }
          slot_off = (pn as usize) * (GP_NAME_CAP as usize);
          zi = 0;
          while (zi < GP_NAME_CAP) {
            names[slot_off + zi as usize] = 0;
            zi = zi + 1;
          }
          if (pl > 0 && data != 0 as *u8) {
            parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, pl, names + slot_off);
          }
          lenses[pn] = pl;
          pn = pn + 1;
        }
        expect_tp = 0;
        saw_any = 1;
        parser_asm_lex_step_kind_c(lex_inout, source);
        continue;
      }
      if (kind == TOKEN_EOF) {
        parser_asm_lex_set_pos_c(lex_inout, pos0);
        parser_asm_lex_set_line_c(lex_inout, line0);
        parser_asm_lex_set_col_c(lex_inout, col0);
        count[0] = 0;
        pending_n[0] = 0;
        return 1;
      }
      if (parser_asm_angle_list_token_is_stmt_boundary_c(kind) != 0) {
        parser_asm_lex_set_pos_c(lex_inout, pos0);
        parser_asm_lex_set_line_c(lex_inout, line0);
        parser_asm_lex_set_col_c(lex_inout, col0);
        count[0] = 0;
        pending_n[0] = 0;
        return 1;
      }
      if (depth == 1 && kind == TOKEN_RPAREN) {
        parser_asm_lex_set_pos_c(lex_inout, pos0);
        parser_asm_lex_set_line_c(lex_inout, line0);
        parser_asm_lex_set_col_c(lex_inout, col0);
        count[0] = 0;
        pending_n[0] = 0;
        return 1;
      }
      if (depth == 1) {
        saw_any = 1;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
    }
  }
  return 1;
}

/**
 * True when IDENT spelling at `token_start` is the six bytes `unsafe`.
 * File-local: ASI stmt-head only. Do not export (P4b buf remains the
 * primary-parse ident-spelling authority; helpers ident_is_unsafe_stmt
 * stays the by-value lexer_result wrapper).
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT length; must be 6
 * @return i32 — 1 if the span is `unsafe`; 0 otherwise
 * PLATFORM: SHARED — ASI helper; not a second ident-probe table.
 */
function parser_asm_lex_skip_ident_is_unsafe_stmt(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (data == 0 as *u8 || ident_len != 6) {
    return 0;
  }
  if (token_start + 6 as usize > length) {
    return 0;
  }
  unsafe {
    if (data[token_start] != 117) {
      return 0;
    }
    if (data[token_start + 1 as usize] != 110) {
      return 0;
    }
    if (data[token_start + 2 as usize] != 115) {
      return 0;
    }
    if (data[token_start + 3 as usize] != 97) {
      return 0;
    }
    if (data[token_start + 4 as usize] != 102) {
      return 0;
    }
    if (data[token_start + 5 as usize] != 101) {
      return 0;
    }
  }
  return 1;
}

/**
 * True when `k` is a wave654 ASI following-stmt head (not `;`).
 * IDENT is included: expr parse already finished, so a following IDENT
 * cannot continue the prior expr.
 * @param k i32 — lexer token kind
 * @return i32 — 1 if ASI-legal stmt head; 0 otherwise
 * PLATFORM: SHARED.
 */
function parser_asm_lex_skip_is_asi_stmt_head_kind(k: i32): i32 {
  if (k == TOKEN_LET || k == TOKEN_CONST || k == TOKEN_RETURN) {
    return 1;
  }
  if (k == TOKEN_IF || k == TOKEN_WHILE || k == TOKEN_FOR) {
    return 1;
  }
  if (k == TOKEN_RBRACE || k == TOKEN_IDENT || k == TOKEN_BREAK) {
    return 1;
  }
  if (k == TOKEN_CONTINUE || k == TOKEN_MATCH || k == TOKEN_LOOP) {
    return 1;
  }
  if (k == TOKEN_PANIC || k == TOKEN_DEFER || k == TOKEN_GOTO) {
    return 1;
  }
  if (k == TOKEN_STAR || k == TOKEN_SELF) {
    return 1;
  }
  return 0;
}

/**
 * Consume the next token and accept it as `;` or an ASI stmt head.
 * Entry cursor is the start of the following token (C `lex` by value).
 * Always steps once. Returns 1 for `;`, `unsafe`, or the wave654
 * allowlist (LET/CONST/RETURN/IF/WHILE/FOR/RBRACE/IDENT/BREAK/
 * CONTINUE/MATCH/LOOP/PANIC/DEFER/GOTO/STAR/SELF). The C trampoline
 * in helpers.inc keeps the original name
 * `parser_asm_advance_past_stmt_semicolon_into_slice_c` and
 * materializes `*r_out` via lexer_next_into from the entry cursor.
 * @param lex_inout *u8 — opaque lexer (advanced past the following token)
 * @param source *u8 — opaque slice
 * @return i32 — 1 if the token is `;` or an ASI stmt head; 0 on null / other
 * PLATFORM: SHARED — product P1d B-minus; C twin stays in helpers.inc.
 */
#[no_mangle]
export function parser_asm_advance_past_stmt_semicolon_into_c(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  let idlen: i32 = 0;
  let tstart: usize = 0;
  let data: *u8 = 0 as *u8;
  let slen: usize = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    idlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    tstart = parser_asm_lex_peek_token_start_c(lex_inout, source);
    data = parser_asm_lex_source_data_c(source);
    slen = parser_asm_lex_source_length_c(source);
    if (tstart == 0 as usize) {
      tstart = parser_asm_lex_pos_c(lex_inout);
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    if (kind == TOKEN_SEMICOLON) {
      return 1;
    }
    if (parser_asm_lex_skip_ident_is_unsafe_stmt(data, slen, tstart, idlen) != 0) {
      return 1;
    }
    if (parser_asm_lex_skip_is_asi_stmt_head_kind(kind) != 0) {
      return 1;
    }
  }
  return 0;
}

/**
 * Consume the next token after an if/while condition: accept `)` (and
 * step the token after it) or `{` (bare `if cond {`).
 * Entry cursor is the start of the token after the condition expr.
 * Fail-leave still consumes that one token (C filled `*r_out` then
 * returned 0). Success on `)` steps a second token (C extra
 * lexer_next_into). Success on `{` leaves the lexer after `{`.
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @return i32 — 1 if `)` or `{`; 0 on null / other
 * PLATFORM: SHARED — product P1d B-minus; C trampoline keeps
 * `parser_asm_advance_past_cond_rparen_into_slice_c`.
 */
#[no_mangle]
export function parser_asm_advance_past_cond_rparen_into_c(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    parser_asm_lex_step_kind_c(lex_inout, source);
    if (kind == TOKEN_RPAREN) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      return 1;
    }
    if (kind == TOKEN_LBRACE) {
      return 1;
    }
  }
  return 0;
}

/**
 * Peek `function name` / `function spawn` from the entry cursor.
 * Entry is the start of `function` (C `lex` by value). Non-FUNCTION
 * first token: return 0 with `out` untouched. After consuming
 * FUNCTION, SPAWN writes four bytes `spaw` and returns 5 (C twin
 * does not write the fifth byte). IDENT copies `ident_len` bytes
 * via P1b copy_slice (cap 1..63). The C trampoline in helpers.inc
 * keeps `parser_asm_parse_peek_function_name_buf_c` (wraps data/len
 * as a slice; caller lex is by-value and is not written back).
 * @param lex_inout *u8 — opaque lexer (local copy; caller lex unmoved)
 * @param source *u8 — opaque slice
 * @param out *u8 — dest name bytes; caller owns; null is 0
 * @return i32 — name length (5 for spawn, ident_len for IDENT), or 0
 * PLATFORM: SHARED — product P1e B-minus; leftover AUDIT stays cold.
 */
#[no_mangle]
export function parser_asm_parse_peek_function_name_into_c(lex_inout: *u8, source: *u8, out: *u8): i32 {
  let kind: i32 = 0;
  let idlen: i32 = 0;
  let tstart: usize = 0;
  let data: *u8 = 0 as *u8;
  let slen: usize = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8 || out == 0 as *u8) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_FUNCTION) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_SPAWN) {
      out[0] = 115;
      out[1] = 112;
      out[2] = 97;
      out[3] = 119;
      return 5;
    }
    idlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    if (kind != TOKEN_IDENT || idlen <= 0 || idlen > 63) {
      return 0;
    }
    tstart = parser_asm_lex_peek_token_start_c(lex_inout, source);
    if (tstart == 0 as usize) {
      tstart = parser_asm_lex_pos_c(lex_inout);
    }
    data = parser_asm_lex_source_data_c(source);
    slen = parser_asm_lex_source_length_c(source);
    parser_asm_copy_slice_to_name64_buf_c(data, slen as i32, tstart, idlen, out);
  }
  return idlen;
}

/**
 * Return the kind of the first token at the entry cursor.
 * The C trampoline inits a fresh lexer (language has no lexer_init)
 * then calls this; a null source is TOKEN_EOF without a call.
 * @param lex_inout *u8 — opaque lexer at file start
 * @param source *u8 — opaque slice
 * @return i32 — first token kind, or TOKEN_EOF on null
 * PLATFORM: SHARED — product P1e B-minus; C trampoline keeps
 * `parser_asm_first_token_kind_slice_c`. buf stays a wrap over slice.
 */
#[no_mangle]
export function parser_asm_first_token_kind_into_c(lex_inout: *u8, source: *u8): i32 {
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return TOKEN_EOF;
  }
  unsafe {
    return parser_asm_lex_step_kind_c(lex_inout, source);
  }
}
