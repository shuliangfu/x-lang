// STD-061：shuffle/select 热循环 bench（import("std.simd") 生产路径）
const simd = import("std.simd");

function main(): i32 {
  let limit: i32 = 2000000;
  let acc: i32 = 0;
  let i: i32 = 0;
  let v4: Vec4f = [1.0, 2.0, 3.0, 4.0];
  let v8: Vec8i = [0, 1, 2, 3, 4, 5, 6, 7];
  let m4: i32[4] = [3, 2, 1, 0];
  let m8: i32[8] = [3, 2, 1, 0, 7, 6, 5, 4];
  let mask4: Vec4f = [1.0, 0.0, 1.0, 0.0];
  let a4: Vec4f = [2.0, 2.0, 2.0, 2.0];
  let b4: Vec4f = [0.5, 0.5, 0.5, 0.5];
  while (i < limit) {
    let r4: Vec4f = simd.shuffle(v4, m4);
    let s4: Vec4f = simd.select(mask4, a4, b4);
    let r8: Vec8i = simd.shuffle(v8, m8);
    let s8: Vec8i = simd.select(simd.splat(1), r8, simd.splat(0));
    acc = acc + (r8[0] as i32) + (s8[1] as i32) + (r4[0] as i32) + (s4[0] as i32);
    i = i + 1;
  }
  let _unused: i32 = acc;
  return 0;
}
