// wpo_scale_loop.x — WPO-S2 bench：热循环内 scale(1024,64) 常量 call
// 默认编译：try_inline_wpo_const_scalar_binop_call_elf 将每轮 call fold 为 s = s + 65536。
// 对照：SHUX_WPO_NO_FOLD=1 编译同一源码，保留 bl _scale。
/** 两参标量乘法；WPO-S2 可识别 param0*param1 形态。 */
function scale(n: i32, k: i32): i32 {
  return n * k;
}

function main(): i32 {
  let limit: i32 = 10000000;
  let s: i32 = 0;
  let i: i32 = 0;
  while (i < limit) {
    s = s + scale(1024, 64);
    i = i + 1;
  }
  return s;
}
