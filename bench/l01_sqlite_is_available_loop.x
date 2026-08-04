/**
 * See implementation.
 */
const sqlite = import("std.db.sqlite");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let acc: i32 = 0;
  let i: i32 = 0;
  while (i < 100000) {
    acc = acc + sqlite.is_available();
    i = i + 1;
  }
  if (acc < 0) { return 1; }
  return 0;
}
