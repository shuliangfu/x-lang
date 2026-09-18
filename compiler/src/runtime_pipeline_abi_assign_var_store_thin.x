// Thin pure: VAR store dispatcher — slice / f32 / retval-pair (wave473).
// G.7: part of glue_emit_assign_var_finish_elf_c (peer-flat).
// wave473: no-local tip U=5/5. PRODUCT inject: LINUX PREFER (stamp w473); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function glue_emit_assign_var_store_slice_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_var_store_f32_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_var_store_pair_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * VAR store gate — SLICE(11) → slice dual-GP; F32(14) → eax; else retval pair.
 * wave473: no-local — kind via re-call; flat if cascade (no else).
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_var_store_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (pipeline_type_kind_ord_at(arena, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref)) == 11) {
      return glue_emit_assign_var_store_slice_elf_c(arena, elf_ctx, left_ref, ctx, ta);
    }
    if (pipeline_type_kind_ord_at(arena, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref)) == 14) {
      return glue_emit_assign_var_store_f32_elf_c(arena, elf_ctx, left_ref, ctx, ta);
    }
    return glue_emit_assign_var_store_pair_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
  }
}
