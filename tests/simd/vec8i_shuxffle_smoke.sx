// SIMD-S4 烟测：Vec8i comptime shuffle → vpshufd（每 128-bit 半幅内反转）。
const simd = import("std.simd");

function main(): i32 {
  let v: Vec8i = [0, 1, 2, 3, 4, 5, 6, 7];
  let m: i32[8] = [3, 2, 1, 0, 7, 6, 5, 4];
  let r: Vec8i = simd.shuffle(v, m);
  let _unused: Vec8i = r - r;
  return 0;
}
