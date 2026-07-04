// 7.3：块内 a+b 后 b+a 应复用 rbx 中的 b 并 swap（run-asm-binop-block-var.sh）。
function main(): i32 {
  let a: i32 = 10;
  let b: i32 = 20;
  let c: i32 = a + b;
  let d: i32 = b + a;
  return c + d;
}
