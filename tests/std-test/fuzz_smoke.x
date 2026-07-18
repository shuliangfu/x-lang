// See implementation.
const test = import("std.test");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let st: u32 = test.fuzz_seed();
  let n: u32 = test.fuzz_next(&st);
  if (n == 0) {
    return 1;
  }
  return 0;
}
