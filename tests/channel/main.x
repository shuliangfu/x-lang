// See implementation.
// send/recv、try_send/try_recv、close/free。
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
  debug.assert_eq_i32(channel.try_send(ch, 30), 1);
  let v: i32 = 0;
  debug.assert_eq_i32(channel.recv(ch, &v), 0);
  debug.assert_eq_i32(v, 10);
  debug.assert_eq_i32(channel.recv(ch, &v), 0);
  debug.assert_eq_i32(v, 20);
  debug.assert_eq_i32(channel.try_recv(ch, &v), 1);
  channel.close(ch);
  let r: i32 = channel.try_recv(ch, &v);
  debug.assert_eq_i32(r, 0 - 1);
  channel.free(ch);
  return 0;
}
