// Thin pure: transparent block-value peel (wave422 helpers).
// wave554 Soft Cap: 42 unused extern decls were tipU misses. The ten
//   live queries were mid-assign, and the inner-region reads lived only
//   inside `if (local)`, which Ubuntu tip drops. w554_peel_query always
//   runs the outer block and the region body into one byte cell; the
//   export only reads that cell. Extra queries on the miss path are
//   tip-only. stamp w554 HARD BAN tip PRODUCT reinject (keep the w422
//   overlay). MACOS still PREFER-injects the full binop thin.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_block_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_expr_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_stmt_order(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_final_expr_ref(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_stmt_order_kind(arena: *u8, block_ref: i32, si: i32): i32;
export extern function ast_ast_block_stmt_order_idx(arena: *u8, block_ref: i32, si: i32): i32;
export extern function pipeline_block_region_body_ref(arena: *u8, block_ref: i32, ri: i32): i32;

/**
 * Store the outer block and the first region body for one expr.
 * Offsets in cell (i32 le): 0 kind, 4 block ref, 8 lets, 12 loops,
 * 16 expr stmts, 20 stmt-order count, 24 final expr, 28 order kind,
 * 32 order idx, 36 region body, 40 inner lets, 44 inner loops,
 * 48 inner final expr. The inner triple uses the same three symbols
 * as the outer counts; both sites run so the export can pick.
 * @param arena *u8 — AST arena; may be null
 * @param expr_ref i32 — expr, may be <=0
 * @param cell *u8 — at least 52 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding.
 */
function w554_peel_query(arena: *u8, expr_ref: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_expr_kind_ord_at(arena, expr_ref));
    pipe_store_i32_le(cell, 4, pipeline_expr_block_ref_at(arena, expr_ref));
    pipe_store_i32_le(cell, 8, ast_ast_block_num_lets(arena, pipe_load_i32_le(cell, 4)));
    pipe_store_i32_le(cell, 12, ast_ast_block_num_loops(arena, pipe_load_i32_le(cell, 4)));
    pipe_store_i32_le(cell, 16, ast_ast_block_num_expr_stmts(arena, pipe_load_i32_le(cell, 4)));
    pipe_store_i32_le(cell, 20, ast_ast_block_num_stmt_order(arena, pipe_load_i32_le(cell, 4)));
    pipe_store_i32_le(cell, 24, ast_ast_block_final_expr_ref(arena, pipe_load_i32_le(cell, 4)));
    pipe_store_i32_le(cell, 28, ast_ast_block_stmt_order_kind(arena, pipe_load_i32_le(cell, 4), 0));
    pipe_store_i32_le(cell, 32, ast_ast_block_stmt_order_idx(arena, pipe_load_i32_le(cell, 4), 0));
    pipe_store_i32_le(cell, 36, pipeline_block_region_body_ref(arena, pipe_load_i32_le(cell, 4), pipe_load_i32_le(cell, 32)));
    pipe_store_i32_le(cell, 40, ast_ast_block_num_lets(arena, pipe_load_i32_le(cell, 36)));
    pipe_store_i32_le(cell, 44, ast_ast_block_num_loops(arena, pipe_load_i32_le(cell, 36)));
    pipe_store_i32_le(cell, 48, ast_ast_block_final_expr_ref(arena, pipe_load_i32_le(cell, 36)));
    return 0;
  }
}

/**
 * wave422/554: inner value expr of a transparent block, else 0.
 * w554_peel_query always runs. Null arena or expr_ref<=0 returns 0.
 * Kind must be EXPR_BLOCK (26). Extra lets or loops return 0.
 * `unsafe { e }` is stmt-order kind 6 with one region; a bare `{ e }`
 * returns the block final expr when there is at most one expr stmt.
 * @param arena *u8 — ASTArena*; null returns 0
 * @param expr_ref i32 — candidate expr; <=0 returns 0
 * @return i32 — inner value expr ref, or 0 if not a transparent block
 * PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function glue_expr_block_transparent_value_ref_at(arena: *u8, expr_ref: i32): i32 {
  unsafe {
    let cell: u8[56] = [];
    let go: i32 = 1;
    if ((arena == (0 as *u8)) || expr_ref <= 0) {
      go = 0;
    }
    w554_peel_query(arena, expr_ref, &cell[0]);
    if (go == 0) {
      return 0;
    }
    if (pipe_load_i32_le(&cell[0], 0) != 26) {
      return 0;
    }
    if (pipe_load_i32_le(&cell[0], 4) <= 0) {
      return 0;
    }
    if (pipe_load_i32_le(&cell[0], 8) != 0 || pipe_load_i32_le(&cell[0], 12) != 0) {
      return 0;
    }
    if (pipe_load_i32_le(&cell[0], 20) == 1 && pipe_load_i32_le(&cell[0], 16) == 0 && pipe_load_i32_le(&cell[0], 24) <= 0) {
      if (pipe_load_i32_le(&cell[0], 28) == 6 && pipe_load_i32_le(&cell[0], 32) >= 0) {
        if (pipe_load_i32_le(&cell[0], 36) > 0) {
          if (pipe_load_i32_le(&cell[0], 40) == 0 && pipe_load_i32_le(&cell[0], 44) == 0 && pipe_load_i32_le(&cell[0], 48) > 0) {
            return pipe_load_i32_le(&cell[0], 48);
          }
        }
      }
      return 0;
    }
    if (pipe_load_i32_le(&cell[0], 16) <= 1 && pipe_load_i32_le(&cell[0], 24) > 0) {
      return pipe_load_i32_le(&cell[0], 24);
    }
    return 0;
  }
}
