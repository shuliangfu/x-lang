// 7.3：assign + return arr[i*j] 读写均 scratch 寻址（run-asm-assign-index-expr.sh）。
function main(): i32 {
  let arr: i32[4] = [10, 20, 30, 40];
  let i: i32 = 2;
  let j: i32 = 1;
  arr[i * j] = 99;
  return arr[i * j];
}
