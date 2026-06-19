// 7.3：嵌套 while：内层 continue+break，外层再 a+=；return a+b → 5（cfg-merge）。
function main(): i32 {
  let a: i32 = 0;
  let b: i32 = 2;
  let c: i32 = a + b;
  while (a < 3) {
    while (a < 2) {
      if (a == 0) {
        a += 1;
        continue;
      }
      if (a == 1) {
        break;
      }
      a += 1;
    }
    a += 1;
  }
  return a + b;
}
