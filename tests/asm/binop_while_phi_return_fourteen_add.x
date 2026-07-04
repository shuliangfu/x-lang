// 7.3：while 体 redefine a（loop φ 失效 cache）+ 十四元 return；exit 105（0→1 后 1+2+…+14）。
function main(): i32 {
  let a: i32 = 0;
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
  while (a < 1) {
    a += 1;
  }
  return a + b + c + d + e + f + g + h + i + j + k + l + m + n;
}
