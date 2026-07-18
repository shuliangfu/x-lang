// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
const time = import("std.time");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let t0: i64 = 0;
  t0 = time.now_monotonic_ns();
  time.sleep_ms(50);
  let t1: i64 = 0;
  t1 = time.now_monotonic_ns();
  let elapsed_ns: i64 = 0;
  elapsed_ns = time.duration_ns(t0, t1);
  if (elapsed_ns < 10000000) {
    return 2;
  }
  return 0;
}
