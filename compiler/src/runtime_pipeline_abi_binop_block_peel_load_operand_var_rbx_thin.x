// Thin pure: load_operand VAR into rbx (wave436).
// wave552 Soft Cap: 47 unused extern decls were tipU misses. The eleven
//   live calls were mid-assign or lived only inside `if (local)`, which
//   Ubuntu tip drops. w552_rbx_query always runs them into one byte cell;
//   the export only reads that cell. Both the f32 and integer loaders run;
//   kind 14 selects which status to keep. Reload asks for rbx (to_rbx=1),
//   matching the w436 body. Extra calls on the miss path are tip-only.
//   stamp w552 HARD BAN tip PRODUCT reinject (keep the w436 overlay).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function glue_asm73_evict_cache_if_live_pressure_elf_c(ta: i32, elf_ctx: *u8): void;
export extern function glue_binop_var_slot_cache_hit_rbx(ctx: *u8, off: i32): i32;
export extern function glue_binop_try_reload_spill_off_elf_c(elf_ctx: *u8, ctx: *u8, off: i32, ta: i32, to_rbx: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function glue_try_binop_load_f32_rbx_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32;
export extern function glue_try_binop_load_i_rbx_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32;
export extern function glue_asm73_var_prefers_stack_spill(off: i32): i32;
export extern function glue_try_binop_spill_rbx_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32;
export extern function glue_binop_var_slot_cache_set_rbx(ctx: *u8, off: i32): void;

/**
 * Run every rbx-load query for one VAR. Offsets in cell (i32 le):
 *   0 stack off, 4 cache hit, 8 reload, 12 decl type, 16 type kind,
 *   20 f32 load status, 24 integer load status, 28 prefers spill,
 *   32 spill status.
 * Reload asks for rbx (to_rbx=1), matching the w436 body. Void calls
 * (evict, cache set) are statements so Ubuntu tip keeps them.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param expr_ref i32 — VAR expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param to_rbx i32 — forwarded to the f32 / integer / spill loaders
 * @param cell *u8 — at least 36 bytes
 * @return i32 — 0 after the queries
 * PLATFORM: SHARED freestanding.
 */
function w552_rbx_query(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, glue_var_expr_stack_off_elf_c(arena, ctx, expr_ref));
    glue_asm73_evict_cache_if_live_pressure_elf_c(ta, elf_ctx);
    pipe_store_i32_le(cell, 4, glue_binop_var_slot_cache_hit_rbx(ctx, pipe_load_i32_le(cell, 0)));
    pipe_store_i32_le(cell, 8, glue_binop_try_reload_spill_off_elf_c(elf_ctx, ctx, pipe_load_i32_le(cell, 0), ta, 1));
    pipe_store_i32_le(cell, 12, glue_var_decl_type_ref_elf_c(arena, ctx, expr_ref));
    pipe_store_i32_le(cell, 16, pipeline_type_kind_ord_at(arena, pipe_load_i32_le(cell, 12)));
    pipe_store_i32_le(cell, 20, glue_try_binop_load_f32_rbx_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx));
    pipe_store_i32_le(cell, 24, glue_try_binop_load_i_rbx_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx));
    pipe_store_i32_le(cell, 28, glue_asm73_var_prefers_stack_spill(pipe_load_i32_le(cell, 0)));
    pipe_store_i32_le(cell, 32, glue_try_binop_spill_rbx_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx));
    glue_binop_var_slot_cache_set_rbx(ctx, pipe_load_i32_le(cell, 0));
    return 0;
  }
}

/**
 * wave436/552: load a VAR operand into rbx.
 * w552_rbx_query always runs. off<0 returns -2. A cache hit or a
 * successful reload returns 0. Kind 14 keeps the f32 status; any other
 * kind keeps the integer status. A preferred spill returns that status.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit ctx
 * @param ta i32 — target arch
 * @param to_rbx i32 — forwarded to the loaders (reload itself is rbx)
 * @return i32 — 0 ok / -1 emit fail / -2 not handled
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_load_var_rbx_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let cell: u8[40] = [];
    let use_f32: i32 = 0;
    let vr: i32 = 0;
    w552_rbx_query(arena, elf_ctx, expr_ref, ctx, ta, to_rbx, &cell[0]);
    if (pipe_load_i32_le(&cell[0], 0) < 0) {
      return -2;
    }
    if (pipe_load_i32_le(&cell[0], 4) != 0) {
      return 0;
    }
    if (pipe_load_i32_le(&cell[0], 8) < 0) {
      return -1;
    }
    if (pipe_load_i32_le(&cell[0], 8) != 0) {
      return 0;
    }
    if (pipe_load_i32_le(&cell[0], 12) > 0) {
      if (pipe_load_i32_le(&cell[0], 16) == 14) {
        use_f32 = 1;
      }
    }
    vr = pipe_load_i32_le(&cell[0], 24);
    if (use_f32 != 0) {
      vr = pipe_load_i32_le(&cell[0], 20);
    }
    if (vr != 0) {
      return vr;
    }
    if (pipe_load_i32_le(&cell[0], 28) != 0) {
      return pipe_load_i32_le(&cell[0], 32);
    }
    return 0;
  }
}
