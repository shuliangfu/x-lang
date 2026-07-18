// foo: see function docblock below.
/** Internal function `foo`.
 * Implements `foo`.
 * @return u8[4]
 */
function foo(): u8[4] {
  return [1, 2, 3, 4];
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let e: u8 = foo()[0];
  let f: u8 = foo()[1];
  if (e != 1 || f != 2) {
    return 1;
  }
  return 0;
}
