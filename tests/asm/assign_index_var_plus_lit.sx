// 7.3：arr[var+lit]=右值 下标 scratch 寻址，main 内无 mov x2（run-asm-assign-index-expr.sh）。
function main(): i32 {
  let arr: i32[3] = [5, 10, 15];
  let i: i32 = 0;
  arr[i + 1] = 99;
  return arr[1];
}
