// 7.3：arr[i-lit]=value SUB 字面量下标 scratch 寻址（run-asm-assign-index-expr.sh）。
function main(): i32 {
  let arr: i32[3] = [5, 10, 15];
  let i: i32 = 2;
  arr[i - 1] = 99;
  return arr[1];
}
