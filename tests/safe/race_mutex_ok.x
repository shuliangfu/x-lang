// See implementation.
const sync = import("std.sync");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let m: *u8 = sync.new_mutex();
  if (m == 0) { return 1; }
  let sum: i32 = 0;
  let i: i32 = 0;
  while (i < 100) {
    if (sync.lock(m) != 0) { sync.free_mutex(m); return 2; }
    sum = sum + 1;
    if (sync.unlock(m) != 0) { sync.free_mutex(m); return 3; }
    i = i + 1;
  }
  sync.free_mutex(m);
  if (sum != 100) { return 4; }
  return 0;
}
