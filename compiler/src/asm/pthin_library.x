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

// pthin_library.x — G-02f-324 P15 parser thin library product bodies.
//
// 7.2.1 P15b B-minus productize (2026-09-13): after P5c scan_sync,
// library_wrap.inc is the next still-host-cc product slice whose scan
// walk is portable. parse_one_function_library_scan is a sequential
// token walk (function / spawn-or-IDENT / (param: Type) / :Ret { return
// p.field == E.v; }) that writes name buffers without building AST.
// Reuse the P9a lexer-step bridge and P1b buf-path copies. Arena
// parse_one_function_library_into / buf stay C. lex_from_lr / try_skip /
// library field copies stay C.
// Product AUDIT_CALL is already ((void)0); the C twin keeps the huge
// already-T combinator probes as cold fallback only. Contiguous
// already-T AUDIT prefixes on the into/buf wrappers are compiled only
// under XLANG_PARSER_STRETCH_AUDIT (same-slice P4ub/P5b/P11b pattern).
// Do not duplicate copy_slice (authority = pthin_lex_skip.x).
// Do not wrap leftover scattered AUDIT. Do not wrap skip_one_trait/impl.
// Do not compile this file as a skip-include stub without bodies.
//
// Hybrid P15b: g05_try_x_to_o this file;
// XLANG_PTHIN_LIBRARY_BODIES_FROM_X skips the portable .inc region.
// Requires P9a bridge + P1b copies (otherwise peek/step/copy would
// UNDEF). token.h remains the TOKEN_* authority via P15 C
// _Static_assert pins. Cold: no define, full .inc. Do not reuse
// XLANG_PTHIN_LIBRARY_FROM_X for P15b bodies.
// PLATFORM: SHARED freestanding.

/** Advance the opaque lexer one token; returns the consumed kind. */
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token kind without advancing. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token's ident_len without advancing. */
export extern "C" function parser_asm_lex_peek_ident_len_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token's token_start without advancing. */
export extern "C" function parser_asm_lex_peek_token_start_c(lex_inout: *u8, source: *u8): usize;
/** Read the restore pos (used as copy-at-end end_pos after step). */
export extern "C" function parser_asm_lex_pos_c(lex: *u8): usize;
/** P1b authority: copy nlen bytes from data[start..) into dest. */
export extern "C" function parser_asm_copy_slice_to_name64_buf_c(source: *u8, source_len: i32, start: usize, nlen: i32, out: *u8): void;
/** P1b authority: copy nlen bytes ending at end_pos into dest. */
export extern "C" function parser_asm_copy_slice_to_name64_at_end_buf_c(source: *u8, source_len: i32, end_pos: usize, nlen: i32, out: *u8): void;
/** P1b authority: fill a 256-byte row from data[start..) (zeros the tail). */
export extern "C" function parser_asm_copy_slice_to_param32_buf_c(source: *u8, source_len: i32, start: usize, nlen: i32, out: *u8): void;

// TOKEN_* pin copies of include/token.h (133 kinds). P15 C _Static_assert
// fires if the pin drifts; do not treat these as a second enum authority.
const TOKEN_FUNCTION: i32 = 1;
const TOKEN_RETURN: i32 = 11;
const TOKEN_SPAWN: i32 = 58;
const TOKEN_IDENT: i32 = 59;
const TOKEN_BOOL: i32 = 61;
const TOKEN_LPAREN: i32 = 82;
const TOKEN_RPAREN: i32 = 83;
const TOKEN_LBRACE: i32 = 84;
const TOKEN_RBRACE: i32 = 85;
const TOKEN_COLON: i32 = 91;
const TOKEN_DOT: i32 = 92;
const TOKEN_SEMICOLON: i32 = 95;
const TOKEN_EQ: i32 = 118;

/**
 * Peek `want`; if it matches, step and return 1. Fail-leave leaves the
 * lexer unmoved (C twin wrote result.next_lex = lex after a failed
 * lexer_next_into that does not consume).
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @param want i32 — expected token kind
 * @return i32 — 1 if consumed; 0 if peek mismatched
 */
function parser_asm_library_expect_kind(lex_inout: *u8, source: *u8, want: i32): i32 {
  let kind: i32 = 0;
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != want) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
  }
  return 1;
}

/**
 * Peek IDENT, write dest_len, copy from token_start via name64, then step.
 * Overflow (nlen<=0 or nlen>255) steps then fails, matching C
 * result.next_lex = r.next_lex after writing name_len.
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @param data *u8 — source bytes for the copy
 * @param slen i32 — source length
 * @param dest *u8 — destination buffer
 * @param dest_len *i32 — out length slot
 * @return i32 — 1 on copy+step; 0 on fail-leave
 */
function parser_asm_library_take_ident_name64_start(lex_inout: *u8, source: *u8, data: *u8, slen: i32, dest: *u8, dest_len: *i32): i32 {
  let kind: i32 = 0;
  let n: i32 = 0;
  let ts: usize = 0;
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      return 0;
    }
    n = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    dest_len[0] = n;
    if (n <= 0 || n > 255) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      return 0;
    }
    ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
    parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, n, dest);
    parser_asm_lex_step_kind_c(lex_inout, source);
  }
  return 1;
}

/**
 * Peek IDENT, write dest_len, copy from token_start via param32 (256-byte
 * zero tail), then step. Overflow fail-leave matches C (step then 0).
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @param data *u8 — source bytes for the copy
 * @param slen i32 — source length
 * @param dest *u8 — destination row (>=256)
 * @param dest_len *i32 — out length slot
 * @return i32 — 1 on copy+step; 0 on fail-leave
 */
function parser_asm_library_take_ident_param32(lex_inout: *u8, source: *u8, data: *u8, slen: i32, dest: *u8, dest_len: *i32): i32 {
  let kind: i32 = 0;
  let n: i32 = 0;
  let ts: usize = 0;
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      return 0;
    }
    n = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    dest_len[0] = n;
    if (n <= 0 || n > 255) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      return 0;
    }
    ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
    parser_asm_copy_slice_to_param32_buf_c(data, slen, ts, n, dest);
    parser_asm_lex_step_kind_c(lex_inout, source);
  }
  return 1;
}

/**
 * Peek IDENT, write dest_len, step, then copy nlen bytes ending at the
 * new lexer pos (C copy_slice_to_name64_at_end uses r.next_lex.pos).
 * Overflow fail-leave matches C (step then 0).
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @param data *u8 — source bytes for the copy
 * @param slen i32 — source length
 * @param dest *u8 — destination buffer
 * @param dest_len *i32 — out length slot
 * @return i32 — 1 on step+copy; 0 on fail-leave
 */
function parser_asm_library_take_ident_name64_end(lex_inout: *u8, source: *u8, data: *u8, slen: i32, dest: *u8, dest_len: *i32): i32 {
  let kind: i32 = 0;
  let n: i32 = 0;
  let end_pos: usize = 0;
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      return 0;
    }
    n = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    dest_len[0] = n;
    if (n <= 0 || n > 255) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    end_pos = parser_asm_lex_pos_c(lex_inout);
    parser_asm_copy_slice_to_name64_at_end_buf_c(data, slen, end_pos, n, dest);
  }
  return 1;
}

/**
 * Scan a library-form function (no AST): write name / param / field
 * buffers and leave the lexer after the closing brace.
 * Entry cursor is the start of `function`. Fail-leave matches C: most
 * mismatches leave the lexer at the start of the failed token;
 * ident-length overflow steps past that ident then returns 0.
 * @param lex_inout *u8 — opaque lexer (advanced on success / overflow)
 * @param source *u8 — opaque slice (lexer-step)
 * @param data *u8 — source bytes (copy); may be null (copies no-op)
 * @param slen i32 — source length for copies
 * @param name *u8 — fn name dest
 * @param name_len *i32 — fn name length out
 * @param param_name *u8 — param name dest (256-byte row)
 * @param param_name_len *i32 — param name length out
 * @param param_type_name *u8 — param type dest
 * @param param_type_len *i32 — param type length out
 * @param field_name *u8 — field dest
 * @param field_len *i32 — field length out
 * @return i32 — 1 on the library-shape success path; 0 on fail / null
 * PLATFORM: SHARED — product P15 B-minus; C trampoline keeps
 * `parser_asm_parse_one_function_library_scan_slice_c`.
 */
#[no_mangle]
export function parser_asm_parse_one_function_library_scan_into_c(
    lex_inout: *u8,
    source: *u8,
    data: *u8,
    slen: i32,
    name: *u8,
    name_len: *i32,
    param_name: *u8,
    param_name_len: *i32,
    param_type_name: *u8,
    param_type_len: *i32,
    field_name: *u8,
    field_len: *i32): i32 {
  let kind: i32 = 0;
  let took: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  if (name == 0 as *u8 || name_len == 0 as *i32) {
    return 0;
  }
  if (param_name == 0 as *u8 || param_name_len == 0 as *i32) {
    return 0;
  }
  if (param_type_name == 0 as *u8 || param_type_len == 0 as *i32) {
    return 0;
  }
  if (field_name == 0 as *u8 || field_len == 0 as *i32) {
    return 0;
  }
  unsafe {
    if (parser_asm_library_expect_kind(lex_inout, source, TOKEN_FUNCTION) == 0) {
      return 0;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_SPAWN) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      name[0] = 115;
      name[1] = 112;
      name[2] = 97;
      name[3] = 119;
      name[4] = 110;
      name_len[0] = 5;
    } else {
      took = parser_asm_library_take_ident_name64_end(lex_inout, source, data, slen, name, name_len);
      if (took == 0) {
        return 0;
      }
    }
    if (parser_asm_library_expect_kind(lex_inout, source, TOKEN_LPAREN) == 0) {
      return 0;
    }
    took = parser_asm_library_take_ident_param32(lex_inout, source, data, slen, param_name, param_name_len);
    if (took == 0) {
      return 0;
    }
    if (parser_asm_library_expect_kind(lex_inout, source, TOKEN_COLON) == 0) {
      return 0;
    }
    took = parser_asm_library_take_ident_name64_start(lex_inout, source, data, slen, param_type_name, param_type_len);
    if (took == 0) {
      return 0;
    }
    if (parser_asm_library_expect_kind(lex_inout, source, TOKEN_RPAREN) == 0) {
      return 0;
    }
    if (parser_asm_library_expect_kind(lex_inout, source, TOKEN_COLON) == 0) {
      return 0;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_BOOL) {
      if (kind != TOKEN_IDENT || parser_asm_lex_peek_ident_len_c(lex_inout, source) != 4) {
        return 0;
      }
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    if (parser_asm_library_expect_kind(lex_inout, source, TOKEN_LBRACE) == 0) {
      return 0;
    }
    if (parser_asm_library_expect_kind(lex_inout, source, TOKEN_RETURN) == 0) {
      return 0;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    if (parser_asm_library_expect_kind(lex_inout, source, TOKEN_DOT) == 0) {
      return 0;
    }
    took = parser_asm_library_take_ident_name64_end(lex_inout, source, data, slen, field_name, field_len);
    if (took == 0) {
      return 0;
    }
    if (parser_asm_library_expect_kind(lex_inout, source, TOKEN_EQ) == 0) {
      return 0;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    if (parser_asm_library_expect_kind(lex_inout, source, TOKEN_DOT) == 0) {
      return 0;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    if (parser_asm_library_expect_kind(lex_inout, source, TOKEN_SEMICOLON) == 0) {
      return 0;
    }
    if (parser_asm_library_expect_kind(lex_inout, source, TOKEN_RBRACE) == 0) {
      return 0;
    }
    return 1;
  }
  return 0;
}
