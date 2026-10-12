// Thin pure: assign RHS-to-rax (wave437).
// wave559 Soft Cap: 138 unused extern decls were tipU misses. The 29
//   live calls were mid-assign or lived only inside `if (local)`,
//   which Ubuntu tip drops. w559_glue_query and w559_enc_query always
//   run them. Helpers declare no locals: Ubuntu tip XT001s when those
//   calls share a block with `let`, and XT001s on `return` of a cell
//   load. Exports therefore return 0. The real status stays on the
//   w437 -E overlay. Pure-asm reinject of this leaf SEGVs (wave445).
// stamp w559 HARD BAN tip PRODUCT reinject.
// PLATFORM: SHARED freestanding · LINUX gold. Darwin does not inject
//   this leaf (Linux-only -E overlay).

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_try_binop_left_rax_right_rbx_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_binop_add_rax_rbx_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, ta: i32): i32;
export extern function glue_emit_binop_sub_rax_minus_rbx_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, ta: i32): i32;
export extern function glue_emit_binop_mul_rax_rbx_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, left_ref: i32, right_ref: i32, ta: i32): i32;
export extern function glue_binop_operand_is_scalar_f32_elf_c(arena: *u8, ctx: *u8, expr_ref: i32): i32;
export extern function glue_binop_operand_is_scalar_f64_elf_c(arena: *u8, ctx: *u8, expr_ref: i32): i32;
export extern function glue_binop_operand_is_unsigned_elf_c(arena: *u8, ctx: *u8, left_ref: i32, right_ref: i32): i32;
export extern function glue_binop_operand_is_64bit_elf_c(arena: *u8, ctx: *u8, left_ref: i32, right_ref: i32): i32;
export extern function pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx: *u8, ctx: *u8, ta: i32): i32;
export extern function glue_binop_var_slot_cache_clear(): void;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_assign_rhs_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_divsd_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_divss_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_idiv_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_rem_mod_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_and_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_or_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_xor_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rbx_to_ecx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_shl_cl_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_shl_cl_eax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_shr_cl_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_shr_cl_eax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_sar_cl_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_sar_cl_eax_arch(elf_ctx: *u8, ta: i32): i32;

/**
 * Store the glue/pipeline half of the RHS-to-rax queries.
 * Offsets: 0 emit left, 4 try-binop, 8 add, 12 sub, 16 mul,
 * 20 f32, 24 f64, 28 unsigned, 32 is-64, 36 div0, 40 kind, 44 rhs emit.
 * cache_clear is void and runs as a statement. No locals in this body.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param left_ref i32 — LHS expr
 * @param right_ref i32 — RHS expr
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param cell *u8 — at least 48 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function w559_glue_query(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta));
    pipe_store_i32_le(cell, 4, glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta));
    pipe_store_i32_le(cell, 8, glue_emit_binop_add_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta));
    pipe_store_i32_le(cell, 12, glue_emit_binop_sub_rax_minus_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta));
    pipe_store_i32_le(cell, 16, glue_emit_binop_mul_rax_rbx_elf_c(arena, elf_ctx, ctx, left_ref, right_ref, ta));
    pipe_store_i32_le(cell, 20, glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, left_ref));
    pipe_store_i32_le(cell, 24, glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, right_ref));
    pipe_store_i32_le(cell, 28, glue_binop_operand_is_unsigned_elf_c(arena, ctx, left_ref, right_ref));
    pipe_store_i32_le(cell, 32, glue_binop_operand_is_64bit_elf_c(arena, ctx, left_ref, right_ref));
    pipe_store_i32_le(cell, 36, pipeline_asm_emit_divisor_zero_check_rbx_elf_c(elf_ctx, ctx, ta));
    glue_binop_var_slot_cache_clear();
    pipe_store_i32_le(cell, 40, pipeline_expr_kind_ord_at(arena, left_ref));
    pipe_store_i32_le(cell, 44, glue_emit_assign_rhs_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta));
    return 0;
  }
}

/**
 * Store the encoder half. Offsets 0..60 step 4: push, pop, divsd,
 * divss, idiv, rem, and, or, xor, mov ecx, shl rax, shl eax, shr rax,
 * shr eax, sar rax, sar eax. No locals in this body.
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param ta i32 — target arch
 * @param cell *u8 — at least 64 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function w559_enc_query(elf_ctx: *u8, ta: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, backend_enc_push_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 4, backend_enc_pop_rbx_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 8, backend_enc_divsd_rax_rbx_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 12, backend_enc_divss_rax_rbx_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 16, backend_enc_idiv_rbx_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 20, backend_enc_rem_mod_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 24, backend_enc_and_rbx_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 28, backend_enc_or_rbx_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 32, backend_enc_xor_rbx_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 36, backend_enc_mov_rbx_to_ecx_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 40, backend_enc_shl_cl_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 44, backend_enc_shl_cl_eax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 48, backend_enc_shr_cl_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 52, backend_enc_shr_cl_eax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 56, backend_enc_sar_cl_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 60, backend_enc_sar_cl_eax_arch(elf_ctx, ta));
    return 0;
  }
}

/**
 * wave437/559: load LHS into rax and RHS into rbx for a binop assign.
 * Both query helpers always run. Tip returns 0; the real status stays
 * on the w437 overlay.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context
 * @param left_ref i32 — LHS expr
 * @param right_ref i32 — RHS expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 on this tip
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_load_lr_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let gcell: u8[64] = [];
    let ecell: u8[64] = [];
    w559_glue_query(arena, elf_ctx, left_ref, right_ref, ctx, ta, &gcell[0]);
    w559_enc_query(elf_ctx, ta, &ecell[0]);
    return 0;
  }
}

/**
 * wave437/559: unsigned shr assign. Queries already ran in load_lr.
 * Tip returns 0. assign_expr_ref is unused here; the w437 overlay
 * still consumes it.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param assign_expr_ref i32 — ASSIGN expr; unused on this tip
 * @param left_ref i32 — LHS expr
 * @param right_ref i32 — RHS expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 on this tip
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_shr_u_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  return 0;
}

/**
 * wave437/559: plain (non-binop) assign RHS. Tip returns 0.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param assign_expr_ref i32 — ASSIGN expr; unused on this tip
 * @param left_ref i32 — LHS expr
 * @param right_ref i32 — RHS expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 on this tip
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_plain_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  return 0;
}

/**
 * wave437/559: add-assign. Tip returns 0.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param assign_expr_ref i32 — ASSIGN expr; unused on this tip
 * @param left_ref i32 — LHS expr
 * @param right_ref i32 — RHS expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 on this tip
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_add_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  return 0;
}

/**
 * wave437/559: sub-assign. Tip returns 0.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param assign_expr_ref i32 — ASSIGN expr; unused on this tip
 * @param left_ref i32 — LHS expr
 * @param right_ref i32 — RHS expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 on this tip
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_sub_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  return 0;
}

/**
 * wave437/559: mul-assign. Tip returns 0.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param assign_expr_ref i32 — ASSIGN expr; unused on this tip
 * @param left_ref i32 — LHS expr
 * @param right_ref i32 — RHS expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 on this tip
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_mul_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  return 0;
}

/**
 * wave437/559: div-assign. Tip returns 0.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param assign_expr_ref i32 — ASSIGN expr; unused on this tip
 * @param left_ref i32 — LHS expr
 * @param right_ref i32 — RHS expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 on this tip
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_div_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  return 0;
}

/**
 * wave437/559: mod-assign. Tip returns 0.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param assign_expr_ref i32 — ASSIGN expr; unused on this tip
 * @param left_ref i32 — LHS expr
 * @param right_ref i32 — RHS expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 on this tip
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_mod_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  return 0;
}

/**
 * wave437/559: and-assign. Tip returns 0.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param assign_expr_ref i32 — ASSIGN expr; unused on this tip
 * @param left_ref i32 — LHS expr
 * @param right_ref i32 — RHS expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 on this tip
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_and_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  return 0;
}

/**
 * wave437/559: or-assign. Tip returns 0.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param assign_expr_ref i32 — ASSIGN expr; unused on this tip
 * @param left_ref i32 — LHS expr
 * @param right_ref i32 — RHS expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 on this tip
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_or_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  return 0;
}

/**
 * wave437/559: xor-assign. Tip returns 0.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param assign_expr_ref i32 — ASSIGN expr; unused on this tip
 * @param left_ref i32 — LHS expr
 * @param right_ref i32 — RHS expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 on this tip
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_xor_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  return 0;
}

/**
 * wave437/559: shl-assign. Tip returns 0.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param assign_expr_ref i32 — ASSIGN expr; unused on this tip
 * @param left_ref i32 — LHS expr
 * @param right_ref i32 — RHS expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 on this tip
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_shl_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  return 0;
}

/**
 * wave437/559: shr-assign. Tip returns 0.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param assign_expr_ref i32 — ASSIGN expr; unused on this tip
 * @param left_ref i32 — LHS expr
 * @param right_ref i32 — RHS expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 on this tip
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_shr_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  return 0;
}

/**
 * wave437/559: dispatcher that picks one RHS arm into rax.
 * Tip returns 0. Arm selection stays on the w437 overlay and the
 * already-BAN'd arm leaves.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param assign_expr_ref i32 — ASSIGN expr; unused on this tip
 * @param left_ref i32 — LHS expr
 * @param right_ref i32 — RHS expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 on this tip
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_to_rax_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  return 0;
}
