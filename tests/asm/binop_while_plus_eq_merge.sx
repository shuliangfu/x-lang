// 7.3：while 出口汇合后 return a+b 须见循环内 a+= 后的值；run-asm-binop-cfg-merge.sh。
function main(): i32 {
  let a: i32 = 0;
  let b: i32 = 2;
  while (a < 1) {
    a += 1;
  }
  return a + b;
}
