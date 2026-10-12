// See implementation.
const option = import("core.option");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /* none_i32 and some_i32 write through an out pointer. or_i32 still returns Option_i32. */
  let n: Option_i32 = { is_some: false, value: 0 };
  let s: Option_i32 = { is_some: false, value: 0 };
  option.none_i32(&n);
  option.some_i32(&s, 99);
  let o1: Option_i32 = option.or_i32(n, s);
  if (option.expect_i32(o1) != 99) {
    return -3;
  }
  return 0;
}
