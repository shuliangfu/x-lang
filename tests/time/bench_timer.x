// See implementation.
//
// See implementation.
// See implementation.
const time = import("std.time");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let t: time.Timer = time.start();
  // See implementation.
  time.sleep_ms(100);
  let ns: i64 = 0;
  ns = time.elapsed_ns(t);
  if (ns < 5000000) { return 1; }
  let ms: i64 = 0;
  ms = time.elapsed_ms(t);
  if (ms < 5) { return 2; }
  let us: i64 = 0;
  us = time.elapsed_us(t);
  if (us < 5000) { return 3; }
  let sec: i64 = 0;
  sec = time.elapsed_sec(t);
  if (sec < 0) { return 4; }

  time.reset(&t);
  time.sleep_ms(60);
  let after_reset: i64 = 0;
  after_reset = time.elapsed_ns(t);
  if (after_reset < 3000000) { return 5; }
  /* See implementation. */

  time.reset(&t);
  time.sleep_ms(40);
  let lap1: i64 = 0;
  lap1 = time.lap_ns(&t);
  if (lap1 < 3000000) { return 7; }
  time.sleep_ms(40);
  let lap2: i64 = 0;
  lap2 = time.lap_ns(&t);
  if (lap2 < 3000000) { return 8; }
  let tail: i64 = 0;
  tail = time.elapsed_ns(t);
  if (tail < 0) { return 9; }
  return 0;
}
