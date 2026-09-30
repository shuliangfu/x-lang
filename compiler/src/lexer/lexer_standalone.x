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

// Lexer self-test entry. Kept out of lexer.x so the product lexer_x.o
// pure-asm emit has no main and no main-rooted dead-code drop.
// PLATFORM: SHARED.

const token = import("token");
const lexer = import("lexer");

/**
 * Lex the bytes for `let x = 1;` and check the six token kinds.
 * @return i32 — 0 when the stream matches, otherwise the failing step (1..6)
 * PLATFORM: SHARED
 */
export function main(): i32 {
  let src: u8[32] = [108, 101, 116, 32, 120, 32, 61, 32, 49, 59, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  // Same-module slice adapter. The extern returns a named struct so
  // Windows passes the hidden return pointer (w1545).
  let sl: u8[] = [];
  unsafe {
    sl = lexer.lexer_slice_from_raw(&src[0], 11);
  }
  let lex: lexer.Lexer = lexer.lexer_init();
  let r: lexer.LexerResult = lexer.lexer_next_slice(lex, sl);
  if (r.tok.kind != (2 as token.TokenKind)) { return 1; }
  lex = r.next_lex;
  r = lexer.lexer_next_slice(lex, sl);
  if (r.tok.kind != (59 as token.TokenKind)) { return 2; }
  lex = r.next_lex;
  r = lexer.lexer_next_slice(lex, sl);
  if (r.tok.kind != (117 as token.TokenKind)) { return 3; }
  lex = r.next_lex;
  r = lexer.lexer_next_slice(lex, sl);
  if (r.tok.kind != (80 as token.TokenKind)) { return 4; }
  lex = r.next_lex;
  r = lexer.lexer_next_slice(lex, sl);
  if (r.tok.kind != (95 as token.TokenKind)) { return 5; }
  lex = r.next_lex;
  r = lexer.lexer_next_slice(lex, sl);
  if (r.tok.kind != (0 as token.TokenKind)) { return 6; }
  return 0;
}
