// Thin pure: DEREF arm gate/dispatcher (wave441/w472).
// G.7: body MUST match pipeline_asm_emit_assign_elf_c DEREF path (peer-flat).
// wave449: LINUX PREFER tip pure-asm (product si green alone + with peers).
// wave441b: monolithic tip `let x=call()` → U-starved 1/15 (L2 假绿 if PREFER).
// wave472: gate + peel + peel_var + finish + after_addr + vec_gate no-local
//   split. Tip U=5/5. PRODUCT inject: LINUX PREFER (stamp w472); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function glue_emit_assign_deref_scalar_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_deref_finish_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, ltr: i32, ltk: i32): i32;
export extern function glue_emit_assign_deref_peel_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * DEREF lvalue assign gate — ta check, direct ARRAY/VEC/SLICE/STRUCT finish,
 *   else PTR peel. wave472: no-local — type kind via re-call; no `let x=call()`.
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_deref_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (ta != 0) {
      if (ta != 1) {
        return glue_emit_assign_deref_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
      }
    }
    if (pipeline_expr_resolved_type_ref(arena, left_ref) <= 0) {
      return glue_emit_assign_deref_peel_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (pipeline_type_kind_ord_at(arena, pipeline_expr_resolved_type_ref(arena, left_ref)) == 8) {
      return glue_emit_assign_deref_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, pipeline_expr_resolved_type_ref(arena, left_ref), 8);
    }
    if (pipeline_type_kind_ord_at(arena, pipeline_expr_resolved_type_ref(arena, left_ref)) == 11) {
      return glue_emit_assign_deref_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, pipeline_expr_resolved_type_ref(arena, left_ref), 11);
    }
    if (pipeline_type_kind_ord_at(arena, pipeline_expr_resolved_type_ref(arena, left_ref)) == 13) {
      return glue_emit_assign_deref_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, pipeline_expr_resolved_type_ref(arena, left_ref), 13);
    }
    if (pipeline_type_kind_ord_at(arena, pipeline_expr_resolved_type_ref(arena, left_ref)) == 10) {
      return glue_emit_assign_deref_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, pipeline_expr_resolved_type_ref(arena, left_ref), 10);
    }
    return glue_emit_assign_deref_peel_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
  }
}
