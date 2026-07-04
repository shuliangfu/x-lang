// 7.3：块内连续 a op b 应复用 rbx 中仍有效的右操作数 VAR（run-asm-binop-block-var.sh）。
function main(): i32 {
  let a: i32 = 10;
  let b: i32 = 20;
  let c: i32 = a + b;
  let d: i32 = a & b;
  let e: i32 = a | b;
  let f: i32 = a ^ b;
  return c + d + e + f;
}
