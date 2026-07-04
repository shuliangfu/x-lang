// 三元整型拓宽：i64 目标无需对 n 写 as
function main(): i32 {
  let n: i32 = 3;
  let r: i64 = n >= 0 ? n : -1;
  if (r < 0) {
    return 1;
  }
  return 0;
}
