// 7.3：if 汇合仅 kill 写槽 a，return a+b 应复用 rbx 中 b（run-asm-binop-cfg-merge.sh ldur 门禁）。
function main(): i32 {
  let a: i32 = 1;
  let b: i32 = 2;
  let c: i32 = a + b;
  if (1 == 1) {
    a += 10;
  } else {
    a += 0;
  }
  return a + b;
}
