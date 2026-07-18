// See implementation.
// See implementation.
// See implementation.

/**
* See implementation.
*/

/* See implementation. */

const option = import("core.option");

// fmt_test_semicolon_chain: see function docblock below.

/** Internal function `fmt_test_semicolon_chain`.
 * Implements `fmt_test_semicolon_chain`.
 * @return i32
 */
function fmt_test_semicolon_chain(): i32 {
  let prefix: u8[32] = [];
  prefix[0] = 1; prefix[1] = 2; prefix[2] = 3; prefix[3] = 4; prefix[4] = 5; prefix[5] = 6;
  prefix[6] = 7; prefix[7] = 8; prefix[8] = 9; prefix[9] = 10; prefix[10] = 11; prefix[11] = 12;
  return prefix[0] + prefix[11];
}

// fmt_test_long_add: see function docblock below.
/** Internal function `fmt_test_long_add`.
 * Implements `fmt_test_long_add`.
 * @return i32
 */
function fmt_test_long_add(): i32 {
  let accumulator_name_for_fmt: i32 = 1;
  let another_long_identifier: i32 = 2;
  return accumulator_name_for_fmt + another_long_identifier;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let x: i32 = fmt_test_semicolon_chain();
  let y: i32 = fmt_test_long_add();
  return x + y;
}
