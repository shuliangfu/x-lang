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
// bytes and mis-closed large if then-bodies). parse_if_stmt / arena
// / scan_sync / realign / match / if_expr stay C. Contiguous already-T
// AUDIT_CALL padding on parse_if_stmt is compiled only under
// XLANG_PARSER_STRETCH_AUDIT (product AUDIT_CALL is already ((void)0)).
// Do not wrap the leftover else-if AUDIT after TOKEN_ELSE (scattered;
// same leftover rule as unary's leftover between two lexer_next_into).
// Do not wrap skip_one_trait/impl (trait-reg). Do not duplicate P1b
// token skip_balanced. skip_ws_and_comments is P9b authority.
//
// Hybrid P5b: g05_try_x_to_o this file; XLANG_PTHIN_CTRL_BODIES_FROM_X
// skips the portable .inc region. No lexer-step bridge (buf-path only).
// Cold: no define, full .inc. Do not reuse XLANG_PTHIN_CTRL_FROM_X for
// P5b bodies.
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
