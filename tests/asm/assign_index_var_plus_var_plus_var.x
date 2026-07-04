// 7.3：arr[i+j+k]=value 三 VAR ADD 链 assign scratch（run-asm-assign-index-expr.sh）。
function main(): i32 {
  let arr: i32[4] = [10, 20, 30, 40];
  let i: i32 = 1;
  let j: i32 = 2;
  let k: i32 = 0;
  arr[i + j + k] = 99;
  return arr[3];
}
