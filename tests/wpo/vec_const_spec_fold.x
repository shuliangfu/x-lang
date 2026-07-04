// vec_const_spec_fold.x — WPO-S2 vec 特化：lane0(vec_add4([const],[const])) 应编译期 fold
/** 两形参向量加法。 */
function vec_add4(a: i32x4, b: i32x4): i32x4 {
  return a + b;
}

/** 取向量第 0 lane（WPO 特化外层形态）。 */
function lane0(v: i32x4): i32 {
  return v[0];
}

function main(): i32 {
  return lane0(vec_add4([1, 2, 3, 4], [10, 20, 30, 40])) - 11;
}
