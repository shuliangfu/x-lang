// See implementation.
//
// See implementation.
// See implementation.
const io = import("std.io");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  if (io.stdin() != 0) { return 1; }
  // case 2
  if (io.stdout() != 1) { return 2; }
  // case 3
  if (io.stderr() != 2) { return 3; }
  // See implementation.
  let h: usize = io.from_fd(7, 0);
  if (h != 7) { return 4; }
  // See implementation.
  let empty: u8[1] = [0];
  let z: i32 = io.write_stdout(&empty[0], 0);
  if (z != 0) { return 5; }
  // See implementation.
  let one: u8[1] = [65];
  if (io.write(&one[0], 1, 1000) != 1) { return 6; }
  // See implementation.
  if (io.write_stderr(&empty[0], 0) != 0) { return 7; }
  // See implementation.
  if (io.print(&empty[0], 0) != 0) { return 8; }
  // See implementation.
  let zr: i32 = io.read(io.stdin(), &empty[0], 0, 0);
  if (zr < 0) { return 9; }
  return 0;
}
