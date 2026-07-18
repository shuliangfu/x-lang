// See implementation.
// See implementation.

// See implementation.
extern function test_default_abi(a: i32): i32;

// See implementation.
extern "X" function test_x_abi(a: i32): i32;

// C ABI
extern "C" function test_c_abi(a: i32): i32;

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return 0;
}
