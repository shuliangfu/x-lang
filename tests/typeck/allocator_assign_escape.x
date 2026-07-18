// See implementation.
// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let v: i32 = 0;
  with_arena(4096) {
    v = 1;
  }
  return v;
}
