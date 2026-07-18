// See implementation.
const option = import("core.option");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let o1: Option_i32 = option.or_i32(option.none_i32(), option.some_i32(99));
  if (option.expect_i32(o1) != 99) {
    return -3;
  }
  return 0;
}
