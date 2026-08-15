// Gate: Vec8i shuffle must write the high 16B half (lanes 4..7).
// ARM64 product vector home is low-end (lane0 at slot). half1 lea is slot+16.
// Historic slot-16 was clamped to 0 by lea_rbp, so r[4] stayed leftover.
// Expected: 0.
const simd = import("std.simd");

/**
 * Probe Vec8i identity and reverse shuffle, including high-half lanes.
 * @return i32 — 0 on success; 24 = identity r[4] miss; 6 = reverse r[4] miss
 */
function main(): i32 {
  let v: Vec8i = [0, 1, 2, 3, 4, 5, 6, 7];
  let mid: i32[8] = [0, 1, 2, 3, 4, 5, 6, 7];
  let rid: Vec8i = simd.shuffle(v, mid);
  if (rid[0] != 0) { return 20; }
  if (rid[4] != 4) { return 24; }
  if (rid[7] != 7) { return 27; }
  let mrev: i32[8] = [3, 2, 1, 0, 7, 6, 5, 4];
  let rrev: Vec8i = simd.shuffle(v, mrev);
  if (rrev[0] != 3) { return 5; }
  if (rrev[4] != 7) { return 6; }
  if (rrev[7] != 4) { return 63; }
  return 0;
}
