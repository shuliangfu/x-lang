// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let max: u32 = 4294967295;
  let wrapped: u32 = max + 1;
  if (wrapped != 0) {
    return 1;
  }
  return 42;
}
