// 7.3：if 汇合后 return a+b 须读栈上最新 a（then 中 a+=，空 else）；run-asm-binop-cfg-merge.sh。
function main(): i32 {
  let a: i32 = 1;
  let b: i32 = 2;
  let c: i32 = a + b;
  if (1 == 1) {
    a += 10;
  } else {
    /** 不可达，仅平衡 AST */
    a += 0;
  }
  return a + b;
}
