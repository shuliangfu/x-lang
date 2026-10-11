// 记211: tip pure overlay — fold module-const init to i32 imm.
// tipU: mid `x=call()` drops on Ubuntu — pipe cells keep results.
// PRODUCT: both ends _g05_pure_overlay first-wins Cap const_lit_overlay.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_module_top_level_let_name_len(m: *u8, tl: i32): i32;
export extern function pipeline_module_top_level_let_name_byte_at(m: *u8, tl: i32, k: i32): i32;
export extern function pipeline_module_top_level_let_is_const(m: *u8, tl: i32): i32;
export extern function pipeline_module_top_level_let_init_ref(m: *u8, tl: i32): i32;
export extern function pipeline_expr_kind_ord_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_int_val_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_left_ref_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_right_ref_at(a: *u8, expr_ref: i32): i32;

/**
 * Fold const init expr to i32. Depth-capped; 0 = miss.
 * PLATFORM: SHARED freestanding · tipU pipe cells.
 */
function w211_fold_const_expr_i32(a: *u8, eref: i32, out_imm: *i32, depth: i32): i32 {
  unsafe {
    let cell: u8[32];
    if (a == 0 as *u8 || eref <= 0 || out_imm == 0 as *i32 || depth > 8) {
      return 0;
    }
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(a, eref));
    if (pipe_load_i32_le(&cell[0], 0) == 0 || pipe_load_i32_le(&cell[0], 0) == 2) {
      pipe_store_i32_le(&cell[0], 4, pipeline_expr_int_val_at(a, eref));
      *out_imm = pipe_load_i32_le(&cell[0], 4);
      return 1;
    }
    if (pipe_load_i32_le(&cell[0], 0) == 22) {
      pipe_store_i32_le(&cell[0], 8, pipeline_expr_unary_operand_ref_at(a, eref));
      if (w211_fold_const_expr_i32(a, pipe_load_i32_le(&cell[0], 8), out_imm, depth + 1) == 0) {
        return 0;
      }
      *out_imm = 0 - *out_imm;
      return 1;
    }
    if (pipe_load_i32_le(&cell[0], 0) >= 4 && pipe_load_i32_le(&cell[0], 0) <= 13) {
      let lv_cell: u8[8];
      let rv_cell: u8[8];
      pipe_store_i32_le(&cell[0], 8, pipeline_expr_binop_left_ref_at(a, eref));
      pipe_store_i32_le(&cell[0], 12, pipeline_expr_binop_right_ref_at(a, eref));
      if (w211_fold_const_expr_i32(a, pipe_load_i32_le(&cell[0], 8), &lv_cell[0] as *i32, depth + 1) == 0) {
        return 0;
      }
      if (w211_fold_const_expr_i32(a, pipe_load_i32_le(&cell[0], 12), &rv_cell[0] as *i32, depth + 1) == 0) {
        return 0;
      }
      if (pipe_load_i32_le(&cell[0], 0) == 4) {
        *out_imm = pipe_load_i32_le(&lv_cell[0], 0) + pipe_load_i32_le(&rv_cell[0], 0);
        return 1;
      }
      if (pipe_load_i32_le(&cell[0], 0) == 5) {
        *out_imm = pipe_load_i32_le(&lv_cell[0], 0) - pipe_load_i32_le(&rv_cell[0], 0);
        return 1;
      }
      if (pipe_load_i32_le(&cell[0], 0) == 6) {
        *out_imm = pipe_load_i32_le(&lv_cell[0], 0) * pipe_load_i32_le(&rv_cell[0], 0);
        return 1;
      }
      if (pipe_load_i32_le(&cell[0], 0) == 7) {
        if (pipe_load_i32_le(&rv_cell[0], 0) == 0) { *out_imm = 0; return 1; }
        *out_imm = pipe_load_i32_le(&lv_cell[0], 0) / pipe_load_i32_le(&rv_cell[0], 0);
        return 1;
      }
      if (pipe_load_i32_le(&cell[0], 0) == 8) {
        if (pipe_load_i32_le(&rv_cell[0], 0) == 0) { *out_imm = 0; return 1; }
        *out_imm = pipe_load_i32_le(&lv_cell[0], 0) % pipe_load_i32_le(&rv_cell[0], 0);
        return 1;
      }
      if (pipe_load_i32_le(&cell[0], 0) == 9) {
        if (pipe_load_i32_le(&rv_cell[0], 0) < 0 || pipe_load_i32_le(&rv_cell[0], 0) >= 32) { return 0; }
        *out_imm = pipe_load_i32_le(&lv_cell[0], 0) << pipe_load_i32_le(&rv_cell[0], 0);
        return 1;
      }
      if (pipe_load_i32_le(&cell[0], 0) == 10) {
        if (pipe_load_i32_le(&rv_cell[0], 0) < 0 || pipe_load_i32_le(&rv_cell[0], 0) >= 32) { return 0; }
        *out_imm = pipe_load_i32_le(&lv_cell[0], 0) >> pipe_load_i32_le(&rv_cell[0], 0);
        return 1;
      }
      if (pipe_load_i32_le(&cell[0], 0) == 11) {
        *out_imm = pipe_load_i32_le(&lv_cell[0], 0) & pipe_load_i32_le(&rv_cell[0], 0);
        return 1;
      }
      if (pipe_load_i32_le(&cell[0], 0) == 12) {
        *out_imm = pipe_load_i32_le(&lv_cell[0], 0) | pipe_load_i32_le(&rv_cell[0], 0);
        return 1;
      }
      if (pipe_load_i32_le(&cell[0], 0) == 13) {
        *out_imm = pipe_load_i32_le(&lv_cell[0], 0) ^ pipe_load_i32_le(&rv_cell[0], 0);
        return 1;
      }
    }
    return 0;
  }
}

/**
 * If module top-level *const* name folds to an int imm, write *out_imm.
 * @return i32 — 1 found, 0 miss
 * PLATFORM: SHARED freestanding · tip pure overlay · tipU pipe cells.
 */
#[no_mangle]
export function asm_module_top_level_const_lit_i32(m: *u8, a: *u8, name: *u8, name_len: i32, out_imm: *i32): i32 {
  unsafe {
    let cell: u8[32];
    let tl: i32;
    let ntl: i32;
    if (m == 0 as *u8 || a == 0 as *u8 || name == 0 as *u8 || name_len <= 0 || out_imm == 0 as *i32) {
      return 0;
    }
    ntl = pipe_load_i32_le(m, 12);
    tl = 0;
    while (tl < ntl) {
      pipe_store_i32_le(&cell[0], 0, pipeline_module_top_level_let_name_len(m, tl));
      if (pipe_load_i32_le(&cell[0], 0) == name_len && pipe_load_i32_le(&cell[0], 0) > 0) {
        pipe_store_i32_le(&cell[0], 4, 0);
        while (pipe_load_i32_le(&cell[0], 4) < name_len) {
          pipe_store_i32_le(&cell[0], 8, pipeline_module_top_level_let_name_byte_at(m, tl, pipe_load_i32_le(&cell[0], 4)));
          if (pipe_load_i32_le(&cell[0], 8) != (name[pipe_load_i32_le(&cell[0], 4)] as i32)) {
            break;
          }
          pipe_store_i32_le(&cell[0], 4, pipe_load_i32_le(&cell[0], 4) + 1);
        }
        if (pipe_load_i32_le(&cell[0], 4) == name_len) {
          pipe_store_i32_le(&cell[0], 12, pipeline_module_top_level_let_is_const(m, tl));
          if (pipe_load_i32_le(&cell[0], 12) == 0) {
            return 0;
          }
          pipe_store_i32_le(&cell[0], 16, pipeline_module_top_level_let_init_ref(m, tl));
          if (pipe_load_i32_le(&cell[0], 16) > 0) {
            if (w211_fold_const_expr_i32(a, pipe_load_i32_le(&cell[0], 16), out_imm, 0) != 0) {
              return 1;
            }
          }
        }
      }
      tl = tl + 1;
    }
    return 0;
  }
}
