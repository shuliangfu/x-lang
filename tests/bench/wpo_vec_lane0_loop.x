// wpo_vec_lane0_loop.x — WPO-S2 vec bench：热循环内 lane0(vec_add4([const],[const]))
// 默认：try_inline_wpo_const_vector_lane_of_binop_call_elf 将每轮 fold 为 s = s + 11。
// 对照：SHUX_WPO_NO_FOLD=1 保留 bl lane0 / bl vec_add4。
/** 两形参向量加法；WPO 可识别 param0+param1 向量形态。 */
function vec_add4(a: i32x4, b: i32x4): i32x4 {
  return a + b;
}

/** 取向量第 0 lane。 */
function lane0(v: i32x4): i32 {
  return v[0];
}

function main(): i32 {
  let limit: i32 = 10000000;
  let s: i32 = 0;
  let i: i32 = 0;
  while (i < limit) {
    s = s + lane0(vec_add4([1, 2, 3, 4], [10, 20, 30, 40]));
    i = i + 1;
  }
  /* fold 正确时 s=110000000；勿 return s（mod 256→128 会误伤 perf 脚本的 exit 检查） */
  if (s != 110000000) {
    return 1;
  }
  return 0;
}
