// 7.3：块内混合 SUB/ADD*lit INDEX assign + 求和，main 内无 mov x2（run-asm-assign-index-block.sh）。
function main(): i32 {
  let arr: i32[4] = [10, 20, 30, 40];
  let i: i32 = 1;
  let j: i32 = 0;
  let k: i32 = 0;
  arr[(i - j + k) * 2] = 11;
  arr[(i - j) - k] = 22;
  return arr[2] + arr[1];
}
