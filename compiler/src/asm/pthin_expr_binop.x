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
// single-tok & ^ | && || map, kept complete) is Route C (int32). Peek
// cache, single_tok_chain, and parse_* stay C.
// 7.2.1 P4bc B-minus (2026-09-15): 有则补全 wrap dest-buffer.
// Language has no Expr by-value; the C trampoline in expr_binop_slice.inc
// holds parse_expr_result* and forwards out.ok / out.expr_ref. Sidecar
// writes go through the PABI writer family (set_common_zeros / set_kind /
// set_line_col) plus pipeline_expr_set_binop_operands_c defined in the
// P4b seed (pabi inject-only skips new rest symbols; do not FORCE the
// mega). Do not copy wrap into parse_term / parse_addsub / …. Do not merge
// unary wrap (unary_operand_ref vs left/right). Do not open a new P-lane.
// Contiguous already-T AUDIT_CALL padding on parse_logor is gated in the
// .inc under XLANG_PARSER_STRETCH_AUDIT (product AUDIT_CALL is already
// ((void)0); compiling ~700 lexer-init nops is dead preprocess).
// Do not merge parser_asm_unary_token_to_expr_kind_c (same TOKEN_* can
// mean unary prefix vs binary op: STAR deref vs mul, AMP addr-of vs
// bitand, MINUS neg vs sub). Do not rewrite single_tok_chain to call
// this table as a side effect.
// 7.2.1 P4bd B-minus (2026-09-15): 有则补全 left-assoc parse dest-buffer.
// Token walk reuses P9a peek/step (same family as P4ud parse_unary).
// Ten precedence levels share one dest-buffer: term (* / %) through
// logor (||). Level 0's lower is parse_cast through a zero-algorithm
// pointer-face shim in binop.inc (unary + as_suffix stay C). Higher
// levels recurse this dest-buffer (reuse trampoline out_ok /
// out_expr_ref — no &local i32). Wrap stays P4bc. C trampoline keeps
// AUDIT padding and publishes next_lex. TLS peek-cache stays C-twin
// only (P9a peek is semantically the unconsumed token). Do not copy
// wrap into parse. Do not dest-buffer parse_cast / as_suffix / unary
// this wave. Do not open a new P-lane.
//
// Hybrid P4bb/P4bc/P4bd: g05_try_x_to_o this file; XLANG_PTHIN_EXPR_BINOP_BODIES_FROM_X
// skips the portable .inc region (TOKEN table + wrap twin + parse_*).
// token.h remains the TOKEN_* authority via P4b C _Static_assert pins.
// Cold: no define, full .inc stays.
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

/** Allocate a fresh Expr slot; 0 on failure. */
export extern "C" function ast_ast_arena_expr_alloc(arena: *u8): i32;
/** Wave-0: wipe ref/base/count fields on a freshly allocated expr. */
export extern "C" function pipeline_expr_set_common_zeros_c(a: *u8, er: i32): void;
/** Wave-0: write Expr.kind. */
export extern "C" function pipeline_expr_set_kind(a: *u8, er: i32, kind: i32): void;
/** Wave-0: write Expr.line / Expr.col. */
export extern "C" function pipeline_expr_set_line_col(a: *u8, er: i32, line: i32, col: i32): void;
/** P4bc: write Expr.binop_left_ref and Expr.binop_right_ref. Call after set_common_zeros_c. */
export extern "C" function pipeline_expr_set_binop_operands_c(a: *u8, er: i32, left_ref: i32, right_ref: i32): void;
/** P9a: peek next kind without advancing. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
/** P9a: consume one token; returns its kind. */
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
/**
 * Pointer-face parse_cast. Zero-algorithm C shim in binop.inc:
 * copies lexer, calls parser_parse_cast_into (unary + as_suffix),
 * writes ok/ref/next_lex.
 */
export extern "C" function parser_parse_cast_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32;

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

/**
 * Allocate a binary Expr and write kind / left / right (line/col = 0).
 * Dest-buffer twin of parser_asm_binop_wrap_c: zeros first, then kind,
 * operands, line/col. On alloc fail writes out_ok=0 and returns 0.
 * Success writes out_expr_ref and returns the new ref (does not set
 * out_ok=1 — parse_* already hold ok from the operand parse). Does not
 * reject left_ref==0 / right_ref==0: the C twin only checks arena/out.
 * @param arena *u8 — opaque AST arena; null → 0
 * @param out_ok *i32 — parse_expr_result.ok slot; null → 0; alloc fail → 0
 * @param out_expr_ref *i32 — parse_expr_result.expr_ref slot; null → 0
 * @param kind i32 — ExprKind ordinal (ADD/SUB/MUL/…/LOGOR)
 * @param left_ref i32 — left operand expr ref
 * @param right_ref i32 — right operand expr ref
 * @return i32 — new expr ref, or 0 on null/alloc fail
 * PLATFORM: SHARED — product P4bc B-minus. Authority for
 * `parser_asm_binop_wrap_c`. parse dest-buffer is P4bd; do not copy wrap.
 */
#[no_mangle]
export function parser_asm_binop_wrap_into_c(arena: *u8, out_ok: *i32, out_expr_ref: *i32, kind: i32, left_ref: i32, right_ref: i32): i32 {
  let bin_ref: i32 = 0;
  if (arena == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    bin_ref = ast_ast_arena_expr_alloc(arena);
    if (bin_ref == 0) {
      out_ok[0] = 0;
      return 0;
    }
    // Zeros first: set_common_zeros_c clears binop_left_ref / binop_right_ref.
    pipeline_expr_set_common_zeros_c(arena, bin_ref);
    pipeline_expr_set_kind(arena, bin_ref, kind);
    pipeline_expr_set_binop_operands_c(arena, bin_ref, left_ref, right_ref);
    // C twin writes line=0 / col=0 after zeros (zeros does not touch line/col).
    pipeline_expr_set_line_col(arena, bin_ref, 0, 0);
    out_expr_ref[0] = bin_ref;
  }
  return bin_ref;
}

// P4bd precedence ids — G.7 ≡ parse_term … parse_logor in expr_binop_slice.inc.
const BINOP_LEVEL_TERM: i32 = 0;
const BINOP_LEVEL_ADDSUB: i32 = 1;
const BINOP_LEVEL_SHIFT: i32 = 2;
const BINOP_LEVEL_REL: i32 = 3;
const BINOP_LEVEL_EQ: i32 = 4;
const BINOP_LEVEL_BITAND: i32 = 5;
const BINOP_LEVEL_BITXOR: i32 = 6;
const BINOP_LEVEL_BITOR: i32 = 7;
const BINOP_LEVEL_LOGAND: i32 = 8;
const BINOP_LEVEL_LOGOR: i32 = 9;

/**
 * Return 1 if `mapped` ExprKind belongs to this precedence `level`.
 * term: MUL/DIV/MOD; addsub: ADD/SUB; shift: SHL/SHR; rel: LT/LE/GT/GE;
 * eq: EQ/NE; bitand/bitxor/bitor/logand/logor: the single matching kind.
 * mapped < 0 (not a binary token) never matches.
 * @param mapped i32 — ExprKind from parser_asm_binop_token_to_expr_kind_c
 * @param level i32 — 0..9 (BINOP_LEVEL_*)
 * @return i32 — 1 match, 0 otherwise
 * PLATFORM: SHARED — single matcher for the P4bd dest-buffer chain.
 */
#[no_mangle]
export function parser_asm_binop_kind_matches_level_c(mapped: i32, level: i32): i32 {
  if (mapped < 0) {
    return 0;
  }
  if (level == BINOP_LEVEL_TERM) {
    if (mapped == EXPR_MUL) {
      return 1;
    }
    if (mapped == EXPR_DIV) {
      return 1;
    }
    if (mapped == EXPR_MOD) {
      return 1;
    }
    return 0;
  }
  if (level == BINOP_LEVEL_ADDSUB) {
    if (mapped == EXPR_ADD) {
      return 1;
    }
    if (mapped == EXPR_SUB) {
      return 1;
    }
    return 0;
  }
  if (level == BINOP_LEVEL_SHIFT) {
    if (mapped == EXPR_SHL) {
      return 1;
    }
    if (mapped == EXPR_SHR) {
      return 1;
    }
    return 0;
  }
  if (level == BINOP_LEVEL_REL) {
    if (mapped == EXPR_LT) {
      return 1;
    }
    if (mapped == EXPR_LE) {
      return 1;
    }
    if (mapped == EXPR_GT) {
      return 1;
    }
    if (mapped == EXPR_GE) {
      return 1;
    }
    return 0;
  }
  if (level == BINOP_LEVEL_EQ) {
    if (mapped == EXPR_EQ) {
      return 1;
    }
    if (mapped == EXPR_NE) {
      return 1;
    }
    return 0;
  }
  if (level == BINOP_LEVEL_BITAND) {
    if (mapped == EXPR_BITAND) {
      return 1;
    }
    return 0;
  }
  if (level == BINOP_LEVEL_BITXOR) {
    if (mapped == EXPR_BITXOR) {
      return 1;
    }
    return 0;
  }
  if (level == BINOP_LEVEL_BITOR) {
    if (mapped == EXPR_BITOR) {
      return 1;
    }
    return 0;
  }
  if (level == BINOP_LEVEL_LOGAND) {
    if (mapped == EXPR_LOGAND) {
      return 1;
    }
    return 0;
  }
  if (level == BINOP_LEVEL_LOGOR) {
    if (mapped == EXPR_LOGOR) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/**
 * Parse one left-assoc binop precedence level.
 * .x mirror of parse_term … parse_logor: lower operand, then
 * (op lower)* wrapping via P4bc. Level 0 lower = parse_cast ptr shim;
 * level n>0 lower = this dest-buffer at n-1. Recurse reuses the
 * trampoline dest slots (no &local i32). Peek does not consume; a
 * non-matching op leaves the cursor parked (same as C peek-cache
 * mismatch). Wrap does not set out_ok=1 — operand parse already did.
 * @param arena *u8 — AST arena; null → 0
 * @param lex_inout *u8 — cursor; parked after the parsed expr
 * @param source *u8 — opaque slice
 * @param out_ok *i32 — parse_expr_result.ok
 * @param out_expr_ref *i32 — parse_expr_result.expr_ref
 * @param level i32 — 0..9 (BINOP_LEVEL_*); out of range → 0
 * @return i32 — 1 success (out_ok=1); 0 failure
 * PLATFORM: SHARED — product P4bd B-minus. C trampoline keeps AUDIT
 * and the by-value parse_expr_result face. Do not open a new lane.
 */
#[no_mangle]
export function parser_asm_parse_binop_level_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32, level: i32): i32 {
  let kind: i32 = 0;
  let mapped: i32 = 0;
  let left_ref: i32 = 0;
  let right_ref: i32 = 0;
  let wr: i32 = 0;
  let rc: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  if (level < 0) {
    return 0;
  }
  if (level > BINOP_LEVEL_LOGOR) {
    return 0;
  }
  unsafe {
    out_ok[0] = 0;
    out_expr_ref[0] = 0;
    if (level == BINOP_LEVEL_TERM) {
      rc = parser_parse_cast_ptr_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
    } else {
      rc = parser_asm_parse_binop_level_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref, level - 1);
    }
    if (rc == 0) {
      return 0;
    }
    if (out_ok[0] == 0) {
      return 0;
    }
    loop {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      mapped = parser_asm_binop_token_to_expr_kind_c(kind);
      if (parser_asm_binop_kind_matches_level_c(mapped, level) == 0) {
        return 1;
      }
      left_ref = out_expr_ref[0];
      parser_asm_lex_step_kind_c(lex_inout, source);
      if (level == BINOP_LEVEL_TERM) {
        rc = parser_parse_cast_ptr_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
      } else {
        rc = parser_asm_parse_binop_level_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref, level - 1);
      }
      if (rc == 0) {
        return 0;
      }
      if (out_ok[0] == 0) {
        return 0;
      }
      right_ref = out_expr_ref[0];
      wr = parser_asm_binop_wrap_into_c(arena, out_ok, out_expr_ref, mapped, left_ref, right_ref);
      if (wr == 0) {
        out_ok[0] = 0;
        return 0;
      }
    }
  }
  return 0;
}
