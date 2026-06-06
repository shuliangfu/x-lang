// 7.3：while 回边多轮（a<2 两次 a+=1）；出口须见 a=2，return a+b → exit 4（cfg-merge）。
function main(): i32 {
  let a: i32 = 0;
  let b: i32 = 2;
  while (a < 2) {
    a += 1;
  }
  return a + b;
}
