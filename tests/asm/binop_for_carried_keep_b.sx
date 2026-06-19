// 7.3：for 体内写 a（入口活跃携带重定义 φ）；b 未写，return a+b（cfg-merge ldur 门禁）。
function main(): i32 {
  let a: i32 = 0;
  let b: i32 = 2;
  for ( ; a < 1 && b == 2 ; ) {
    a += 1;
  }
  return a + b;
}
