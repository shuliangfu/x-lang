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
export enum TokenKind {
  TOKEN_EOF,
  TOKEN_FUNCTION,
  TOKEN_LET,
  TOKEN_CONST,
  TOKEN_IF,
  TOKEN_ELSE,
  TOKEN_WHILE,
  TOKEN_LOOP,
  TOKEN_FOR,
  TOKEN_BREAK,
  TOKEN_CONTINUE,
  TOKEN_RETURN,
  TOKEN_PANIC,
  TOKEN_DEFER,
  /* See implementation. */
  TOKEN_TRY,
  TOKEN_CATCH,
  /* See implementation. */
  TOKEN_REGION,
  /* See implementation. */
  TOKEN_WITH_ARENA,
  TOKEN_MATCH,
  TOKEN_STRUCT,
  /* See implementation. */
  TOKEN_TYPE,
  TOKEN_PACKED,
  TOKEN_SOA,
  TOKEN_ATTR_SOA,
  /* See implementation. */
  TOKEN_ATTR_CFG,
  /* See implementation. */
  TOKEN_ATTR_REPR_C,
  /* See implementation. */
  TOKEN_ATTR_REPR_COMPATIBLE,
  /* See implementation. */
  TOKEN_ATTR_ALLOC,
  /* See implementation. */
  TOKEN_ATTR_LINK_SECTION,
  /* See implementation. */
  TOKEN_ATTR_NAKED,
  /* See implementation. */
  TOKEN_ATTR_ENTRY,
  /* See implementation. */
  TOKEN_ATTR_USED,
  /* See implementation. */
  TOKEN_ATTR_NO_MANGLE,
  /* See implementation. */
  TOKEN_ATTR_LINK_NAME,
  /* See implementation. */
  TOKEN_ATTR_MAX_STACK,
  /* See implementation. */
  TOKEN_ATTR_INTERRUPT,
  /* See implementation. */
  TOKEN_ATTR_SEND,
  /* See implementation. */
  TOKEN_ATTR_SYNC,
  /* See implementation. */
  TOKEN_ATTR_GLOBAL_ALLOCATOR,
  /* See implementation. */
  TOKEN_ATTR_COLD,
  /* See implementation. */
  TOKEN_ATTR_INLINE_NEVER,
  /* See implementation. */
  TOKEN_ATTR_INLINE_ALWAYS,
  /* See implementation. */
  TOKEN_ATTR_EXPORT_NAME,
  /* See implementation. */
  TOKEN_ATTR_PANIC_HANDLER,
  /* See implementation. */
  TOKEN_ATTR_THREAD_LOCAL,
  /* See implementation. */
  TOKEN_ATTR_PERCPU,
  /* See implementation. */
  TOKEN_ALIGN,
  TOKEN_ENUM,
  TOKEN_GOTO,
  TOKEN_TRAIT,
  TOKEN_IMPL,
  TOKEN_SELF,
  TOKEN_UNDERSCORE,
  TOKEN_IMPORT,
  TOKEN_EXTERN,
  /* See implementation. */
  TOKEN_ASYNC,
  /* See implementation. */
  TOKEN_AWAIT,
  /* See implementation. */
  TOKEN_RUN,
  /* See implementation. */
  TOKEN_SPAWN,
  TOKEN_IDENT,
  TOKEN_I32,
  TOKEN_BOOL,
  TOKEN_U8,
  TOKEN_U32,
  TOKEN_U64,
  TOKEN_I64,
  TOKEN_USIZE,
  TOKEN_ISIZE,
  TOKEN_I32X4,
  TOKEN_I32X8,
  TOKEN_I32X16,
  TOKEN_U32X4,
  TOKEN_U32X8,
  TOKEN_U32X16,
  TOKEN_F32X4,
  TOKEN_TRUE,
  TOKEN_FALSE,
  TOKEN_F32,
  TOKEN_F64,
  TOKEN_VOID,
  TOKEN_INT,
  TOKEN_FLOAT,
  TOKEN_LPAREN,
  TOKEN_RPAREN,
  TOKEN_LBRACE,
  TOKEN_RBRACE,
  TOKEN_LBRACKET,
  TOKEN_RBRACKET,
  TOKEN_ARROW,
  TOKEN_FATARROW,
  TOKEN_COMMA,
  TOKEN_COLON,
  TOKEN_DOT,
  /* See implementation. */
  TOKEN_DOTDOT,
  /* See implementation. */
  TOKEN_ELLIPSIS,
  TOKEN_SEMICOLON,
  TOKEN_PLUS,
  TOKEN_MINUS,
  TOKEN_STAR,
  TOKEN_SLASH,
  TOKEN_PERCENT,
  TOKEN_AMP,
  TOKEN_PIPE,
  TOKEN_CARET,
  TOKEN_LSHIFT,
  TOKEN_RSHIFT,
/** See implementation for details. */
  TOKEN_PLUS_EQ,
  TOKEN_MINUS_EQ,
  TOKEN_STAR_EQ,
  TOKEN_SLASH_EQ,
  TOKEN_PERCENT_EQ,
  TOKEN_AMP_EQ,
  TOKEN_PIPE_EQ,
  TOKEN_CARET_EQ,
  TOKEN_LSHIFT_EQ,
  TOKEN_RSHIFT_EQ,
  TOKEN_TILDE,
  TOKEN_ASSIGN,
  TOKEN_EQ,
  TOKEN_NE,
  TOKEN_LT,
  TOKEN_GT,
  TOKEN_LE,
  TOKEN_GE,
  TOKEN_AMPAMP,
  TOKEN_PIPEPIPE,
  TOKEN_BANG,
  TOKEN_QUESTION,
  /* See implementation. */
  TOKEN_AS,
  /** @ SIMD comptime builtin（@shuffle / @select） */
  TOKEN_AT,
  /* See implementation. */
  TOKEN_STRING,
  /* See implementation. */
  TOKEN_EXPORT,
}

// See implementation.
// See implementation.
// See implementation.
export allow(padding) struct Token {
  kind: TokenKind;
  line: i32;
  col: i32;
  /* See implementation. */
  int_val: i64;
  float_val: f64;
  ident: *u8;
  ident_len: i32;
}

/**
* See implementation.
* See implementation.
* See implementation.
* See implementation.
* See implementation.
*/
export function token_is_eof(t: Token): bool {
  return t.kind == TokenKind.TOKEN_EOF;
}
