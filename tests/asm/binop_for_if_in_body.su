// 7.3：for 体内 if 写 a；循环出口 live ∪ 后 return a+b（cfg-merge）。
function main(): i32 {
  let a: i32 = 0;
  let b: i32 = 2;
  for ( ; a < 1 ; ) {
    if (1 == 1) {
      a += 1;
    } else {
      a += 0;
    }
  }
  return a + b;
}
