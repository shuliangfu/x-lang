// Vector add correctness without std.string memcmp (MG: string.o ensure
// may not cold-build; component equality is the product semantic).
/**
 * Internal function `main`.
 * Program/test entry point.
 * @return i32 — 0 if a+b matches expect lane-wise; 1 on mismatch
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [10, 20, 30, 40];
  let c: i32x4 = a + b;
  let expect: i32x4 = [11, 22, 33, 44];
  if (c[0] != expect[0]) {
    return 1;
  }
  if (c[1] != expect[1]) {
    return 1;
  }
  if (c[2] != expect[2]) {
    return 1;
  }
  if (c[3] != expect[3]) {
    return 1;
  }
  return 0;
}
