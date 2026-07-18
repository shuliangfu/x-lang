// See implementation.
const slice = import("core.slice");
const option = import("core.option");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: i32[2] = [10, 20];
  let s: i32[] = a;
  let o: Option_i32 = slice.get_i32(s, 0);
  if (!o.is_some) {
    return 1;
  }
  if (o.value != 10) {
    return 2;
  }
  return 0;
}
