// 7.3：a==2 时先 +=1 再 continue（跳过后续 a+=1），随后 break；return a+b → 6（cfg-merge）。
function main(): i32 {
  let a: i32 = 0;
  let b: i32 = 2;
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
  return a + b;
}
