// 7.3：两阶段四 VAR（峰值各 4，全块 8 槽）；Chaitin 可共享 spill 家园；exit 36。
function main(): i32 {
  let a: i32 = 1;
  let b: i32 = 2;
  let c: i32 = 3;
  let d: i32 = 4;
  let s: i32 = a + b + c + d;
  let e: i32 = 5;
  let f: i32 = 6;
  let g: i32 = 7;
  let h: i32 = 8;
  return s + e + f + g + h;
}
