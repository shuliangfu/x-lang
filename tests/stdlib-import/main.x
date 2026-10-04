// See implementation.
// See implementation.
// See implementation.
// See implementation.
const types = import("core.types");
const option = import("core.option");
const result = import("core.result");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: i32 = types.placeholder();
  // See implementation.
  // See implementation.
  /* some_i32 writes through an out pointer. */
  let s: Option_i32 = { is_some: false, value: 0 };
  option.some_i32(&s, 42);
  let b: i32 = option.unwrap_or_i32(s, 0);
  let res: Result_i32 = result.ok_i32(1);
  // See implementation.
  let c: i32 = 0;
  if (result.is_ok_i32(res)) {
    c = res.value;
  }
  let _sum: i32 = a + b + c;
  return 0;
}
