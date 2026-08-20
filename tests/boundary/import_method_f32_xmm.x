// Isolated import METHOD scalar f32 extras must use SysV xmm / AAPCS64 s0.
// Host-C std_simd_select_lane_f32_f32_f32 reads xmm0–2 (x86) or s0–s2 (arm64).
// PLATFORM: SHARED — Ubuntu x86_64 gold (xmm); Darwin arm64 s0–s7.
const simd = import("std.simd");

/**
 * Probe: import METHOD f32 extras via SysV xmm (select_lane mask/a/b).
 * @return i32 — 0 on success; 7 = 1.0-mask miss; 8 = 0.0-mask miss
 */
function main(): i32 {
  let lf: f32 = simd.select_lane(1.0, 3.0, 4.0);
  if (lf != 3.0) { return 7; }
  let lg: f32 = simd.select_lane(0.0, 3.0, 4.0);
  if (lg != 4.0) { return 8; }
  let li: i32 = simd.select_lane(1, 10, 20);
  if (li != 10) { return 5; }
  return 0;
}
