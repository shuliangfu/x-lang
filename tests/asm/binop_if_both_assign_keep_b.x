// 7.3：if 两分支均写 a（φ 槽）；b 未写，return a+b 应复用 b 槽（cfg-merge ldur 门禁）。
function main(): i32 {
  let a: i32 = 1;
  let b: i32 = 2;
  let c: i32 = a + b;
  if (1 == 1) {
    a += 10;
  } else {
    a += 11;
  }
  return a + b;
}
