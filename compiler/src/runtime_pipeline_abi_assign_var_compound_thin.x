// Thin pure overlay: VAR assign gate for Darwin + Windows (w1502, 终局待办 10.25).
// Darwin pabi is a libtool archive, so the w620 inject of the assign_var
// leaves never ran there; the live gate was a leftover host-cc body that only
// handled plain ASSIGN (kind 28). Windows used seeds/win_assign_var_override.c,
// also kind 28 only. `a += 3` and every compound op (kinds 29..38) then
// returned -1 and the whole function failed with CG002.
// This gate keeps the leaf split of runtime_pipeline_abi_assign_var_thin.x
// (try_let + finish; finish calls glue_emit_assign_rhs_to_rax_elf_c, which
// dispatches compound ops) and adds the file-scope scalar path the Windows
// override had: no frame slot + shared module let → value to rax → egg store.
// It also defines glue_emit_assign_rhs_elf_c (same body as
// runtime_pipeline_abi_assign_thin.x); neither egg links that name.
// It also defines glue_emit_assign_load_lr_elf_c (replaces the unchanged
// runtime_pipeline_abi_assign_rhsrax_arms_load_lr_thin.x leaf, which calls
// glue_try_binop_left_rax_right_rbx_elf_c twice and so emits the load pair
// twice). For a VAR target the right side is loaded first into rbx, then the
// VAR into rax: a VAR load never touches rbx, so arm64 needs no frame home
// for rax (that home grew the frame cursor past the prologue's frame size,
// and `g += 5; g *= 2` in a leaf function wrote over saved x19/caller frame,
// SIGBUS). Other targets try the fast pair once, else push/pop.
// Editing the assign_var / rhsrax leaves marks pabi.o stale (FORCE pabi is
// banned), so this lives in its own file. g05_relink_env compiles it with the
// current product every relink, next to the unchanged leaves.
// PLATFORM: MACOS|DARWIN + WINDOWS. Linux keeps the injected pabi leaves.

export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_assign_var_try_let_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_var_finish_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_rhs_to_rax_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_asm_modlet_name_is_shared(name: *u8, name_len: i32): i32;
export extern function pipeline_asm_modlet_store_from_rax_elf_c(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern function glue_binop_var_slot_cache_invalidate_slot(off: i32): void;
export extern function glue_index_scratch_spill_invalidate_var(arena: *u8, elf_ctx: *u8, ctx: *u8, var_ref: i32, ta: i32): void;
export extern function glue_assign_lhs_f32_type_ref_elf_c(arena: *u8, ctx: *u8, left_ref: i32): i32;
export extern function glue_emit_float_lit_to_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ta: i32, force_ty_ref: i32, call_abi_widen_f64: i32): i32;
export extern function glue_try_binop_left_rax_right_rbx_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_binop_var_slot_cache_invalidate_rbx(): void;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * File-scope scalar assign: value (plain or compound) into rax, then store
 * into the module cell. Only names the egg table marks shared.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param expr_ref i32 — ASSIGN / compound assign expr
 * @param left_ref i32 — VAR lhs
 * @param right_ref i32 — rhs
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 ok; -1 not a shared module let or emit failure
 * PLATFORM: SHARED freestanding (linked on Darwin + Windows).
 */
function w1502_assign_modlet(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let vname: u8[256] = [];
    let vlen: i32 = pipeline_expr_var_name_len(arena, left_ref);
    if (vlen <= 0 || vlen > 255) {
      return 0 - 1;
    }
    pipeline_expr_var_name_into(arena, left_ref, &vname[0]);
    if (pipeline_asm_modlet_name_is_shared(&vname[0], vlen) == 0) {
      return 0 - 1;
    }
    if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    return pipeline_asm_modlet_store_from_rax_elf_c(elf_ctx, &vname[0], vlen, ta);
  }
}

/**
 * VAR lvalue assign gate. Frame local: kind 28 tries try_let, then finish
 * (plain + compound 29..38 via rhs_to_rax, typed store). No frame slot:
 * shared module let path. Drops the binop var-slot cache and index scratch
 * spill for the slot before and after the store.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param expr_ref i32 — ASSIGN / compound assign expr
 * @param left_ref i32 — VAR lhs
 * @param right_ref i32 — rhs
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding (linked on Darwin + Windows).
 */
#[no_mangle]
export function glue_emit_assign_var_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8)) {
      return 0 - 1;
    }
    if (left_ref <= 0 || right_ref <= 0) {
      return 0 - 1;
    }
    let off: i32 = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
    if (off < 0) {
      return w1502_assign_modlet(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    }
    glue_index_scratch_spill_invalidate_var(arena, elf_ctx, ctx, left_ref, ta);
    glue_binop_var_slot_cache_invalidate_slot(off);
    let rc: i32 = 0 - 1;
    if (pipeline_expr_kind_ord_at(arena, expr_ref) == 28) {
      rc = glue_emit_assign_var_try_let_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (rc != 0) {
      rc = glue_emit_assign_var_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    }
    glue_binop_var_slot_cache_invalidate_slot(off);
    return rc;
  }
}

/**
 * Assign RHS emit: f32 lhs + FLOAT_LIT rhs uses the imm32 path; else the
 * general expression emitter. Same body as runtime_pipeline_abi_assign_thin.x.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param left_ref i32 — lhs
 * @param right_ref i32 — rhs
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 ok; -1 failure
 * PLATFORM: SHARED freestanding (linked on Darwin + Windows).
 */
#[no_mangle]
export function glue_emit_assign_rhs_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (arena == (0 as *u8) || right_ref <= 0) {
      return 0 - 1;
    }
    if (pipeline_expr_kind_ord_at(arena, right_ref) == 1) {
      let lhs_f32: i32 = glue_assign_lhs_f32_type_ref_elf_c(arena, ctx, left_ref);
      if (lhs_f32 > 0) {
        return glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, right_ref, ta, lhs_f32, 0);
      }
    }
    return pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta);
  }
}

/**
 * Compound assign: load target to rax and right side to rbx.
 * VAR target (kind 3): right side first, mov rax to rbx, drop the rbx VAR
 * cache, then the VAR load (touches only rax). Other targets: one call of
 * the fast pair; on -2 emit left, push, emit right, pop rbx.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — emit context
 * @param left_ref i32 — assign target
 * @param right_ref i32 — right side
 * @param ctx *u8 — AsmFuncCtx*
 * @param ta i32 — target arch
 * @return i32 — 0 ok; -1 failure
 * PLATFORM: MACOS|ARM64 + WINDOWS x86_64.
 */
#[no_mangle]
export function glue_emit_assign_load_lr_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, left_ref) == 3) {
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0) {
        return 0 - 1;
      }
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
        return 0 - 1;
      }
      glue_binop_var_slot_cache_invalidate_rbx();
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0) {
        return 0 - 1;
      }
      return 0;
    }
    return w1502_load_lr_other(arena, elf_ctx, left_ref, right_ref, ctx, ta, glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta));
  }
}

/**
 * Non-VAR tail of glue_emit_assign_load_lr_elf_c: r is the single fast-pair
 * result (0 done, -1 fail, -2 not handled and nothing emitted).
 * @return i32 — 0 ok; -1 failure
 * PLATFORM: MACOS|ARM64 + WINDOWS x86_64.
 */
export function w1502_load_lr_other(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, r: i32): i32 {
  unsafe {
    if (r == 0) {
      return 0;
    }
    if (r != (0 - 2)) {
      return 0 - 1;
    }
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    return 0;
  }
}
