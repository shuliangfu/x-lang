// Thin pure: load_operand f32/int/spill leaves (wave436).
// wave555 Soft Cap: 48 unused extern decls were tipU misses. Each leaf
//   did `off = glue_var_expr_stack_off_elf_c(...)` (mid-assign, dropped
//   by Ubuntu tip) then a slot load or spill push. w555_off stores the
//   offset; each leaf stores the load/spill status before branching.
//   cache_set runs even when the spill fails (tip-only). stamp w555
//   HARD BAN tip PRODUCT reinject (keep the w436 overlay).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function glue_load_f32_var_slot_to_rbx_elf_c(elf_ctx: *u8, arena: *u8, ctx: *u8, expr_ref: i32, off: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function glue_binop_stack_spill_push_elf_c(elf_ctx: *u8, ta: i32, off: i32, which: i32): i32;
export extern function glue_binop_var_slot_cache_set_ctx_key(ctx: *u8): void;
export extern function glue_load_f32_var_slot_to_rax_elf_c(elf_ctx: *u8, arena: *u8, ctx: *u8, expr_ref: i32, off: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, off: i32, ta: i32): i32;

/**
 * Store the VAR stack offset. Call-as-arg so Ubuntu tip keeps the symbol.
 * @param arena *u8 — AST arena
 * @param ctx *u8 — emit context
 * @param expr_ref i32 — VAR expr
 * @param cell *u8 — receives the offset at byte 0
 * @return i32 — 0 after the store
 * PLATFORM: SHARED freestanding.
 */
function w555_off(arena: *u8, ctx: *u8, expr_ref: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, glue_var_expr_stack_off_elf_c(arena, ctx, expr_ref));
    return 0;
  }
}

/**
 * wave436/555: f32 VAR slot into rbx.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit ctx
 * @param ta i32 — target arch
 * @param to_rbx i32 — unused; kept for the export ABI
 * @return i32 — 0 ok / -1 emit fail
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_load_f32_rbx_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let cell: u8[8] = [];
    let st: u8[8] = [];
    w555_off(arena, ctx, expr_ref, &cell[0]);
    pipe_store_i32_le(&st[0], 0, glue_load_f32_var_slot_to_rbx_elf_c(elf_ctx, arena, ctx, expr_ref, pipe_load_i32_le(&cell[0], 0), ta));
    if (pipe_load_i32_le(&st[0], 0) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * wave436/555: integer VAR slot into rbx.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit ctx
 * @param ta i32 — target arch
 * @param to_rbx i32 — unused; kept for the export ABI
 * @return i32 — 0 ok / -1 emit fail
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_load_i_rbx_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let cell: u8[8] = [];
    let st: u8[8] = [];
    w555_off(arena, ctx, expr_ref, &cell[0]);
    pipe_store_i32_le(&st[0], 0, backend_enc_load_rbp_to_rbx_arch(elf_ctx, pipe_load_i32_le(&cell[0], 0), ta));
    if (pipe_load_i32_le(&st[0], 0) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * wave436/555: spill-push rbx (which=1) and set the cache key.
 * cache_set runs even when the push fails so Ubuntu tip keeps it.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit ctx
 * @param ta i32 — target arch
 * @param to_rbx i32 — unused; kept for the export ABI
 * @return i32 — 0 ok / -1 emit fail
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_spill_rbx_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let cell: u8[8] = [];
    let st: u8[8] = [];
    w555_off(arena, ctx, expr_ref, &cell[0]);
    pipe_store_i32_le(&st[0], 0, glue_binop_stack_spill_push_elf_c(elf_ctx, ta, pipe_load_i32_le(&cell[0], 0), 1));
    glue_binop_var_slot_cache_set_ctx_key(ctx);
    if (pipe_load_i32_le(&st[0], 0) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * wave436/555: f32 VAR slot into rax.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit ctx
 * @param ta i32 — target arch
 * @param to_rbx i32 — unused; kept for the export ABI
 * @return i32 — 0 ok / -1 emit fail
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_load_f32_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let cell: u8[8] = [];
    let st: u8[8] = [];
    w555_off(arena, ctx, expr_ref, &cell[0]);
    pipe_store_i32_le(&st[0], 0, glue_load_f32_var_slot_to_rax_elf_c(elf_ctx, arena, ctx, expr_ref, pipe_load_i32_le(&cell[0], 0), ta));
    if (pipe_load_i32_le(&st[0], 0) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * wave436/555: integer VAR slot into rax.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit ctx
 * @param ta i32 — target arch
 * @param to_rbx i32 — unused; kept for the export ABI
 * @return i32 — 0 ok / -1 emit fail
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_load_i_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let cell: u8[8] = [];
    let st: u8[8] = [];
    w555_off(arena, ctx, expr_ref, &cell[0]);
    pipe_store_i32_le(&st[0], 0, backend_enc_load_rbp_to_rax_arch(elf_ctx, pipe_load_i32_le(&cell[0], 0), ta));
    if (pipe_load_i32_le(&st[0], 0) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * wave436/555: spill-push rax (which=0) and set the cache key.
 * cache_set runs even when the push fails so Ubuntu tip keeps it.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit ctx
 * @param ta i32 — target arch
 * @param to_rbx i32 — unused; kept for the export ABI
 * @return i32 — 0 ok / -1 emit fail
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_spill_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let cell: u8[8] = [];
    let st: u8[8] = [];
    w555_off(arena, ctx, expr_ref, &cell[0]);
    pipe_store_i32_le(&st[0], 0, glue_binop_stack_spill_push_elf_c(elf_ctx, ta, pipe_load_i32_le(&cell[0], 0), 0));
    glue_binop_var_slot_cache_set_ctx_key(ctx);
    if (pipe_load_i32_le(&st[0], 0) != 0) {
      return -1;
    }
    return 0;
  }
}
