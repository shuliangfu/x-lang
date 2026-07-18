// See implementation.
const thread = import("std.thread");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let nm: u8[9] = [115, 104, 117, 45, 109, 97, 105, 110, 0];
  if (thread.set_name_self(&nm[0], 8) != 0) {
    // See implementation.
  }
  if (thread.start(2) != 0) {
    return 0;
  }
  let i: i32 = 0;
  while (i < 8) {
    if (thread.submit(thread.dummy_entry_ptr(), 0) != 0) {
      thread.stop();
      return 1;
    }
    i = i + 1;
  }
  if (thread.drain() != 0) {
    thread.stop();
    return 2;
  }
  if (thread.pending() != 0) {
    thread.stop();
    return 3;
  }
  if (thread.stop() != 0) {
    return 4;
  }
  return 0;
}
