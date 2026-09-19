// Thin pure: DEREF PTR peel via resolved operand type (wave472).
// G.7: part of glue_emit_assign_deref_elf_c gate (peer-flat).
// wave472: no-local resolved PTR→elem → finish; else peel_var. Tip U=7/7.
//   PRODUCT inject: LINUX PREFER (stamp w472); MACOS skip.
// wave596: pipe-cell sequential loads (no nested call-as-arg). Ubuntu x86_64
//   product PREFER of the nested-call body SEGV 139 in this export on
//   `unsafe { *p = 1 }` (*i32 / *u8 store). Darwin overlay (MACOS skip) is
//   fine. Keep real dispatch (not a Soft-Cap stub).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
export extern function glue_emit_assign_deref_scalar_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_deref_finish_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, ltr: i32, ltk: i32): i32;
export extern function glue_emit_assign_deref_peel_var_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * DEREF peel — unary operand resolved PTR (ltk==9) → elem finish kinds.
 * wave596: pipe-cell holds operand/type/kind/elem; never mid `x=call()` and
 *   never nested call-as-arg (Ubuntu x86_64 PREFER smashed the frame at 0x9).
 * cell[0]=operand ref, cell[4]=resolved type, cell[8]=kind, cell[12]=elem ref.
 * Missing operand → scalar. Missing resolved type → peel_var. Non-PTR or
 * missing elem → scalar. Elem kinds 8/11/13/10 → finish; else scalar.
 * @param arena *u8 — ASTArena*; forwarded
 * @param elf_ctx *u8 — ElfCodegenCtx*; forwarded
 * @param expr_ref i32 — ASSIGN expr ref
 * @param left_ref i32 — DEREF lhs expr ref
 * @param right_ref i32 — ASSIGN rhs expr ref
 * @param ctx *u8 — PipelineDepCtx*; forwarded
 * @param ta i32 — target arch
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_deref_peel_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  let cell: u8[16] = [];
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_unary_operand_ref_at(arena, left_ref));
    if (pipe_load_i32_le(&cell[0], 0) <= 0) {
      return glue_emit_assign_deref_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    }
    pipe_store_i32_le(&cell[0], 4, pipeline_expr_resolved_type_ref(arena, pipe_load_i32_le(&cell[0], 0)));
    if (pipe_load_i32_le(&cell[0], 4) <= 0) {
      return glue_emit_assign_deref_peel_var_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    }
    pipe_store_i32_le(&cell[0], 8, pipeline_type_kind_ord_at(arena, pipe_load_i32_le(&cell[0], 4)));
    if (pipe_load_i32_le(&cell[0], 8) != 9) {
      return glue_emit_assign_deref_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    }
    pipe_store_i32_le(&cell[0], 12, pipeline_type_elem_ref_at(arena, pipe_load_i32_le(&cell[0], 4)));
    if (pipe_load_i32_le(&cell[0], 12) <= 0) {
      return glue_emit_assign_deref_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    }
    pipe_store_i32_le(&cell[0], 8, pipeline_type_kind_ord_at(arena, pipe_load_i32_le(&cell[0], 12)));
    if (pipe_load_i32_le(&cell[0], 8) == 8) {
      return glue_emit_assign_deref_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, pipe_load_i32_le(&cell[0], 12), 8);
    }
    if (pipe_load_i32_le(&cell[0], 8) == 11) {
      return glue_emit_assign_deref_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, pipe_load_i32_le(&cell[0], 12), 11);
    }
    if (pipe_load_i32_le(&cell[0], 8) == 13) {
      return glue_emit_assign_deref_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, pipe_load_i32_le(&cell[0], 12), 13);
    }
    if (pipe_load_i32_le(&cell[0], 8) == 10) {
      return glue_emit_assign_deref_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, pipe_load_i32_le(&cell[0], 12), 10);
    }
    return glue_emit_assign_deref_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
  }
}
