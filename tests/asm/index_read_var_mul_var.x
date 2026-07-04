// 7.3：return arr[i*j] INDEX 读双 VAR MUL scratch（run-asm-assign-index-expr.sh）。
function main(): i32 {
  let arr: i32[4] = [10, 20, 30, 40];
  let i: i32 = 2;
  let j: i32 = 1;
  return arr[i * j];
}
