// 记211: tip pure overlay — fold module-const init to i32 imm.
// Covers INT_LIT/BOOL, NEG-over-LIT (`const E = -1`), and i32 binops (`0-1`).
// PRODUCT: both ends _g05_pure_overlay first-wins Cap const_lit_overlay.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
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
 * PLATFORM: SHARED freestanding.
 */
function w211_fold_const_expr_i32(a: *u8, eref: i32, out_imm: *i32, depth: i32): i32 {
  unsafe {
    if (a == 0 as *u8 || eref <= 0 || out_imm == 0 as *i32 || depth > 8) {
      return 0;
    }
    let ek: i32 = pipeline_expr_kind_ord_at(a, eref);
    if (ek == 0 || ek == 2) {
      *out_imm = pipeline_expr_int_val_at(a, eref);
      return 1;
    }
    if (ek == 22) {
      let op: i32 = pipeline_expr_unary_operand_ref_at(a, eref);
      if (w211_fold_const_expr_i32(a, op, out_imm, depth + 1) == 0) {
        return 0;
      }
      *out_imm = 0 - *out_imm;
      return 1;
    }
    if (ek >= 4 && ek <= 13) {
      let left: i32 = pipeline_expr_binop_left_ref_at(a, eref);
      let right: i32 = pipeline_expr_binop_right_ref_at(a, eref);
      let lv: i32 = 0;
      let rv: i32 = 0;
      if (w211_fold_const_expr_i32(a, left, &lv, depth + 1) == 0) {
        return 0;
      }
      if (w211_fold_const_expr_i32(a, right, &rv, depth + 1) == 0) {
        return 0;
      }
      if (ek == 4) { *out_imm = lv + rv; return 1; }
      if (ek == 5) { *out_imm = lv - rv; return 1; }
      if (ek == 6) { *out_imm = lv * rv; return 1; }
      if (ek == 7) {
        if (rv == 0) { *out_imm = 0; return 1; }
        *out_imm = lv / rv;
        return 1;
      }
      if (ek == 8) {
        if (rv == 0) { *out_imm = 0; return 1; }
        *out_imm = lv % rv;
        return 1;
      }
      if (ek == 9) {
        if (rv < 0 || rv >= 32) { return 0; }
        *out_imm = lv << rv;
        return 1;
      }
      if (ek == 10) {
        if (rv < 0 || rv >= 32) { return 0; }
        *out_imm = lv >> rv;
        return 1;
      }
      if (ek == 11) { *out_imm = lv & rv; return 1; }
      if (ek == 12) { *out_imm = lv | rv; return 1; }
      if (ek == 13) { *out_imm = lv ^ rv; return 1; }
    }
    return 0;
  }
}

/**
 * If module top-level *const* name folds to an int imm, write *out_imm.
 * wave745: mutable `let` must miss. 记211: NEG / BINOP fold.
 * @return i32 — 1 found, 0 miss
 * PLATFORM: SHARED freestanding · tip pure overlay.
 */
#[no_mangle]
export function asm_module_top_level_const_lit_i32(m: *u8, a: *u8, name: *u8, name_len: i32, out_imm: *i32): i32 {
  unsafe {
    if (m == 0 as *u8 || a == 0 as *u8 || name == 0 as *u8 || name_len <= 0 || out_imm == 0 as *i32) {
      return 0;
    }
    /* LP64: Module.num_top_level_lets @ offset 12 (twin of Cap overlay). */
    let ntl: i32 = pipe_load_i32_le(m, 12);
    let tl: i32 = 0;
    while (tl < ntl) {
      let nl: i32 = pipeline_module_top_level_let_name_len(m, tl);
      if (nl == name_len && nl > 0) {
        let k: i32 = 0;
        while (k < name_len) {
          if (pipeline_module_top_level_let_name_byte_at(m, tl, k) != (name[k] as i32)) {
            break;
          }
          k = k + 1;
        }
        if (k == name_len) {
          if (pipeline_module_top_level_let_is_const(m, tl) == 0) {
            return 0;
          }
          let init_ref: i32 = pipeline_module_top_level_let_init_ref(m, tl);
          if (init_ref > 0) {
            if (w211_fold_const_expr_i32(a, init_ref, out_imm, 0) != 0) {
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
