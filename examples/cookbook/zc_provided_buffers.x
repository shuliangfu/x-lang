/**
 * See implementation.
 */
const io = import("std.io");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let rc: i32 = io.register_provided(2, 1024);
  if (rc == 1) {
    io.unregister_provided();
  }
  return 0;
}
