// Thin pure: assign emit dispatcher (wave441/452).
// G.7: body MUST match pipeline_asm_emit_assign_elf_c (peer-flat arms).
// wave426: LINUX HARD BAN (Ubuntu empty .o).
// wave441: LINUX -E peer chain unlock (wave441b: pure-asm peers/emit
//   CG002 or si SEGV 139 — soft -E product path).
// wave449: tip pure-asm HARD BAN — dispatcher alone → product si SEGV 139
//   (same class as rhsrax to_rax). Stay -E leftover.
// wave452: no-local reshape (re-call left/right/peel/kind; no let-bound
//   call results — same class as w451 var). Tip pure-asm still HARD BAN:
//   product inject → si BUILD FAIL CG002 (elf_ec=-1 out_len=0), not SEGV.
// wave457: hybrid (let left/right/peel; re-call kind) tip → same si CG002.
//   Tip .o drops U left/right/peel (U-starved). Keep soft -E; body=w452.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_peel_as_array_slice_ascription_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;
export extern function glue_emit_assign_field_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_index_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_var_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_deref_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * EXPR_ASSIGN ELF emit — flat peer arm dispatch (FIELD/INDEX/VAR/DEREF).
 * wave452: no-local body (re-call left/right/peel/kind). Tip pure-asm BAN
 *   (si CG002); product stays soft -E. Same reshape class as w451 var.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF codegen ctx
 * @param expr_ref i32 — ASSIGN expr
 * @param ctx *u8 — AsmFuncCtx*
 * @param ta i32 — target arch
 * @return i32 — 0 ok; -1 failure
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function pipeline_asm_emit_assign_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || expr_ref <= 0) {
      return 0 - 1;
    }
    if (pipeline_expr_binop_left_ref_at(arena, expr_ref) <= 0) {
      return 0 - 1;
    }
    if (pipeline_expr_binop_right_ref_at(arena, expr_ref) <= 0) {
      return 0 - 1;
    }
    if (glue_peel_as_array_slice_ascription_c(arena, pipeline_expr_binop_right_ref_at(arena, expr_ref)) <= 0) {
      return 0 - 1;
    }
    if (pipeline_expr_kind_ord_at(arena, pipeline_expr_binop_left_ref_at(arena, expr_ref)) != 47) {
      glue_index_assign_addr_cache_clear();
    }
    if (pipeline_expr_kind_ord_at(arena, pipeline_expr_binop_left_ref_at(arena, expr_ref)) == 44) {
      return glue_emit_assign_field_elf_c(
        arena,
        elf_ctx,
        expr_ref,
        pipeline_expr_binop_left_ref_at(arena, expr_ref),
        glue_peel_as_array_slice_ascription_c(arena, pipeline_expr_binop_right_ref_at(arena, expr_ref)),
        ctx,
        ta
      );
    }
    if (pipeline_expr_kind_ord_at(arena, pipeline_expr_binop_left_ref_at(arena, expr_ref)) == 47) {
      return glue_emit_assign_index_elf_c(
        arena,
        elf_ctx,
        expr_ref,
        pipeline_expr_binop_left_ref_at(arena, expr_ref),
        glue_peel_as_array_slice_ascription_c(arena, pipeline_expr_binop_right_ref_at(arena, expr_ref)),
        ctx,
        ta
      );
    }
    if (pipeline_expr_kind_ord_at(arena, pipeline_expr_binop_left_ref_at(arena, expr_ref)) == 3) {
      return glue_emit_assign_var_elf_c(
        arena,
        elf_ctx,
        expr_ref,
        pipeline_expr_binop_left_ref_at(arena, expr_ref),
        glue_peel_as_array_slice_ascription_c(arena, pipeline_expr_binop_right_ref_at(arena, expr_ref)),
        ctx,
        ta
      );
    }
    if (pipeline_expr_kind_ord_at(arena, pipeline_expr_binop_left_ref_at(arena, expr_ref)) == 52) {
      return glue_emit_assign_deref_elf_c(
        arena,
        elf_ctx,
        expr_ref,
        pipeline_expr_binop_left_ref_at(arena, expr_ref),
        glue_peel_as_array_slice_ascription_c(arena, pipeline_expr_binop_right_ref_at(arena, expr_ref)),
        ctx,
        ta
      );
    }
    return 0 - 1;
  }
}
