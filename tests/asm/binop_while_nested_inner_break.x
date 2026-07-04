// 7.3：嵌套 while：内层 j 计数、外层 a+=；return a+b → 4（cfg-merge）。
function main(): i32 {
  let a: i32 = 0;
  let b: i32 = 2;
  let c: i32 = a + b;
  while (a < 2) {
    let j: i32 = 0;
    while (j < 1) {
      j = j + 1;
    }
    a += 1;
  }
  return a + b;
}
