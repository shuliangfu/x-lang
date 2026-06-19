// 7.3：while 内 break 提前出口；return a+b 须见 break 时 a=1（cfg-merge）。
function main(): i32 {
  let a: i32 = 0;
  let b: i32 = 2;
  while (a < 10) {
    if (a == 1) {
      break;
    }
    a += 1;
  }
  return a + b;
}
