// 7.3：assign + return arr[i*lit] 读写均 scratch 寻址（run-asm-assign-index-expr.sh）。
function main(): i32 {
  let arr: i32[4] = [10, 20, 30, 40];
  let i: i32 = 1;
  arr[i * 2] = 99;
  return arr[i * 2];
}
