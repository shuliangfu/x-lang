// Isolated: dest-assign a SIMD array element, then a second SIMD
// ARRAY_LIT (`let one:[1]i32x4=[a]`). `[N]i32x4` slots used N*8
// (TYPE_NAMED treated as a pointer). dest `arr[0]=a` wrote 16B;
// the second 16B write from an 8B high-end home planted a[2]=3
// at arr[0][0] (Ubuntu t[0]=3). Darwin ARM64 low-end was
// false-green. G.7: array slot bytes reuse
// glue_fixed_array_total_bytes_c / size_simple (lanes*esz).
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 was false-green.
allow(padding)

/**
 * Exit 0 when dest-assigned arr[0] survives a later SIMD ARRAY_LIT.
 * @return i32 — 0 ok; t[0] raw / 20+t[1] / 30+t[2] / 40+t[3]; 50+u[0]
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let z: i32x4 = [0, 0, 0, 0];
  let arr: [2]i32x4 = [z, z];
  arr[0] = a;
  let one: [1]i32x4 = [a];
  let t: i32x4 = arr[0];
  if (t[0] != 1) { return t[0]; }
  if (t[1] != 2) { return 20 + t[1]; }
  if (t[2] != 3) { return 30 + t[2]; }
  if (t[3] != 4) { return 40 + t[3]; }
  let u: i32x4 = one[0];
  if (u[0] != 1) { return 50 + u[0]; }
  if (u[1] != 2) { return 60 + u[1]; }
  if (u[2] != 3) { return 70 + u[2]; }
  if (u[3] != 4) { return 80 + u[3]; }
  return 0;
}
