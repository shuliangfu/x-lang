// Isolated: ARRAY_LIT of SIMD named VAR elems
// (`let arr: [2]i32x4 = [z, z]` / `[1]i32x4 = [a]`). Fixed-array
// let-init used to fall through to scalar emit_expr; a 16B VAR
// load writes dual-GP into x0+x1, clobbering dest-in-x1, then
// `str [x1]` with z high=0 is Darwin 139. G.7: vector let-init
// into the real frame home (same as FIELD dest VECTOR CALL).
// Does not INDEX arr[1] — INDEX stride of [N]i32x4 is still 4
// (leftover; arr[1] reads into the first vector). Checks use
// arr[0] / [1]T only (INDEX +0). Nested arr[0][0] is leftover.
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail.

/**
 * Exit 0 when ARRAY_LIT of SIMD VAR elems writes every lane of elem 0
 * and a 2-elem ctor does not crash.
 * @return i32 — 0 ok; 1..4 zero-fill; 10..40 [1] copy; 50..53 two-elem first
 */
function main(): i32 {
  let z: i32x4 = [0, 0, 0, 0];
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [10, 20, 30, 40];
  let arr0: [2]i32x4 = [z, z];
  let z0: i32x4 = arr0[0];
  if (z0[0] != 0) { return 1; }
  if (z0[1] != 0) { return 2; }
  if (z0[2] != 0) { return 3; }
  if (z0[3] != 0) { return 4; }
  let one: [1]i32x4 = [a];
  let t: i32x4 = one[0];
  if (t[0] != 1) { return 10; }
  if (t[1] != 2) { return 20; }
  if (t[2] != 3) { return 30; }
  if (t[3] != 4) { return 40; }
  let two: [2]i32x4 = [a, b];
  let c0: i32x4 = two[0];
  if (c0[0] != 1) { return 50; }
  if (c0[1] != 2) { return 51; }
  if (c0[2] != 3) { return 52; }
  if (c0[3] != 4) { return 53; }
  return 0;
}
