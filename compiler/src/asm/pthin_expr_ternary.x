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

// pthin_expr_ternary.x — G-02f-285 P4 parser thin ternary/assign product bodies.
//
// 7.2.1 P4tb Route C (2026-09-15): first bodies in this P-lane file
// (EXPR_TERNARY wrap).
// 7.2.1 P4tc Route C (2026-09-15): 有则补全 assign wrap dest-buffer
// in the same domain file (efficiency: one L2 for remaining wrap soup).
// 7.2.1 P4td B-minus (2026-09-16): 有则补全 parse_ternary dest-buffer.
// Token walk reuses P9a peek/step (same family as P4ud / P4bd / P4ad).
// Cond lower: logor through the pointer-face shim in ternary_assign.inc
// (zero-algorithm over historical parser_parse_logor_into; language
// has no struct-by-value). Then-branch: existing primary
// parser_parse_expr_ptr_into_c (G.7: one expr ptr shim; do not copy;
// C twin's then is parse_expr_into = assign-level). Else: recurse
// this dest-buffer (right-assoc; C twin calls parse_ternary_into).
// Wrap stays P4tb. C trampoline keeps AUDIT and the by-value
// parse_expr_result face.
// 7.2.1 P4te B-minus (2026-09-16): 有则补全 parse_assign dest-buffer.
// Token walk reuses P9a peek/step plus peek_tok_line/col (assign wrap
// needs the token's line/col; P4bc wrap hardcodes 0,0). Left/right
// are this file's parse_ternary dest-buffer. C twin parses ternary
// twice from the same start cursor (AUDIT/parse boundary); .x
// save/restores pos+line+col via the P9a cursor trio rather than
// "fixing" the double parse. Non-assign and non-lvalue park the
// cursor (peek does not consume). Compound kind / lvalue tests
// reuse parser_asm_is_compound_assign_token_c (P1) and
// compound_assign_token_to_expr_kind_from_glue /
// pipeline_expr_ref_is_assign_lvalue (G.7: do not copy those
// tables). Wrap stays P4tc. Do not copy wrap into parse.
// Do not dest-buffer parse_type_ref / parse_match this wave.
// Do not merge unary / binop / as_suffix parse. Do not open a new
// P-lane. Do not add bodies to pthin_expr_primary.x. Do not FORCE
// pabi mega. Do not "fix" the redundant double parse_ternary as a
// side effect.
//
// Hybrid P4tb/P4tc/P4td/P4te: g05_try_x_to_o this file;
// XLANG_PTHIN_EXPR_TERNARY_BODIES_FROM_X skips the portable wrap twins
// + parse_ternary body + parse_assign body. Cold: no define, full .inc stays.
// Do not reuse XLANG_PTHIN_EXPR_TERNARY_FROM_X for bodies.
// PLATFORM: SHARED freestanding.

// TOKEN_* pin copies of include/token.h. P4t C _Static_assert fires if
// the pin drifts; do not treat these as a second enum authority.
const TOKEN_COLON: i32 = 91;
const TOKEN_QUESTION: i32 = 127;
const TOKEN_ASSIGN: i32 = 117;

// ExprKind ordinals — G.7 ≡ ast.x / PARSER_ASM_EXPR_* in
// ternary_assign_slice.inc.
const EXPR_TERNARY: i32 = 27;
const EXPR_ASSIGN: i32 = 28;

/** Allocate a fresh Expr slot; 0 on failure. */
export extern "C" function ast_ast_arena_expr_alloc(arena: *u8): i32;
/** Wave-0: wipe ref/base/count fields on a freshly allocated expr. */
export extern "C" function pipeline_expr_set_common_zeros_c(a: *u8, er: i32): void;
/** Wave-0: write Expr.kind. */
export extern "C" function pipeline_expr_set_kind(a: *u8, er: i32, kind: i32): void;
/** Wave-0: write Expr.line / Expr.col. */
export extern "C" function pipeline_expr_set_line_col(a: *u8, er: i32, line: i32, col: i32): void;
/**
 * P5f consumer-wave writer: write Expr.if_cond_ref / if_then_ref / if_else_ref.
 * G.7: one writer for those slots (EXPR_IF and EXPR_TERNARY share the layout).
 * Lives in the P5 seed; do not copy into this seed.
 */
export extern "C" function pipeline_expr_set_if_c(a: *u8, er: i32, cond_ref: i32, then_ref: i32, else_ref: i32): void;
/**
 * P4bc consumer-wave writer: write Expr.binop_left_ref / binop_right_ref.
 * G.7: one writer for those slots (binop wrap and assign wrap share them).
 * Lives in the P4bc seed; do not copy into this seed; do not FORCE pabi mega.
 */
export extern "C" function pipeline_expr_set_binop_operands_c(a: *u8, er: i32, left_ref: i32, right_ref: i32): void;
/** P9a: peek next kind without advancing. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
/** P9a: consume one token; returns its kind. */
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
/** P9a: peek the upcoming token's line (assign wrap copies r.tok.line). */
export extern "C" function parser_asm_lex_peek_tok_line_c(lex_inout: *u8, source: *u8): i32;
/** P9a: peek the upcoming token's col (assign wrap copies r.tok.col). */
export extern "C" function parser_asm_lex_peek_tok_col_c(lex_inout: *u8, source: *u8): i32;
/** P9a cursor trio: snapshot/restore the opaque lexer for the C twin's
 * double parse_ternary from the same start (language has no lexer by-value). */
export extern "C" function parser_asm_lex_pos_c(lex: *u8): usize;
export extern "C" function parser_asm_lex_line_c(lex: *u8): i32;
export extern "C" function parser_asm_lex_col_c(lex: *u8): i32;
export extern "C" function parser_asm_lex_set_pos_c(lex: *u8, pos: usize): void;
export extern "C" function parser_asm_lex_set_line_c(lex: *u8, line: i32): void;
export extern "C" function parser_asm_lex_set_col_c(lex: *u8, col: i32): void;
/**
 * P1: true when kind is += … >>=. G.7: one compound-assign token table
 * (pthin_lex_skip.x); do not copy.
 */
export extern "C" function parser_asm_is_compound_assign_token_c(kind: i32): i32;
/**
 * Glue: TOKEN_PLUS_EQ… → ExprKind. G.7: one TOKEN→kind table; do not copy.
 */
export extern "C" function compound_assign_token_to_expr_kind_from_glue(kind: i32): i32;
/**
 * Sidecar: true when expr_ref is an assign lvalue. G.7: one lvalue
 * predicate (pabi); do not copy into this file.
 */
export extern "C" function pipeline_expr_ref_is_assign_lvalue(arena: *u8, expr_ref: i32): i32;
/**
 * Pointer-face parse_logor. Zero-algorithm C shim in ternary_assign.inc:
 * copies lexer, calls parser_parse_logor_into, writes ok/ref/next_lex.
 */
export extern "C" function parser_parse_logor_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32;
/**
 * Pointer-face parse_expr (assign-level). G.7: lives in primary.inc
 * (suffix_loop call/index); do not copy. C twin's then-branch is
 * parse_expr_into.
 */
export extern "C" function parser_parse_expr_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32;

/**
 * Allocate a ternary Expr and write kind / if_cond / if_then / if_else.
 * Dest-buffer twin of the wrap soup in parser_asm_parse_ternary_into_slice_c:
 * zeros first, then kind=27, if_* slots, line/col=0. On alloc fail writes
 * out_ok=0 and returns 0. Success writes out_expr_ref and returns the new
 * ref (does not set out_ok=1 — parse_ternary already holds ok from the
 * recursive else parse). Does not reject cond/then/else == 0: the C twin
 * only checks arena/out/alloc.
 * @param arena *u8 — opaque AST arena; null → 0
 * @param out_ok *i32 — parse_expr_result.ok slot; null → 0; alloc fail → 0
 * @param out_expr_ref *i32 — parse_expr_result.expr_ref slot; null → 0
 * @param cond_ref i32 — condition expr (logor)
 * @param then_ref i32 — middle expr (parse_expr between `?` and `:`)
 * @param else_ref i32 — recursive ternary else expr
 * @return i32 — new expr ref, or 0 on null/alloc fail
 * PLATFORM: SHARED — product P4tb Route C. Authority for the ternary
 * wrap soup. parse dest-buffer is P4td; do not copy wrap.
 */
#[no_mangle]
export function parser_asm_ternary_wrap_into_c(arena: *u8, out_ok: *i32, out_expr_ref: *i32, cond_ref: i32, then_ref: i32, else_ref: i32): i32 {
  let tern_ref: i32 = 0;
  if (arena == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    tern_ref = ast_ast_arena_expr_alloc(arena);
    if (tern_ref == 0) {
      out_ok[0] = 0;
      return 0;
    }
    // Zeros first: set_common_zeros_c clears if_cond/then/else.
    pipeline_expr_set_common_zeros_c(arena, tern_ref);
    pipeline_expr_set_kind(arena, tern_ref, EXPR_TERNARY);
    pipeline_expr_set_if_c(arena, tern_ref, cond_ref, then_ref, else_ref);
    // C twin writes line=0 / col=0 after zeros (zeros does not touch line/col).
    pipeline_expr_set_line_col(arena, tern_ref, 0, 0);
    out_expr_ref[0] = tern_ref;
  }
  return tern_ref;
}

/**
 * Allocate an assign / compound-assign Expr and write kind / left / right
 * plus the assign-token line/col. Dest-buffer twin of the wrap soup in
 * parser_asm_parse_assign_into_slice_c: zeros first, then kind, binop
 * operands, token line/col. On alloc fail writes out_ok=0 and returns 0.
 * Success writes out_expr_ref and returns the new ref (does not set
 * out_ok=1 — parse_assign already holds ok from the right-hand ternary).
 * Does not reject left/right == 0: the C twin only checks arena/out/alloc.
 * kind is EXPR_ASSIGN=28 or a compound-assign ExprKind from glue.
 * line/col come from the assign token (non-zero); this is why we do not
 * reuse parser_asm_binop_wrap_into_c (that wrap hardcodes 0,0).
 * @param arena *u8 — opaque AST arena; null → 0
 * @param out_ok *i32 — parse_expr_result.ok slot; null → 0; alloc fail → 0
 * @param out_expr_ref *i32 — parse_expr_result.expr_ref slot; null → 0
 * @param kind i32 — ExprKind ordinal (ASSIGN or +=/-=/… compound)
 * @param left_ref i32 — lvalue expr (already parsed ternary)
 * @param right_ref i32 — rvalue expr (parsed ternary after the token)
 * @param line i32 — assign-token line (C twin copies r.tok.line)
 * @param col i32 — assign-token col (C twin copies r.tok.col)
 * @return i32 — new expr ref, or 0 on null/alloc fail
 * PLATFORM: SHARED — product P4tc Route C. Authority for the assign
 * wrap soup. parse dest-buffer is P4te; do not copy. Do not extend P4bc wrap.
 */
#[no_mangle]
export function parser_asm_assign_wrap_into_c(arena: *u8, out_ok: *i32, out_expr_ref: *i32, kind: i32, left_ref: i32, right_ref: i32, line: i32, col: i32): i32 {
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
    // C twin writes the assign-token line/col after zeros (zeros does not
    // touch line/col). Do not hardcode 0,0 — that is the P4bc contract.
    pipeline_expr_set_line_col(arena, bin_ref, line, col);
    out_expr_ref[0] = bin_ref;
  }
  return bin_ref;
}

/**
 * Parse `logor ('?' parse_expr ':' parse_ternary)?` (right-assoc).
 * .x mirror of parser_asm_parse_ternary_into_slice_c: logor ptr shim
 * fills out_ok / out_expr_ref; peek does not consume. Non-`?` returns
 * success with the cursor parked (same as C peek-and-restore). `?`
 * steps, then-branch parse_expr_ptr (assign-level; dest slots reused
 * after cond_ref is saved), `:` must follow or out_ok=0 (C does not
 * restore the cursor). Else recurse this dest-buffer then wrap via
 * P4tb. Wrap does not set out_ok=1 — the else parse already did.
 * @param arena *u8 — AST arena; null → 0
 * @param lex_inout *u8 — cursor; parked after the parsed expr
 * @param source *u8 — opaque slice
 * @param out_ok *i32 — parse_expr_result.ok
 * @param out_expr_ref *i32 — parse_expr_result.expr_ref
 * @return i32 — 1 success (out_ok=1); 0 failure
 * PLATFORM: SHARED — product P4td B-minus. C trampoline keeps AUDIT
 * and the by-value parse_expr_result face. Do not open a new lane.
 */
#[no_mangle]
export function parser_asm_parse_ternary_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let kind: i32 = 0;
  let cond_ref: i32 = 0;
  let then_ref: i32 = 0;
  let else_ref: i32 = 0;
  let wr: i32 = 0;
  let rc: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    out_ok[0] = 0;
    out_expr_ref[0] = 0;
    rc = parser_parse_logor_ptr_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
    if (rc == 0) {
      return 0;
    }
    if (out_ok[0] == 0) {
      return 0;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_QUESTION) {
      // C twin: lexer_next then restore next_lex when not `?`.
      return 1;
    }
    cond_ref = out_expr_ref[0];
    parser_asm_lex_step_kind_c(lex_inout, source);
    // Then-branch is assign-level parse_expr (C: parse_expr_into into mid).
    // Reuse dest slots after cond_ref is saved; G.7 one expr ptr shim.
    rc = parser_parse_expr_ptr_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
    if (rc == 0) {
      out_ok[0] = 0;
      return 0;
    }
    if (out_ok[0] == 0) {
      return 0;
    }
    then_ref = out_expr_ref[0];
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_COLON) {
      // C twin: out.ok=0 without restoring the cursor.
      out_ok[0] = 0;
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    // Else is right-assoc parse_ternary (C: recurse parse_ternary_into).
    rc = parser_asm_parse_ternary_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
    if (rc == 0) {
      return 0;
    }
    if (out_ok[0] == 0) {
      return 0;
    }
    else_ref = out_expr_ref[0];
    wr = parser_asm_ternary_wrap_into_c(arena, out_ok, out_expr_ref, cond_ref, then_ref, else_ref);
    if (wr == 0) {
      out_ok[0] = 0;
      return 0;
    }
    return 1;
  }
  return 0;
}

/**
 * Parse `ternary (('='|'+='|…) ternary)?` (lvalue-only).
 * .x mirror of parser_asm_parse_assign_into_slice_c: parse_ternary dest-buffer
 * fills out_ok / out_expr_ref. C twin parses ternary twice from the same
 * start cursor (AUDIT/parse boundary); this body save/restores pos+line+col
 * and does the same double parse — do not collapse it. Peek does not
 * consume. Non-assign and non-lvalue return success with the cursor parked
 * (same as C peek-and-restore). Assign / compound steps, then-right is
 * another parse_ternary dest-buffer, wrap via P4tc with the token line/col.
 * Wrap does not set out_ok=1 — the right-hand ternary already did.
 * @param arena *u8 — AST arena; null → 0
 * @param lex_inout *u8 — cursor; parked after the parsed expr
 * @param source *u8 — opaque slice
 * @param out_ok *i32 — parse_expr_result.ok
 * @param out_expr_ref *i32 — parse_expr_result.expr_ref
 * @return i32 — 1 success (out_ok=1); 0 failure
 * PLATFORM: SHARED — product P4te B-minus. C trampoline keeps AUDIT
 * and the by-value parse_expr_result face. Do not open a new lane.
 */
#[no_mangle]
export function parser_asm_parse_assign_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let kind: i32 = 0;
  let left_ref: i32 = 0;
  let right_ref: i32 = 0;
  let assign_kind: i32 = 0;
  let assign_line: i32 = 0;
  let assign_col: i32 = 0;
  let wr: i32 = 0;
  let rc: i32 = 0;
  let lv: i32 = 0;
  let pos0: usize = 0;
  let line0: i32 = 0;
  let col0: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    out_ok[0] = 0;
    out_expr_ref[0] = 0;
    // C twin: two parse_ternary_into from the same by-value `lex`
    // (first result is overwritten; no ok-check on the first call).
    pos0 = parser_asm_lex_pos_c(lex_inout);
    line0 = parser_asm_lex_line_c(lex_inout);
    col0 = parser_asm_lex_col_c(lex_inout);
    rc = parser_asm_parse_ternary_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
    parser_asm_lex_set_pos_c(lex_inout, pos0);
    parser_asm_lex_set_line_c(lex_inout, line0);
    parser_asm_lex_set_col_c(lex_inout, col0);
    rc = parser_asm_parse_ternary_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
    if (rc == 0) {
      return 0;
    }
    if (out_ok[0] == 0) {
      return 0;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_ASSIGN && parser_asm_is_compound_assign_token_c(kind) == 0) {
      // C twin: lexer_next then restore next_lex when not assign.
      return 1;
    }
    lv = pipeline_expr_ref_is_assign_lvalue(arena, out_expr_ref[0]);
    if (lv == 0) {
      // C twin: not an lvalue → park cursor, keep the ternary result.
      return 1;
    }
    left_ref = out_expr_ref[0];
    assign_kind = EXPR_ASSIGN;
    if (kind != TOKEN_ASSIGN) {
      assign_kind = compound_assign_token_to_expr_kind_from_glue(kind);
    }
    assign_line = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    assign_col = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    parser_asm_lex_step_kind_c(lex_inout, source);
    rc = parser_asm_parse_ternary_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
    if (rc == 0) {
      out_ok[0] = 0;
      return 0;
    }
    if (out_ok[0] == 0) {
      return 0;
    }
    right_ref = out_expr_ref[0];
    wr = parser_asm_assign_wrap_into_c(arena, out_ok, out_expr_ref, assign_kind, left_ref, right_ref, assign_line, assign_col);
    if (wr == 0) {
      out_ok[0] = 0;
      return 0;
    }
    return 1;
  }
  return 0;
}
