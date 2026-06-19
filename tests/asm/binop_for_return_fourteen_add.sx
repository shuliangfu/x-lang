// 7.3：cfg 父块（for）+ 十四元 return 加链；final_expr VAR≥12 启栈帧 spill（1+…+14=105）。
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
  let k: i32 = 11;
  let l: i32 = 12;
  let m: i32 = 13;
  let n: i32 = 14;
  // 零次循环：汇合 live 不引入额外 let，return 链拿 which=6。
  for ( ; 0 == 1 ; ) {
    a = a;
  }
  return a + b + c + d + e + f + g + h + i + j + k + l + m + n;
}
