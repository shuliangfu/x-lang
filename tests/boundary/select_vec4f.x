// Gate: Vec4f simd.select must blend lanes (mask>0 → a else b).
// ARM64 hw path after fcmgt must emit BSL (dest=predicate, n=a, m=b).
// Historic BIT treated b as the predicate and mixed a with leftover bits.
// Expected: 0.
const simd = import("std.simd");

/**
 * Probe Vec4f select mixed / all-a / all-b masks including s[0] and s[1].
 * @return i32 — 0 on success; 7/8 = mixed miss; 1..4 = all-a miss; 11..14 = all-b miss
 */
function main(): i32 {
  let mask4: Vec4f = [1.0, 0.0, 1.0, 0.0];
  let a4: Vec4f = [2.0, 2.0, 2.0, 2.0];
  let b4: Vec4f = [0.5, 0.5, 0.5, 0.5];
  let s4: Vec4f = simd.select(mask4, a4, b4);
  if (s4[0] != 2.0) { return 7; }
  if (s4[1] != 0.5) { return 8; }
  if (s4[2] != 2.0) { return 72; }
  if (s4[3] != 0.5) { return 73; }
  let ma: Vec4f = [1.0, 1.0, 1.0, 1.0];
  let aa: Vec4f = [2.0, 3.0, 4.0, 5.0];
  let ba: Vec4f = [0.5, 0.5, 0.5, 0.5];
  let sa: Vec4f = simd.select(ma, aa, ba);
  if (sa[0] != 2.0) { return 1; }
  if (sa[1] != 3.0) { return 2; }
  if (sa[2] != 4.0) { return 3; }
  if (sa[3] != 5.0) { return 4; }
  let mb: Vec4f = [0.0, 0.0, 0.0, 0.0];
  let ab: Vec4f = [2.0, 3.0, 4.0, 5.0];
  let bb: Vec4f = [0.5, 0.6, 0.7, 0.8];
  let sb: Vec4f = simd.select(mb, ab, bb);
  if (sb[0] != 0.5) { return 11; }
  if (sb[1] != 0.6) { return 12; }
  if (sb[2] != 0.7) { return 13; }
  if (sb[3] != 0.8) { return 14; }
  return 0;
}
