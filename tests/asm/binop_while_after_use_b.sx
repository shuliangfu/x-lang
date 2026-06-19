// 7.3：while 出口 live ∪ 后 return a+b；a 在循环内 +=，b 应保持入口值 2（run-asm-binop-cfg-merge.sh）。
function main(): i32 {
  let a: i32 = 0;
  let b: i32 = 2;
  while (a < 1) {
    a += 1;
  }
  return a + b;
}
