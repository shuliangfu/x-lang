// See implementation.
// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let i64_min: i64 = 0 - 9223372036854775807 - 1;
  let zero: i64 = 0;
  if (zero == i64_min) {
    return 1;
  }
  return 42;
}
