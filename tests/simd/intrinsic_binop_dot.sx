// STD-SIMD-INTRINSIC：std.simd mul/sub/dot 烟测
const simd = import("std.simd");

function main(): i32 {
  let a: Vec4f = [1.0, 2.0, 3.0, 4.0];
  let b: Vec4f = [1.0, 1.0, 1.0, 1.0];
  let p: Vec4f = simd.mul(a, b);
  let d: f32 = simd.dot(a, b);
  if (d < 9.99 || d > 10.01) {
    return 1;
  }
  let c: Vec4f = simd.sub(p, simd.splat(0.0));
  if (c[0] != 1.0) {
    return 2;
  }
  if (simd.dot(a, b) < 9.99) {
    return 3;
  }
  let ai: Vec8i = simd.splat(2);
  let bi: Vec8i = simd.splat(3);
  let si: Vec8i = simd.sub(bi, ai);
  if (si[0] != 1) {
    return 4;
  }
  let mi: Vec8i = simd.mul(ai, bi);
  if (mi[0] != 6) {
    return 5;
  }
  let fma_a: Vec4f = [1.0, 2.0, 3.0, 4.0];
  let fma_b: Vec4f = [2.0, 2.0, 2.0, 2.0];
  let fma_c: Vec4f = [0.5, 0.5, 0.5, 0.5];
  let f: Vec4f = simd.fma(fma_a, fma_b, fma_c);
  if (f[0] != 2.0 || f[1] != 3.0 || f[2] != 4.0 || f[3] != 5.0) {
    return 6;
  }
  let m: Vec4f = simd.madd(fma_a, fma_b, fma_c);
  if (m[0] != 2.0) {
    return 7;
  }
  let sf: Vec4f = simd.fma(fma_a, fma_b, fma_c);
  if (sf[3] != 5.0) {
    return 8;
  }
  return 0;
}
