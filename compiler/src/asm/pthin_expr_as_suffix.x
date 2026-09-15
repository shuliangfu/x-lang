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

// pthin_expr_as_suffix.x — G-02f-285 P4 parser thin as_suffix product bodies.
//
// 7.2.1 P4as Route C (2026-09-15): first bodies in this P-lane file.
// as_suffix.inc is always host-cc'd into the hybrid P4as object.
// Language has no Expr by-value; dest-buffer both postfix wrap soups
// in one wave (efficiency: one domain file, two wraps, one L2):
//   TRY_PROPAGATE (kind=58 + unary_operand_ref + line/col=0)
//   EXPR_AS       (kind=54 + as_operand/as_target + line/col=0)
// The C trampoline in as_suffix_slice.inc holds parse_expr_result*
// and forwards out.ok / out.expr_ref. Sidecar writes go through the
// PABI writer family (set_common_zeros / set_kind / set_line_col)
// plus pipeline_expr_set_unary_operand_c in the P4u seed (G.7: one
// writer for unary_operand_ref; do not copy into this seed) and
// pipeline_expr_set_as_c in this P-lane seed (late as_* offsets;
// pabi inject-only skips new rest symbols; do not FORCE the mega).
// parse_as_suffix stays C (lexer_next + type_ref by-value) and calls
// the historical wrap symbols. Do not dest-buffer parse this wave.
// Do not copy wrap into parse_as_suffix / parse_unary / primary.
// Do not merge unary wrap (prefix kinds + non-zero line/col +
// operand_ref==0 reject). Do not merge binop wrap. Do not merge
// ternary wrap. Do not wrap assign wrap as extra. Do not open a
// new P-lane. Do not add bodies to pthin_expr_primary.x.
//
// Hybrid P4as: g05_try_x_to_o this file; XLANG_PTHIN_EXPR_AS_SUFFIX_BODIES_FROM_X
// skips the portable wrap twins. Cold: no define, full .inc stays.
// Do not reuse XLANG_PTHIN_EXPR_AS_SUFFIX_FROM_X for P4as bodies.
// PLATFORM: SHARED freestanding.

// ExprKind ordinals — G.7 ≡ ast.x / PARSER_ASM_EXPR_* in as_suffix_slice.inc.
const EXPR_AS: i32 = 54;
const EXPR_TRY_PROPAGATE: i32 = 58;

/** Allocate a fresh Expr slot; 0 on failure. */
export extern "C" function ast_ast_arena_expr_alloc(arena: *u8): i32;
/** Wave-0: wipe ref/base/count fields on a freshly allocated expr. */
export extern "C" function pipeline_expr_set_common_zeros_c(a: *u8, er: i32): void;
/** Wave-0: write Expr.kind. */
export extern "C" function pipeline_expr_set_kind(a: *u8, er: i32, kind: i32): void;
/** Wave-0: write Expr.line / Expr.col. */
export extern "C" function pipeline_expr_set_line_col(a: *u8, er: i32, line: i32, col: i32): void;
/**
 * P4uc consumer-wave writer: write Expr.unary_operand_ref.
 * G.7: one writer for that slot (unary prefix and TRY_PROPAGATE share it).
 * Lives in the P4u seed; do not copy into this seed.
 */
export extern "C" function pipeline_expr_set_unary_operand_c(a: *u8, er: i32, operand_ref: i32): void;
/**
 * P4as consumer-wave writer: write Expr.as_operand_ref / as_target_type_ref.
 * Lives in the P4as seed; do not FORCE pabi mega; do not copy into other seeds.
 */
export extern "C" function pipeline_expr_set_as_c(a: *u8, er: i32, operand_ref: i32, type_ref: i32): void;

/**
 * Allocate a TRY_PROPAGATE Expr and write kind / unary_operand_ref.
 * Dest-buffer twin of the `?` postfix wrap soup in
 * parser_asm_parse_as_suffix_into_slice_c: zeros first, then kind=58,
 * unary_operand, line/col=0. On alloc fail writes out_ok=0 and returns 0.
 * Success writes out_expr_ref and returns the new ref (does not set
 * out_ok=1 — parse already holds ok from primary). Does not reject
 * inner_ref == 0: the C twin only checks alloc. next_lex stays in parse.
 * @param arena *u8 — opaque AST arena; null → 0
 * @param out_ok *i32 — parse_expr_result.ok slot; null → 0; alloc fail → 0
 * @param out_expr_ref *i32 — parse_expr_result.expr_ref slot; null → 0
 * @param inner_ref i32 — operand expr (already parsed primary / prior suffix)
 * @return i32 — new expr ref, or 0 on null/alloc fail
 * PLATFORM: SHARED — product P4as Route C. Authority for the try-propagate
 * wrap soup. parse_as_suffix stays C; do not copy. Do not merge P4uc unary wrap.
 */
#[no_mangle]
export function parser_asm_try_propagate_wrap_into_c(arena: *u8, out_ok: *i32, out_expr_ref: *i32, inner_ref: i32): i32 {
  let try_ref: i32 = 0;
  if (arena == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    try_ref = ast_ast_arena_expr_alloc(arena);
    if (try_ref == 0) {
      out_ok[0] = 0;
      return 0;
    }
    // Zeros first: set_common_zeros_c clears unary_operand_ref.
    pipeline_expr_set_common_zeros_c(arena, try_ref);
    pipeline_expr_set_kind(arena, try_ref, EXPR_TRY_PROPAGATE);
    pipeline_expr_set_unary_operand_c(arena, try_ref, inner_ref);
    // C twin writes line=0 / col=0 (zeros does not touch line/col).
    pipeline_expr_set_line_col(arena, try_ref, 0, 0);
    out_expr_ref[0] = try_ref;
  }
  return try_ref;
}

/**
 * Allocate an EXPR_AS Expr and write kind / as_operand / as_target.
 * Dest-buffer twin of the `as type` wrap soup in
 * parser_asm_parse_as_suffix_into_slice_c: zeros first, then kind=54,
 * as_* slots, line/col=0. On alloc fail writes out_ok=0 and returns 0.
 * Success writes out_expr_ref and returns the new ref (does not set
 * out_ok=1 — parse already holds ok). Does not reject inner/type == 0:
 * the C twin only checks alloc; type_ref==0 already failed before wrap.
 * @param arena *u8 — opaque AST arena; null → 0
 * @param out_ok *i32 — parse_expr_result.ok slot; null → 0; alloc fail → 0
 * @param out_expr_ref *i32 — parse_expr_result.expr_ref slot; null → 0
 * @param inner_ref i32 — operand expr (already parsed primary / prior suffix)
 * @param type_ref i32 — target type from parse_type_ref after `as`
 * @return i32 — new expr ref, or 0 on null/alloc fail
 * PLATFORM: SHARED — product P4as Route C. Authority for the as wrap soup.
 * parse_as_suffix stays C; do not copy. Do not merge unary/binop/ternary wrap.
 */
#[no_mangle]
export function parser_asm_as_wrap_into_c(arena: *u8, out_ok: *i32, out_expr_ref: *i32, inner_ref: i32, type_ref: i32): i32 {
  let as_ref: i32 = 0;
  if (arena == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    as_ref = ast_ast_arena_expr_alloc(arena);
    if (as_ref == 0) {
      out_ok[0] = 0;
      return 0;
    }
    // Zeros first: set_common_zeros_c clears as_operand/as_target.
    pipeline_expr_set_common_zeros_c(arena, as_ref);
    pipeline_expr_set_kind(arena, as_ref, EXPR_AS);
    pipeline_expr_set_as_c(arena, as_ref, inner_ref, type_ref);
    // C twin writes line=0 / col=0 after zeros (zeros does not touch line/col).
    pipeline_expr_set_line_col(arena, as_ref, 0, 0);
    out_expr_ref[0] = as_ref;
  }
  return as_ref;
}
