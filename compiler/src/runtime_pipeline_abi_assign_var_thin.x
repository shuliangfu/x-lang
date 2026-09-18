// Thin pure: VAR assign arm (wave441/451).
// G.7: match glue_emit_assign_var_elf_c in assign_thin / mega (scalar +
//   array/vector/struct let-init arms; modlet/name-path deferred).
// wave441b: LINUX product via -E (tip pure-asm → si SEGV).
// wave449: tip pure-asm HARD BAN (single T; product si SEGV 139).
// wave451: LINUX PREFER reshape — tip SEGV root is `let x = call()` local
//   bind of call results inside this face; rewrite uses only inline
//   `if (call(...) != 0)` / re-call stack_off (no let-bound call results,
//   no u8[256] name buffer). PLATFORM: SHARED · LINUX gold · MACOS.

export extern function glue_emit_assign_rhs_to_rax_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function glue_binop_var_slot_cache_kill_def_at_slot(off: i32): void;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function backend_enc_store_rdx_to_rbp_arch(elf_ctx: *u8, slot_off: i32, ta: i32): i32;
export extern function glue_slice_dual_gp_length_off_c(off: i32, ta: i32): i32;
export extern function backend_enc_store_eax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function glue_store_retval_pair_to_rbp_elf_c(m: *u8, arena: *u8, elf_ctx: *u8, ty_ref: i32, slot_off: i32, ta: i32, init_ref: i32, ctx: *u8): i32;
export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function glue_float_promote_src_ty_ref_c(arena: *u8, right_ref: i32): i32;
export extern function glue_maybe_promote_f32_to_f64_rax_elf_c(arena: *u8, elf_ctx: *u8, ltr: i32, rty: i32, ta: i32): i32;
export extern function glue_maybe_demote_f64_to_f32_eax_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ltr: i32, right_ref: i32, ta: i32): i32;
export extern function glue_emit_fixed_array_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;
export extern function glue_emit_vector_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, let_ty_ref: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;

/**
 * VAR lvalue assign arm — wave451 no-local tip reshape.
 * Dispatches plain-assign (ako==28) array/vector/struct let-init helpers, then
 * RHS→rax + float promote/demote + slice/f32/dual-GP store. Uses
 * glue_var_expr_stack_off_elf_c (re-called; no let-bound call results) because
 * tip pure-asm SEGVs on `let x = call()` inside this face (wave449/451).
 * Deferred vs mega: modlet shared-name path, slice←array_lit / slice←[N]T arms,
 * name-buffer lookup (u8[256]).
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF codegen ctx
 * @param expr_ref i32 — ASSIGN / compound assign expr
 * @param left_ref i32 — VAR LHS
 * @param right_ref i32 — RHS
 * @param ctx *u8 — AsmFuncCtx*
 * @param ta i32 — target arch
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
export function glue_emit_assign_var_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || left_ref <= 0 || right_ref <= 0) {
      return 0 - 1;
    }
    if (glue_var_expr_stack_off_elf_c(arena, ctx, left_ref) < 0) {
      return 0 - 1;
    }
    // TYPE_ARRAY whole-array
    if (pipeline_expr_kind_ord_at(arena, expr_ref) == 28) {
      if (pipeline_type_kind_ord_at(arena, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref)) == 10) {
        if (glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref), glue_var_expr_stack_off_elf_c(arena, ctx, left_ref)) == 0) {
          glue_binop_var_slot_cache_kill_def_at_slot(glue_var_expr_stack_off_elf_c(arena, ctx, left_ref));
          return 0;
        }
      }
      if (glue_var_decl_type_ref_elf_c(arena, ctx, left_ref) > 0) {
        if (glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, glue_var_expr_stack_off_elf_c(arena, ctx, left_ref), glue_var_decl_type_ref_elf_c(arena, ctx, left_ref)) == 0) {
          glue_binop_var_slot_cache_kill_def_at_slot(glue_var_expr_stack_off_elf_c(arena, ctx, left_ref));
          return 0;
        }
      }
      if (pipeline_type_kind_ord_at(arena, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref)) == 8) {
        if (glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref), glue_var_expr_stack_off_elf_c(arena, ctx, left_ref)) == 0) {
          glue_binop_var_slot_cache_kill_def_at_slot(glue_var_expr_stack_off_elf_c(arena, ctx, left_ref));
          return 0;
        }
      }
    }
    if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref), glue_float_promote_src_ty_ref_c(arena, right_ref), ta) != 0) {
      return 0 - 1;
    }
    if (glue_maybe_demote_f64_to_f32_eax_elf_c(arena, elf_ctx, ctx, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref), right_ref, ta) != 0) {
      return 0 - 1;
    }
    if (pipeline_type_kind_ord_at(arena, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref)) == 11) {
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_var_expr_stack_off_elf_c(arena, ctx, left_ref), ta) != 0) {
        return 0 - 1;
      }
      if (backend_enc_store_rdx_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(glue_var_expr_stack_off_elf_c(arena, ctx, left_ref), ta), ta) != 0) {
        return 0 - 1;
      }
    } else {
      if (pipeline_type_kind_ord_at(arena, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref)) == 14) {
        if (backend_enc_store_eax_to_rbp_arch(elf_ctx, glue_var_expr_stack_off_elf_c(arena, ctx, left_ref), ta) != 0) {
          return 0 - 1;
        }
      } else {
        if (glue_store_retval_pair_to_rbp_elf_c(glue_emit_module_from_ctx(ctx), arena, elf_ctx, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref), glue_var_expr_stack_off_elf_c(arena, ctx, left_ref), ta, right_ref, ctx) != 0) {
          return 0 - 1;
        }
      }
    }
    glue_binop_var_slot_cache_kill_def_at_slot(glue_var_expr_stack_off_elf_c(arena, ctx, left_ref));
    return 0;
  }
}
