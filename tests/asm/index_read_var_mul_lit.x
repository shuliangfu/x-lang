// 7.3：return arr[i*lit] INDEX 读 MUL scratch 寻址（run-asm-assign-index-expr.sh）。
function main(): i32 {
  let arr: i32[4] = [10, 20, 30, 40];
  let i: i32 = 1;
  return arr[i * 2];
}
