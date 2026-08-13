// Isolated: ARRAY_LIT as SIMD CALL argument (typeck stamp + emit).
// typeck: coerce before score (typeck_check_call_arg_types).
// emit: pipeline_asm_emit_expr_elf_for_call_args packs ≤16B dual-GP
// (reuse glue_emit_vector_type_let_init). Non-const elems block WPO fold
// so run≠7 cannot hide behind mov-imm. METHOD receiver uses the same
// emit function when rty/pty is SIMD (same-layer leftover, later probe).
// PLATFORM: SHARED — Ubuntu gold.

/**
 * Extract lane 0 of an i32x4 (CALL formal).
 * @param v i32x4 — vector value
 * @return i32 — lane 0
 */
function take_vec(v: i32x4): i32 {
  return v[0];
}

/**
 * Add two i32x4 values (CALL formals).
 * @param a i32x4 — left lanes
 * @param b i32x4 — right lanes
 * @return i32x4 — a + b
 */
function add4(a: i32x4, b: i32x4): i32x4 {
  return a + b;
}

/**
 * Exit 0 when ARRAY_LIT SIMD CALL args typeck and emit (lane0 == expected).
 * @return i32 — 0 ok, else the failing case
 */
function main(): i32 {
  /* Nested CALL: typeck + possible WPO fold of const lanes. */
  if (take_vec(add4([1, 2, 3, 4], [10, 20, 30, 40])) != 11) { return 1; }
  /* let-then-CALL neighborhood (green before this knife). */
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [10, 20, 30, 40];
  if (take_vec(add4(a, b)) != 11) { return 2; }
  /* Bare ARRAY_LIT as i32x4 CALL arg — this knife (may still fold). */
  if (take_vec([7, 8, 9, 10]) != 7) { return 3; }
  /* Non-const elem: fold cannot mov-imm; must emit packed lanes. */
  let x: i32 = 7;
  if (take_vec([x, 8, 9, 10]) != 7) { return 4; }
  let y: i32 = 10;
  if (take_vec(add4([1, 2, 3, 4], [y, 20, 30, 40])) != 11) { return 5; }
  return 0;
}
