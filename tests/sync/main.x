// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
const sync = import("std.sync");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  let m: *u8 = sync.new_mutex();
  if (m == 0) {
    return 1;
  }
  // See implementation.
  if (sync.lock(m) != 0) {
    sync.free_mutex(m);
    return 2;
  }
  // See implementation.
  // See implementation.
  // See implementation.
  // See implementation.
  if (sync.unlock(m) != 0) {
    sync.free_mutex(m);
    return 3;
  }
  // See implementation.
  if (sync.try_lock(m) != 0) {
    sync.free_mutex(m);
    return 4;
  }
  if (sync.unlock(m) != 0) {
    sync.free_mutex(m);
    return 5;
  }
  sync.free_mutex(m);
  return 0;
}
