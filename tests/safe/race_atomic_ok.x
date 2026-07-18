// See implementation.
const atomic = import("std.atomic");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let counter: i32 = 0;
  let i: i32 = 0;
  while (i < 200) {
    let _prev: i32 = atomic.fetch_add(&counter, 1);
    i = i + 1;
  }
  if (atomic.load(&counter) != 200) { return 1; }
  return 0;
}
