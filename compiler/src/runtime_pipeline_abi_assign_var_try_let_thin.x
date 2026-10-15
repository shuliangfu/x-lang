// Thin pure: VAR try_let — array/vector/struct let-init arms (wave473).
// G.7: part of glue_emit_assign_var_elf_c (peer-flat).
// wave473: no-local tip U=7/7. PRODUCT inject: LINUX PREFER (stamp w473); MACOS skip.
// wave600: LINUX -E replace smash leftover PREFER T. HARD BAN PREFER.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_var_slot_cache_kill_def_at_slot(off: i32): void;
export extern function glue_emit_fixed_array_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;
export extern function glue_emit_vector_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, let_ty_ref: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;
export extern function glue_expr_block_transparent_value_ref_at(arena: *u8, expr_ref: i32): i32;

/**
 * VAR try_let — TYPE_ARRAY(10) / vector / STRUCT(8) let-init; kill slot on hit.
 * A TYPE_VECTOR (kind 13) whose right side is a DEREF (kind 52) or
 * a FIELD (kind 44) is declined by the vector face with no bytes
 * emitted. Block-let then copies that value with struct let-init.
 * DEREF used to fall through to an 8/16-byte pair store, so
 * `v = *p` left lane 0 unset. FIELD fell through to the same finish
 * and SIGSEGV'd (`v = h.v`). A transparent block (`unsafe { *p }`,
 * kind 26) peels to that DEREF or FIELD before the same copy.
 * Kind 8 still uses the struct call below, and uses the peeled
 * expr when it is a DEREF or a FIELD. A -1 from the vector face
 * already emitted, so struct let-init is not called again. This
 * does not store through a pointer and does not write the field.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — object writer
 * @param expr_ref i32 — ASSIGN expr; unused, the caller already split it
 * @param left_ref i32 — VAR lhs
 * @param right_ref i32 — rhs
 * @param ctx *u8 — AsmFuncCtx
 * @param ta i32 — 0 x86_64, 1 arm64
 * @return i32 — 0 handled; -1 encode failure; -3 not handled
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_emit_assign_var_try_let_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (pipeline_type_kind_ord_at(arena, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref)) == 10) {
      if (glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref), glue_var_expr_stack_off_elf_c(arena, ctx, left_ref)) == 0) {
        glue_binop_var_slot_cache_kill_def_at_slot(glue_var_expr_stack_off_elf_c(arena, ctx, left_ref));
        return 0;
      }
    }
    if (glue_var_decl_type_ref_elf_c(arena, ctx, left_ref) > 0) {
      let vst: i32 = glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, glue_var_expr_stack_off_elf_c(arena, ctx, left_ref), glue_var_decl_type_ref_elf_c(arena, ctx, left_ref));
      if (vst == 0) {
        glue_binop_var_slot_cache_kill_def_at_slot(glue_var_expr_stack_off_elf_c(arena, ctx, left_ref));
        return 0;
      }
      // TYPE_VECTOR = 13. EXPR_DEREF = 52, EXPR_FIELD = 44. The
      // vector face returns -3 and emits nothing. Struct let-init
      // leas the field or the pointee and copies lanes*esz (32 for
      // Vec8i). Vec4f is 16 and uses the 16-byte pair store in that
      // same arm. A scalar is not kind 13, so it stays on finish.
      // INDEX and VAR already return 0 from finish; do not retarget
      // them. PLATFORM: SHARED.
      if (vst == (0 - 1)) {
        return 0 - 1;
      }
      if (pipeline_type_kind_ord_at(arena, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref)) == 13) {
        let use_ref: i32 = right_ref;
        let peel_n: i32 = 0;
        let peeled: i32 = 0;
        // `unsafe { *p }` is a block. The vector face peels it, sees a
        // bare DEREF, and returns -3 with no bytes. The kind here was
        // still 26, so this copy never ran. A transparent block has no
        // lets or loops. At most four peels, then the existing struct
        // let-init copies a DEREF or a FIELD. The store is not through
        // the pointer. PLATFORM: SHARED.
        while (peel_n < 4) {
          peeled = glue_expr_block_transparent_value_ref_at(arena, use_ref);
          if (peeled <= 0) {
            peel_n = 4;
          } else {
            if (peeled == use_ref) {
              peel_n = 4;
            } else {
              use_ref = peeled;
              peel_n = peel_n + 1;
            }
          }
        }
        let rko: i32 = pipeline_expr_kind_ord_at(arena, use_ref);
        if (rko == 52 || rko == 44) {
          let st: i32 = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, use_ref, ctx, ta, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref), glue_var_expr_stack_off_elf_c(arena, ctx, left_ref));
          if (st == 0) {
            glue_binop_var_slot_cache_kill_def_at_slot(glue_var_expr_stack_off_elf_c(arena, ctx, left_ref));
            return 0;
          }
          if (st == (0 - 1)) {
            return 0 - 1;
          }
        }
      }
    }
    if (pipeline_type_kind_ord_at(arena, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref)) == 8) {
      let use_ref: i32 = right_ref;
      let peel_n: i32 = 0;
      let peeled: i32 = 0;
      let rko: i32 = 0;
      // Same transparent-block peel as kind 13. i32x8 is kind 8, so
      // `v = unsafe { *p }` never entered the arm above. A DEREF or
      // FIELD uses the peeled expr. Every other rhs stays the original
      // ref. PLATFORM: SHARED.
      while (peel_n < 4) {
        peeled = glue_expr_block_transparent_value_ref_at(arena, use_ref);
        if (peeled <= 0) {
          peel_n = 4;
        } else {
          if (peeled == use_ref) {
            peel_n = 4;
          } else {
            use_ref = peeled;
            peel_n = peel_n + 1;
          }
        }
      }
      rko = pipeline_expr_kind_ord_at(arena, use_ref);
      if (rko != 52) {
        if (rko != 44) {
          use_ref = right_ref;
        }
      }
      if (glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, use_ref, ctx, ta, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref), glue_var_expr_stack_off_elf_c(arena, ctx, left_ref)) == 0) {
        glue_binop_var_slot_cache_kill_def_at_slot(glue_var_expr_stack_off_elf_c(arena, ctx, left_ref));
        return 0;
      }
    }
    return 0 - 3;
  }
}
