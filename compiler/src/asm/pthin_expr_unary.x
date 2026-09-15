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
// Arena expr alloc, lexer by-value, and parse_unary_into stay C.
// 7.2.1 P4uc B-minus (2026-09-15): 有则补全 wrap_operand dest-buffer.
// Language has no Expr by-value; the C trampoline in unary.inc holds
// parse_expr_result* and forwards out.ok / out.expr_ref. Sidecar writes
// go through the PABI writer family (set_common_zeros / set_kind /
// set_line_col) plus pipeline_expr_set_unary_operand_c defined in the
// P4u seed (pabi inject-only skips new rest symbols; do not FORCE the
// mega). parse_unary stays C and calls the historical wrap symbol.
// Do not copy wrap into parse_unary. Do not merge binop_wrap (different
// left/right fields). Do not open a new P-lane. Contiguous already-T AUDIT_CALL padding is gated in the .inc
// under XLANG_PARSER_STRETCH_AUDIT (product AUDIT_CALL is already
// ((void)0); compiling ~700 lexer-init nops is dead preprocess, not
// combinator logic). Do not "fix" the redundant double lexer_next_into
// at the AUDIT/parse boundary as a side effect. Do not merge
// compound_assign_token_to_expr_kind (different TOKEN set: += -= *= …).
// 7.2.1 P4ud B-minus (2026-09-15): 有则补全 parse_unary dest-buffer.
// Token walk reuses P9a peek/step (same family as P5f parse_if_expr).
// Unary prefix: peek kind, step, recurse this dest-buffer, wrap via
// P4uc wrap_operand_into_c. Non-prefix: parse_primary through the
// pointer-face shim in unary.inc (zero-algorithm over the historical
// by-value parser_parse_primary_into; language has no struct-by-value).
// C trampoline keeps AUDIT_CALL padding and publishes next_lex.
// Do not copy wrap into parse. Do not merge binop parse. Do not
// dest-buffer parse_primary this wave. Do not open a new P-lane.
//
// Hybrid P4ub/P4uc/P4ud: g05_try_x_to_o this file; XLANG_PTHIN_EXPR_UNARY_BODIES_FROM_X
// skips the portable .inc region (TOKEN table + wrap twin + parse_unary). token.h remains
// the TOKEN_* authority via P4u C _Static_assert pins. Cold: no define,
// full .inc stays.
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

/** Allocate a fresh Expr slot; 0 on failure. */
export extern "C" function ast_ast_arena_expr_alloc(arena: *u8): i32;
/** Wave-0: wipe ref/base/count fields on a freshly allocated expr. */
export extern "C" function pipeline_expr_set_common_zeros_c(a: *u8, er: i32): void;
/** Wave-0: write Expr.kind. */
export extern "C" function pipeline_expr_set_kind(a: *u8, er: i32, kind: i32): void;
/** Wave-0: write Expr.line / Expr.col. */
export extern "C" function pipeline_expr_set_line_col(a: *u8, er: i32, line: i32, col: i32): void;
/** P4uc: write Expr.unary_operand_ref. Call after set_common_zeros_c. */
export extern "C" function pipeline_expr_set_unary_operand_c(a: *u8, er: i32, operand_ref: i32): void;
/** P9a: peek next kind without advancing. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
/** P9a: consume one token; returns its kind. */
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
/** P9a: peek tok.line of the next token. */
export extern "C" function parser_asm_lex_peek_tok_line_c(lex_inout: *u8, source: *u8): i32;
/** P9a: peek tok.col of the next token. */
export extern "C" function parser_asm_lex_peek_tok_col_c(lex_inout: *u8, source: *u8): i32;
/**
 * Pointer-face parse_primary. Zero-algorithm C shim in unary.inc:
 * copies lexer, calls parser_parse_primary_into, writes ok/ref/next_lex.
 */
export extern "C" function parser_parse_primary_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32;

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

/**
 * Allocate a unary Expr and write kind / unary_operand_ref / line / col.
 * Dest-buffer twin of parser_asm_unary_wrap_operand_c: zeros first, then
 * kind, operand, line/col. On alloc fail writes out_ok=0 and returns 0.
 * Success writes out_expr_ref and returns the new ref (does not set
 * out_ok=1 — parse_unary already holds ok from the operand parse).
 * @param arena *u8 — opaque AST arena; null → 0
 * @param out_ok *i32 — parse_expr_result.ok slot; null → 0; alloc fail → 0
 * @param out_expr_ref *i32 — parse_expr_result.expr_ref slot; null → 0
 * @param kind i32 — ExprKind ordinal (NEG/BITNOT/LOGNOT/ADDR_OF/DEREF/AWAIT/RUN/SPAWN)
 * @param operand_ref i32 — inner expr ref; 0 → 0 (no wrap)
 * @param line i32 — prefix token line
 * @param col i32 — prefix token column
 * @return i32 — new expr ref, or 0 on null/alloc fail
 * PLATFORM: SHARED — product P4uc B-minus. Authority for
 * `parser_asm_unary_wrap_operand_c`. parse_unary stays C; do not copy.
 */
#[no_mangle]
export function parser_asm_unary_wrap_operand_into_c(arena: *u8, out_ok: *i32, out_expr_ref: *i32, kind: i32, operand_ref: i32, line: i32, col: i32): i32 {
  let op_ref: i32 = 0;
  if (arena == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32 || operand_ref == 0) {
    return 0;
  }
  unsafe {
    op_ref = ast_ast_arena_expr_alloc(arena);
    if (op_ref == 0) {
      out_ok[0] = 0;
      return 0;
    }
    // Zeros first: set_common_zeros_c clears unary_operand_ref.
    pipeline_expr_set_common_zeros_c(arena, op_ref);
    pipeline_expr_set_kind(arena, op_ref, kind);
    pipeline_expr_set_unary_operand_c(arena, op_ref, operand_ref);
    pipeline_expr_set_line_col(arena, op_ref, line, col);
    out_expr_ref[0] = op_ref;
  }
  return op_ref;
}

/**
 * Parse unary prefix (`-` `~` `!` `&` `*` await/run/spawn) or fall back
 * to parse_primary. .x mirror of parser_asm_parse_unary_into_slice_c:
 * one P9a peek (the C twin's redundant double lexer_next_into both
 * start from the same lex — not a double-advance). Prefix: step,
 * recurse this dest-buffer, wrap. Non-prefix: primary ptr shim
 * (cursor unadvanced, matching C parse_primary from the original lex).
 * @param arena *u8 — AST arena; null → 0
 * @param lex_inout *u8 — cursor; parked after the parsed expr
 * @param source *u8 — opaque slice
 * @param out_ok *i32 — parse_expr_result.ok
 * @param out_expr_ref *i32 — parse_expr_result.expr_ref
 * @return i32 — 1 success (out_ok=1); 0 failure
 * PLATFORM: SHARED — product P4ud B-minus. C trampoline keeps AUDIT
 * and the by-value parse_expr_result face. Do not open a new lane.
 */
#[no_mangle]
export function parser_asm_parse_unary_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let kind: i32 = 0;
  let expr_kind: i32 = 0;
  let tl: i32 = 0;
  let tc: i32 = 0;
  let wr: i32 = 0;
  let inner_ref: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    out_ok[0] = 0;
    out_expr_ref[0] = 0;
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    expr_kind = parser_asm_unary_token_to_expr_kind_c(kind);
    if (expr_kind >= 0) {
      tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
      tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
      parser_asm_lex_step_kind_c(lex_inout, source);
      if (parser_asm_parse_unary_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref) == 0) {
        return 0;
      }
      if (out_ok[0] == 0) {
        return 0;
      }
      inner_ref = out_expr_ref[0];
      wr = parser_asm_unary_wrap_operand_into_c(arena, out_ok, out_expr_ref, expr_kind, inner_ref, tl, tc);
      if (wr == 0) {
        out_ok[0] = 0;
        return 0;
      }
      return 1;
    }
    if (parser_parse_primary_ptr_into_c(arena, lex_inout, source, out_ok, out_expr_ref) == 0) {
      return 0;
    }
    if (out_ok[0] == 0) {
      return 0;
    }
    return 1;
  }
  return 0;
}
