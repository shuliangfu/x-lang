// Thin pure: load_operand dispatcher (wave436).
// wave553 Soft Cap: 51 unused extern decls were tipU misses. The ten
//   live calls were mid-assign or `return` inside `if (ko==N)`, which
//   Ubuntu tip drops. w553_disp_query always runs them into one byte
//   cell; the export only reads that cell and may recurse on a
//   transparent block. Extra arm calls on the miss path are tip-only.
//   stamp w553 HARD BAN tip PRODUCT reinject (keep the w436 overlay).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function glue_expr_block_transparent_value_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_try_binop_load_var_ko3_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32;
export extern function glue_try_binop_load_field_ko44_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32;
export extern function glue_try_binop_load_index_ko47_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32;
export extern function glue_try_binop_load_deref_ko52_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32;
export extern function glue_expr_is_await_at_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_try_binop_load_await_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32;
export extern function glue_expr_is_x_as_cast_at_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_try_binop_load_as_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32;

/**
 * Run every load-operand arm for one expr. Offsets in cell (i32 le):
 *   0 transparent ref, 4 kind, 8 VAR, 12 FIELD, 16 INDEX, 20 DEREF,
 *   24 is-await, 28 await load, 32 is-as-cast, 36 AS load.
 * All ten calls are call-as-arg so Ubuntu tip keeps them even when
 * the kind does not match.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param to_rbx i32 — 1 = result in rbx
 * @param cell *u8 — at least 40 bytes
 * @return i32 — 0 after the queries
 * PLATFORM: SHARED freestanding.
 */
function w553_disp_query(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, glue_expr_block_transparent_value_ref_at(arena, expr_ref));
    pipe_store_i32_le(cell, 4, pipeline_expr_kind_ord_at(arena, expr_ref));
    pipe_store_i32_le(cell, 8, glue_try_binop_load_var_ko3_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx));
    pipe_store_i32_le(cell, 12, glue_try_binop_load_field_ko44_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx));
    pipe_store_i32_le(cell, 16, glue_try_binop_load_index_ko47_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx));
    pipe_store_i32_le(cell, 20, glue_try_binop_load_deref_ko52_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx));
    pipe_store_i32_le(cell, 24, glue_expr_is_await_at_c(arena, expr_ref));
    pipe_store_i32_le(cell, 28, glue_try_binop_load_await_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx));
    pipe_store_i32_le(cell, 32, glue_expr_is_x_as_cast_at_c(arena, expr_ref));
    pipe_store_i32_le(cell, 36, glue_try_binop_load_as_elf_c(arena, elf_ctx, expr_ref, ctx, ta, to_rbx));
    return 0;
  }
}

/**
 * wave149/553: dispatch one operand load.
 * w553_disp_query always runs. A null arena, elf_ctx, or ctx, or
 * expr_ref<=0, returns -2. A transparent block recurses. Kind 3/44/47/52
 * and await / AS keep the matching stored status.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit ctx
 * @param ta i32 — target arch
 * @param to_rbx i32 — 1=result in rbx
 * @return i32 — 0 ok / -1 emit fail / -2 not handled
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_load_operand_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let cell: u8[48] = [];
    let go: i32 = 1;
    let inner: i32 = 0;
    let ko: i32 = 0;
    if ((arena == (0 as *u8)) || (elf_ctx == (0 as *u8)) || (ctx == (0 as *u8)) || expr_ref <= 0) {
      go = 0;
    }
    w553_disp_query(arena, elf_ctx, expr_ref, ctx, ta, to_rbx, &cell[0]);
    if (go == 0) {
      return -2;
    }
    inner = pipe_load_i32_le(&cell[0], 0);
    if (inner > 0) {
      return glue_try_binop_load_operand_elf_c(arena, elf_ctx, inner, ctx, ta, to_rbx);
    }
    ko = pipe_load_i32_le(&cell[0], 4);
    if (ko == 3) {
      return pipe_load_i32_le(&cell[0], 8);
    }
    if (ko == 44) {
      return pipe_load_i32_le(&cell[0], 12);
    }
    if (ko == 47) {
      return pipe_load_i32_le(&cell[0], 16);
    }
    if (ko == 52) {
      return pipe_load_i32_le(&cell[0], 20);
    }
    if (pipe_load_i32_le(&cell[0], 24) != 0) {
      return pipe_load_i32_le(&cell[0], 28);
    }
    if (pipe_load_i32_le(&cell[0], 32) != 0) {
      return pipe_load_i32_le(&cell[0], 36);
    }
    return -2;
  }
}
