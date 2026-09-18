// Thin pure: DEREF PTR peel via resolved operand type (wave472).
// G.7: part of glue_emit_assign_deref_elf_c gate (peer-flat).
// wave472: no-local resolved PTR→elem → finish; else peel_var. Tip U=7/7.
//   PRODUCT inject: LINUX PREFER (stamp w472); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
export extern function glue_emit_assign_deref_scalar_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_deref_finish_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, ltr: i32, ltk: i32): i32;
export extern function glue_emit_assign_deref_peel_var_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * DEREF peel — unary operand resolved PTR (ltk==9) → elem finish kinds.
 * wave472: no-local — nested re-calls; missing resolved → peel_var; else scalar.
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_deref_peel_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (pipeline_expr_unary_operand_ref_at(arena, left_ref) <= 0) {
      return glue_emit_assign_deref_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (pipeline_expr_resolved_type_ref(arena, pipeline_expr_unary_operand_ref_at(arena, left_ref)) <= 0) {
      return glue_emit_assign_deref_peel_var_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (pipeline_type_kind_ord_at(arena, pipeline_expr_resolved_type_ref(arena, pipeline_expr_unary_operand_ref_at(arena, left_ref))) != 9) {
      return glue_emit_assign_deref_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (pipeline_type_elem_ref_at(arena, pipeline_expr_resolved_type_ref(arena, pipeline_expr_unary_operand_ref_at(arena, left_ref))) <= 0) {
      return glue_emit_assign_deref_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (pipeline_type_kind_ord_at(arena, pipeline_type_elem_ref_at(arena, pipeline_expr_resolved_type_ref(arena, pipeline_expr_unary_operand_ref_at(arena, left_ref)))) == 8) {
      return glue_emit_assign_deref_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, pipeline_type_elem_ref_at(arena, pipeline_expr_resolved_type_ref(arena, pipeline_expr_unary_operand_ref_at(arena, left_ref))), 8);
    }
    if (pipeline_type_kind_ord_at(arena, pipeline_type_elem_ref_at(arena, pipeline_expr_resolved_type_ref(arena, pipeline_expr_unary_operand_ref_at(arena, left_ref)))) == 11) {
      return glue_emit_assign_deref_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, pipeline_type_elem_ref_at(arena, pipeline_expr_resolved_type_ref(arena, pipeline_expr_unary_operand_ref_at(arena, left_ref))), 11);
    }
    if (pipeline_type_kind_ord_at(arena, pipeline_type_elem_ref_at(arena, pipeline_expr_resolved_type_ref(arena, pipeline_expr_unary_operand_ref_at(arena, left_ref)))) == 13) {
      return glue_emit_assign_deref_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, pipeline_type_elem_ref_at(arena, pipeline_expr_resolved_type_ref(arena, pipeline_expr_unary_operand_ref_at(arena, left_ref))), 13);
    }
    if (pipeline_type_kind_ord_at(arena, pipeline_type_elem_ref_at(arena, pipeline_expr_resolved_type_ref(arena, pipeline_expr_unary_operand_ref_at(arena, left_ref)))) == 10) {
      return glue_emit_assign_deref_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, pipeline_type_elem_ref_at(arena, pipeline_expr_resolved_type_ref(arena, pipeline_expr_unary_operand_ref_at(arena, left_ref))), 10);
    }
    return glue_emit_assign_deref_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
  }
}
