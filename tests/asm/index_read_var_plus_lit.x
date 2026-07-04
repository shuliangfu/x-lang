// 7.3：return arr[i+lit] INDEX 读 ADD 下标 scratch（run-asm-assign-index-expr.sh）。
function main(): i32 {
  let arr: i32[3] = [5, 10, 15];
  let i: i32 = 0;
  return arr[i + 1];
}
