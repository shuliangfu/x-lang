// Thin pure: load-to-rbx may-clobber-rax (wave423).
// wave550 Soft Cap: 49 unused extern decls were tipU misses. The seven
//   live queries were mid-assign or lived only inside `if (local)`, which
//   Ubuntu tip drops. w550_query always runs them into one byte cell;
//   the export only reads that cell and may recurse. full-AS still
//   returns 1 without walking the operand (w423 contract). Extra queries
//   on the null/empty path are tip-only. stamp w550 HARD BAN tip PRODUCT
//   reinject (keep the w423 overlay).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_expr_is_await_at_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_expr_is_x_as_cast_at_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_as_needs_full_emit_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_as_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_expr_block_transparent_value_ref_at(arena: *u8, expr_ref: i32): i32;

/**
 * Store every clobber query for one expr. Offsets in cell (i32 le):
 *   0 transparent value ref, 4 kind, 8 is-await, 12 unary operand,
 *   16 is-as-cast, 20 full-AS, 24 AS operand.
 * All seven calls are call-as-arg so Ubuntu tip keeps them.
 * @param arena *u8 — AST arena; may be null (callee contract, not checked here)
 * @param expr_ref i32 — expr, may be <=0
 * @param cell *u8 — at least 28 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding.
 */
function w550_query(arena: *u8, expr_ref: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, glue_expr_block_transparent_value_ref_at(arena, expr_ref));
    pipe_store_i32_le(cell, 4, pipeline_expr_kind_ord_at(arena, expr_ref));
    pipe_store_i32_le(cell, 8, glue_expr_is_await_at_c(arena, expr_ref));
    pipe_store_i32_le(cell, 12, pipeline_expr_unary_operand_ref_at(arena, expr_ref));
    pipe_store_i32_le(cell, 16, glue_expr_is_x_as_cast_at_c(arena, expr_ref));
    pipe_store_i32_le(cell, 20, glue_binop_as_needs_full_emit_elf_c(arena, expr_ref));
    pipe_store_i32_le(cell, 24, pipeline_expr_as_operand_ref_at(arena, expr_ref));
    return 0;
  }
}

/**
 * wave149/550: 1 when loading the operand into rbx may clobber rax, else 0.
 * w550_query always runs. go==0 (null arena or expr_ref<=0) returns 1.
 * Transparent and await arms recurse. full-AS returns 1 and does not
 * walk the operand; a plain AS walks the stored operand ref.
 * @param arena *u8 — AST arena
 * @param expr_ref i32 — expr
 * @return i32 — 1 may clobber rax, 0 does not
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_binop_operand_load_to_rbx_clobbers_rax_elf_c(arena: *u8, expr_ref: i32): i32 {
  unsafe {
    let cell: u8[32] = [];
    let go: i32 = 1;
    let op: i32 = 0;
    let ko: i32 = 0;
    if ((arena == (0 as *u8)) || expr_ref <= 0) {
      go = 0;
    }
    w550_query(arena, expr_ref, &cell[0]);
    if (go == 0) {
      return 1;
    }
    op = pipe_load_i32_le(&cell[0], 0);
    if (op > 0) {
      return glue_binop_operand_load_to_rbx_clobbers_rax_elf_c(arena, op);
    }
    ko = pipe_load_i32_le(&cell[0], 4);
    if (ko == 3 || ko == 0 || ko == 2) {
      return 0;
    }
    if (ko == 44 || ko == 47) {
      return 1;
    }
    if (pipe_load_i32_le(&cell[0], 8) != 0) {
      op = pipe_load_i32_le(&cell[0], 12);
      if (op > 0) {
        return glue_binop_operand_load_to_rbx_clobbers_rax_elf_c(arena, op);
      }
      return 1;
    }
    if (pipe_load_i32_le(&cell[0], 16) != 0) {
      if (pipe_load_i32_le(&cell[0], 20) != 0) {
        return 1;
      }
      op = pipe_load_i32_le(&cell[0], 24);
      if (op > 0) {
        return glue_binop_operand_load_to_rbx_clobbers_rax_elf_c(arena, op);
      }
      return 1;
    }
    return 1;
  }
}
