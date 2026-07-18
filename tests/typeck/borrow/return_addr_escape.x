// leak: see function docblock below.
/** Internal function `leak`.
 * Implements `leak`.
 * @return *i32
 */
function leak(): *i32 {
  let x: i32 = 42;
  return &x;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return 0;
}
