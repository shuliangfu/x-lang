// const_spec.x — WPO-S2 烟测：main 以整型常量实参调用 scale，call graph 应记录 all_const profile
/** 两整型参数相乘；WPO-S2 见 call site args=[1024,64]。 */
function scale(n: i32, k: i32): i32 {
  return n * k;
}

function main(): i32 {
  return scale(1024, 64);
}
