// 阶段 8 性能基线：固定工作量（循环 + 整数运算），便于 -O2/-Os 前后对比
function main(): i32 {
  let n: i32 = 0;
  let i: i32 = 0;
  while (i < 10000000) {
    n = n + i;
    i = i + 1;
  }
  return n;
}
