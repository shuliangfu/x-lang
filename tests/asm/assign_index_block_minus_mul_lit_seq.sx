// 7.3：块内连续 (i-j)*lit assign 前缀栈复用（run-asm-assign-index-block.sh）。
function main(): i32 {
  let arr: i32[8] = [10, 20, 30, 40, 50, 60, 70, 80];
  let i: i32 = 2;
  let j: i32 = 1;
  arr[(i - j) * 2] = 11;
  arr[(i - j) * 3] = 22;
  return arr[2] + arr[3];
}
