// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

const token = import("token");

/* See implementation. */
export extern function cfg_eval_expr_c(start: *u8, len: i32): i32;

/** See implementation for details. */
allow(padding) struct Lexer {
  pos: usize;
  line: i32;
  col: i32;
}

/** See implementation for details. */
/** See implementation for details. */
allow(padding) struct LexerResult {
  next_lex: Lexer;
  tok: token.Token;
  token_start: usize;
}

/**
* See implementation.
* See implementation.
* See implementation.
*/
export extern function lexer_parser_slice_from_buf(data: *u8, len: i32): u8[];

/** Exported function `lexer_init`.
 * Implements `lexer_init`.
 * @return Lexer
 */
export function lexer_init(): Lexer {
  return Lexer { pos: 0, line: 1, col: 1 };
}

/** Exported function `advance_one`.
 * Implements `advance_one`.
 * @param lex Lexer
 * @param c u8
 * @return Lexer
 */
export function advance_one(lex: Lexer, c: u8): Lexer {
  if (c == 10) {
    return Lexer { pos: lex.pos + 1, line: lex.line + 1, col: 1 };
  }
  return Lexer { pos: lex.pos + 1, line: lex.line, col: lex.col + 1 };
}

/** Exported function `is_alpha`.
 * Query helper `is_alpha`.
 * @param c u8
 * @return bool
 */
export function is_alpha(c: u8): bool {
  if (c >= 97 && c <= 122) { return true; }
  if (c >= 65 && c <= 90) { return true; }
  return c == 95;
}

/** Exported function `is_hex_digit`.
 * Query helper `is_hex_digit`.
 * @param c u8
 * @return bool
 */
export function is_hex_digit(c: u8): bool {
  if (c >= 48 && c <= 57) { return true; }
  if (c >= 97 && c <= 102) { return true; }
  if (c >= 65 && c <= 70) { return true; }
  return false;
}

/** Exported function `hex_digit_value`.
 * Implements `hex_digit_value`.
 * @param c u8
 * @return i32
 */
export function hex_digit_value(c: u8): i32 {
  if (c >= 48 && c <= 57) { return (c - 48) as i32; }
  if (c >= 97 && c <= 102) { return (c - 97 + 10) as i32; }
  if (c >= 65 && c <= 70) { return (c - 65 + 10) as i32; }
  return 0;
}

/** Exported function `is_digit`.
 * Query helper `is_digit`.
 * @param c u8
 * @return bool
 */
export function is_digit(c: u8): bool {
  return c >= 48 && c <= 57;
}

/** Exported function `is_alnum_underscore`.
 * Query helper `is_alnum_underscore`.
 * @param c u8
 * @return bool
 */
export function is_alnum_underscore(c: u8): bool {
  return is_alpha(c) || is_digit(c);
}

/** Exported function `match_keyword`.
 * Implements `match_keyword`.
 * @param data u8[]
 * @param start usize
 * @param len i32
 * @param keyword u8[]
 * @return bool
 */
export function match_keyword(data: u8[], start: usize, len: i32, keyword: u8[]): bool {
  let i: i32 = 0;
  while (i < len) {
    if (data[start + i] != keyword[i]) { return false; }
    i = i + 1;
  }
  return true;
}

/** Exported function `match_keyword_buf`.
 * Implements `match_keyword_buf`.
 * @param data *u8
 * @param data_len i32
 * @param start usize
 * @param len i32
 * @param keyword u8[]
 * @return bool
 */
export function match_keyword_buf(data: *u8, data_len: i32, start: usize, len: i32, keyword: u8[]): bool {
  let i: i32 = 0;
  while (i < len) {
    if ((start as i32) + i >= data_len) { return false; }
    if (data[start + i] != keyword[i]) { return false; }
    i = i + 1;
  }
  return true;
}

/** Map scanned identifier (data, start, len) to a keyword token.Token, or
 * TOKEN_IDENT (ident null, ident_len = len) when not a keyword.
 *
 * kind fields use TokenKind ordinal integers (see token.x export enum order:
 * 0=TOKEN_EOF, 1=TOKEN_FUNCTION, …). Direct `kind: token.TokenKind.VARIANT`
 * inside `token.Token { ... }` still hits a codegen residual (entry emission
 * -6); ordinals are the product-safe form and match the cold seed C
 * (token_TokenKind_TOKEN_* tags). Comparisons elsewhere may use the same
 * ordinals. PLATFORM: SHARED. */
export function try_keyword(data: u8[], start: usize, len: usize, line0: i32, col0: i32): token.Token {
  if (len == 8 && match_keyword(data, start, 8, [102, 117, 110, 99, 116, 105, 111, 110])) {
    let t: token.Token = token.Token {
      kind: 1,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 3 && match_keyword(data, start, 3, [108, 101, 116])) {
    let t: token.Token = token.Token {
      kind: 2,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 5 && match_keyword(data, start, 5, [99, 111, 110, 115, 116])) {
    let t: token.Token = token.Token {
      kind: 3,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 2 && match_keyword(data, start, 2, [105, 102])) {
    let t: token.Token = token.Token {
      kind: 4,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 4 && match_keyword(data, start, 4, [101, 108, 115, 101])) {
    let t: token.Token = token.Token {
      kind: 5,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 5 && match_keyword(data, start, 5, [119, 104, 105, 108, 101])) {
    let t: token.Token = token.Token {
      kind: 6,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 4 && match_keyword(data, start, 4, [108, 111, 111, 112])) {
    let t: token.Token = token.Token {
      kind: 7,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 3 && match_keyword(data, start, 3, [102, 111, 114])) {
    let t: token.Token = token.Token {
      kind: 8,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 5 && match_keyword(data, start, 5, [98, 114, 101, 97, 107])) {
    let t: token.Token = token.Token {
      kind: 9,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 8 && match_keyword(data, start, 8, [99, 111, 110, 116, 105, 110, 117, 101])) {
    let t: token.Token = token.Token {
      kind: 10,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 6 && match_keyword(data, start, 6, [114, 101, 116, 117, 114, 110])) {
    let t: token.Token = token.Token {
      kind: 11,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 5 && match_keyword(data, start, 5, [112, 97, 110, 105, 99])) {
    let t: token.Token = token.Token {
      kind: 12,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 5 && match_keyword(data, start, 5, [100, 101, 102, 101, 114])) {
    let t: token.Token = token.Token {
      kind: 13,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 6 && match_keyword(data, start, 6, [114, 101, 103, 105, 111, 110])) {
    let t: token.Token = token.Token {
      kind: 16,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 10 && match_keyword(data, start, 10, [119, 105, 116, 104, 95, 97, 114, 101, 110, 97])) {
    let t: token.Token = token.Token {
      kind: 17,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 5 && match_keyword(data, start, 5, [109, 97, 116, 99, 104])) {
    let t: token.Token = token.Token {
      kind: 18,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 6 && match_keyword(data, start, 6, [115, 116, 114, 117, 99, 116])) {
    let t: token.Token = token.Token {
      kind: 19,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 4 && match_keyword(data, start, 4, [116, 121, 112, 101])) {
    let t: token.Token = token.Token {
      kind: 20,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 6 && match_keyword(data, start, 6, [112, 97, 99, 107, 101, 100])) {
    let t: token.Token = token.Token {
      kind: 21,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 3 && match_keyword(data, start, 3, [115, 111, 97])) {
    let t: token.Token = token.Token {
      kind: 22,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 5 && match_keyword(data, start, 5, [97, 108, 105, 103, 110])) {
    let t: token.Token = token.Token {
      kind: 46,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 4 && match_keyword(data, start, 4, [101, 110, 117, 109])) {
    let t: token.Token = token.Token {
      kind: 47,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 4 && match_keyword(data, start, 4, [103, 111, 116, 111])) {
    let t: token.Token = token.Token {
      kind: 48,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 5 && match_keyword(data, start, 5, [116, 114, 97, 105, 116])) {
    let t: token.Token = token.Token {
      kind: 49,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 4 && match_keyword(data, start, 4, [105, 109, 112, 108])) {
    let t: token.Token = token.Token {
      kind: 50,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 4 && match_keyword(data, start, 4, [115, 101, 108, 102])) {
    let t: token.Token = token.Token {
      kind: 51,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 1 && data[start] == 95) {
    let t: token.Token = token.Token {
      kind: 52,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 6 && match_keyword(data, start, 6, [105, 109, 112, 111, 114, 116])) {
    let t: token.Token = token.Token {
      kind: 53,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 6 && match_keyword(data, start, 6, [101, 120, 116, 101, 114, 110])) {
    let t: token.Token = token.Token {
      kind: 54,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 5 && match_keyword(data, start, 5, [97, 115, 121, 110, 99])) {
    let t: token.Token = token.Token {
      kind: 55,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 5 && match_keyword(data, start, 5, [97, 119, 97, 105, 116])) {
    let t: token.Token = token.Token {
      kind: 56,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 3 && match_keyword(data, start, 3, [114, 117, 110])) {
    let t: token.Token = token.Token {
      kind: 57,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 5 && match_keyword(data, start, 5, [115, 112, 97, 119, 110])) {
    let t: token.Token = token.Token {
      kind: 58,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  /** export：e x p o r t */
  if (len == 6 && match_keyword(data, start, 6, [101, 120, 112, 111, 114, 116])) {
    let t: token.Token = token.Token {
      kind: 131,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 3 && match_keyword(data, start, 3, [105, 51, 50])) {
    let t: token.Token = token.Token {
      kind: 60,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 4 && match_keyword(data, start, 4, [98, 111, 111, 108])) {
    let t: token.Token = token.Token {
      kind: 61,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 2 && match_keyword(data, start, 2, [117, 56])) {
    let t: token.Token = token.Token {
      kind: 62,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 3 && match_keyword(data, start, 3, [117, 51, 50])) {
    let t: token.Token = token.Token {
      kind: 63,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 3 && match_keyword(data, start, 3, [117, 54, 52])) {
    let t: token.Token = token.Token {
      kind: 64,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 3 && match_keyword(data, start, 3, [105, 54, 52])) {
    let t: token.Token = token.Token {
      kind: 65,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 5 && match_keyword(data, start, 5, [117, 115, 105, 122, 101])) {
    let t: token.Token = token.Token {
      kind: 66,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 5 && match_keyword(data, start, 5, [105, 115, 105, 122, 101])) {
    let t: token.Token = token.Token {
      kind: 67,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 4 && match_keyword(data, start, 4, [116, 114, 117, 101])) {
    let t: token.Token = token.Token {
      kind: 75,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 5 && match_keyword(data, start, 5, [102, 97, 108, 115, 101])) {
    let t: token.Token = token.Token {
      kind: 76,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 3 && match_keyword(data, start, 3, [102, 51, 50])) {
    let t: token.Token = token.Token {
      kind: 77,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 3 && match_keyword(data, start, 3, [102, 54, 52])) {
    let t: token.Token = token.Token {
      kind: 78,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 4 && match_keyword(data, start, 4, [118, 111, 105, 100])) {
    let t: token.Token = token.Token {
      kind: 79,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 5 && match_keyword(data, start, 5, [105, 51, 120, 52])) {
    let t: token.Token = token.Token {
      kind: 68,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 5 && match_keyword(data, start, 5, [105, 51, 120, 56])) {
    let t: token.Token = token.Token {
      kind: 69,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 6 && match_keyword(data, start, 6, [105, 51, 120, 49, 54])) {
    let t: token.Token = token.Token {
      kind: 70,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 5 && match_keyword(data, start, 5, [117, 51, 120, 52])) {
    let t: token.Token = token.Token {
      kind: 71,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 5 && match_keyword(data, start, 5, [117, 51, 120, 56])) {
    let t: token.Token = token.Token {
      kind: 72,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 6 && match_keyword(data, start, 6, [117, 51, 120, 49, 54])) {
    let t: token.Token = token.Token {
      kind: 73,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  if (len == 2 && match_keyword(data, start, 2, [97, 115])) {
    let t: token.Token = token.Token {
      kind: 128,
      line: line0,
      col: col0,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return t;
  }
  let t: token.Token = token.Token {
    kind: 59,
    line: line0,
    col: col0,
    int_val: 0,
    float_val: 0.0,
    ident: 0,
    ident_len: len
  }
  return t;
}

/* See implementation. */
export function try_keyword_buf(data: *u8, data_len: i32, start: usize, len: usize, line0: i32, col0:
i32): token.Token {
  if (len == 8 && match_keyword_buf(data, data_len, start, 8, [102, 117, 110, 99, 116, 105, 111,
  110])) {
    let t: token.Token = token.Token { kind: 1, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 3 && match_keyword_buf(data, data_len, start, 3, [108, 101, 116])) {
    let t: token.Token = token.Token { kind: 2, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 5 && match_keyword_buf(data, data_len, start, 5, [99, 111, 110, 115, 116])) {
    let t: token.Token = token.Token { kind: 3, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 2 && match_keyword_buf(data, data_len, start, 2, [105, 102])) {
    let t: token.Token = token.Token { kind: 4, line: line0, col: col0, int_val: 0, float_val:
      0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 4 && match_keyword_buf(data, data_len, start, 4, [101, 108, 115, 101])) {
    let t: token.Token = token.Token { kind: 5, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 6 && match_keyword_buf(data, data_len, start, 6, [114, 101, 116, 117, 114, 110])) {
    let t: token.Token = token.Token { kind: 11, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 6 && match_keyword_buf(data, data_len, start, 6, [115, 116, 114, 117, 99, 116])) {
    let t: token.Token = token.Token { kind: 19, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 4 && match_keyword_buf(data, data_len, start, 4, [116, 121, 112, 101])) {
    let t: token.Token = token.Token { kind: 20, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 4 && match_keyword_buf(data, data_len, start, 4, [101, 110, 117, 109])) {
    let t: token.Token = token.Token { kind: 47, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 5 && match_keyword_buf(data, data_len, start, 5, [109, 97, 116, 99, 104])) {
    let t: token.Token = token.Token { kind: 18, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 4 && match_keyword_buf(data, data_len, start, 4, [116, 114, 117, 101])) {
    let t: token.Token = token.Token { kind: 75, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 5 && match_keyword_buf(data, data_len, start, 5, [102, 97, 108, 115, 101])) {
    let t: token.Token = token.Token { kind: 76, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 3 && match_keyword_buf(data, data_len, start, 3, [102, 54, 52])) {
    let t: token.Token = token.Token { kind: 78, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 4 && match_keyword_buf(data, data_len, start, 4, [118, 111, 105, 100])) {
    let t: token.Token = token.Token { kind: 79, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 3 && match_keyword_buf(data, data_len, start, 3, [105, 51, 50])) {
    let t: token.Token = token.Token { kind: 60, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 4 && match_keyword_buf(data, data_len, start, 4, [98, 111, 111, 108])) {
    let t: token.Token = token.Token { kind: 61, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 2 && match_keyword_buf(data, data_len, start, 2, [117, 56])) {
    let t: token.Token = token.Token { kind: 62, line: line0, col: col0, int_val: 0, float_val:
      0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 5 && match_keyword_buf(data, data_len, start, 5, [117, 115, 105, 122, 101])) {
    let t: token.Token = token.Token { kind: 66, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 5 && match_keyword_buf(data, data_len, start, 5, [105, 115, 105, 122, 101])) {
    let t: token.Token = token.Token { kind: 67, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 2 && match_keyword_buf(data, data_len, start, 2, [97, 115])) {
    let t: token.Token = token.Token { kind: 128, line: line0, col: col0, int_val: 0, float_val:
      0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 6 && match_keyword_buf(data, data_len, start, 6, [105, 109, 112, 111, 114, 116])) {
    let t: token.Token = token.Token { kind: 53, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 6 && match_keyword_buf(data, data_len, start, 6, [101, 120, 116, 101, 114, 110])) {
    let t: token.Token = token.Token { kind: 54, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 5 && match_keyword_buf(data, data_len, start, 5, [97, 115, 121, 110, 99])) {
    let t: token.Token = token.Token { kind: 55, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 5 && match_keyword_buf(data, data_len, start, 5, [97, 119, 97, 105, 116])) {
    let t: token.Token = token.Token { kind: 56, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 3 && match_keyword_buf(data, data_len, start, 3, [114, 117, 110])) {
    let t: token.Token = token.Token { kind: 57, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 5 && match_keyword_buf(data, data_len, start, 5, [115, 112, 97, 119, 110])) {
    let t: token.Token = token.Token { kind: 58, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 6 && match_keyword_buf(data, data_len, start, 6, [101, 120, 112, 111, 114, 116])) {
    let t: token.Token = token.Token { kind: 131, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  if (len == 1 && start < (data_len as usize) && data[start] == 95) {
    let t: token.Token = token.Token { kind: 52, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return t;
  }
  let t: token.Token = token.Token { kind: 59, line: line0, col: col0, int_val: 0,
    float_val: 0.0, ident: 0, ident_len: len }
  return t;
}

/**
 * See implementation.
 * See implementation.
 */
export function skip_repr_c_attr_if_present(lex: Lexer, data: u8[]): Lexer {
  let l: Lexer = lex;
  if (l.pos + 10 > data.length) {
    return l;
  }
  if (data[l.pos] != 35 || data[l.pos + 1] != 91) {
    return l;
  }
  if (data[l.pos + 2] != 114 || data[l.pos + 3] != 101 || data[l.pos + 4] != 112 ||
      data[l.pos + 5] != 114) {
    return l;
  }
  if (data[l.pos + 6] != 40 || data[l.pos + 7] != 67 || data[l.pos + 8] != 41 ||
      data[l.pos + 9] != 93) {
    return l;
  }
  return Lexer { pos: l.pos + 10, line: l.line, col: l.col };
}

/**
 * See implementation.
 * See implementation.
 */
export function skip_cfg_attr_if_present(lex: Lexer, data: u8[]): Lexer {
  let l: Lexer = lex;
  let p: usize = 0;
  let depth: i32 = 0;
  if (l.pos + 6 > data.length) {
    return l;
  }
  if (data[l.pos] != 35 || data[l.pos + 1] != 91) {
    return l;
  }
  if (data[l.pos + 2] != 99 || data[l.pos + 3] != 102 || data[l.pos + 4] != 103) {
    return l;
  }
  if (data[l.pos + 5] != 40) {
    return l;
  }
  p = l.pos + (6 as usize);
  depth = 1;
  while (p < data.length && depth > 0) {
    if (data[p] == 40) {
      depth = depth + 1;
    } else if (data[p] == 41) {
      depth = depth - 1;
    }
    p = p + (1 as usize);
  }
  if (p >= data.length || data[p] != 93) {
    return lex;
  }
  p = p + (1 as usize);
  return Lexer { pos: p, line: l.line, col: l.col };
}

/**
 * B-01 v1: If `l` is at `#[cfg(...)]`, evaluate host match, write TOKEN_ATTR_CFG, return 1.
 * Copies the expression into a stack buffer before cfg_eval_expr_c (avoids C-frontend ambiguity).
 * PLATFORM: SHARED — LANG-007 S0: cfg_eval_expr_c is extern FFI inside unsafe (Cap-T001).
 */
export function lexer_try_cfg_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  let line0: i32 = l.line;
  let col0: i32 = l.col;
  let p: usize = 0;
  let depth: i32 = 0;
  let expr_start: usize = 0;
  if (l.pos + 6 > data.length) {
    return 0;
  }
  if (data[l.pos] != 35 || data[l.pos + 1] != 91) {
    return 0;
  }
  if (data[l.pos + 2] != 99 || data[l.pos + 3] != 102 || data[l.pos + 4] != 103) {
    return 0;
  }
  if (data[l.pos + 5] != 40) {
    return 0;
  }
  p = l.pos + (6 as usize);
  depth = 1;
  expr_start = p;
  while (p < data.length && depth > 0) {
    if (data[p] == 40) {
      depth = depth + 1;
    } else if (data[p] == 41) {
      depth = depth - 1;
    }
    p = p + (1 as usize);
  }
  if (p >= data.length || data[p] != 93) {
    return 0;
  }
  let expr_len: i32 = (p as i32) - (expr_start as i32) - 1;
  if (expr_len <= 0 || expr_len > 127) {
    return 0;
  }
  let tmp: u8[128] = [];
  let ti: i32 = 0;
  while (ti < expr_len) {
    tmp[ti] = data[expr_start + (ti as usize)];
    ti = ti + 1;
  }
  // PLATFORM: SHARED — LANG-007 S0: extern call requires unsafe (Cap-T001).
  let enabled: i32 = 0;
  unsafe {
    enabled = cfg_eval_expr_c(&tmp[0], expr_len);
  }
  p = p + (1 as usize);
  let l2: Lexer = Lexer { pos: p, line: l.line, col: l.col };
  let tok: token.Token = token.Token {
    kind: 24,
    line: line0,
    col: col0,
    int_val: enabled,
    float_val: 0.0,
    ident: 0,
    ident_len: 0
  };
  write_next_lex_into(out, l2);
  write_tok_into(out, tok);
  out.token_start = (0 as usize);
  return 1;
}

/**
 * See implementation.
 * See implementation.
 */
export function lexer_try_repr_c_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + 10 > data.length) {
    return 0;
  }
  if (data[l.pos] != 35 || data[l.pos + 1] != 91) {
    return 0;
  }
  if (data[l.pos + 2] != 114 || data[l.pos + 3] != 101 || data[l.pos + 4] != 112 ||
      data[l.pos + 5] != 114) {
    return 0;
  }
  if (data[l.pos + 6] != 40 || data[l.pos + 7] != 67 || data[l.pos + 8] != 41 ||
      data[l.pos + 9] != 93) {
    return 0;
  }
  let line0: i32 = l.line;
  let col0: i32 = l.col;
  let np: usize = l.pos + (10 as usize);
  let l2: Lexer = Lexer { pos: np, line: line0, col: col0 };
  let tok: token.Token = token.Token {
    kind: 25,
    line: line0,
    col: col0,
    int_val: 0,
    float_val: 0.0,
    ident: 0,
    ident_len: 0
  };
  write_next_lex_into(out, l2);
  write_tok_into(out, tok);
  out.token_start = (0 as usize);
  return 1;
}

/**
 * See implementation.
 */
export function lexer_try_repr_compatible_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + 19 > data.length) {
    return 0;
  }
  if (data[l.pos] != 35 || data[l.pos + 1] != 91) {
    return 0;
  }
  if (data[l.pos + 2] != 114 || data[l.pos + 3] != 101 || data[l.pos + 4] != 112 ||
      data[l.pos + 5] != 114) {
    return 0;
  }
  if (data[l.pos + 6] != 40) {
    return 0;
  }
  if (data[l.pos + 7] != 99 || data[l.pos + 8] != 111 || data[l.pos + 9] != 109 ||
      data[l.pos + 10] != 112 || data[l.pos + 11] != 97 || data[l.pos + 12] != 116 ||
      data[l.pos + 13] != 105 || data[l.pos + 14] != 98 || data[l.pos + 15] != 108 ||
      data[l.pos + 16] != 101) {
    return 0;
  }
  if (data[l.pos + 17] != 41 || data[l.pos + 18] != 93) {
    return 0;
  }
  let line0: i32 = l.line;
  let col0: i32 = l.col;
  let np: usize = l.pos + (19 as usize);
  let l2: Lexer = Lexer { pos: np, line: line0, col: col0 };
  let tok: token.Token = token.Token {
    kind: 26,
    line: line0,
    col: col0,
    int_val: 0,
    float_val: 0.0,
    ident: 0,
    ident_len: 0
  };
  write_next_lex_into(out, l2);
  write_tok_into(out, tok);
  out.token_start = (0 as usize);
  return 1;
}

/**
 * See implementation.
 */
export function lexer_try_soa_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + 6 > data.length) {
    return 0;
  }
  if (data[l.pos] != 35 || data[l.pos + 1] != 91) {
    return 0;
  }
  if (data[l.pos + 2] != 115 || data[l.pos + 3] != 111 || data[l.pos + 4] != 97 ||
      data[l.pos + 5] != 93) {
    return 0;
  }
  let line0: i32 = l.line;
  let col0: i32 = l.col;
  let l2: Lexer = l;
  l2 = advance_one(l2, 35);
  l2 = advance_one(l2, 91);
  l2 = advance_one(l2, 115);
  l2 = advance_one(l2, 111);
  l2 = advance_one(l2, 97);
  l2 = advance_one(l2, 93);
  let tok: token.Token = token.Token {
    kind: 23,
    line: line0,
    col: col0,
    int_val: 0,
    float_val: 0.0,
    ident: 0,
    ident_len: 0
  };
  write_next_lex_into(out, l2);
  write_tok_into(out, tok);
  out.token_start = (0 as usize);
  return 1;
}

/**
 * See implementation.
 */
export function lexer_try_alloc_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + 8 > data.length) {
    return 0;
  }
  if (data[l.pos] != 35 || data[l.pos + 1] != 91) {
    return 0;
  }
  if (data[l.pos + 2] != 97 || data[l.pos + 3] != 108 || data[l.pos + 4] != 108 ||
      data[l.pos + 5] != 111 || data[l.pos + 6] != 99 || data[l.pos + 7] != 93) {
    return 0;
  }
  let line0: i32 = l.line;
  let col0: i32 = l.col;
  let l2: Lexer = l;
  l2 = advance_one(l2, 35);
  l2 = advance_one(l2, 91);
  l2 = advance_one(l2, 97);
  l2 = advance_one(l2, 108);
  l2 = advance_one(l2, 108);
  l2 = advance_one(l2, 111);
  l2 = advance_one(l2, 99);
  l2 = advance_one(l2, 93);
  let tok: token.Token = token.Token {
    kind: 27,
    line: line0,
    col: col0,
    int_val: 0,
    float_val: 0.0,
    ident: 0,
    ident_len: 0
  };
  write_next_lex_into(out, l2);
  write_tok_into(out, tok);
  out.token_start = (0 as usize);
  return 1;
}

/**
 * See implementation.
 */
export function lexer_try_used_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + 7 > data.length) {
    return 0;
  }
  if (data[l.pos] != 35 || data[l.pos + 1] != 91) {
    return 0;
  }
  if (data[l.pos + 2] != 117 || data[l.pos + 3] != 115 ||
      data[l.pos + 4] != 101 || data[l.pos + 5] != 100 || data[l.pos + 6] != 93) {
    return 0;
  }
  let line0: i32 = l.line;
  let col0: i32 = l.col;
  let l2: Lexer = l;
  l2 = advance_one(l2, 35);
  l2 = advance_one(l2, 91);
  l2 = advance_one(l2, 117);
  l2 = advance_one(l2, 115);
  l2 = advance_one(l2, 101);
  l2 = advance_one(l2, 100);
  l2 = advance_one(l2, 93);
  let tok: token.Token = token.Token {
    kind: 31,
    line: line0,
    col: col0,
    int_val: 0,
    float_val: 0.0,
    ident: 0,
    ident_len: 0
  };
  write_next_lex_into(out, l2);
  write_tok_into(out, tok);
  out.token_start = (0 as usize);
  return 1;
}

/**
 * See implementation.
 */
export function lexer_try_naked_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + 8 > data.length) { return 0; }
  if (data[l.pos] != 35 || data[l.pos + 1] != 91) { return 0; }
  if (data[l.pos + 2] != 110 || data[l.pos + 3] != 97 || data[l.pos + 4] != 107 ||
      data[l.pos + 5] != 101 || data[l.pos + 6] != 100 || data[l.pos + 7] != 93) { return 0; }
  let line0: i32 = l.line; let col0: i32 = l.col; let l2: Lexer = l;
  l2 = advance_one(l2, 35); l2 = advance_one(l2, 91); l2 = advance_one(l2, 110);
  l2 = advance_one(l2, 97); l2 = advance_one(l2, 107); l2 = advance_one(l2, 101);
  l2 = advance_one(l2, 100); l2 = advance_one(l2, 93);
  write_next_lex_into(out, l2);
  write_tok_into(out, token.Token { kind: 29, line: line0, col: col0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 });
  out.token_start = (0 as usize); return 1;
}

/**
 * See implementation.
 */
export function lexer_try_entry_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + 8 > data.length) { return 0; }
  if (data[l.pos] != 35 || data[l.pos + 1] != 91) { return 0; }
  if (data[l.pos + 2] != 101 || data[l.pos + 3] != 110 || data[l.pos + 4] != 116 ||
      data[l.pos + 5] != 114 || data[l.pos + 6] != 121 || data[l.pos + 7] != 93) { return 0; }
  let line0: i32 = l.line; let col0: i32 = l.col; let l2: Lexer = l;
  l2 = advance_one(l2, 35); l2 = advance_one(l2, 91); l2 = advance_one(l2, 101);
  l2 = advance_one(l2, 110); l2 = advance_one(l2, 116); l2 = advance_one(l2, 114);
  l2 = advance_one(l2, 101); l2 = advance_one(l2, 93);
  write_next_lex_into(out, l2);
  write_tok_into(out, token.Token { kind: 30, line: line0, col: col0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 });
  out.token_start = (0 as usize); return 1;
}

/**
 * See implementation.
 */
export function lexer_try_no_mangle_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + 12 > data.length) { return 0; }
  if (data[l.pos] != 35 || data[l.pos + 1] != 91) { return 0; }
  if (data[l.pos + 2] != 110 || data[l.pos + 3] != 111 || data[l.pos + 4] != 95 ||
      data[l.pos + 5] != 109 || data[l.pos + 6] != 97 || data[l.pos + 7] != 110 ||
      data[l.pos + 8] != 103 || data[l.pos + 9] != 108 || data[l.pos + 10] != 101 || data[l.pos + 11] != 93) { return 0; }
  let line0: i32 = l.line; let col0: i32 = l.col; let l2: Lexer = l;
  l2 = advance_one(l2, 35); l2 = advance_one(l2, 91); l2 = advance_one(l2, 110);
  l2 = advance_one(l2, 111); l2 = advance_one(l2, 95); l2 = advance_one(l2, 109);
  l2 = advance_one(l2, 97); l2 = advance_one(l2, 110); l2 = advance_one(l2, 103);
  l2 = advance_one(l2, 108); l2 = advance_one(l2, 101); l2 = advance_one(l2, 93);
  write_next_lex_into(out, l2);
  write_tok_into(out, token.Token { kind: 32, line: line0, col: col0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 });
  out.token_start = (0 as usize); return 1;
}

/**
 * See implementation.
 */
export function lexer_try_interrupt_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + 13 > data.length) { return 0; }
  if (data[l.pos] != 35 || data[l.pos + 1] != 91) { return 0; }
  if (data[l.pos + 2] != 105 || data[l.pos + 3] != 110 || data[l.pos + 4] != 116 ||
      data[l.pos + 5] != 101 || data[l.pos + 6] != 114 || data[l.pos + 7] != 114 ||
      data[l.pos + 8] != 117 || data[l.pos + 9] != 112 || data[l.pos + 10] != 116 || data[l.pos + 11] != 93) { return 0; }
  let line0: i32 = l.line; let col0: i32 = l.col; let l2: Lexer = l;
  l2 = advance_one(l2, 35); l2 = advance_one(l2, 91); l2 = advance_one(l2, 105);
  l2 = advance_one(l2, 110); l2 = advance_one(l2, 116); l2 = advance_one(l2, 101);
  l2 = advance_one(l2, 114); l2 = advance_one(l2, 114); l2 = advance_one(l2, 117);
  l2 = advance_one(l2, 112); l2 = advance_one(l2, 116); l2 = advance_one(l2, 93);
  write_next_lex_into(out, l2);
  write_tok_into(out, token.Token { kind: 35, line: line0, col: col0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 });
  out.token_start = (0 as usize); return 1;
}

/**
 * See implementation.
 */
export function lexer_try_send_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + 8 > data.length) { return 0; }
  if (data[l.pos] != 35 || data[l.pos + 1] != 91) { return 0; }
  if (data[l.pos + 2] != 115 || data[l.pos + 3] != 101 || data[l.pos + 4] != 110 ||
      data[l.pos + 5] != 100 || data[l.pos + 6] != 93) { return 0; }
  let line0: i32 = l.line; let col0: i32 = l.col; let l2: Lexer = l;
  l2 = advance_one(l2, 35); l2 = advance_one(l2, 91); l2 = advance_one(l2, 115);
  l2 = advance_one(l2, 101); l2 = advance_one(l2, 110); l2 = advance_one(l2, 100);
  l2 = advance_one(l2, 93);
  write_next_lex_into(out, l2);
  write_tok_into(out, token.Token { kind: 36, line: line0, col: col0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 });
  out.token_start = (0 as usize); return 1;
}

/**
 * See implementation.
 */
export function lexer_try_sync_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + 8 > data.length) { return 0; }
  if (data[l.pos] != 35 || data[l.pos + 1] != 91) { return 0; }
  if (data[l.pos + 2] != 115 || data[l.pos + 3] != 121 || data[l.pos + 4] != 110 ||
      data[l.pos + 5] != 99 || data[l.pos + 6] != 93) { return 0; }
  let line0: i32 = l.line; let col0: i32 = l.col; let l2: Lexer = l;
  l2 = advance_one(l2, 35); l2 = advance_one(l2, 91); l2 = advance_one(l2, 115);
  l2 = advance_one(l2, 121); l2 = advance_one(l2, 110); l2 = advance_one(l2, 99);
  l2 = advance_one(l2, 93);
  write_next_lex_into(out, l2);
  write_tok_into(out, token.Token { kind: 37, line: line0, col: col0, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 });
  out.token_start = (0 as usize); return 1;
}

/**
 * Whether `prev` continues a path/ident so an interior `/`+`*` is a path glob
 * (e.g. `src/*.x`, `arrow}/*.o`), not a nested block-comment opener.
 * @param prev u8 — byte immediately before a candidate `/` of `/*`
 * @return i32 — 1 if path/ident continuum (suppress nest-open), else 0
 * PLATFORM: SHARED
 */
function lexer_block_comment_prev_is_path_like(prev: u8): i32 {
  // A-Z
  if (prev >= 65) {
    if (prev <= 90) {
      return 1;
    }
  }
  // a-z
  if (prev >= 97) {
    if (prev <= 122) {
      return 1;
    }
  }
  // 0-9
  if (prev >= 48) {
    if (prev <= 57) {
      return 1;
    }
  }
  // _ . } ) ] > " '
  if (prev == 95) {
    return 1;
  }
  if (prev == 46) {
    return 1;
  }
  if (prev == 125) {
    return 1;
  }
  if (prev == 41) {
    return 1;
  }
  if (prev == 93) {
    return 1;
  }
  if (prev == 62) {
    return 1;
  }
  if (prev == 34) {
    return 1;
  }
  if (prev == 39) {
    return 1;
  }
  return 0;
}

/**
 * Skip whitespace and comments from the current lexer position.
 *
 * Line comments: `//` to end of line, and bare `#` lines (not `#[` attrs).
 * Block comments (single-line and multi-line — one algorithm): nested `/* ... */`
 * by head/tail depth balance (not C first-close):
 *   - outer `/*` sets depth=1; each true nest-open `/*` does depth+1;
 *   - each `*/` does depth-1; the block ends only when depth returns to 0.
 * Examples (all valid on one line):
 *   `/* xxx /* xxx */ xxx */`, `/* /* */ */`, `/**/`, dense `/*/*inner*/*/`.
 * Unbalanced `/* /* */` alone leaves depth>0 (unclosed) — need a second `*/`.
 *
 * Nest-open is path-safe (wave138 root fix):
 * - Intentional nests still open: space/`*` before `/*`, prose `/**/`, dense nests.
 * - Path globs do NOT open: `src/*.x`, `std/*.o`, `std/db/{kv,arrow}/*.o`,
 *   line-start `/*.o` (prev path-like, or next byte after `/*` is `.`).
 * Unmatched bare `*/` with no nested open still closes the outer block (depth 1 → 0).
 *
 * PLATFORM: SHARED — language lexical semantics; dual-host product matrix.
 *
 * @param lex Lexer — current position / line / col
 * @param data u8[] — full source buffer (not required to be NUL-terminated)
 * @return Lexer — advanced past whitespace and comments; unchanged on EOF
 */
export function skip_whitespace_and_comments(lex: Lexer, data: u8[]): Lexer {
  let l: Lexer = lex;
  // Nesting depth for block comments; 0 means not inside a block comment.
  let depth: i32 = 0;
  while (l.pos < data.length) {
    let c: u8 = data[l.pos];
    if (c == 32 || c == 9 || c == 10 || c == 13) {
      l = advance_one(l, c);
    } else if (c == 47 && l.pos + 1 < data.length && data[l.pos + 1] == 47) {
      // Line comment // ...
      while (l.pos < data.length && data[l.pos] != 10) {
        l = advance_one(l, data[l.pos]);
      }
    } else if (c == 47 && l.pos + 1 < data.length && data[l.pos + 1] == 42) {
      // Block comment /* ... */ with nesting (depth counter).
      l = advance_one(l, 47);
      l = advance_one(l, 42);
      depth = 1;
      while (l.pos < data.length && depth > 0) {
        // Prefer path-safe /* nest-open before */ nest-close when both could match.
        if (l.pos + 1 < data.length && data[l.pos] == 47 && data[l.pos + 1] == 42) {
          // Decide whether this interior /* is a true nest or a path glob.
          let nest_ok: i32 = 1;
          if (l.pos > (0 as usize)) {
            let prev: u8 = data[l.pos - (1 as usize)];
            if (lexer_block_comment_prev_is_path_like(prev) != 0) {
              nest_ok = 0;
            }
          }
          // /*.ext path globs after newline / outer open (prev not path-like).
          if (nest_ok != 0) {
            if (l.pos + 2 < data.length) {
              if (data[l.pos + 2] == 46) {
                nest_ok = 0;
              }
            }
          }
          if (nest_ok != 0) {
            l = advance_one(l, 47);
            l = advance_one(l, 42);
            depth = depth + 1;
          } else {
            // Path glob or non-nest: consume only '/' so '*' is ordinary body text.
            l = advance_one(l, data[l.pos]);
          }
        } else if (l.pos + 1 < data.length && data[l.pos] == 42 && data[l.pos + 1] == 47) {
          l = advance_one(l, 42);
          l = advance_one(l, 47);
          depth = depth - 1;
        } else {
          l = advance_one(l, data[l.pos]);
        }
      }
      // EOF with depth > 0: unclosed block comment; body already swallowed to EOF.
      // Parser sees missing following decls (fail). Prefer path-safe nest so this
      // is rare; dedicated unclosed diag is a follow-up if needed.
      depth = 0;
    } else if (c == 35) {
      // Bare # line comment; leave #[cfg]/attrs to the token scanner.
      if (l.pos + 1 < data.length && data[l.pos + 1] == 91) {
        return l;
      } else {
        while (l.pos < data.length && data[l.pos] != 10) {
          l = advance_one(l, data[l.pos]);
        }
      }
    } else {
      return l;
    }
  }
  return l;
}

/** See implementation for details. */
/**
 * Same as skip_whitespace_and_comments for raw (data, len) buffers.
 * PLATFORM: SHARED — LANG-007 S0: slice glue is extern; call inside unsafe (Cap-T001).
 */
export function skip_whitespace_and_comments_buf(lex: Lexer, data: *u8, len: i32): Lexer {
  unsafe {
    return skip_whitespace_and_comments(lex, lexer_parser_slice_from_buf(data, len));
  }
  return lex;
}

/** Exported function `lexer_next`.
 * Implements `lexer_next`.
 * @param lex Lexer
 * @param data u8[]
 * @return LexerResult
 */
export function lexer_next(lex: Lexer, data: u8[]): LexerResult {
  let l: Lexer = skip_whitespace_and_comments(lex, data);
  if (l.pos >= data.length) {
    let t: token.Token = token.Token {
      kind: 0,
      line: l.line,
      col: l.col,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return LexerResult { next_lex: l, tok: t, token_start: (0 as usize) }
  }
  if (data[l.pos] == 0) {
    let t: token.Token = token.Token {
      kind: 0,
      line: l.line,
      col: l.col,
      int_val: 0,
      float_val: 0.0,
      ident: 0,
      ident_len: 0
    }
    return LexerResult { next_lex: l, tok: t, token_start: (0 as usize) }
  }
  /* See implementation. */
  let attr_out: LexerResult = LexerResult {
    next_lex: l,
    tok: token.Token { kind: 0, line: l.line, col: l.col, int_val: 0, float_val: 0.0, ident: 0, ident_len: 0 },
    token_start: (0 as usize)
  };
  if (lexer_try_cfg_attr_into(&attr_out, l, data) != 0) {
    return attr_out;
  }
  if (lexer_try_repr_c_attr_into(&attr_out, l, data) != 0) {
    return attr_out;
  }
  if (lexer_try_repr_compatible_attr_into(&attr_out, l, data) != 0) {
    return attr_out;
  }
  if (lexer_try_soa_attr_into(&attr_out, l, data) != 0) {
    return attr_out;
  }
  if (lexer_try_alloc_attr_into(&attr_out, l, data) != 0) {
    return attr_out;
  }
  if (lexer_try_used_attr_into(&attr_out, l, data) != 0) {
    return attr_out;
  }
  if (lexer_try_naked_attr_into(&attr_out, l, data) != 0) {
    return attr_out;
  }
  if (lexer_try_entry_attr_into(&attr_out, l, data) != 0) {
    return attr_out;
  }
  if (lexer_try_no_mangle_attr_into(&attr_out, l, data) != 0) {
    return attr_out;
  }
  if (lexer_try_interrupt_attr_into(&attr_out, l, data) != 0) {
    return attr_out;
  }
  if (lexer_try_send_attr_into(&attr_out, l, data) != 0) {
    return attr_out;
  }
  if (lexer_try_sync_attr_into(&attr_out, l, data) != 0) {
    return attr_out;
  }
  /* See implementation. */
  lexer_next_body_into(&attr_out, l, data);
  return attr_out;
}

/**
* See implementation.
* See implementation.
*/
export function lexer_apply_optional_exponent(l: Lexer, data: u8[], fval: f64, out_l: *Lexer, out_f:
*f64): void {
  let lex: Lexer = l;
  let cur: f64 = fval;
  if (lex.pos < data.length && (data[lex.pos] == 101 || data[lex.pos] == 69)) {
    lex = advance_one(lex, data[lex.pos]);
    let exp_sign: i32 = 1;
    if (lex.pos < data.length && data[lex.pos] == 45) {
      exp_sign = -1;
      lex = advance_one(lex, 45);
    } else {
      if (lex.pos < data.length && data[lex.pos] == 43) { lex = advance_one(lex, 43); }
    }
    let exp: i32 = 0;
    while (lex.pos < data.length && is_digit(data[lex.pos])) {
      let d: u8 = data[lex.pos];
      lex = advance_one(lex, d);
      exp = exp * 10 + (d - 48);
    }
    exp = exp * exp_sign;
    let scale: f64 = 1.0;
    let e: i32 = 0;
    if (exp > 0) {
      while (e < exp) {
        scale = scale * 10.0;
        e = e + 1;
      }
    } else {
      while (e > exp) {
        scale = scale * 0.1;
        e = e - 1;
      }
    }
    cur = fval * scale;
  }
  out_l[0] = lex;
  out_f[0] = cur;
}

/** Exported function `lexer_next_body_into`.
 * Implements `lexer_next_body_into`.
 * @param out *LexerResult
 * @param l Lexer
 * @param data u8[]
 * @return void
 */
export function lexer_next_body_into(out: *LexerResult, l: Lexer, data: u8[]): void {
  let c: u8 = data[l.pos];
  /* See implementation. */
  if (lexer_try_cfg_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_repr_c_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_repr_compatible_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_soa_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_alloc_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_used_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_naked_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_entry_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_no_mangle_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_interrupt_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_send_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_sync_attr_into(out, l, data) != 0) {
    return;
  }
  /* See implementation. */
  if (c == 34) {
    let line0: i32 = l.line;
    let col0: i32 = l.col;
    let start: usize = l.pos + (1 as usize);
    l = advance_one(l, 34);
    while (l.pos < data.length && data[l.pos] != 34) {
      if (data[l.pos] == 92 && l.pos + 1 < data.length) {
        l = advance_one(l, data[l.pos]);
        l = advance_one(l, data[l.pos]);
      } else {
        l = advance_one(l, data[l.pos]);
      }
    }
    if (l.pos >= data.length) {
      let tok_eof: token.Token = token.Token { kind: 0, line: line0, col: col0, int_val: 0,
        float_val: 0.0, ident: 0, ident_len: 0 };
      write_next_lex_into(out, l);
      write_tok_into(out, tok_eof);
      out.token_start = start;
      return;
    }
    let slen: i32 = (l.pos - start) as i32;
    l = advance_one(l, 34);
    let tok_str: token.Token = token.Token { kind: 130, line: line0, col: col0, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: slen };
    write_next_lex_into(out, l);
    write_tok_into(out, tok_str);
    out.token_start = start;
    return;
  }
  if (is_alpha(c)) {
    let start: usize = l.pos;
    let line0: i32 = l.line;
    let col0: i32 = l.col;
    l = advance_one(l, c);
    while (l.pos < data.length && is_alnum_underscore(data[l.pos])) {
      l = advance_one(l, data[l.pos]);
    }
    let len: usize = l.pos - start;
    let tok: token.Token = try_keyword(data, start, len, line0, col0);
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (is_digit(c)) {
    let start: usize = l.pos;
    let line0: i32 = l.line;
    let col0: i32 = l.col;
    let ival: i64 = 0;
    l = advance_one(l, c);
    if (c == 48 && l.pos < data.length && (data[l.pos] == 120 || data[l.pos] == 88)) {
      l = advance_one(l, data[l.pos]);
      let hval: u64 = (0 as u64);
      while (l.pos < data.length && is_hex_digit(data[l.pos])) {
        let hd: u8 = data[l.pos];
        hval = hval * 16 + (hex_digit_value(hd) as u64);
        l = advance_one(l, hd);
      }
      let tok: token.Token = token.Token { kind: 80, line: line0, col: col0, int_val: hval as i64,
        float_val: 0.0, ident: 0, ident_len: 0 };
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    ival = ival * 10 + (c - 48);
    while (l.pos < data.length && is_digit(data[l.pos])) {
      let d: u8 = data[l.pos];
      l = advance_one(l, d);
      ival = ival * 10 + (d - 48);
    }
    if (l.pos < data.length && data[l.pos] == 46 && l.pos + 1 < data.length && is_digit(data[l.pos
    + 1])) {
      l = advance_one(l, 46);
      let fval: f64 = (ival as f64);
      let frac: f64 = 0.1;
      while (l.pos < data.length && is_digit(data[l.pos])) {
        let d: u8 = data[l.pos];
        l = advance_one(l, d);
        fval = fval + frac * (d - 48);
        frac = frac * 0.1;
      }
      lexer_apply_optional_exponent(l, data, fval, &l, &fval);
      let tok: token.Token = token.Token { kind: 81, line: line0, col: col0, int_val: 0,
        float_val: fval, ident: 0, ident_len: 0 };
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    if (l.pos < data.length && (data[l.pos] == 101 || data[l.pos] == 69)) {
      l = advance_one(l, data[l.pos]);
      let exp_sign: i32 = 1;
      if (l.pos < data.length && data[l.pos] == 45) {
        exp_sign = -1;
        l = advance_one(l, 45);
      } else {
        if (l.pos < data.length && data[l.pos] == 43) { l = advance_one(l, 43); }
      }
      let exp: i32 = 0;
      while (l.pos < data.length && is_digit(data[l.pos])) {
        let d: u8 = data[l.pos];
        l = advance_one(l, d);
        exp = exp * 10 + (d - 48);
      }
      exp = exp * exp_sign;
      let scale: f64 = 1.0;
      let e: i32 = 0;
      if (exp > 0) {
        while (e < exp) {
          scale = scale * 10.0;
          e = e + 1;
        }
      } else {
        while (e > exp) {
          scale = scale * 0.1;
          e = e - 1;
        }
      }
      let fval: f64 = (ival as f64) * scale;
      let tok: token.Token = token.Token { kind: 81, line: line0, col: col0, int_val: 0,
        float_val: fval, ident: 0, ident_len: 0 };
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    let tok: token.Token = token.Token { kind: 80, line: line0, col: col0, int_val: ival,
      float_val: 0.0, ident: 0, ident_len: 0 };
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    /* See implementation. */
    out.token_start = start;
    return;
  }
  if (c == 46 && l.pos + 1 < data.length && is_digit(data[l.pos + 1])) {
    let start: usize = l.pos;
    let line0: i32 = l.line;
    let col0: i32 = l.col;
    l = advance_one(l, 46);
    let fval: f64 = 0.0;
    let frac: f64 = 0.1;
    while (l.pos < data.length && is_digit(data[l.pos])) {
      let d: u8 = data[l.pos];
      l = advance_one(l, d);
      fval = fval + frac * (d - 48);
      frac = frac * 0.1;
    }
    lexer_apply_optional_exponent(l, data, fval, &l, &fval);
    let tok: token.Token = token.Token { kind: 81, line: line0, col: col0, int_val: 0,
      float_val: fval, ident: 0, ident_len: 0 };
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  // Punctuation/operators: dedicated helper keeps body_into under typeck limits.
  lexer_next_punct_into(out, l, data, c);

}

/**
 * Lex one punctuation/operator token at the current position.
 * Caller has observed first character `c` at data[l.pos] and has not advanced yet.
 * Split out of lexer_next_body_into so each function stays under typeck body limits
 * (large if-chain + fallthrough previously reported bogus TokenKind/? errors).
 * PLATFORM: SHARED — pure lex logic; no FFI.
 */
export function lexer_next_punct_into(out: *LexerResult, l: Lexer, data: u8[], c: u8): void {
  let start: usize = l.pos;
  let line0: i32 = l.line;
  let col0: i32 = l.col;
  l = advance_one(l, c);
  let tok: token.Token = token.Token { kind: 0, line: line0, col: col0, int_val: 0,
    float_val: 0.0, ident: 0, ident_len: 0 };
  if (c == 40) { tok.kind = 82; write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 41) { tok.kind = 83; write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 123) { tok.kind = 84; write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 125) { tok.kind = 85; write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 91) { tok.kind = 86; write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 93) { tok.kind = 87; write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 44) { tok.kind = 90; write_next_lex_into(out, l); write_tok_into(out,
    tok); out.token_start = start; return; }
  if (c == 58) { tok.kind = 91; write_next_lex_into(out, l); write_tok_into(out,
    tok); out.token_start = start; return; }
  if (c == 46) {
    /* See implementation. */
    if (l.pos + 1 < data.length && data[l.pos] == 46 && data[l.pos + 1] == 46) {
      l = advance_one(l, 46);
      l = advance_one(l, 46);
      tok.kind = 94;
    } else {
      tok.kind = 92;
    }
    write_next_lex_into(out, l); write_tok_into(out,
    tok); out.token_start = start; return; }
  if (c == 59) { tok.kind = 95; write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 43) {
    /* See implementation. */
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 106;
    } else {
      tok.kind = 96;
    }
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 45) {
    if (l.pos < data.length && data[l.pos] == 62) {
      l = advance_one(l, 62);
      tok.kind = 88;
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 107;
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    tok.kind = 97;
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 42) {
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 108;
    } else {
      tok.kind = 98;
    }
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 47) {
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 109;
    } else {
      tok.kind = 99;
    }
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 37) {
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 110;
    } else {
      tok.kind = 100;
    }
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 94) {
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 113;
    } else {
      tok.kind = 103;
    }
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 126) { tok.kind = 116; write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 38) {
    if (l.pos < data.length && data[l.pos] == 38) {
      l = advance_one(l, 38);
      tok.kind = 124;
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 111;
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    tok.kind = 101;
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 124) {
    if (l.pos < data.length && data[l.pos] == 124) {
      l = advance_one(l, 124);
      tok.kind = 125;
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 112;
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    tok.kind = 102;
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 60) {
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 122;
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    if (l.pos < data.length && data[l.pos] == 60) {
      l = advance_one(l, 60);
      if (l.pos < data.length && data[l.pos] == 61) {
        l = advance_one(l, 61);
        tok.kind = 114;
      } else {
        tok.kind = 104;
      }
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    tok.kind = 120;
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 62) {
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 123;
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    if (l.pos < data.length && data[l.pos] == 62) {
      l = advance_one(l, 62);
      if (l.pos < data.length && data[l.pos] == 61) {
        l = advance_one(l, 61);
        tok.kind = 115;
      } else {
        tok.kind = 105;
      }
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    tok.kind = 121;
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 33) {
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 119;
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    tok.kind = 126;
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 63) { tok.kind = 127; write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 64) { tok.kind = 129; write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 61) {
    if (l.pos < data.length && data[l.pos] == 62) {
      l = advance_one(l, 62);
      tok.kind = 89;
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 118;
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    tok.kind = 117;
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  // Unknown byte: keep TOKEN_EOF placeholder (same as historical fallthrough).
  // Re-bind tok so typeck does not hit the long-chain fallthrough edge case.
  let unk: token.Token = token.Token {
    kind: 0,
    line: line0,
    col: col0,
    int_val: 0,
    float_val: 0.0,
    ident: 0,
    ident_len: 0
  };
  write_next_lex_into(out, l);
  write_tok_into(out, unk);
  out.token_start = start;
}

/** Exported function `write_next_lex_into`.
 * Write path helper `write_next_lex_into`.
 * @param out *LexerResult
 * @param l Lexer
 * @return void
 */
export function write_next_lex_into(out: *LexerResult, l: Lexer): void {
  out.next_lex.pos = l.pos;
  out.next_lex.line = l.line;
  out.next_lex.col = l.col;
  out.token_start = (0 as usize);
}
/** Exported function `write_tok_into`.
 * Write path helper `write_tok_into`.
 * @param out *LexerResult
 * @param t token.Token
 * @return void
 */
export function write_tok_into(out: *LexerResult, t: token.Token): void {
  out.tok.kind = t.kind;
  out.tok.line = t.line;
  out.tok.col = t.col;
  out.tok.int_val = t.int_val;
  out.tok.float_val = t.float_val;
  out.tok.ident = t.ident;
  out.tok.ident_len = t.ident_len;
}

/** Exported function `lexer_next_impl`.
 * Implements `lexer_next_impl`.
 * @param out *LexerResult
 * @param lex Lexer
 * @param data u8[]
 * @return void
 */
export function lexer_next_impl(out: *LexerResult, lex: Lexer, data: u8[]): void {
  let l: Lexer = skip_whitespace_and_comments(lex, data);
  if (l.pos >= data.length) {
    let t: token.Token = token.Token { kind: 0, line: l.line, col: l.col, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 };
    write_next_lex_into(out, l);
    write_tok_into(out, t);
    return;
  }
  if (data[l.pos] == 0) {
    let t: token.Token = token.Token { kind: 0, line: l.line, col: l.col, int_val: 0,
      float_val: 0.0, ident: 0, ident_len: 0 };
    write_next_lex_into(out, l);
    write_tok_into(out, t);
    return;
  }
  lexer_next_body_into(out, l, data);
}

/** Exported function `lexer_next_into`.
 * Implements `lexer_next_into`.
 * @param out *LexerResult
 * @param lex Lexer
 * @param data u8[]
 * @return void
 */
export function lexer_next_into(out: *LexerResult, lex: Lexer, data: u8[]): void {
  lexer_next_impl(out, lex, data);
}

/** See implementation for details. */
/**
 * Buf + len path writing into out via lexer_next_into.
 * PLATFORM: SHARED — LANG-007 S0: slice glue is extern; call inside unsafe (Cap-T001).
 */
export function lexer_next_buf_into(out: *LexerResult, lex: Lexer, data: *u8, len: i32): void {
  unsafe {
    lexer_next_into(out, lex, lexer_parser_slice_from_buf(data, len));
  }
}

/**
* See implementation.
* See implementation.
* See implementation.
* See implementation.
*/
/**
 * Same as lexer_next for raw (data, len).
 * PLATFORM: SHARED — LANG-007 S0: slice glue is extern; call inside unsafe (Cap-T001).
 */
export function lexer_next_buf(lex: Lexer, data: *u8, len: i32): LexerResult {
  unsafe {
    return lexer_next(lex, lexer_parser_slice_from_buf(data, len));
  }
}

/** Exported function `lexer_next_body`.
 * Implements `lexer_next_body`.
 * @param l Lexer
 * @param data u8[]
 * @return LexerResult
 */
export function lexer_next_body(l: Lexer, data: u8[]): LexerResult {
  let c: u8 = data[l.pos];
  if (is_alpha(c)) {
    let start: usize = l.pos;
    let line0: i32 = l.line;
    let col0: i32 = l.col;
    l = advance_one(l, c);
    while (l.pos < data.length && is_alnum_underscore(data[l.pos])) {
      l = advance_one(l, data[l.pos]);
    }
    let len: usize = l.pos - start;
    let tok: token.Token = try_keyword(data, start, len, line0, col0);
/** See implementation for details. */
    return LexerResult { next_lex: l, tok: tok, token_start: start };
  }
  if (is_digit(c)) {
    let start: usize = l.pos;
    let line0: i32 = l.line;
    let col0: i32 = l.col;
    let ival: i64 = 0;
    l = advance_one(l, c);
    if (c == 48 && l.pos < data.length && (data[l.pos] == 120 || data[l.pos] == 88)) {
      l = advance_one(l, data[l.pos]);
      let hval: u64 = (0 as u64);
      while (l.pos < data.length && is_hex_digit(data[l.pos])) {
        let hd: u8 = data[l.pos];
        hval = hval * 16 + (hex_digit_value(hd) as u64);
        l = advance_one(l, hd);
      }
      let tok: token.Token = token.Token { kind: 80, line: line0, col: col0, int_val: hval as i64,
        float_val: 0.0, ident: 0, ident_len: 0 }
      return LexerResult { next_lex: l, tok: tok, token_start: start };
    }
    ival = ival * 10 + (c - 48);
    while (l.pos < data.length && is_digit(data[l.pos])) {
      let d: u8 = data[l.pos];
      l = advance_one(l, d);
      ival = ival * 10 + (d - 48);
    }
    if (l.pos < data.length && data[l.pos] == 46 && l.pos + 1 < data.length && is_digit(data[l.pos
    + 1])) {
      l = advance_one(l, 46);
      let fval: f64 = (ival as f64);
      let frac: f64 = 0.1;
      while (l.pos < data.length && is_digit(data[l.pos])) {
        let d: u8 = data[l.pos];
        l = advance_one(l, d);
        fval = fval + frac * (d - 48);
        frac = frac * 0.1;
      }
      lexer_apply_optional_exponent(l, data, fval, &l, &fval);
      let tok: token.Token = token.Token { kind: 81, line: line0, col: col0, int_val: 0,
        float_val: fval, ident: 0, ident_len: 0 }
      return LexerResult { next_lex: l, tok: tok, token_start: start };
    }
    if (l.pos < data.length && (data[l.pos] == 101 || data[l.pos] == 69)) {
      l = advance_one(l, data[l.pos]);
      let exp_sign: i32 = 1;
      if (l.pos < data.length && data[l.pos] == 45) {
        exp_sign = -1;
        l = advance_one(l, 45);
      } else {
        if (l.pos < data.length && data[l.pos] == 43) { l = advance_one(l, 43); }
      }
      let exp: i32 = 0;
      while (l.pos < data.length && is_digit(data[l.pos])) {
        let d: u8 = data[l.pos];
        l = advance_one(l, d);
        exp = exp * 10 + (d - 48);
      }
      exp = exp * exp_sign;
      let scale: f64 = 1.0;
      let e: i32 = 0;
      if (exp > 0) {
        while (e < exp) {
          scale = scale * 10.0;
          e = e + 1;
        }
      } else {
        while (e > exp) {
          scale = scale * 0.1;
          e = e - 1;
        }
      }
      let fval: f64 = (ival as f64) * scale;
      let tok: token.Token = token.Token { kind: 81, line: line0, col: col0, int_val: 0,
        float_val: fval, ident: 0, ident_len: 0 }
      return LexerResult { next_lex: l, tok: tok, token_start: start };
    }
    let tok: token.Token = token.Token { kind: 80, line: line0, col: col0, int_val: ival,
      float_val: 0.0, ident: 0, ident_len: 0 }
    return LexerResult { next_lex: l, tok: tok, token_start: start };
  }
  if (c == 46 && l.pos + 1 < data.length && is_digit(data[l.pos + 1])) {
    let start: usize = l.pos;
    let line0: i32 = l.line;
    let col0: i32 = l.col;
    l = advance_one(l, 46);
    let fval: f64 = 0.0;
    let frac: f64 = 0.1;
    while (l.pos < data.length && is_digit(data[l.pos])) {
      let d: u8 = data[l.pos];
      l = advance_one(l, d);
      fval = fval + frac * (d - 48);
      frac = frac * 0.1;
    }
    lexer_apply_optional_exponent(l, data, fval, &l, &fval);
    let tok: token.Token = token.Token { kind: 81, line: line0, col: col0, int_val: 0,
      float_val: fval, ident: 0, ident_len: 0 }
    return LexerResult { next_lex: l, tok: tok, token_start: start };
  }
  let start: usize = l.pos;
  let line0: i32 = l.line;
  let col0: i32 = l.col;
  l = advance_one(l, c);
  let tok: token.Token = token.Token { kind: 0, line: line0, col: col0, int_val: 0,
    float_val: 0.0, ident: 0, ident_len: 0 }
  if (c == 40) { tok.kind = 82; return LexerResult { next_lex: l, tok: tok,
      token_start: start } };
  if (c == 41) { tok.kind = 83; return LexerResult { next_lex: l, tok: tok,
      token_start: start } };
  if (c == 123) { tok.kind = 84; return LexerResult { next_lex: l, tok: tok,
      token_start: start } };
  if (c == 125) { tok.kind = 85; return LexerResult { next_lex: l, tok: tok,
      token_start: start } };
  if (c == 91) { tok.kind = 86; return LexerResult { next_lex: l, tok: tok,
      token_start: start } };
  if (c == 93) { tok.kind = 87; return LexerResult { next_lex: l, tok: tok,
      token_start: start } };
  if (c == 44) { tok.kind = 90; return LexerResult { next_lex: l, tok: tok,
      token_start: start } };
  if (c == 58) { tok.kind = 91; return LexerResult { next_lex: l, tok: tok,
      token_start: start } };
  if (c == 46) {
    /* See implementation. */
    if (l.pos + 1 < data.length && data[l.pos] == 46 && data[l.pos + 1] == 46) {
      l = advance_one(l, 46);
      l = advance_one(l, 46);
      tok.kind = 94;
    } else {
      tok.kind = 92;
    }
    return LexerResult { next_lex: l, tok: tok,
      token_start: start } };
  if (c == 59) { tok.kind = 95; return LexerResult { next_lex: l, tok: tok,
      token_start: start } };
  if (c == 43) {
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 106;
    } else {
      tok.kind = 96;
    }
    return LexerResult { next_lex: l, tok: tok, token_start: start };
  }
  if (c == 45) {
    if (l.pos < data.length && data[l.pos] == 62) {
      l = advance_one(l, 62);
      tok.kind = 88;
      return LexerResult { next_lex: l, tok: tok, token_start: start };
    }
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 107;
      return LexerResult { next_lex: l, tok: tok, token_start: start };
    }
    tok.kind = 97;
    return LexerResult { next_lex: l, tok: tok, token_start: start };
  }
  if (c == 42) {
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 108;
    } else {
      tok.kind = 98;
    }
    return LexerResult { next_lex: l, tok: tok, token_start: start };
  }
  if (c == 47) {
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 109;
    } else {
      tok.kind = 99;
    }
    return LexerResult { next_lex: l, tok: tok, token_start: start };
  }
  if (c == 37) {
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 110;
    } else {
      tok.kind = 100;
    }
    return LexerResult { next_lex: l, tok: tok, token_start: start };
  }
  if (c == 94) {
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 113;
    } else {
      tok.kind = 103;
    }
    return LexerResult { next_lex: l, tok: tok, token_start: start };
  }
  if (c == 126) { tok.kind = 116; return LexerResult { next_lex: l, tok: tok,
      token_start: start } };
  if (c == 38) {
    if (l.pos < data.length && data[l.pos] == 38) {
      l = advance_one(l, 38);
      tok.kind = 124;
      return LexerResult { next_lex: l, tok: tok, token_start: start };
    }
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 111;
      return LexerResult { next_lex: l, tok: tok, token_start: start };
    }
    tok.kind = 101;
    return LexerResult { next_lex: l, tok: tok, token_start: start };
  }
  if (c == 124) {
    if (l.pos < data.length && data[l.pos] == 124) {
      l = advance_one(l, 124);
      tok.kind = 125;
      return LexerResult { next_lex: l, tok: tok, token_start: start };
    }
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 112;
      return LexerResult { next_lex: l, tok: tok, token_start: start };
    }
    tok.kind = 102;
    return LexerResult { next_lex: l, tok: tok, token_start: start };
  }
  if (c == 60) {
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 122;
      return LexerResult { next_lex: l, tok: tok, token_start: start };
    }
    if (l.pos < data.length && data[l.pos] == 60) {
      l = advance_one(l, 60);
      if (l.pos < data.length && data[l.pos] == 61) {
        l = advance_one(l, 61);
        tok.kind = 114;
      } else {
        tok.kind = 104;
      }
      return LexerResult { next_lex: l, tok: tok, token_start: start };
    }
    tok.kind = 120;
    return LexerResult { next_lex: l, tok: tok, token_start: start };
  }
  if (c == 62) {
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 123;
      return LexerResult { next_lex: l, tok: tok, token_start: start };
    }
    if (l.pos < data.length && data[l.pos] == 62) {
      l = advance_one(l, 62);
      if (l.pos < data.length && data[l.pos] == 61) {
        l = advance_one(l, 61);
        tok.kind = 115;
      } else {
        tok.kind = 105;
      }
      return LexerResult { next_lex: l, tok: tok, token_start: start };
    }
    tok.kind = 121;
    return LexerResult { next_lex: l, tok: tok, token_start: start };
  }
  if (c == 33) {
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 119;
      return LexerResult { next_lex: l, tok: tok, token_start: start };
    }
    tok.kind = 126;
    return LexerResult { next_lex: l, tok: tok, token_start: start };
  }
  if (c == 63) { tok.kind = 127; return LexerResult { next_lex: l, tok: tok,
      token_start: start } };
  if (c == 64) { tok.kind = 129; return LexerResult { next_lex: l, tok: tok,
      token_start: start } };
  if (c == 61) {
    if (l.pos < data.length && data[l.pos] == 62) {
      l = advance_one(l, 62);
      tok.kind = 89;
      return LexerResult { next_lex: l, tok: tok, token_start: start };
    }
    if (l.pos < data.length && data[l.pos] == 61) {
      l = advance_one(l, 61);
      tok.kind = 118;
      return LexerResult { next_lex: l, tok: tok, token_start: start };
    }
    tok.kind = 117;
    return LexerResult { next_lex: l, tok: tok, token_start: start };
  }
  return LexerResult { next_lex: l, tok: tok, token_start: start };
}

/** Exported function `main`.
 * Program/test entry point.
 * @return i32
 */
export function main(): i32 {
  let src: u8[32] = [108, 101, 116, 32, 120, 32, 61, 32, 49, 59, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  /* See implementation. */
  // PLATFORM: SHARED — LANG-007 S0: slice glue is extern; call inside unsafe (Cap-T001).
  let sl: u8[] = [];
  unsafe {
    sl = lexer_parser_slice_from_buf(&src[0], 11);
  }
  let lex: Lexer = lexer_init();
  let r: LexerResult = lexer_next(lex, sl);
  if (r.tok.kind != 2) { return 1; }
  lex = r.next_lex;
  r = lexer_next(lex, sl);
  if (r.tok.kind != 59) { return 2; }
  lex = r.next_lex;
  r = lexer_next(lex, sl);
  if (r.tok.kind != 117) { return 3; }
  lex = r.next_lex;
  r = lexer_next(lex, sl);
  if (r.tok.kind != 80) { return 4; }
  lex = r.next_lex;
  r = lexer_next(lex, sl);
  if (r.tok.kind != 95) { return 5; }
  lex = r.next_lex;
  r = lexer_next(lex, sl);
  if (r.tok.kind != 0) { return 6; }
  return 0;
}
