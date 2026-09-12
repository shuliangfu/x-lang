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

// pthin_expr_unary.x — G-02f-283 P4 parser thin unary product bodies.
//
// 7.2.1 P4ub Route C productize (2026-09-13): after P7b simd ident/callee,
// unary.inc is the next still-host-cc product slice with a portable scalar
// table. TOKEN → ExprKind for await/run/spawn/-/~/!/&/* is Route C (int32).
// Arena expr alloc, lexer by-value, wrap_operand, and parse_unary_into stay
// C. Contiguous already-T AUDIT_CALL padding is gated in the .inc under
// XLANG_PARSER_STRETCH_AUDIT (product AUDIT_CALL is already ((void)0);
// compiling ~700 lexer-init nops is dead preprocess, not combinator logic).
// Do not "fix" the redundant double lexer_next_into at the AUDIT/parse
// boundary as a side effect. Do not merge compound_assign_token_to_expr_kind
// (different TOKEN set: += -= *= …).
//
// Hybrid P4ub: g05_try_x_to_o this file; XLANG_PTHIN_EXPR_UNARY_BODIES_FROM_X
// skips the portable .inc region. token.h remains the TOKEN_* authority
// via P4u C _Static_assert pins. Cold: no define, full .inc stays.
// PLATFORM: SHARED freestanding.

// TOKEN_* pin copies of include/token.h. P4u C _Static_assert fires if
// the pin drifts; do not treat these as a second enum authority.
const TOKEN_AWAIT: i32 = 56;
const TOKEN_RUN: i32 = 57;
const TOKEN_SPAWN: i32 = 58;
const TOKEN_MINUS: i32 = 97;
const TOKEN_STAR: i32 = 98;
const TOKEN_AMP: i32 = 101;
const TOKEN_TILDE: i32 = 116;
const TOKEN_BANG: i32 = 126;

// ExprKind ordinals — G.7 ≡ ast.x / PARSER_ASM_EXPR_* in unary_slice.inc.
const EXPR_NEG: i32 = 22;
const EXPR_BITNOT: i32 = 23;
const EXPR_LOGNOT: i32 = 24;
const EXPR_ADDR_OF: i32 = 51;
const EXPR_DEREF: i32 = 52;
const EXPR_AWAIT: i32 = 55;
const EXPR_RUN: i32 = 56;
const EXPR_SPAWN: i32 = 57;

/**
 * Map unary prefix token → ExprKind ordinal.
 * await→55 run→56 spawn→57 minus→22 tilde→23 bang→24 amp→51 star→52;
 * anything else → -1 (caller falls back to parse_primary).
 * @param kind i32 — lexer token kind (token.h numbering)
 * @return i32 — ExprKind ordinal >=0, or -1 if not a unary prefix
 * PLATFORM: SHARED — single TOKEN→ExprKind table for unary prefixes.
 */
#[no_mangle]
export function parser_asm_unary_token_to_expr_kind_c(kind: i32): i32 {
  if (kind == TOKEN_AWAIT) {
    return EXPR_AWAIT;
  }
  if (kind == TOKEN_RUN) {
    return EXPR_RUN;
  }
  if (kind == TOKEN_SPAWN) {
    return EXPR_SPAWN;
  }
  if (kind == TOKEN_MINUS) {
    return EXPR_NEG;
  }
  // PLATFORM: SHARED — `~x` BITNOT (LANG-006 CTFE / unary residual).
  if (kind == TOKEN_TILDE) {
    return EXPR_BITNOT;
  }
  if (kind == TOKEN_BANG) {
    return EXPR_LOGNOT;
  }
  if (kind == TOKEN_AMP) {
    return EXPR_ADDR_OF;
  }
  if (kind == TOKEN_STAR) {
    return EXPR_DEREF;
  }
  return -1;
}
