// 7.3：for 多轮体 a+=1（a<2 两次）；出口 return a+b → exit 4（cfg-merge）。
function main(): i32 {
  let a: i32 = 0;
  let b: i32 = 2;
  for ( ; a < 2 ; ) {
    a += 1;
  }
  return a + b;
}
