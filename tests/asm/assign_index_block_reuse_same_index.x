// 7.3：块内连续相同 INDEX assign 复用 rbx 有效址（run-asm-assign-index-block.sh）。
function main(): i32 {
  let arr: i32[4] = [10, 20, 30, 40];
  let i: i32 = 1;
  let j: i32 = 0;
  let k: i32 = 0;
  arr[(i - j + k) * 2] = 11;
  arr[(i - j + k) * 2] = 22;
  return arr[2];
}
