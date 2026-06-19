// 7.3：if 汇合 live union 后 let x=b 应仍复用 rbx 中 b（run-asm-binop-cfg-merge.sh）。
function main(): i32 {
  let a: i32 = 1;
  let b: i32 = 2;
  let c: i32 = a + b;
  if (1 == 1) {
    a += 10;
  } else {
    a += 0;
  }
  let x: i32 = b;
  return x + a;
}
