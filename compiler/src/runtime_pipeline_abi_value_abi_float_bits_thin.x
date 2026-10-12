// Thin pure: wave517 value_abi float-bits peer-flat (tipU Soft Cap).
// G.7: bodies MUST match pipeline_expr_float_bits_* /
//   pipeline_expr_typeck_set_float_bits_from_val formerly in
//   runtime_pipeline_abi_value_abi_thin.x (sret monolith tip CG002 on
//   Ubuntu — peer has no by-value Type/Expr/Block/Func).
// wave517: tip T001 heal (typeck_float64_bits_* unsafe+pipe-cell) →
//   tipU 8/8 both ends; tip PRODUCT reinject HARD BAN (value_abi sret
//   family; keep prior -E overlay via w517 stamp).
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS.

export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern function pipeline_arena_expr_ptr(a: *u8, ref: i32): *u8;
export extern function typeck_float64_bits_lo(d: f64): i32;
export extern function typeck_float64_bits_hi(d: f64): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;

/**
 * Expr float bits lo: kind==1 uses live f64@+24 via typeck; else stored lo@+684.
 * Layout LE: kind@0, float_val@24, float_bits_lo@684.
 * wave517: ban return-subexpr / mid typeck call outside unsafe; pipe-cell.
 * @param a *u8 — ASTArena*
 * @param expr_ref i32 — 1-based expr ref
 * @return i32 — lo bits
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_expr_float_bits_lo_at(a: *u8, expr_ref: i32): i32 {
  let pcell: u8[8] = [];
  let kcell: u8[4] = [];
  let cell: u8[4] = [];
  let fv: f64 = 0.0;
  unsafe {
    pipe_store_ptr_slot(&pcell[0], 0, pipeline_arena_expr_ptr(a, expr_ref));
    if (pipe_load_ptr_slot(&pcell[0], 0) == (0 as *u8)) {
      return 0;
    }
    memcpy(&kcell[0], pipe_load_ptr_slot(&pcell[0], 0) + (0 as usize), 4 as usize);
    if (pipe_load_i32_le(&kcell[0], 0) == 1) {
      memcpy((&fv) as *u8, pipe_load_ptr_slot(&pcell[0], 0) + (24 as usize), 8 as usize);
      pipe_store_i32_le(&cell[0], 0, typeck_float64_bits_lo(fv));
      return pipe_load_i32_le(&cell[0], 0);
    }
    memcpy(&cell[0], pipe_load_ptr_slot(&pcell[0], 0) + (684 as usize), 4 as usize);
    return pipe_load_i32_le(&cell[0], 0);
  }
}

/**
 * Expr float bits hi: kind==1 uses live f64@+24 via typeck; else stored hi@+688.
 * wave517: ban return-subexpr / mid typeck call outside unsafe; pipe-cell.
 * @param a *u8 — ASTArena*
 * @param expr_ref i32 — 1-based expr ref
 * @return i32 — hi bits
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_expr_float_bits_hi_at(a: *u8, expr_ref: i32): i32 {
  let pcell: u8[8] = [];
  let kcell: u8[4] = [];
  let cell: u8[4] = [];
  let fv: f64 = 0.0;
  unsafe {
    pipe_store_ptr_slot(&pcell[0], 0, pipeline_arena_expr_ptr(a, expr_ref));
    if (pipe_load_ptr_slot(&pcell[0], 0) == (0 as *u8)) {
      return 0;
    }
    memcpy(&kcell[0], pipe_load_ptr_slot(&pcell[0], 0) + (0 as usize), 4 as usize);
    if (pipe_load_i32_le(&kcell[0], 0) == 1) {
      memcpy((&fv) as *u8, pipe_load_ptr_slot(&pcell[0], 0) + (24 as usize), 8 as usize);
      pipe_store_i32_le(&cell[0], 0, typeck_float64_bits_hi(fv));
      return pipe_load_i32_le(&cell[0], 0);
    }
    memcpy(&cell[0], pipe_load_ptr_slot(&pcell[0], 0) + (688 as usize), 4 as usize);
    return pipe_load_i32_le(&cell[0], 0);
  }
}

/**
 * Materialize typeck float bits from Expr float_val@+24 into lo@684/hi@688.
 * Bounds-check via arena num_exprs@+4.
 * wave517: ban mid `lo=/hi=typeck()` outside unsafe; pipe-cell.
 * @param a *u8 — ASTArena*
 * @param expr_ref i32 — 1-based expr ref
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_expr_typeck_set_float_bits_from_val(a: *u8, expr_ref: i32): void {
  let pcell: u8[8] = [];
  let necell: u8[4] = [];
  let locell: u8[4] = [];
  let hicell: u8[4] = [];
  let fv: f64 = 0.0;
  if (a == (0 as *u8) || expr_ref <= 0) {
    return;
  }
  unsafe {
    memcpy(&necell[0], a + (4 as usize), 4 as usize);
    if (expr_ref > pipe_load_i32_le(&necell[0], 0)) {
      return;
    }
    pipe_store_ptr_slot(&pcell[0], 0, pipeline_arena_expr_ptr(a, expr_ref));
    if (pipe_load_ptr_slot(&pcell[0], 0) == (0 as *u8)) {
      return;
    }
    memcpy((&fv) as *u8, pipe_load_ptr_slot(&pcell[0], 0) + (24 as usize), 8 as usize);
    pipe_store_i32_le(&locell[0], 0, typeck_float64_bits_lo(fv));
    pipe_store_i32_le(&hicell[0], 0, typeck_float64_bits_hi(fv));
    memcpy(pipe_load_ptr_slot(&pcell[0], 0) + (684 as usize), &locell[0], 4 as usize);
    memcpy(pipe_load_ptr_slot(&pcell[0], 0) + (688 as usize), &hicell[0], 4 as usize);
  }
}
