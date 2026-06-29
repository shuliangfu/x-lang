// STD-047：shuffle/select 金样（断言 lane 值，非仅编译）
const simd = import("std.simd");

function main(): i32 {
  let v4: Vec4f = [1.0, 2.0, 3.0, 4.0];
  let m4: i32[4] = [3, 2, 1, 0];
  let r4: Vec4f = simd.shuffle(v4, m4);
  if (r4[0] != 4.0) { return 1; }
  if (r4[1] != 3.0) { return 2; }
  if (r4[2] != 2.0) { return 3; }
  if (r4[3] != 1.0) { return 4; }
  let v8: Vec8i = [0, 1, 2, 3, 4, 5, 6, 7];
  let m8: i32[8] = [3, 2, 1, 0, 7, 6, 5, 4];
  let r8: Vec8i = simd.shuffle(v8, m8);
  if (r8[0] != 3) { return 5; }
  if (r8[4] != 7) { return 6; }
  let mask4: Vec4f = [1.0, 0.0, 1.0, 0.0];
  let a4: Vec4f = [2.0, 2.0, 2.0, 2.0];
  let b4: Vec4f = [0.5, 0.5, 0.5, 0.5];
  let s4: Vec4f = simd.select(mask4, a4, b4);
  if (s4[0] != 2.0) { return 7; }
  if (s4[1] != 0.5) { return 8; }
  let mask8: Vec8i = [1, 0, 1, 0, 0, 1, 0, 1];
  let a8: Vec8i = [10, 10, 10, 10, 10, 10, 10, 10];
  let b8: Vec8i = [1, 1, 1, 1, 1, 1, 1, 1];
  let s8: Vec8i = simd.select(mask8, a8, b8);
  if (s8[0] != 10) { return 9; }
  if (s8[1] != 1) { return 10; }
  if (s8[5] != 10) { return 11; }
  return 0;
}
