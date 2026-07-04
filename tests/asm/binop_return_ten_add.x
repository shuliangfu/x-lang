// 7.3：十 VAR 左结合加链；|live|max≥9 时第六溢出走栈帧 spill（1+…+10=55）。
function main(): i32 {
  let a: i32 = 1;
  let b: i32 = 2;
  let c: i32 = 3;
  let d: i32 = 4;
  let e: i32 = 5;
  let f: i32 = 6;
  let g: i32 = 7;
  let h: i32 = 8;
  let i: i32 = 9;
  let j: i32 = 10;
  return a + b + c + d + e + f + g + h + i + j;
}
