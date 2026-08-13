/**
 * WPO-S2 METHOD neighborhood of vec_const_spec_mono.x.
 * Default path (env unset): wpo_const vector_lane folds to imm.
 * XLANG_WPO_MONO=1: try_call_wpo_mono_vector_lane emits zero-arg thunk
 * `lane0__wpo_1_2_3_4_10_20_30_40`.
 *
 * METHOD inner + METHOD outer only. CALL-inner neighborhood lives on
 * vec_const_spec_fold.x (typeck ARRAY_LIT→i32x4 CALL green; bare
 * ARRAY_LIT SIMD CALL-arg emit is pipeline_asm_emit_expr_elf_for_call_args).
 * smf 25/26 keep the CALL-inner neighborhood on the larger file.
 */

trait Lane0able {
  function lane0(self): i32;
}

/**
 * METHOD outer of the lane-of-const-vector-binop fold / mono thunk.
 * Callee shape is `return self[0]` (one i32x4 param).
 * @param self i32x4 — receiver (const vec_binop at the call site)
 * @return i32 — lane 0
 */
impl Lane0able for i32x4 {
  function lane0(self: i32x4): i32 {
    return self[0];
  }
}

trait VecAdd4able {
  function vec_add4(self, other: i32x4): i32x4;
}

/**
 * METHOD inner of vector_lane fold: same `return self + other` as vec_add4.
 * @param self i32x4 — left lanes (array lit at the call site)
 * @param other i32x4 — right lanes
 * @return i32x4 — self + other
 */
impl VecAdd4able for i32x4 {
  function vec_add4(self: i32x4, other: i32x4): i32x4 {
    return self + other;
  }
}

/**
 * Exit 0 when METHOD inner+METHOD outer folds or thunks to 11.
 * @return i32 — 0 ok, 1 miss
 */
function main(): i32 {
  if ([1, 2, 3, 4].vec_add4([10, 20, 30, 40]).lane0() != 11) { return 1; }
  return 0;
}
