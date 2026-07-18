/**
 * See implementation.
 */
const sqlite = import("std.db.sqlite");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let av: i32 = sqlite.is_available();
  if (av != 0 && av != 1) { return 1; }
  return 0;
}
