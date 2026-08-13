/**
 * WPO-S2 METHOD neighborhood of vec_const_spec_mono.x.
 * Default path (env unset): wpo_const vector_lane folds both sites to imm.
 * XLANG_WPO_MONO=1: try_call_wpo_mono_vector_lane emits zero-arg thunks
 * `lane0__wpo_1_2_3_4_10_20_30_40` and `lane0_call__wpo_1_2_3_4_10_20_30_40`.
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

/**
 * CALL outer neighborhood of lane0 (same `return param0[0]` shape).
 * Named apart so name-scan / overload do not collide with the METHOD.
 * @param v i32x4 — const vec_binop at the call site
 * @return i32 — lane 0
 */
function lane0_call(v: i32x4): i32 {
  return v[0];
}

/**
 * CALL inner of vector_lane fold: `return param0 + param1` on i32x4.
 * Named apart from the METHOD so name-scan / overload do not collide.
 * @param a i32x4 — left lanes
 * @param b i32x4 — right lanes
 * @return i32x4 — a + b
 */
function vec_add4_call(a: i32x4, b: i32x4): i32x4 {
  return a + b;
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
 * Exit 0 when METHOD outer+CALL inner, METHOD inner+METHOD outer,
 * and CALL outer+CALL inner all fold or thunk to 11.
 * @return i32 — 0 ok, 1 METHOD-outer miss, 2 METHOD-inner miss, 3 CALL miss
 */
function main(): i32 {
  if (vec_add4_call([1, 2, 3, 4], [10, 20, 30, 40]).lane0() != 11) { return 1; }
  if ([1, 2, 3, 4].vec_add4([10, 20, 30, 40]).lane0() != 11) { return 2; }
  if (lane0_call(vec_add4_call([1, 2, 3, 4], [10, 20, 30, 40])) != 11) { return 3; }
  return 0;
}
