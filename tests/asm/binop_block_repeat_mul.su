// 7.3：块内连续 a*b 第二次应复用 rbx 中的 b（run-asm-binop-block-var.sh）。
function main(): i32 {
  let a: i32 = 2;
  let b: i32 = 3;
  let x: i32 = a * b;
  let y: i32 = a * b;
  return x + y;
}
