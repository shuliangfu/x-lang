// See implementation.
/** Internal function `dead_helper`.
 * Implements `dead_helper`.
 * @return i32
 */
function dead_helper(): i32 {
  return 42;
}

/** Internal function `used_helper`.
 * Implements `used_helper`.
 * @return i32
 */
function used_helper(): i32 {
  return 1;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return used_helper();
}
