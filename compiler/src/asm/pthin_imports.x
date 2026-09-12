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

// pthin_imports.x — G-02f-320 P11 parser thin imports product bodies.
//
// 7.2.1 P11b B-minus productize (2026-09-13): skip_imports peek loop
// over ATTR_CFG / pending cfg-skip / CONST + try_skip_const_import.
// 7.2.1 P11c B-minus (2026-09-13): 有则补全 this file — consume_path
// (`import("path");` after the IMPORT keyword) and try_skip
// (`IDENT = import("path");` after CONST) are sequential peek+step
// walks. Language has no local u8[128]; the C trampoline
// `parser_asm_try_skip_const_import_stmt` still owns the path buffer
// and calls try_skip_into. collect_imports (void* module +
// binding/path/select buffers) stays C and calls the consume_path
// trampoline. copy_token_bytes_to_buf64 stays C (collect only).
// Contiguous already-T AUDIT prefix on collect_imports is compiled
// only under XLANG_PARSER_STRETCH_AUDIT (same slice, P4ub pattern).
// By-value lexer returns stay as C trampolines in
// seeds/pthin_imports.from_x.c (language has no struct-by-value).
// Product AUDIT_CALL is already ((void)0); the C twins keep the huge
// already-T combinator probes as cold fallback only.
// Do not duplicate copy_slice (authority = pthin_lex_skip.x).
// Do not duplicate skip_ws / import_path_validate / finalize
// (authority = pthin_stretch.x).
// Do not wrap leftover collect walk AUDIT.
// Do not wrap skip_one_trait/impl (trait-reg globals).
// Do not compile this file as a skip-include stub without bodies.
// Do not open a new P-lane (有则补全 P11b).
//
// Hybrid P11b/P11c: g05_try_x_to_o this file;
// XLANG_PTHIN_IMPORTS_BODIES_FROM_X skips the portable .inc region.
// Requires P9a bridge (otherwise peek/step would UNDEF). copy_slice
// and stretch validate/finalize resolve from P1b / P9b (or their
// cold C twins). token.h remains the TOKEN_* authority via P11 C
// _Static_assert pins. Cold: no define, full .inc. Do not reuse
// XLANG_PTHIN_IMPORTS_FROM_X for P11b/P11c bodies.
// PLATFORM: SHARED freestanding.

/** Advance the opaque lexer one token; returns the consumed kind. */
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token kind without advancing. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token's int_val (ATTR_CFG keep/skip flag) without advancing. */
export extern "C" function parser_asm_lex_peek_int_val_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token's ident_len without advancing. */
export extern "C" function parser_asm_lex_peek_ident_len_c(lex_inout: *u8, source: *u8): i32;
/** Peek the next token's token_start without advancing. */
export extern "C" function parser_asm_lex_peek_token_start_c(lex_inout: *u8, source: *u8): usize;
/** Read the restore pos. */
export extern "C" function parser_asm_lex_pos_c(lex: *u8): usize;
/** Write the restore pos. */
export extern "C" function parser_asm_lex_set_pos_c(lex: *u8, pos: usize): void;
/** Read the restore line. */
export extern "C" function parser_asm_lex_line_c(lex: *u8): i32;
/** Write the restore line. */
export extern "C" function parser_asm_lex_set_line_c(lex: *u8, line: i32): void;
/** Read the restore col. */
export extern "C" function parser_asm_lex_col_c(lex: *u8): i32;
/** Write the restore col. */
export extern "C" function parser_asm_lex_set_col_c(lex: *u8, col: i32): void;
/** Source slice data pointer (for quoted-path fallback and copy). */
export extern "C" function parser_asm_lex_source_data_c(source: *u8): *u8;
/** Source slice length. */
export extern "C" function parser_asm_lex_source_length_c(source: *u8): usize;
/** P18 C authority: apply cfg-skip of the next top-level item; returns new pending. */
export extern "C" function parser_asm_cfg_skip_pending_apply_c(lex_inout: *u8, source: *u8, pending: i32): i32;
/** C trampoline: skip `IDENT = import("path");` after CONST; owns the 128-byte path buf. */
export extern "C" function parser_asm_try_skip_const_import_stmt(lex_inout: *u8, source: *u8): i32;
/** P1b authority: copy nlen bytes from data[start..) into dest. */
export extern "C" function parser_asm_copy_slice_to_name64_buf_c(source: *u8, source_len: i32, start: usize, nlen: i32, out: *u8): void;
/** P9b authority: every path byte is ident-class or '.' . */
export extern "C" function parser_asm_stretch_import_path_validate_c(path: *u8, path_len: i32): i32;
/** P9b authority: normalize then re-validate; returns new length or 0. */
export extern "C" function parser_asm_stretch_import_path_finalize_c(path_buf: *u8, path_len: i32, source: *u8, source_len: usize): i32;

// TOKEN_* pin copies of include/token.h (133 kinds). P11 C _Static_assert
// fires if the pin drifts; do not treat these as a second enum authority.
const TOKEN_CONST: i32 = 3;
const TOKEN_ATTR_CFG: i32 = 24;
const TOKEN_IMPORT: i32 = 53;
const TOKEN_IDENT: i32 = 59;
const TOKEN_LPAREN: i32 = 82;
const TOKEN_RPAREN: i32 = 83;
const TOKEN_SEMICOLON: i32 = 95;
const TOKEN_ASSIGN: i32 = 117;
const TOKEN_STRING: i32 = 130;

/**
 * Restore lexer pos/line/col saved at try_skip entry (C twin left
 * *lex unmoved on any fail because consume_path mutated a dummy).
 * @param lex *u8 — opaque lexer
 * @param pos usize — saved pos
 * @param line i32 — saved line
 * @param col i32 — saved col
 */
function parser_asm_imports_restore_lex(lex: *u8, pos: usize, line: i32, col: i32): void {
  unsafe {
    parser_asm_lex_set_pos_c(lex, pos);
    parser_asm_lex_set_line_c(lex, line);
    parser_asm_lex_set_col_c(lex, col);
  }
}

/**
 * Peek `want`; if it matches, step and return 1. Fail-leave leaves
 * the lexer unmoved (C lexer_next_into does not consume).
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @param want i32 — expected token kind
 * @return i32 — 1 if consumed; 0 if peek mismatched
 */
function parser_asm_imports_expect_kind(lex_inout: *u8, source: *u8, want: i32): i32 {
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
 * IDENT-quote compat: lexer emitted IDENT but the bytes start with `"`.
 * Copy the bytes between quotes into path_buf (max 127), NUL-terminate,
 * write path_len. Matching C: q1-q0 > 127 or unclosed quote fails
 * without writing path_len.
 * @param data *u8 — source bytes
 * @param slen_us usize — source length
 * @param ts usize — token_start of the IDENT (the opening quote)
 * @param path_buf *u8 — destination (capacity 128)
 * @param path_len *i32 — out length slot
 * @return i32 — 1 on copy; 0 on unclosed / overflow
 */
function parser_asm_imports_copy_quoted_path(data: *u8, slen_us: usize, ts: usize, path_buf: *u8, path_len: *i32): i32 {
  let q0: usize = 0;
  let q1: usize = 0;
  let k: usize = 0;
  let c: u8 = 0;
  unsafe {
    q0 = ts + 1;
    q1 = q0;
    while (q1 < slen_us) {
      c = data[q1];
      if (c == 34) {
        break;
      }
      q1 = q1 + 1;
    }
    if (q1 >= slen_us) {
      return 0;
    }
    if (q1 - q0 > 127 as usize) {
      return 0;
    }
    while (k < q1 - q0) {
      c = data[q0 + k];
      path_buf[k] = c;
      k = k + 1;
    }
    path_buf[k] = 0;
    path_len[0] = k as i32;
  }
  return 1;
}

/**
 * Parse `("path");` from the token after `import`. Writes path_buf /
 * path_len, leaves the lexer after `;` on success. Fail-leave matches
 * C: tokens already consumed stay consumed (try_skip restores).
 * STRING ident_len in 1..255 copies via P1b name64. IDENT whose first
 * byte is `"` uses the quote-scan fallback (max 127). Then require
 * `)` `;`, P9b validate, P9b finalize (rewrites path_len).
 * @param lex_inout *u8 — opaque lexer (entry = start of `(`)
 * @param source *u8 — opaque slice
 * @param path_buf *u8 — destination (capacity 128)
 * @param path_len *i32 — out length slot
 * @return i32 — 1 on success; 0 on null / mismatch
 * PLATFORM: SHARED — product P11c B-minus; C trampoline keeps
 * `parser_asm_collect_imports_consume_path`.
 */
#[no_mangle]
export function parser_asm_collect_imports_consume_path_into_c(lex_inout: *u8, source: *u8, path_buf: *u8, path_len: *i32): i32 {
  let kind: i32 = 0;
  let n: i32 = 0;
  let ts: usize = 0;
  let data: *u8 = 0 as *u8;
  let slen_us: usize = 0;
  let slen: i32 = 0;
  let copied: i32 = 0;
  let finalized: i32 = 0;
  let first: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8 || path_buf == 0 as *u8 || path_len == 0 as *i32) {
    return 0;
  }
  unsafe {
    path_len[0] = 0;
    copied = parser_asm_imports_expect_kind(lex_inout, source, TOKEN_LPAREN);
    if (copied == 0) {
      return 0;
    }
    data = parser_asm_lex_source_data_c(source);
    slen_us = parser_asm_lex_source_length_c(source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    n = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
    if (slen_us > 2147483647 as usize) {
      slen = 2147483647;
    } else {
      slen = slen_us as i32;
    }
    if (kind == TOKEN_STRING && n > 0 && n <= 255) {
      parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, n, path_buf);
      path_len[0] = n;
      parser_asm_lex_step_kind_c(lex_inout, source);
    } else {
      copied = 0;
      if (kind == TOKEN_IDENT && n > 0 && n <= 255) {
        if (data != 0 as *u8 && ts < slen_us) {
          first = data[ts] as i32;
          if (first == 34) {
            copied = parser_asm_imports_copy_quoted_path(data, slen_us, ts, path_buf, path_len);
          }
        }
      }
      if (copied == 0) {
        return 0;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
    }
    copied = parser_asm_imports_expect_kind(lex_inout, source, TOKEN_RPAREN);
    if (copied == 0) {
      return 0;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_SEMICOLON) {
      return 0;
    }
    n = path_len[0];
    copied = parser_asm_stretch_import_path_validate_c(path_buf, n);
    if (copied == 0) {
      return 0;
    }
    finalized = parser_asm_stretch_import_path_finalize_c(path_buf, n, data, slen_us);
    if (finalized <= 0) {
      return 0;
    }
    path_len[0] = finalized;
    parser_asm_lex_step_kind_c(lex_inout, source);
  }
  return 1;
}

/**
 * After CONST, skip `IDENT = import("path");`. Entry is the start of
 * IDENT. Fail-leave restores the entry cursor (C mutated a dummy lexer
 * and left *lex unmoved). Success leaves the lexer after `;`.
 * @param lex_inout *u8 — opaque lexer
 * @param source *u8 — opaque slice
 * @param path_buf *u8 — scratch path (capacity 128; C trampoline owns it)
 * @param path_len *i32 — scratch length slot
 * @return i32 — 1 if the import stmt was skipped; 0 on null / mismatch
 * PLATFORM: SHARED — product P11c B-minus; C trampoline keeps
 * `parser_asm_try_skip_const_import_stmt`.
 */
#[no_mangle]
export function parser_asm_try_skip_const_import_into_c(lex_inout: *u8, source: *u8, path_buf: *u8, path_len: *i32): i32 {
  let pos0: usize = 0;
  let line0: i32 = 0;
  let col0: i32 = 0;
  let kind: i32 = 0;
  let n: i32 = 0;
  let ok: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8 || path_buf == 0 as *u8 || path_len == 0 as *i32) {
    return 0;
  }
  unsafe {
    pos0 = parser_asm_lex_pos_c(lex_inout);
    line0 = parser_asm_lex_line_c(lex_inout);
    col0 = parser_asm_lex_col_c(lex_inout);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    n = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    if (kind != TOKEN_IDENT || n <= 0) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    ok = parser_asm_imports_expect_kind(lex_inout, source, TOKEN_ASSIGN);
    if (ok == 0) {
      parser_asm_imports_restore_lex(lex_inout, pos0, line0, col0);
      return 0;
    }
    ok = parser_asm_imports_expect_kind(lex_inout, source, TOKEN_IMPORT);
    if (ok == 0) {
      parser_asm_imports_restore_lex(lex_inout, pos0, line0, col0);
      return 0;
    }
    ok = parser_asm_collect_imports_consume_path_into_c(lex_inout, source, path_buf, path_len);
    if (ok == 0) {
      parser_asm_imports_restore_lex(lex_inout, pos0, line0, col0);
      return 0;
    }
  }
  return 1;
}

/**
 * Skip leading top-level `const name = import("path");` statements
 * (and `#[cfg]` that prunes the following top-level item).
 * Entry cursor is the start of the first token. Peek ATTR_CFG: step
 * and set pending from int_val==0. While pending, P18 cfg-skip
 * consumes the next top-level construct (const/let/struct/function).
 * Peek CONST: step then try_skip_const_import_stmt (C trampoline;
 * owns the 128-byte path buf and calls try_skip_into). Non-CONST /
 * failed try_skip: leave the lexer at that cursor (after CONST on a
 * failed import-shaped stmt, unmoved on a non-CONST peek), matching
 * the C twin.
 * @param lex_inout *u8 — opaque lexer (advanced to the first
 *   non-import token, or left after a failed CONST)
 * @param source *u8 — opaque slice
 * @return i32 — 1 on the success / fail-leave path; 0 on null
 * PLATFORM: SHARED — product P11 B-minus; C trampoline keeps
 * `parser_asm_skip_imports_slice_c` and the buf twin.
 */
#[no_mangle]
export function parser_asm_skip_imports_into_c(lex_inout: *u8, source: *u8): i32 {
  let pending: i32 = 0;
  let kind: i32 = 0;
  let skipped: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    while (true) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      // B-01/B-19: unmatched `#[cfg]` prunes the following top-level item.
      if (kind == TOKEN_ATTR_CFG) {
        pending = 0;
        if (parser_asm_lex_peek_int_val_c(lex_inout, source) == 0) {
          pending = 1;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        continue;
      }
      if (pending != 0) {
        pending = parser_asm_cfg_skip_pending_apply_c(lex_inout, source, pending);
        if (pending != 0) {
          pending = 0;
        }
        continue;
      }
      if (kind != TOKEN_CONST) {
        return 1;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      skipped = parser_asm_try_skip_const_import_stmt(lex_inout, source);
      if (skipped != 0) {
        continue;
      }
      return 1;
    }
  }
  return 1;
}
