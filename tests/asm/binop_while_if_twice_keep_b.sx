// 7.3：多轮 while + 体内 if；b 未写，出口 live 须含 b（cfg-merge ldur 门禁，子块出口快照）。
function main(): i32 {
  let a: i32 = 0;
  let b: i32 = 2;
  let c: i32 = a + b;
  while (a < 2) {
    if (a == 0) {
      a += 1;
    } else {
      a += 1;
    }
  }
  let x: i32 = b;
  return x + a;
}
