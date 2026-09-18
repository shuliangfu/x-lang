// Thin pure: FIELD VAR-root finish — ptr_hit + mag_fold + stores (wave470).
// G.7: part of pipeline_asm_emit_assign_elf_c FIELD VAR-root path
//   (peer-flat; after gate peels hit_init).
// wave441b: monolithic root tip `let x=call()` U-starved (1/16);
//   large no-local monolith empties tip .o.
// wave470: finish peer — re-walk chain, stack_off (no vname[256]),
//   mag_fold side-effect then stores; no `let x=call()` /
//   no `slot[0]=call()`. Tip U=8/8. PRODUCT: LINUX PREFER with gate.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_field_access_effective_offset_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function pipeline_expr_field_access_load_byte_sz(arena: *u8, mod: *u8, expr_ref: i32): i32;
export extern function glue_emit_assign_field_chain_walk_elf_c(arena: *u8, left_ref: i32, out_fa: *i32, out_root: *i32): i32;
export extern function glue_emit_assign_field_ptr_hit_elf_c(arena: *u8, mod: *u8, chain_fa: *i32, chain_n: i32, hit_in: i32): i32;
export extern function glue_emit_assign_field_mag_fold_elf_c(arena: *u8, mod: *u8, chain_fa: *i32, chain_n: i32, off_in: i32, hit_in: i32, ta: i32, out_off: *i32): i32;
export extern function glue_emit_assign_field_var_stores_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, hit: i32, off: i32, field_off: i32, load_sz: i32, walk_cur: i32, var_off: i32, chain_n: i32): i32;

/**
 * FIELD VAR-root finish — fold frame-mag then typed stores.
 * wave470: no-local — chain_walk / stack_off / ptr_hit re-called into
 *   mag_fold + stores args; mag_fold in `if (==0)` fills off_slot then
 *   stores (hit 0) or stores(ptr_hit(hit_init), off_slot). load_sz<=0 → 4.
 * @param hit_init i32 — 0 if root VAR is PTR (ltk==9); else 1
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_var_root_finish_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, hit_init: i32): i32 {
  unsafe {
    let chain_fa: i32[16] = [];
    let root_slot: i32[1] = [];
    let off_slot: i32[1] = [];
    if (glue_emit_assign_field_chain_walk_elf_c(arena, left_ref, &chain_fa[0], &root_slot[0]) <= 0) {
      return 0 - 3;
    }
    if (root_slot[0] <= 0) {
      return 0 - 3;
    }
    if (glue_var_expr_stack_off_elf_c(arena, ctx, root_slot[0]) < 0) {
      return 0 - 1;
    }
    if (pipeline_expr_field_access_load_byte_sz(arena, pipeline_asm_emit_module_ref_c(), left_ref) <= 0) {
      if (glue_emit_assign_field_mag_fold_elf_c(arena, pipeline_asm_emit_module_ref_c(), &chain_fa[0], glue_emit_assign_field_chain_walk_elf_c(arena, left_ref, &chain_fa[0], &root_slot[0]), glue_var_expr_stack_off_elf_c(arena, ctx, root_slot[0]), glue_emit_assign_field_ptr_hit_elf_c(arena, pipeline_asm_emit_module_ref_c(), &chain_fa[0], glue_emit_assign_field_chain_walk_elf_c(arena, left_ref, &chain_fa[0], &root_slot[0]), hit_init), ta, &off_slot[0]) == 0) {
        return glue_emit_assign_field_var_stores_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, 0, off_slot[0], glue_field_access_effective_offset_c(arena, pipeline_asm_emit_module_ref_c(), left_ref), 4, root_slot[0], glue_var_expr_stack_off_elf_c(arena, ctx, root_slot[0]), glue_emit_assign_field_chain_walk_elf_c(arena, left_ref, &chain_fa[0], &root_slot[0]));
      }
      return glue_emit_assign_field_var_stores_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, glue_emit_assign_field_ptr_hit_elf_c(arena, pipeline_asm_emit_module_ref_c(), &chain_fa[0], glue_emit_assign_field_chain_walk_elf_c(arena, left_ref, &chain_fa[0], &root_slot[0]), hit_init), off_slot[0], glue_field_access_effective_offset_c(arena, pipeline_asm_emit_module_ref_c(), left_ref), 4, root_slot[0], glue_var_expr_stack_off_elf_c(arena, ctx, root_slot[0]), glue_emit_assign_field_chain_walk_elf_c(arena, left_ref, &chain_fa[0], &root_slot[0]));
    }
    if (glue_emit_assign_field_mag_fold_elf_c(arena, pipeline_asm_emit_module_ref_c(), &chain_fa[0], glue_emit_assign_field_chain_walk_elf_c(arena, left_ref, &chain_fa[0], &root_slot[0]), glue_var_expr_stack_off_elf_c(arena, ctx, root_slot[0]), glue_emit_assign_field_ptr_hit_elf_c(arena, pipeline_asm_emit_module_ref_c(), &chain_fa[0], glue_emit_assign_field_chain_walk_elf_c(arena, left_ref, &chain_fa[0], &root_slot[0]), hit_init), ta, &off_slot[0]) == 0) {
      return glue_emit_assign_field_var_stores_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, 0, off_slot[0], glue_field_access_effective_offset_c(arena, pipeline_asm_emit_module_ref_c(), left_ref), pipeline_expr_field_access_load_byte_sz(arena, pipeline_asm_emit_module_ref_c(), left_ref), root_slot[0], glue_var_expr_stack_off_elf_c(arena, ctx, root_slot[0]), glue_emit_assign_field_chain_walk_elf_c(arena, left_ref, &chain_fa[0], &root_slot[0]));
    }
    return glue_emit_assign_field_var_stores_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, glue_emit_assign_field_ptr_hit_elf_c(arena, pipeline_asm_emit_module_ref_c(), &chain_fa[0], glue_emit_assign_field_chain_walk_elf_c(arena, left_ref, &chain_fa[0], &root_slot[0]), hit_init), off_slot[0], glue_field_access_effective_offset_c(arena, pipeline_asm_emit_module_ref_c(), left_ref), pipeline_expr_field_access_load_byte_sz(arena, pipeline_asm_emit_module_ref_c(), left_ref), root_slot[0], glue_var_expr_stack_off_elf_c(arena, ctx, root_slot[0]), glue_emit_assign_field_chain_walk_elf_c(arena, left_ref, &chain_fa[0], &root_slot[0]));
  }
}
