/** M-4：call 实参二次使用 linear 应失败 */
function take(v: Linear(i32)): i32 {
  return v;
}

function main(): i32 {
  let a: Linear(i32) = 1;
  let x: i32 = take(a);
  let y: i32 = take(a);
  return x;
}
