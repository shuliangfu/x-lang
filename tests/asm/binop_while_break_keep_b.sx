// 7.3：break 出口 live ∪ 后复用 b 槽（ldur 门禁，run-asm-binop-cfg-merge.sh）。
function main(): i32 {
  let a: i32 = 0;
  let b: i32 = 2;
  let c: i32 = a + b;
  while (a < 10) {
    if (a == 1) {
      break;
    }
    a += 1;
  }
  let x: i32 = b;
  return x + a;
}
