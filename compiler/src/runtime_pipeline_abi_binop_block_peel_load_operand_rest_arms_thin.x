// Thin pure: load_operand rest arms (wave436).
// wave556 Soft Cap: 43 unused extern decls were tipU misses. The live
//   calls were mid-assign (`vr = emit()`) or lived only after
//   `if (local)`, which Ubuntu tip drops. Each arm stores the query
//   first, then selects the w436 return code. Extra calls on the miss
//   path are tip-only. stamp w556 HARD BAN tip PRODUCT reinject (keep
//   the w436 overlay).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_is_enum_variant(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_var_slot_cache_clear(): void;
export extern function pipeline_asm_emit_expr_elf_fast(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_field_access_elf_fast_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_index_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_deref_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_as_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_as_needs_full_emit_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_as_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_try_binop_load_operand_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32;

/**
 * wave436/556: mov rax to rbx when to_rbx!=0.
 * The encoder always runs. to_rbx==0 still returns 0.
 * @param arena *u8 — unused; kept for the export ABI
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — unused; kept for the export ABI
 * @param ctx *u8 — unused; kept for the export ABI
 * @param ta i32 — target arch
 * @param to_rbx i32 — 0 skips the status check
 * @return i32 — 0 ok / -1 mov fail
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_mov_rax_to_rbx_if_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let st: u8[8] = [];
    pipe_store_i32_le(&st[0], 0, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
    if (to_rbx == 0) {
      return 0;
    }
    if (pipe_load_i32_le(&st[0], 0) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * wave436/556: FIELD whose base is INDEX. -99 → -2, other nonzero → -1.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit ctx
 * @param ta i32 — target arch
 * @param to_rbx i32 — forwarded to the mov helper
 * @return i32 — 0 ok / -1 emit fail / -2 not handled
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_load_field_idxbase_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let st: u8[8] = [];
    glue_binop_var_slot_cache_clear();
    pipe_store_i32_le(&st[0], 0, pipeline_asm_emit_expr_elf_fast(arena, elf_ctx, expr_ref, ctx, ta));
    if (pipe_load_i32_le(&st[0], 0) == -99) {
      return -2;
    }
    if (pipe_load_i32_le(&st[0], 0) != 0) {
      return -1;
    }
    return glue_try_binop_mov_rax_to_rbx_if_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx);
  }
}

/**
 * wave436/556: FIELD whose base is VAR. -99 → -2, other nonzero → -1.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit ctx
 * @param ta i32 — target arch
 * @param to_rbx i32 — forwarded to the mov helper
 * @return i32 — 0 ok / -1 emit fail / -2 not handled
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_load_field_varbase_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let st: u8[8] = [];
    glue_binop_var_slot_cache_clear();
    pipe_store_i32_le(&st[0], 0, pipeline_asm_emit_field_access_elf_fast_c(arena, elf_ctx, expr_ref, ctx, ta));
    if (pipe_load_i32_le(&st[0], 0) == -99) {
      return -2;
    }
    if (pipe_load_i32_le(&st[0], 0) != 0) {
      return -1;
    }
    return glue_try_binop_mov_rax_to_rbx_if_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx);
  }
}

/**
 * wave436/556: FIELD (kind 44). Enum variant or a non-VAR/INDEX base
 * returns -2. Kind 47 takes the INDEX base arm; kind 3 takes VAR.
 * The three queries always run.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit ctx
 * @param ta i32 — target arch
 * @param to_rbx i32 — forwarded to the chosen arm
 * @return i32 — 0 ok / -1 emit fail / -2 not handled
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_load_field_ko44_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let cell: u8[16] = [];
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_field_access_is_enum_variant(arena, expr_ref));
    pipe_store_i32_le(&cell[0], 4, pipeline_expr_field_access_base_ref(arena, expr_ref));
    pipe_store_i32_le(&cell[0], 8, pipeline_expr_kind_ord_at(arena, pipe_load_i32_le(&cell[0], 4)));
    if (pipe_load_i32_le(&cell[0], 0) != 0) {
      return -2;
    }
    if (pipe_load_i32_le(&cell[0], 4) <= 0) {
      return -2;
    }
    if (pipe_load_i32_le(&cell[0], 8) == 47) {
      return glue_try_binop_load_field_idxbase_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx);
    }
    if (pipe_load_i32_le(&cell[0], 8) != 3) {
      return -2;
    }
    return glue_try_binop_load_field_varbase_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx);
  }
}

/**
 * wave436/556: INDEX (kind 47). Any nonzero emit status returns -2.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit ctx
 * @param ta i32 — target arch
 * @param to_rbx i32 — forwarded to the mov helper
 * @return i32 — 0 ok / -2 not handled
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_load_index_ko47_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let st: u8[8] = [];
    glue_binop_var_slot_cache_clear();
    pipe_store_i32_le(&st[0], 0, pipeline_asm_emit_index_elf_c(arena, elf_ctx, expr_ref, ctx, ta));
    if (pipe_load_i32_le(&st[0], 0) != 0) {
      return -2;
    }
    return glue_try_binop_mov_rax_to_rbx_if_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx);
  }
}

/**
 * wave436/556: DEREF (kind 52). Nonzero emit status returns -1.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit ctx
 * @param ta i32 — target arch
 * @param to_rbx i32 — forwarded to the mov helper
 * @return i32 — 0 ok / -1 emit fail
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_load_deref_ko52_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let st: u8[8] = [];
    glue_binop_var_slot_cache_clear();
    pipe_store_i32_le(&st[0], 0, pipeline_asm_emit_deref_elf_c(arena, elf_ctx, expr_ref, ctx, ta));
    if (pipe_load_i32_le(&st[0], 0) != 0) {
      return -1;
    }
    return glue_try_binop_mov_rax_to_rbx_if_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx);
  }
}

/**
 * wave436/556: await peel. The operand load always runs; op<=0 still
 * returns -2 and ignores that status.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit ctx
 * @param ta i32 — target arch
 * @param to_rbx i32 — forwarded to the operand load
 * @return i32 — operand-load status, or -2 when there is no operand
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_load_await_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let cell: u8[16] = [];
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_unary_operand_ref_at(arena, expr_ref));
    pipe_store_i32_le(&cell[0], 4, glue_try_binop_load_operand_elf_c(arena, elf_ctx, pipe_load_i32_le(&cell[0], 0), ctx, ta, to_rbx));
    if (pipe_load_i32_le(&cell[0], 0) <= 0) {
      return -2;
    }
    return pipe_load_i32_le(&cell[0], 4);
  }
}

/**
 * wave436/556: full AS emit. Nonzero returns -1, else mov rax to rbx.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit ctx
 * @param ta i32 — target arch
 * @param to_rbx i32 — forwarded to the mov helper
 * @return i32 — 0 ok / -1 emit fail
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_load_as_full_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let st: u8[8] = [];
    glue_binop_var_slot_cache_clear();
    pipe_store_i32_le(&st[0], 0, pipeline_asm_emit_as_elf_impl(arena, elf_ctx, expr_ref, ctx, ta));
    if (pipe_load_i32_le(&st[0], 0) != 0) {
      return -1;
    }
    return glue_try_binop_mov_rax_to_rbx_if_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx);
  }
}

/**
 * wave436/556: AS cast. Operand and full-emit queries always run.
 * op<=0 returns -2. A full emit takes the full arm; otherwise the
 * operand is loaded.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit ctx
 * @param ta i32 — target arch
 * @param to_rbx i32 — forwarded to the chosen arm
 * @return i32 — 0 ok / -1 emit fail / -2 not handled
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_load_as_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let cell: u8[8] = [];
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_as_operand_ref_at(arena, expr_ref));
    pipe_store_i32_le(&cell[0], 4, glue_binop_as_needs_full_emit_elf_c(arena, expr_ref));
    if (pipe_load_i32_le(&cell[0], 0) <= 0) {
      return -2;
    }
    if (pipe_load_i32_le(&cell[0], 4) != 0) {
      return glue_try_binop_load_as_full_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx);
    }
    return glue_try_binop_load_operand_elf_c(arena, elf_ctx, pipe_load_i32_le(&cell[0], 0), ctx, ta, to_rbx);
  }
}
