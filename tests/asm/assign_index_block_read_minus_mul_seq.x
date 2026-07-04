// 7.3：assign (i-j)*lit 后 read 同形 INDEX 复用 minus_pair 前缀栈（run-asm-assign-index-block.sh）。
function main(): i32 {
  let arr: i32[8] = [10, 20, 30, 40, 50, 60, 70, 80];
  let i: i32 = 2;
  let j: i32 = 1;
  arr[(i - j) * 2] = 55;
  let t: i32 = arr[(i - j) * 2];
  return t + arr[2];
}
