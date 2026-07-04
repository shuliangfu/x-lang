// 7.3 线性 scan：五 VAR 左结合加链；|live|max≥5 时可用 x11 第二 spill；1+2+3+4+5=15。
function main(): i32 {
  let a: i32 = 1;
  let b: i32 = 2;
  let c: i32 = 3;
  let d: i32 = 4;
  let e: i32 = 5;
  return a + b + c + d + e;
}
