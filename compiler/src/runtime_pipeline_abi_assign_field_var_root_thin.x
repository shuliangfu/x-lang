// Thin pure: FIELD VAR-root gate/dispatcher (wave441/w470).
// G.7: part of pipeline_asm_emit_assign_elf_c FIELD path (peer-flat).
// wave441b: monolithic tip `let x=call()` → U-starved 1/16 (L2 假绿 if PREFER);
//   no-local monolith empties tip .o.
// wave470: gate + finish split — gate peels hit_init (PTR ltk==9 → 0);
//   stack_off replaces vname[256] lookup; no `let x=call()`. Tip U=8/8.
//   PRODUCT inject: LINUX PREFER (stamp w470); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function glue_emit_assign_field_chain_walk_elf_c(arena: *u8, left_ref: i32, out_fa: *i32, out_root: *i32): i32;
export extern function glue_emit_assign_field_var_root_finish_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, hit_init: i32): i32;

/**
 * FIELD VAR-root gate — walk/kind/stack_off, peel PTR hit_init, finish.
 * wave470: no-local — gates via `if (call()!=…)`; hit_init 0 when root
 *   VAR type is PTR (ltk==9) via decl or resolved; else finish(hit_init=1).
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_var_root_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let chain_fa: i32[16] = [];
    let root_slot: i32[1] = [];
    if (pipeline_expr_field_access_base_ref(arena, left_ref) <= 0) {
      return 0 - 3;
    }
    if (glue_emit_assign_field_chain_walk_elf_c(arena, left_ref, &chain_fa[0], &root_slot[0]) <= 0) {
      return 0 - 3;
    }
    if (root_slot[0] <= 0) {
      return 0 - 3;
    }
    if (pipeline_expr_kind_ord_at(arena, root_slot[0]) != 3) {
      return 0 - 3;
    }
    if (glue_var_expr_stack_off_elf_c(arena, ctx, root_slot[0]) < 0) {
      return 0 - 1;
    }
    if (glue_var_decl_type_ref_elf_c(arena, ctx, root_slot[0]) > 0) {
      if (pipeline_type_kind_ord_at(arena, glue_var_decl_type_ref_elf_c(arena, ctx, root_slot[0])) == 9) {
        return glue_emit_assign_field_var_root_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, 0);
      }
    }
    if (pipeline_expr_resolved_type_ref(arena, root_slot[0]) > 0) {
      if (pipeline_type_kind_ord_at(arena, pipeline_expr_resolved_type_ref(arena, root_slot[0])) == 9) {
        return glue_emit_assign_field_var_root_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, 0);
      }
    }
    return glue_emit_assign_field_var_root_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, 1);
  }
}
