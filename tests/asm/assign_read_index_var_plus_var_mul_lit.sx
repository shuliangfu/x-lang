// 7.3：assign + return arr[(i+j)*lit] 嵌套 ADD*lit 读写 scratch（run-asm-assign-index-expr.sh）。
function main(): i32 {
  let arr: i32[4] = [10, 20, 30, 40];
  let i: i32 = 0;
  let j: i32 = 1;
  arr[(i + j) * 2] = 99;
  return arr[(i + j) * 2];
}
