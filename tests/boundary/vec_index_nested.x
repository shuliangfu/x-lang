// Isolated: nested INDEX rvalue of a SIMD named element
// (`arr[0][0]` / `arr[0][1]`). `let t = arr[0]; t[0]` and `a[0]`
// are already green. Nested INDEX used emit_expr of the inner
// INDEX (rvalue deref_struct16) so rax held packed lanes, not a
// pointer; the outer i32 load then treated that value as an
// address (Darwin 174). G.7: INDEX-as-INDEX-base leaves the
// inner element address (same scaled lea as FIELD-over-INDEX).
// Does not fold nested `idv(add4)` or FIELD-as-receiver.
// Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail.

/**
 * Exit 0 when nested INDEX of a SIMD array element reads every lane.
 * @return i32 — 0 ok; 1..4 dest-assign nest; 10..40 ctor nest; 50 VAR lane
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
  let one: [1]i32x4 = [a];
  if (one[0][0] != 1) { return 10; }
  if (one[0][1] != 2) { return 20; }
  if (one[0][2] != 3) { return 30; }
  if (one[0][3] != 4) { return 40; }
  if (a[0] != 1) { return 50; }
  let t: i32x4 = arr[0];
  if (t[0] != 1) { return 51; }
  return 0;
}
