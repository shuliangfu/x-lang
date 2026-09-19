// Thin pure: assign REST rhs_to_rax DISPATCHER only (wave454).
// G.7: body MUST match glue_emit_assign_rhs_to_rax_elf_c (arms are peers).
// wave448: full to_rax tip (helpers+dispatcher) pure-asm → product si SEGV;
//   arms-only PREFER; to_rax stays -E.
// wave454: dispatcher-only no-local reshape (re-call kind_ord; no let ako=call)
//   — same class as w451 var / w452 emit. Probe LINUX PREFER overlay.
// wave599: leftover PREFER to_rax is a huge-frame smash (objdump:
//   `sub $0x1158,%rsp`, no endbr64). After w598 -E scalar, Ubuntu
//   `unsafe { *p = 1 }` CG002 because smash to_rax returns into scalar
//   and pipe_load reads -1 (rhs_elf itself returned 0). LINUX -E
//   replace leftover T. HARD BAN PREFER. MACOS keep overlay.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_assign_load_lr_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_rhs_plain_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_rhs_add_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_rhs_sub_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_rhs_mul_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_rhs_div_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_rhs_mod_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_rhs_and_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_rhs_or_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_rhs_xor_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_rhs_shl_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_rhs_shr_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * Assign RHS → rax dispatcher (plain / compound ops 28..38).
 * wave454: no-local — re-call pipeline_expr_kind_ord_at in each arm gate
 *   (tip let-bound call results → si SEGV class; same as w451 var).
 * wave599: LINUX product path is -E of this dispatcher (PREFER smash BAN).
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF codegen ctx
 * @param assign_expr_ref i32 — ASSIGN expr kind carrier
 * @param left_ref i32 — LHS
 * @param right_ref i32 — RHS
 * @param ctx *u8 — AsmFuncCtx*
 * @param ta i32 — target arch
 * @return i32 — 0 ok; -1 failure
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_rhs_to_rax_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || assign_expr_ref <= 0 || left_ref <= 0 || right_ref <= 0) {
      return 0 - 1;
    }
    if (pipeline_expr_kind_ord_at(arena, assign_expr_ref) == 28) {
      return glue_emit_assign_rhs_plain_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (pipeline_expr_kind_ord_at(arena, assign_expr_ref) < 29) {
      return 0 - 1;
    }
    if (pipeline_expr_kind_ord_at(arena, assign_expr_ref) > 38) {
      return 0 - 1;
    }
    if (glue_emit_assign_load_lr_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (pipeline_expr_kind_ord_at(arena, assign_expr_ref) == 29) {
      return glue_emit_assign_rhs_add_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (pipeline_expr_kind_ord_at(arena, assign_expr_ref) == 30) {
      return glue_emit_assign_rhs_sub_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (pipeline_expr_kind_ord_at(arena, assign_expr_ref) == 31) {
      return glue_emit_assign_rhs_mul_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (pipeline_expr_kind_ord_at(arena, assign_expr_ref) == 32) {
      return glue_emit_assign_rhs_div_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (pipeline_expr_kind_ord_at(arena, assign_expr_ref) == 33) {
      return glue_emit_assign_rhs_mod_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (pipeline_expr_kind_ord_at(arena, assign_expr_ref) == 34) {
      return glue_emit_assign_rhs_and_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (pipeline_expr_kind_ord_at(arena, assign_expr_ref) == 35) {
      return glue_emit_assign_rhs_or_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (pipeline_expr_kind_ord_at(arena, assign_expr_ref) == 36) {
      return glue_emit_assign_rhs_xor_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (pipeline_expr_kind_ord_at(arena, assign_expr_ref) == 37) {
      return glue_emit_assign_rhs_shl_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (pipeline_expr_kind_ord_at(arena, assign_expr_ref) == 38) {
      return glue_emit_assign_rhs_shr_elf_c(arena, elf_ctx, assign_expr_ref, left_ref, right_ref, ctx, ta);
    }
    return 0 - 1;
  }
}
