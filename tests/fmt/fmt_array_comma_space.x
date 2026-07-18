// See implementation.
// fmt_test_dense_byte_path: see function docblock below.

/** Internal function `fmt_test_dense_byte_path`.
 * Implements `fmt_test_dense_byte_path`.
 * @return i32
 */
function fmt_test_dense_byte_path(): i32 {
  let path: u8[31] =
  [116,101,115,116,115,47,98,101,110,99,104,47,46,105,111,95,109,109,97,112,95,98,101,110,99,104,95,116,109,112,0];
  return path[0] as i32;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return fmt_test_dense_byte_path();
}
