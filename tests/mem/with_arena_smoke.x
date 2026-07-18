// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  with_arena(4096) {
    let x: i32 = 0;
    x
  }
  return 0;
}
