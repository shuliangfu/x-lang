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
// parse_if_stmt / arena / realign / match / if_expr stay C.
// sync_lex_after_if_cond_paren stays C (dead after wave650 inclusive
// parens; do not port). Do not wrap leftover else-if AUDIT. Do not
// wrap skip_one_trait/impl. Do not duplicate P1b token skip_balanced.
// skip_ws_and_comments is P9b authority. kw_at_pos_buf_c stays the
// general C-callable export; scan_sync uses file-local if/else
// probes (language has no address-of for a kw literal).
//
// Hybrid P5b/P5c: g05_try_x_to_o this file; XLANG_PTHIN_CTRL_BODIES_FROM_X
// skips the portable .inc region. No lexer-step bridge (buf-path only).
// Cold: no define, full .inc. Do not reuse XLANG_PTHIN_CTRL_FROM_X for
// P5b/P5c bodies.
// PLATFORM: SHARED freestanding.

/** P9b authority: advance past whitespace and comments. */
export extern "C" function parser_asm_stretch_skip_ws_and_comments_c(data: *u8, len: usize, pos: usize): usize;

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
