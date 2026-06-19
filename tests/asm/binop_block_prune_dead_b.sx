// 7.3：线性块反向 live_in — c=a+b 后 b 已死，return d 前须 prune rbx 中 b（run-asm-binop-block-var.sh）。
function main(): i32 {
  let a: i32 = 10;
  let b: i32 = 20;
  let c: i32 = a + b;
  let d: i32 = a;
  return d;
}
