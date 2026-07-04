// 7.3 线性 scan x10：return 左结合乘链 ((a*b)*c)*d，rbx 换载前 spill 到 x10；2*3*2*2=24。
function main(): i32 {
  let a: i32 = 2;
  let b: i32 = 3;
  let c: i32 = 2;
  let d: i32 = 2;
  return a * b * c * d;
}
