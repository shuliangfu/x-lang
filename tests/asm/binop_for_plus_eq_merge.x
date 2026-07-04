// 7.3：for 出口 live ∪ 后 return a+b；循环体内 a+=（run-asm-binop-cfg-merge.sh）。
function main(): i32 {
  let a: i32 = 0;
  let b: i32 = 2;
  for ( ; a < 1 ; ) {
    a += 1;
  }
  return a + b;
}
