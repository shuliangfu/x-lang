// touch_one: see function docblock below.
/** Internal function `touch_one`.
 * Implements `touch_one`.
 * @param p *i32
 * @return void
 */
function touch_one(p: *i32): void {
  return;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let x: i32 = 0;
  touch_one(&x);
  return 0;
}
