// Regression: fmt.println(i32[]) must use JSON schema A@ (fat slice), not u8_slc mid.
// u8[] stays raw mid; fixed i32[N] stays a@ schema. Empty print was product fake-green.
const fmt = import("std.fmt");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32 — 0 on success
 */
function main(): i32 {
  let arr: i32[3] = [10, 20, 30];
  let s: i32[] = arr;
  let n: i32 = fmt.println(s);
  if (n != 0) { return 1; }
  let lit: i32[] = [1, 2, 3];
  let m: i32 = fmt.println(lit);
  if (m != 0) { return 2; }
  return 0;
}
