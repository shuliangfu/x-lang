// Isolated: nested INDEX rvalue of a SIMD named element
// (`arr[0][0]` / `arr[0][1]`). `let t = arr[0]; t[0]` and `a[0]`
// are already green. Nested INDEX used emit_expr of the inner
// INDEX (rvalue deref_struct16) so rax held packed lanes, not a
// pointer; the outer i32 load then treated that value as an
// address (Darwin 174). G.7: INDEX-as-INDEX-base leaves the
// inner element address (same scaled lea as FIELD-over-INDEX).
// Does not fold nested `idv(add4)`, FIELD-as-receiver, or a
// second ARRAY_LIT of SIMD after dest (x86 slot leftover).
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail.

/**
 * Exit 0 when nested INDEX of a dest-assigned SIMD array element
 * reads every lane.
 * @return i32 — 0 ok; 1..4 nest lanes; 50 VAR lane; 51 split let
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let z: i32x4 = [0, 0, 0, 0];
  let arr: [2]i32x4 = [z, z];
  arr[0] = a;
  if (arr[0][0] != 1) { return 1; }
  if (arr[0][1] != 2) { return 2; }
  if (arr[0][2] != 3) { return 3; }
  if (arr[0][3] != 4) { return 4; }
  if (a[0] != 1) { return 50; }
  let t: i32x4 = arr[0];
  if (t[0] != 1) { return 51; }
  return 0;
}
