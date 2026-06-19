// 7.3：for 头 step（a+=1）经 glue_live_fwd_apply_expr_effect；出口 return a+b（cfg-merge）。
function main(): i32 {
  let a: i32 = 0;
  let b: i32 = 2;
  for ( ; a < 1 ; a += 1) {
    /** 空体，递增仅在 step */
  }
  return a + b;
}
