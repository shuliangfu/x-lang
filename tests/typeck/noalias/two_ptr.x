// touch_two: see function docblock below.
/** Internal function `touch_two`.
 * Implements `touch_two`.
 * @param a *i32
 * @param b *i32
 * @return void
 */
function touch_two(a: *i32, b: *i32): void {
  return;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let x: i32 = 0;
  let y: i32 = 0;
  touch_two(&x, &y);
  return 0;
}
