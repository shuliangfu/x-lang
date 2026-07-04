/** M-4：二次 move 应 typeck 失败 */
function main(): i32 {
  let a: Linear(i32) = 1;
  let b: Linear(i32) = a;
  let c: Linear(i32) = a;
  return 0;
}
