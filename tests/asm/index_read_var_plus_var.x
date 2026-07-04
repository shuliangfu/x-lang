// 7.3：return arr[i+j] INDEX 读双 VAR 下标 scratch（run-asm-assign-index-expr.sh）。
function main(): i32 {
  let arr: i32[4] = [5, 10, 15, 20];
  let i: i32 = 1;
  let j: i32 = 1;
  return arr[i + j];
}
