// See implementation.
// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  unsafe {
    let x: i32 = 42;
    let p: *i32 = &x;
    p[0] = 1;
  }
  return 0;
}
