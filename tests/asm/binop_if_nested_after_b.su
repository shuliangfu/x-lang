// 7.3：then 内嵌套 if 汇合后外层 if 再汇合；return a+b 须见内层 else 的 a+=（cfg-merge ldur 门禁）。
function main(): i32 {
  let a: i32 = 1;
  let b: i32 = 2;
  let c: i32 = a + b;
  if (1 == 1) {
    if (1 == 0) {
      a += 99;
    } else {
      a += 5;
    }
  } else {
    a += 0;
  }
  return a + b;
}
