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
// ternary_assign.inc is always host-cc'd into the hybrid P4t object.
// Language has no Expr by-value; dest-buffer both wrap soups:
//   EXPR_TERNARY (kind=27 + if_cond/then/else + line/col=0)
//   ASSIGN/compound (kind param + binop left/right + token line/col)
// The C trampoline in ternary_assign_slice.inc holds parse_expr_result*
// and forwards out.ok / out.expr_ref. Sidecar writes go through the
// PABI writer family (set_common_zeros / set_kind / set_line_col)
// plus pipeline_expr_set_if_c in the P5 seed (G.7: one writer for
// the if_* slots) and pipeline_expr_set_binop_operands_c in the P4bc
// seed (G.7: one writer for binop_left/right; do not copy; do not
// FORCE pabi mega; do not extend P4bc wrap with line/col — that
// wrap hardcodes 0,0).
// parse_ternary / parse_assign stay C and call the historical wrap
// symbols. Do not dest-buffer parse this wave (extra lexer_next +
// parse_expr by-value). Do not copy wrap into parse_ternary /
// parse_assign. Do not merge unary wrap (unary_operand_ref). Do not
// merge binop wrap (P4bc line/col=0 vs assign token line/col). Do
// not merge skip_if_expr_finish (EXPR_IF=25 plus resolved_type_ref).
// Do not open a new P-lane. Do not wrap dest-SLICE as extra. Do not
// add bodies to pthin_expr_primary.x. Do not "fix" the redundant
// double parse_ternary_into at the AUDIT/parse boundary of
// parse_assign as a side effect.
//
// Hybrid P4tb/P4tc: g05_try_x_to_o this file;
// XLANG_PTHIN_EXPR_TERNARY_BODIES_FROM_X skips the portable wrap twins.
// Cold: no define, full .inc stays.
// Do not reuse XLANG_PTHIN_EXPR_TERNARY_FROM_X for bodies.
// PLATFORM: SHARED freestanding.

// ExprKind ordinal — G.7 ≡ ast.x / PARSER_ASM_EXPR_TERNARY in
// ternary_assign_slice.inc.
const EXPR_TERNARY: i32 = 27;

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
 * wrap soup. parse_ternary stays C; do not copy.
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
 * wrap soup. parse_assign stays C; do not copy. Do not extend P4bc wrap.
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
