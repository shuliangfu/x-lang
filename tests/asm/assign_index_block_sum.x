// 7.3：块内连续 INDEX assign + return 求和，main 内无 mov x2（run-asm-assign-index-block.sh）。
function main(): i32 {
  let arr: i32[3] = [5, 10, 15];
  arr[0] = 1;
  arr[1] = 2;
  arr[2] = 3;
  return arr[0] + arr[1] + arr[2];
}
