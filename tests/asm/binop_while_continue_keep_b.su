// 7.3：continue+break 后复用 b 槽（ldur 门禁，run-asm-binop-cfg-merge.sh）。
function main(): i32 {
  let a: i32 = 0;
  let b: i32 = 2;
  let c: i32 = a + b;
  while (a < 5) {
    if (a == 2) {
      a += 1;
      continue;
    }
    if (a == 4) {
      break;
    }
    a += 1;
  }
  let x: i32 = b;
  return x + a;
}
