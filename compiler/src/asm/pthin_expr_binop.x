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

// pthin_expr_binop.x — G-02f-284 P4 parser thin binop product bodies.
//
// 7.2.1 P4bb Route C productize (2026-09-13): after P4ub unary TOKEN table,
// binop.inc is the next still-host-cc product slice with portable scalar
// tables. TOKEN → ExprKind for * / % + - << >> < <= > >= == != (and the
// single-tok & ^ | && || map, kept complete) is Route C (int32). Arena
// wrap, peek cache, single_tok_chain, and parse_* stay C. Contiguous
// already-T AUDIT_CALL padding on parse_logor is gated in the .inc under
// XLANG_PARSER_STRETCH_AUDIT (product AUDIT_CALL is already ((void)0);
// compiling ~700 lexer-init nops is dead preprocess).
// Do not merge parser_asm_unary_token_to_expr_kind_c (same TOKEN_* can
// mean unary prefix vs binary op: STAR deref vs mul, AMP addr-of vs
// bitand, MINUS neg vs sub). Do not rewrite single_tok_chain to call
// this table as a side effect.
//
// Hybrid P4bb: g05_try_x_to_o this file; XLANG_PTHIN_EXPR_BINOP_BODIES_FROM_X
// skips the portable .inc region. token.h remains the TOKEN_* authority
// via P4b C _Static_assert pins. Cold: no define, full .inc stays.
// PLATFORM: SHARED freestanding.

// TOKEN_* pin copies of include/token.h. P4b C _Static_assert fires if
// the pin drifts; do not treat these as a second enum authority.
const TOKEN_PLUS: i32 = 96;
const TOKEN_MINUS: i32 = 97;
const TOKEN_STAR: i32 = 98;
const TOKEN_SLASH: i32 = 99;
const TOKEN_PERCENT: i32 = 100;
const TOKEN_AMP: i32 = 101;
const TOKEN_PIPE: i32 = 102;
const TOKEN_CARET: i32 = 103;
const TOKEN_LSHIFT: i32 = 104;
const TOKEN_RSHIFT: i32 = 105;
const TOKEN_EQ: i32 = 118;
const TOKEN_NE: i32 = 119;
const TOKEN_LT: i32 = 120;
const TOKEN_GT: i32 = 121;
const TOKEN_LE: i32 = 122;
const TOKEN_GE: i32 = 123;
const TOKEN_AMPAMP: i32 = 124;
const TOKEN_PIPEPIPE: i32 = 125;

// ExprKind ordinals — G.7 ≡ ast.x / PARSER_ASM_EXPR_* in expr_binop_slice.inc.
const EXPR_ADD: i32 = 4;
const EXPR_SUB: i32 = 5;
const EXPR_MUL: i32 = 6;
const EXPR_DIV: i32 = 7;
const EXPR_MOD: i32 = 8;
const EXPR_SHL: i32 = 9;
const EXPR_SHR: i32 = 10;
const EXPR_BITAND: i32 = 11;
const EXPR_BITOR: i32 = 12;
const EXPR_BITXOR: i32 = 13;
const EXPR_EQ: i32 = 14;
const EXPR_NE: i32 = 15;
const EXPR_LT: i32 = 16;
const EXPR_LE: i32 = 17;
const EXPR_GT: i32 = 18;
const EXPR_GE: i32 = 19;
const EXPR_LOGAND: i32 = 20;
const EXPR_LOGOR: i32 = 21;

/**
 * Map binary-operator token → ExprKind ordinal.
 * star→6 slash→7 percent→8 plus→4 minus→5 lshift→9 rshift→10
 * amp→11 pipe→12 caret→13 eq→14 ne→15 lt→16 le→17 gt→18 ge→19
 * ampamp→20 pipepipe→21; anything else → -1 (caller restores lex).
 * Precedence filtering stays in the C parse_* functions.
 * @param kind i32 — lexer token kind (token.h numbering)
 * @return i32 — ExprKind ordinal >=0, or -1 if not a binary operator
 * PLATFORM: SHARED — single TOKEN→ExprKind table for binary ops.
 */
#[no_mangle]
export function parser_asm_binop_token_to_expr_kind_c(kind: i32): i32 {
  if (kind == TOKEN_STAR) {
    return EXPR_MUL;
  }
  if (kind == TOKEN_SLASH) {
    return EXPR_DIV;
  }
  if (kind == TOKEN_PERCENT) {
    return EXPR_MOD;
  }
  if (kind == TOKEN_PLUS) {
    return EXPR_ADD;
  }
  if (kind == TOKEN_MINUS) {
    return EXPR_SUB;
  }
  if (kind == TOKEN_LSHIFT) {
    return EXPR_SHL;
  }
  if (kind == TOKEN_RSHIFT) {
    return EXPR_SHR;
  }
  if (kind == TOKEN_AMP) {
    return EXPR_BITAND;
  }
  if (kind == TOKEN_PIPE) {
    return EXPR_BITOR;
  }
  if (kind == TOKEN_CARET) {
    return EXPR_BITXOR;
  }
  if (kind == TOKEN_EQ) {
    return EXPR_EQ;
  }
  if (kind == TOKEN_NE) {
    return EXPR_NE;
  }
  if (kind == TOKEN_LT) {
    return EXPR_LT;
  }
  if (kind == TOKEN_LE) {
    return EXPR_LE;
  }
  if (kind == TOKEN_GT) {
    return EXPR_GT;
  }
  if (kind == TOKEN_GE) {
    return EXPR_GE;
  }
  if (kind == TOKEN_AMPAMP) {
    return EXPR_LOGAND;
  }
  if (kind == TOKEN_PIPEPIPE) {
    return EXPR_LOGOR;
  }
  return -1;
}
