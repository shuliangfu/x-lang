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

// pthin_ctrl.x — G-02f-286 P5 parser thin ctrl product bodies.
//
// 7.2.1 P5b Route C productize (2026-09-13): after P11b skip_imports,
// if_stmt.inc is the next still-host-cc product slice with a portable
// buf-path region. Comment/string-aware `{...}` byte skip and keyword
// scan at a source offset are Route C (*u8 + length). They are a
// different authority from P1b token skip_balanced_braces (raw bytes
// must ignore braces inside //, block comments, and quotes — the
// lexer path already does this; scan_sync historically counted raw
// bytes and mis-closed large if then-bodies).
//
// 7.2.1 P5c Route C (2026-09-13): 有则补全 this file with scan_sync.
// The C twin returned lexer by value; language has no struct-by-value
// so the .x export is pos-only (usize). C trampoline rebuilds the
// lexer (same line/col, new pos). else-if recursion becomes a loop
// (same fail-leave: a nested miss returns the nested `if` pos).
// parse_if_stmt / arena / match / if_expr stay C.
// sync_lex_after_if_cond_paren stays C (dead after wave650 inclusive
// parens; do not port). Do not wrap leftover else-if AUDIT. Do not
// wrap skip_one_trait/impl. Do not duplicate P1b token skip_balanced.
// skip_ws_and_comments is P9b authority. kw_at_pos_buf_c stays the
// general C-callable export; scan_sync uses file-local if/else
// probes (language has no address-of for a kw literal).
//
// 7.2.1 P5d B-minus (2026-09-13): 有则补全 this file with
// realign_lex_after_if_arm. All six C stages (entry stmt-kw gate,
// LPAREN backscan for `if`, peek re-gate, IDENT "return" backtrace,
// back_kw keyword scan, 512B depth-0 forward keyword scan, rewind
// fallback) live here over the P9a lexer-step bridge peek family.
// Cursor semantics preserved exactly: gate reject keeps the entry
// cursor value; every success writes lex_at_token(token) (P19c pos
// authority + tok.line/col) except the "return" backtrace which
// writes ident_start-7 with the peeked token's line/col. The
// backscan positions round-trip through i32 exactly like the C twin
// (`lex_b.pos = (int32_t)pos_before_run(...)`). P19 scalars
// (pos_before_run / lex_at_token_pos / ident_is_unsafe_kind /
// rewind_kind) resolve from pthin_helpers.x in hybrid and from the
// P19 cold C twins otherwise. parse_if_stmt / arena / match /
// if_expr stay C. Do not open a new P-lane.
//
// Hybrid P5b/P5c/P5d: g05_try_x_to_o this file; XLANG_PTHIN_CTRL_BODIES_FROM_X
// skips the portable .inc region. Requires the P9a lexer-step bridge
// (P5d peeks; otherwise those would UNDEF — g05 gates this lane on
// p9a ok). Cold: no define, full .inc. Do not reuse XLANG_PTHIN_CTRL_FROM_X
// for P5b/P5c/P5d bodies.
// PLATFORM: SHARED freestanding.

/** P9b authority: advance past whitespace and comments. */
export extern "C" function parser_asm_stretch_skip_ws_and_comments_c(data: *u8, len: usize, pos: usize): usize;

/* P9a lexer-step bridge (parser_asm_lex_step_bridge.from_x.c): peek family
 * + cursor trio get/set + source accessors. Pure peeks re-lex the same
 * token each call (no hidden state); the realign stages below chain them
 * exactly like the C twin chained lexer_next_into results. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_ident_len_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_token_start_c(lex_inout: *u8, source: *u8): usize;
export extern "C" function parser_asm_lex_peek_tok_line_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_tok_col_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_next_pos_c(lex_inout: *u8, source: *u8): usize;
export extern "C" function parser_asm_lex_pos_c(lex: *u8): usize;
export extern "C" function parser_asm_lex_line_c(lex: *u8): i32;
export extern "C" function parser_asm_lex_col_c(lex: *u8): i32;
export extern "C" function parser_asm_lex_set_pos_c(lex: *u8, pos: usize): void;
export extern "C" function parser_asm_lex_set_line_c(lex: *u8, line: i32): void;
export extern "C" function parser_asm_lex_set_col_c(lex: *u8, col: i32): void;
export extern "C" function parser_asm_lex_source_data_c(source: *u8): *u8;
export extern "C" function parser_asm_lex_source_length_c(source: *u8): usize;

/* P19 scalar authorities (pthin_helpers.x in hybrid; cold C twins in the
 * P19 seed region — see parser_asm_helpers_slice.inc P5d note). */
export extern "C" function parser_asm_lexer_pos_before_run_c(end_pos: usize, run_len: i32): usize;
export extern "C" function parser_asm_lex_at_token_pos_c(kind: i32, token_start: usize, ident_len: i32, next_pos: usize): usize;
export extern "C" function parser_asm_ident_is_unsafe_stmt_kind_c(kind: i32, ident_len: i32, token_start: usize, next_pos: usize, data: *u8, length: usize): i32;
export extern "C" function parser_asm_rewind_following_stmt_kind_c(kind: i32): i32;

/**
 * True when `c` continues an identifier (`[A-Za-z0-9_]`).
 * @param c u8 — source byte
 * @return i32 — 1 if ident-continue; 0 otherwise
 */
function parser_asm_ctrl_ident_continue(c: u8): i32 {
  if (c >= 97 && c <= 122) {
    return 1;
  }
  if (c >= 65 && c <= 90) {
    return 1;
  }
  if (c >= 48 && c <= 57) {
    return 1;
  }
  if (c == 95) {
    return 1;
  }
  return 0;
}

// TOKEN_* pin copies of include/token.h (133 kinds). P5 C _Static_assert
// pins in seeds/pthin_ctrl.from_x.c fire if these drift; do not treat the
// copies as a second enum authority.
const TOKEN_LET: i32 = 2;
const TOKEN_CONST: i32 = 3;
const TOKEN_IF: i32 = 4;
const TOKEN_WHILE: i32 = 6;
const TOKEN_FOR: i32 = 8;
const TOKEN_RETURN: i32 = 11;
const TOKEN_MATCH: i32 = 18;
const TOKEN_IDENT: i32 = 59;
const TOKEN_LPAREN: i32 = 82;
const TOKEN_RBRACE: i32 = 85;

/**
 * Compare `klen` bytes at `data[i..]` with `kw[0..klen)`.
 * @param data *u8 — source bytes; null is 0
 * @param len usize — source length
 * @param i usize — first source byte
 * @param kw *u8 — expected spelling; null is 0
 * @param klen i32 — expected length; <= 0 is 0
 * @return i32 — 1 if the span fits and every byte matches
 */
function parser_asm_ctrl_bytes_eq(data: *u8, len: usize, i: usize, kw: *u8, klen: i32): i32 {
  let n: usize = 0;
  let j: i32 = 0;
  let a: u8 = 0;
  let b: u8 = 0;
  if (data == 0 as *u8 || kw == 0 as *u8 || klen <= 0) {
    return 0;
  }
  n = klen as usize;
  if (i + n > len) {
    return 0;
  }
  while (j < klen) {
    unsafe {
      a = data[i + j as usize];
      b = kw[j];
    }
    if (a != b) {
      return 0;
    }
    j = j + 1;
  }
  return 1;
}

/**
 * Skip one balanced `{...}` starting at `data[start]`, which must be `{`.
 * Returns the index immediately after the matching `}`. Braces inside
 * line comments, block comments, and quoted strings/chars do not affect
 * depth (same as the C twin).
 * @param data *u8 — source bytes; null returns `start`
 * @param len usize — source length
 * @param start usize — index of the opening `{`
 * @return usize — one-past the matching `}`, or `start` if `data[start]`
 *   is not `{`, or `len` if the group is unclosed
 * PLATFORM: SHARED — byte-scan authority for scan_sync; not P1b token skip.
 */
#[no_mangle]
export function parser_asm_skip_balanced_braces_bytes_comment_aware_c(data: *u8, len: usize, start: usize): usize {
  let i: usize = start;
  let br: i32 = 0;
  let c: u8 = 0;
  let n: u8 = 0;
  if (data == 0 as *u8 || i >= len) {
    return start;
  }
  unsafe { c = data[i]; }
  if (c != 123) {
    return start;
  }
  while (i < len) {
    unsafe { c = data[i]; }
    // Line comment `//` — skip to newline; braces inside do not count.
    if (c == 47 && i + 1 < len) {
      unsafe { n = data[i + 1]; }
      if (n == 47) {
        i = i + 2;
        while (i < len) {
          unsafe { c = data[i]; }
          if (c == 10) {
            break;
          }
          i = i + 1;
        }
        continue;
      }
      // Block comment `/*` — skip to `*/`.
      if (n == 42) {
        i = i + 2;
        while (i + 1 < len) {
          unsafe {
            c = data[i];
            n = data[i + 1];
          }
          if (c == 42 && n == 47) {
            break;
          }
          i = i + 1;
        }
        if (i + 1 < len) {
          i = i + 2;
        } else {
          i = len;
        }
        continue;
      }
    }
    // Double-quoted string; `\\` skips the next byte.
    if (c == 34) {
      i = i + 1;
      while (i < len) {
        unsafe { c = data[i]; }
        if (c == 34) {
          break;
        }
        if (c == 92 && i + 1 < len) {
          i = i + 2;
          continue;
        }
        i = i + 1;
      }
      if (i < len) {
        i = i + 1;
      }
      continue;
    }
    // Single-quoted char / byte literal; same escape rule.
    if (c == 39) {
      i = i + 1;
      while (i < len) {
        unsafe { c = data[i]; }
        if (c == 39) {
          break;
        }
        if (c == 92 && i + 1 < len) {
          i = i + 2;
          continue;
        }
        i = i + 1;
      }
      if (i < len) {
        i = i + 1;
      }
      continue;
    }
    if (c == 123) {
      br = br + 1;
      i = i + 1;
      continue;
    }
    if (c == 125) {
      br = br - 1;
      i = i + 1;
      if (br == 0) {
        return i;
      }
      continue;
    }
    i = i + 1;
  }
  return i;
}

/**
 * True when `data[i..i+klen)` is a standalone keyword `kw`.
 * Rejects ident-continue on either side. After the keyword, skip_ws
 * (P9b) then: `if` rejects `}` / `;` / `,`; `else` accepts `{` / `;`
 * or a following `if`; other keywords require `(` / `{` / `;`.
 * @param data *u8 — source bytes; null is 0
 * @param len usize — source length
 * @param i usize — first keyword byte
 * @param kw *u8 — expected spelling; null is 0
 * @param klen i32 — expected length; <= 0 is 0
 * @return i32 — 1 if `data[i..]` is that standalone keyword
 * PLATFORM: SHARED — G.7 single kw_at_pos + scan_sync bare `if` path.
 */
#[no_mangle]
export function parser_asm_kw_at_pos_buf_c(data: *u8, len: usize, i: usize, kw: *u8, klen: i32): i32 {
  let next_pos: usize = 0;
  let prev: u8 = 0;
  let nx: u8 = 0;
  let nlen: usize = 0;
  if (data == 0 as *u8 || kw == 0 as *u8 || klen <= 0) {
    return 0;
  }
  nlen = klen as usize;
  if (i + nlen > len) {
    return 0;
  }
  if (parser_asm_ctrl_bytes_eq(data, len, i, kw, klen) == 0) {
    return 0;
  }
  if (i > 0) {
    unsafe { prev = data[i - 1]; }
    if (parser_asm_ctrl_ident_continue(prev) != 0) {
      return 0;
    }
  }
  if (i + nlen < len) {
    unsafe {
      next_pos = parser_asm_stretch_skip_ws_and_comments_c(data, len, i + nlen);
    }
    if (next_pos < len) {
      unsafe { nx = data[next_pos]; }
      // Bare `if cond {` is legal; do not require '(' after `if`.
      if (klen == 2) {
        let is_if: i32 = 0;
        unsafe {
          if (kw[0] == 105 && kw[1] == 102) {
            is_if = 1;
          }
        }
        if (is_if != 0) {
          if (nx == 125 || nx == 59 || nx == 44) {
            return 0;
          }
        } else {
          if (nx != 40 && nx != 123 && nx != 59) {
            return 0;
          }
        }
      } else {
        if (klen == 4) {
          let is_else: i32 = 0;
          unsafe {
            if (kw[0] == 101 && kw[1] == 108 && kw[2] == 115 && kw[3] == 101) {
              is_else = 1;
            }
          }
          if (is_else != 0) {
            if (nx != 123 && nx != 59) {
              let a: u8 = 0;
              let b: u8 = 0;
              if (next_pos + 2 > len) {
                return 0;
              }
              unsafe {
                a = data[next_pos];
                b = data[next_pos + 1];
              }
              if (a != 105 || b != 102) {
                return 0;
              }
            }
          } else {
            if (nx != 40 && nx != 123 && nx != 59) {
              return 0;
            }
          }
        } else {
          if (nx != 40 && nx != 123 && nx != 59) {
            return 0;
          }
        }
      }
    }
  }
  return 1;
}

/**
 * True when `data[i..]` is a standalone `if` (same next-char rules as
 * `parser_asm_kw_at_pos_buf_c` with kw=`if`). File-local: language has
 * no address-of for a keyword literal.
 * @param data *u8 — source bytes; null is 0
 * @param len usize — source length
 * @param i usize — first keyword byte
 * @return i32 — 1 if standalone `if`
 */
function parser_asm_ctrl_kw_if_at(data: *u8, len: usize, i: usize): i32 {
  let a: u8 = 0;
  let b: u8 = 0;
  if (data == 0 as *u8 || i + 2 > len) {
    return 0;
  }
  unsafe {
    a = data[i];
    b = data[i + 1];
  }
  if (a != 105 || b != 102) {
    return 0;
  }
  return parser_asm_kw_at_pos_buf_c(data, len, i, data + i, 2);
}

/**
 * True when `data[i..]` is a standalone `else` (same next-char rules as
 * `parser_asm_kw_at_pos_buf_c` with kw=`else`).
 * @param data *u8 — source bytes; null is 0
 * @param len usize — source length
 * @param i usize — first keyword byte
 * @return i32 — 1 if standalone `else`
 */
function parser_asm_ctrl_kw_else_at(data: *u8, len: usize, i: usize): i32 {
  let a: u8 = 0;
  let b: u8 = 0;
  let c: u8 = 0;
  let d: u8 = 0;
  if (data == 0 as *u8 || i + 4 > len) {
    return 0;
  }
  unsafe {
    a = data[i];
    b = data[i + 1];
    c = data[i + 2];
    d = data[i + 3];
  }
  if (a != 101 || b != 108 || c != 115 || d != 101) {
    return 0;
  }
  return parser_asm_kw_at_pos_buf_c(data, len, i, data + i, 4);
}

/**
 * If data[i] starts a line comment, block comment, or quoted span,
 * return one-past that construct (or len). Otherwise return i
 * unchanged. A line comment leaves the cursor on the newline,
 * matching the C scan_sync loop.
 * @param data *u8 — source bytes (non-null; caller checked)
 * @param len usize — source length
 * @param i usize — current byte
 * @return usize — advanced cursor, or i if not a comment/quote
 */
function parser_asm_ctrl_skip_comment_or_quote(data: *u8, len: usize, i: usize): usize {
  let c: u8 = 0;
  let n: u8 = 0;
  let q: u8 = 0;
  unsafe { c = data[i]; }
  if (c == 47 && i + 1 < len) {
    unsafe { n = data[i + 1]; }
    if (n == 47) {
      i = i + 2;
      while (i < len) {
        unsafe { c = data[i]; }
        if (c == 10) {
          break;
        }
        i = i + 1;
      }
      return i;
    }
    if (n == 42) {
      i = i + 2;
      while (i + 1 < len) {
        unsafe {
          c = data[i];
          n = data[i + 1];
        }
        if (c == 42 && n == 47) {
          break;
        }
        i = i + 1;
      }
      if (i + 1 < len) {
        i = i + 2;
      } else {
        i = len;
      }
      return i;
    }
  }
  if (c == 34 || c == 39) {
    q = c;
    i = i + 1;
    while (i < len) {
      unsafe { c = data[i]; }
      if (c == q) {
        break;
      }
      if (c == 92 && i + 1 < len) {
        i = i + 2;
        continue;
      }
      i = i + 1;
    }
    if (i < len) {
      i = i + 1;
    }
    return i;
  }
  return i;
}

/**
 * First `{` at parenthesis-depth 0 after `start`, comment/string aware.
 * @param data *u8 — source bytes (non-null; caller checked)
 * @param len usize — source length
 * @param start usize — first byte of the condition
 * @return usize — index of `{`, or `len` if none
 */
function parser_asm_ctrl_find_then_lbrace(data: *u8, len: usize, start: usize): usize {
  let i: usize = start;
  let par: i32 = 0;
  let c: u8 = 0;
  let skipped: usize = 0;
  while (i < len) {
    skipped = parser_asm_ctrl_skip_comment_or_quote(data, len, i);
    if (skipped != i) {
      i = skipped;
      continue;
    }
    unsafe { c = data[i]; }
    if (c == 40) {
      par = par + 1;
    } else {
      if (c == 41 && par > 0) {
        par = par - 1;
      } else {
        if (c == 123 && par == 0) {
          break;
        }
      }
    }
    i = i + 1;
  }
  return i;
}

/**
 * Byte position of the first token after the whole `if` / `else` /
 * `else if` statement that contains `start_pos`. Backscans up to 512
 * bytes for a standalone `if`, finds the then-body `{` at parenthesis
 * depth 0, skips that group, then optional `else {…}` or `else if …`
 * (loop, not recursion). Fail-leave returns `start_pos` on the first
 * call and the nested `if` pos on a nested miss (same as C).
 * @param data *u8 — source bytes; null returns `start_pos`
 * @param len usize — source length
 * @param start_pos usize — lexer pos near the `if` keyword
 * @return usize — pos after the statement, or `start_pos` / nested
 *   `if` pos on fail-leave
 * PLATFORM: SHARED — scan_sync authority; C trampoline rebuilds lexer.
 */
#[no_mangle]
export function parser_asm_scan_sync_after_if_stmt_pos_c(data: *u8, len: usize, start_pos: usize): usize {
  let cur: usize = start_pos;
  let if_pos: usize = 0;
  let lo: usize = 0;
  let found: i32 = 0;
  let cond_start: usize = 0;
  let probe: usize = 0;
  let i: usize = 0;
  let c: u8 = 0;
  if (data == 0 as *u8) {
    return start_pos;
  }
  while (true) {
    if_pos = cur;
    lo = 0;
    if (if_pos > 512 as usize) {
      lo = if_pos - 512 as usize;
    }
    found = 0;
    cond_start = 0;
    while (true) {
      if (parser_asm_ctrl_kw_if_at(data, len, if_pos) != 0) {
        unsafe {
          probe = parser_asm_stretch_skip_ws_and_comments_c(data, len, if_pos + 2);
        }
        if (probe < len) {
          found = 1;
          cond_start = probe;
          break;
        }
      }
      if (if_pos == lo) {
        break;
      }
      if_pos = if_pos - 1;
    }
    if (found == 0) {
      return cur;
    }
    i = parser_asm_ctrl_find_then_lbrace(data, len, cond_start);
    unsafe {
      i = parser_asm_stretch_skip_ws_and_comments_c(data, len, i);
    }
    if (i >= len) {
      return cur;
    }
    unsafe { c = data[i]; }
    if (c != 123) {
      return cur;
    }
    i = parser_asm_skip_balanced_braces_bytes_comment_aware_c(data, len, i);
    unsafe {
      i = parser_asm_stretch_skip_ws_and_comments_c(data, len, i);
    }
    if (i + 4 <= len && parser_asm_ctrl_kw_else_at(data, len, i) != 0) {
      unsafe {
        i = parser_asm_stretch_skip_ws_and_comments_c(data, len, i + 4);
      }
      if (i < len) {
        unsafe { c = data[i]; }
        if (c == 123) {
          i = parser_asm_skip_balanced_braces_bytes_comment_aware_c(data, len, i);
        } else {
          if (i + 2 <= len && parser_asm_ctrl_kw_if_at(data, len, i) != 0) {
            cur = i;
            continue;
          }
        }
      }
    }
    unsafe {
      i = parser_asm_stretch_skip_ws_and_comments_c(data, len, i);
    }
    return i;
  }
  return cur;
}

/**
 * Stage 1/3 predicate: the peeked token directly names a statement head
 * (or `}`), so the cursor must stay ON it (the C twin's first gate list).
 * @param kind i32 — peeked token kind
 * @return i32 — 1 for RETURN/IF/WHILE/FOR/MATCH/RBRACE/LET/CONST
 */
function parser_asm_ctrl_realign_stmt_kw(kind: i32): i32 {
  if (kind == TOKEN_RETURN || kind == TOKEN_IF || kind == TOKEN_WHILE || kind == TOKEN_FOR ||
      kind == TOKEN_MATCH || kind == TOKEN_RBRACE || kind == TOKEN_LET || kind == TOKEN_CONST) {
    return 1;
  }
  return 0;
}

/**
 * Stage 5 predicate: backscan accept set — the stage 1 list minus RBRACE
 * (a stray `}` behind the cursor is not a statement head to rewind to).
 * @param kind i32 — peeked token kind at a backscan offset
 * @return i32 — 1 for RETURN/IF/WHILE/FOR/MATCH/LET/CONST
 */
function parser_asm_ctrl_realign_back_kw(kind: i32): i32 {
  if (kind == TOKEN_RETURN || kind == TOKEN_IF || kind == TOKEN_WHILE || kind == TOKEN_FOR ||
      kind == TOKEN_MATCH || kind == TOKEN_LET || kind == TOKEN_CONST) {
    return 1;
  }
  return 0;
}

/**
 * Write the cursor for the token the lexer currently points at, using the
 * P19c pos authority (token_start first, STRING quote backup, run-length
 * fallback) plus the peeked token's own line/col — the .x equivalent of
 * the C twin's `lex_at_token_from_result_c(r)`. Peeks are pure, so the
 * five reads below all observe the same token.
 * @param lex_inout *u8 — cursor; must already sit where the token was
 *   materialized FROM (its pos is the pre-token cursor)
 * @param source *u8 — opaque slice
 * @param kind i32 — the peeked token kind (caller cached it)
 * @return void
 */
function parser_asm_ctrl_realign_finish_peek(lex_inout: *u8, source: *u8, kind: i32): void {
  let ts: usize = 0;
  let il: i32 = 0;
  let np: usize = 0;
  let tl: i32 = 0;
  let tc: i32 = 0;
  unsafe {
    ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
    il = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    np = parser_asm_lex_peek_next_pos_c(lex_inout, source);
    tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    parser_asm_lex_set_pos_c(lex_inout, parser_asm_lex_at_token_pos_c(kind, ts, il, np));
    parser_asm_lex_set_line_c(lex_inout, tl);
    parser_asm_lex_set_col_c(lex_inout, tc);
  }
}

/**
 * Stage 6 keyword spell length by table id (0..7).
 * 0=return 1=let 2=const 3=if 4=while 5=for 6=match 7=unsafe.
 * @param kw_id i32 — table id
 * @return i32 — keyword byte length
 */
function parser_asm_ctrl_realign_scan_kw_len(kw_id: i32): i32 {
  if (kw_id == 0) {
    return 6;
  }
  if (kw_id == 1) {
    return 3;
  }
  if (kw_id == 2) {
    return 5;
  }
  if (kw_id == 3) {
    return 2;
  }
  if (kw_id == 4) {
    return 5;
  }
  if (kw_id == 5) {
    return 3;
  }
  if (kw_id == 6) {
    return 5;
  }
  if (kw_id == 7) {
    return 6;
  }
  return 0;
}

/**
 * Stage 6 keyword spelling compare at data[scan] by table id. Caller has
 * already bounded scan+klen inside the scan window. Language has no
 * address-of for a kw literal, so each id is an explicit byte chain
 * (same style as parser_asm_ctrl_kw_if_at).
 * @param data *u8 — source bytes (non-null; caller checked)
 * @param scan usize — first keyword byte
 * @param kw_id i32 — table id (0..7)
 * @return i32 — 1 if every byte matches
 */
function parser_asm_ctrl_realign_scan_kw_bytes_at(data: *u8, scan: usize, kw_id: i32): i32 {
  unsafe {
    if (kw_id == 0) {
      if (data[scan] == 114 && data[scan + 1] == 101 && data[scan + 2] == 116 &&
          data[scan + 3] == 117 && data[scan + 4] == 114 && data[scan + 5] == 110) {
        return 1;
      }
      return 0;
    }
    if (kw_id == 1) {
      if (data[scan] == 108 && data[scan + 1] == 101 && data[scan + 2] == 116) {
        return 1;
      }
      return 0;
    }
    if (kw_id == 2) {
      if (data[scan] == 99 && data[scan + 1] == 111 && data[scan + 2] == 110 &&
          data[scan + 3] == 115 && data[scan + 4] == 116) {
        return 1;
      }
      return 0;
    }
    if (kw_id == 3) {
      if (data[scan] == 105 && data[scan + 1] == 102) {
        return 1;
      }
      return 0;
    }
    if (kw_id == 4) {
      if (data[scan] == 119 && data[scan + 1] == 104 && data[scan + 2] == 105 &&
          data[scan + 3] == 108 && data[scan + 4] == 101) {
        return 1;
      }
      return 0;
    }
    if (kw_id == 5) {
      if (data[scan] == 102 && data[scan + 1] == 111 && data[scan + 2] == 114) {
        return 1;
      }
      return 0;
    }
    if (kw_id == 6) {
      if (data[scan] == 109 && data[scan + 1] == 97 && data[scan + 2] == 116 &&
          data[scan + 3] == 99 && data[scan + 4] == 104) {
        return 1;
      }
      return 0;
    }
    if (kw_id == 7) {
      if (data[scan] == 117 && data[scan + 1] == 110 && data[scan + 2] == 115 &&
          data[scan + 3] == 97 && data[scan + 4] == 102 && data[scan + 5] == 101) {
        return 1;
      }
      return 0;
    }
  }
  return 0;
}

/**
 * Stage 6 expected token kind by table id (`unsafe` re-lexes as IDENT,
 * matching the C table's stmt_kws[].tok).
 * @param kw_id i32 — table id (0..7)
 * @return i32 — expected kind after the verify re-lex
 */
function parser_asm_ctrl_realign_scan_kw_kind(kw_id: i32): i32 {
  if (kw_id == 0) {
    return TOKEN_RETURN;
  }
  if (kw_id == 1) {
    return TOKEN_LET;
  }
  if (kw_id == 2) {
    return TOKEN_CONST;
  }
  if (kw_id == 3) {
    return TOKEN_IF;
  }
  if (kw_id == 4) {
    return TOKEN_WHILE;
  }
  if (kw_id == 5) {
    return TOKEN_FOR;
  }
  if (kw_id == 6) {
    return TOKEN_MATCH;
  }
  if (kw_id == 7) {
    return TOKEN_IDENT;
  }
  return 0;
}

/**
 * Stage 6 one-keyword pre-verify check at `scan`: window bounds, spelling,
 * previous-byte identifier boundary, and next-byte separator (space/tab/
 * CR/LF/`(`/`;`/`{`; when the keyword ends at EOF the separator check is
 * skipped, same as the C twin). Full-source length (not the 512B window)
 * gates the next-byte read, exactly like the C `scan + klen < length`.
 * @param data *u8 — source bytes (non-null; caller checked)
 * @param len usize — full source length
 * @param scan usize — candidate keyword start
 * @param scan_end usize — 512B window end (clamped to len)
 * @param kw_id i32 — table id (0..7)
 * @return i32 — 1 if the byte-level checks pass (caller then re-lexes)
 */
function parser_asm_ctrl_realign_scan_kw_at(data: *u8, len: usize, scan: usize, scan_end: usize, kw_id: i32): i32 {
  let klen: usize = 0;
  let prev: u8 = 0;
  let nx: u8 = 0;
  klen = parser_asm_ctrl_realign_scan_kw_len(kw_id) as usize;
  if (scan + klen > scan_end) {
    return 0;
  }
  if (parser_asm_ctrl_realign_scan_kw_bytes_at(data, scan, kw_id) == 0) {
    return 0;
  }
  if (scan > 0) {
    unsafe {
      prev = data[scan - 1];
    }
    if (parser_asm_ctrl_ident_continue(prev) != 0) {
      return 0;
    }
  }
  if (scan + klen < len) {
    unsafe {
      nx = data[scan + klen];
    }
    if (nx != 32 && nx != 9 && nx != 10 && nx != 13 && nx != 40 && nx != 59 && nx != 123) {
      return 0;
    }
  }
  return 1;
}

/**
 * Realign the cursor after a then/else block: parse_block sometimes lands
 * on the next if's `(`; backscan to TOKEN_IF or a statement keyword.
 * Faithful .x port of parser_asm_realign_lex_after_if_arm_c (six stages,
 * same order, same fail-leave): entry stmt-kw gate → LPAREN backscan for
 * `if` (2..128) → peek re-gate (same token as the entry gate, so the
 * cached check subsumes the C twin's second pass) → IDENT "return"
 * backtrace (7-byte backprobe + separator) → back_kw keyword scan
 * (2..160, no RBRACE) → 512B depth-0 forward keyword scan with re-lex
 * verify → rewind_following_stmt fallback. Backscan positions round-trip
 * through i32 exactly like the C twin (`(int32_t)pos_before_run(...)`).
 * Null lex/source returns 0 with the cursor untouched (a safe superset:
 * the C twin would dereference).
 * @param lex_inout *u8 — cursor; IN holds lex_cur, OUT holds the aligned
 *   lexer (pos/line/col written through the bridge trio setters)
 * @param source *u8 — opaque slice
 * @return i32 — 1 when the cursor was written (including the unchanged
 *   fallback), 0 on null inputs
 * PLATFORM: SHARED — product P5d B-minus; the by-value C name
 * `parser_asm_realign_lex_after_if_arm_c` stays on the .inc trampoline.
 */
#[no_mangle]
export function parser_asm_realign_lex_after_if_arm_into_c(lex_inout: *u8, source: *u8): i32 {
  let pos0: usize = 0;
  let line0: i32 = 0;
  let col0: i32 = 0;
  let data: *u8 = 0 as *u8;
  let len: usize = 0;
  let p_kind: i32 = 0;
  let p_il: i32 = 0;
  let p_ts: usize = 0;
  let p_np: usize = 0;
  let p_tl: i32 = 0;
  let p_tc: i32 = 0;
  let back: i32 = 0;
  let pb: i32 = 0;
  let k: i32 = 0;
  let ident_start: usize = 0;
  let sep: u8 = 0;
  let scan: usize = 0;
  let scan_end: usize = 0;
  let depth: i32 = 0;
  let ch: u8 = 0;
  let kw_id: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  unsafe {
    pos0 = parser_asm_lex_pos_c(lex_inout);
    line0 = parser_asm_lex_line_c(lex_inout);
    col0 = parser_asm_lex_col_c(lex_inout);
    data = parser_asm_lex_source_data_c(source);
    len = parser_asm_lex_source_length_c(source);
    p_kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    p_il = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    p_ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
    p_np = parser_asm_lex_peek_next_pos_c(lex_inout, source);
    p_tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    p_tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
  }
  /* Stage 1: cursor already on a statement keyword (or `}` / `unsafe`). */
  unsafe {
    if (parser_asm_ctrl_realign_stmt_kw(p_kind) != 0 ||
        parser_asm_ident_is_unsafe_stmt_kind_c(p_kind, p_il, p_ts, p_np, data, len) != 0) {
      parser_asm_ctrl_realign_finish_peek(lex_inout, source, p_kind);
      return 1;
    }
  }
  /* Stage 2: on `(` — backscan (2..128) for the owning `if`. */
  if (p_kind == TOKEN_LPAREN) {
    back = 2;
    while (back <= 128) {
      unsafe {
        pb = parser_asm_lexer_pos_before_run_c(pos0, back) as i32;
        parser_asm_lex_set_pos_c(lex_inout, pb as usize);
        parser_asm_lex_set_line_c(lex_inout, p_tl);
        parser_asm_lex_set_col_c(lex_inout, p_tc);
        if (parser_asm_lex_peek_kind_c(lex_inout, source) == TOKEN_IF) {
          parser_asm_ctrl_realign_finish_peek(lex_inout, source, TOKEN_IF);
          return 1;
        }
      }
      back = back + 1;
    }
    unsafe {
      parser_asm_lex_set_pos_c(lex_inout, pos0);
      parser_asm_lex_set_line_c(lex_inout, line0);
      parser_asm_lex_set_col_c(lex_inout, col0);
    }
  }
  /* Stage 3 re-checks the SAME peeked token with the SAME predicate as
   * stage 1 (peek = at_cur in the C twin), so the cached verdict above
   * already decided it — no second pass needed. */
  /* Stage 4: expr-head IDENT with a `return ` seven bytes behind it. */
  if (p_kind == TOKEN_IDENT) {
    ident_start = p_ts;
    if (ident_start == 0 && p_il > 0) {
      unsafe {
        ident_start = parser_asm_lexer_pos_before_run_c(p_np, p_il);
      }
    }
    if (ident_start >= 7 && data != 0 as *u8) {
      unsafe {
        if (data[ident_start - 7] == 114 && data[ident_start - 6] == 101 && data[ident_start - 5] == 116 &&
            data[ident_start - 4] == 117 && data[ident_start - 3] == 114 && data[ident_start - 2] == 110) {
          sep = data[ident_start - 1];
          if (sep == 32 || sep == 9 || sep == 10 || sep == 13) {
            parser_asm_lex_set_pos_c(lex_inout, ident_start - 7);
            parser_asm_lex_set_line_c(lex_inout, p_tl);
            parser_asm_lex_set_col_c(lex_inout, p_tc);
            return 1;
          }
        }
      }
    }
  }
  /* Stage 5: backscan (2..160) to a statement keyword (no RBRACE). */
  back = 2;
  while (back <= 160) {
    unsafe {
      pb = parser_asm_lexer_pos_before_run_c(pos0, back) as i32;
      parser_asm_lex_set_pos_c(lex_inout, pb as usize);
      parser_asm_lex_set_line_c(lex_inout, p_tl);
      parser_asm_lex_set_col_c(lex_inout, p_tc);
      k = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (parser_asm_ctrl_realign_back_kw(k) != 0) {
        parser_asm_ctrl_realign_finish_peek(lex_inout, source, k);
        return 1;
      }
      if (k == TOKEN_IDENT) {
        if (parser_asm_ident_is_unsafe_stmt_kind_c(k, parser_asm_lex_peek_ident_len_c(lex_inout, source),
                                                   parser_asm_lex_peek_token_start_c(lex_inout, source),
                                                   parser_asm_lex_peek_next_pos_c(lex_inout, source), data, len) != 0) {
          parser_asm_ctrl_realign_finish_peek(lex_inout, source, k);
          return 1;
        }
      }
    }
    back = back + 1;
  }
  unsafe {
    parser_asm_lex_set_pos_c(lex_inout, pos0);
    parser_asm_lex_set_line_c(lex_inout, line0);
    parser_asm_lex_set_col_c(lex_inout, col0);
  }
  /* Stage 6: forward scan (≤512B, paren/brace depth 0) for a statement
   * keyword, verified by a re-lex from the scan offset. */
  if (data != 0 as *u8) {
    scan = pos0;
    scan_end = scan + 512;
    if (scan_end > len) {
      scan_end = len;
    }
    depth = 0;
    while (scan + 2 < scan_end) {
      unsafe {
        ch = data[scan];
      }
      if (ch == 40) {
        depth = depth + 1;
      } else {
        if (ch == 41 && depth > 0) {
          depth = depth - 1;
        } else {
          if (ch == 123) {
            depth = depth + 1;
          } else {
            if (ch == 125 && depth > 0) {
              depth = depth - 1;
            }
          }
        }
      }
      if (depth == 0) {
        kw_id = 0;
        while (kw_id <= 7) {
          if (parser_asm_ctrl_realign_scan_kw_at(data, len, scan, scan_end, kw_id) != 0) {
            unsafe {
              parser_asm_lex_set_pos_c(lex_inout, scan);
              parser_asm_lex_set_line_c(lex_inout, line0);
              parser_asm_lex_set_col_c(lex_inout, col0);
              k = parser_asm_lex_peek_kind_c(lex_inout, source);
              if (k == parser_asm_ctrl_realign_scan_kw_kind(kw_id)) {
                parser_asm_ctrl_realign_finish_peek(lex_inout, source, k);
                return 1;
              }
              parser_asm_lex_set_pos_c(lex_inout, pos0);
              parser_asm_lex_set_line_c(lex_inout, line0);
              parser_asm_lex_set_col_c(lex_inout, col0);
            }
          }
          kw_id = kw_id + 1;
        }
      }
      scan = scan + 1;
    }
  }
  /* Fallback: rewind when the peeked token itself is a following-stmt head. */
  unsafe {
    if (parser_asm_rewind_following_stmt_kind_c(p_kind) != 0) {
      parser_asm_ctrl_realign_finish_peek(lex_inout, source, p_kind);
    } else {
      parser_asm_lex_set_pos_c(lex_inout, pos0);
      parser_asm_lex_set_line_c(lex_inout, line0);
      parser_asm_lex_set_col_c(lex_inout, col0);
    }
  }
  return 1;
}
