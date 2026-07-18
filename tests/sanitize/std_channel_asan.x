// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
const channel = import("std.channel");
const debug = import("core.debug");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let ch: *u8 = channel.bounded(2);
  if (ch == 0) {
    return 0;
  }
  debug.assert_eq_i32(channel.send(ch, 10), 0);
  debug.assert_eq_i32(channel.send(ch, 20), 0);
  let v: i32 = 0;
  debug.assert_eq_i32(channel.recv(ch, &v), 0);
  debug.assert_eq_i32(v, 10);
  debug.assert_eq_i32(channel.recv(ch, &v), 0);
  debug.assert_eq_i32(v, 20);
  channel.close(ch);
  channel.free(ch);
  return 0;
}
