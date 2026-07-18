/**
 * Cookbook TIME-02：std.time Timer elapsed / reset（STD-133）。
 */
const time = import("std.time");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let t: Timer = time.start();
  let ns: i64 = time.elapsed_ns(t);
  if (ns < 0) { return 1; }
  time.reset(&t);
  if (time.elapsed_ns(t) < 0) { return 2; }
  return 0;
}
