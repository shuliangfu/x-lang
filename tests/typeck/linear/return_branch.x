/** M-4：return 消耗 linear；分支外二次使用应失败 */
function main(): i32 {
  let a: Linear(i32) = 1;
  if (true) {
    return a;
  }
  let c: Linear(i32) = a;
  return 0;
}
