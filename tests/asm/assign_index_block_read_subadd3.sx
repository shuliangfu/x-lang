// 7.3：assign (i-j+k)*lit 后 read 同形 INDEX 复用 subadd3 前缀栈（run-asm-assign-index-block.sh）。
function main(): i32 {
  let arr: i32[8] = [10, 20, 30, 40, 50, 60, 70, 80];
  let i: i32 = 2;
  let j: i32 = 1;
  let k: i32 = 0;
  arr[(i - j + k) * 2] = 99;
  let a: i32 = arr[(i - j + k) * 2];
  return a + arr[2];
}
