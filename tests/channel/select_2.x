// See implementation.
const channel = import("std.channel");
const debug = import("core.debug");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let ch0: *u8 = channel.bounded(2);
  let ch1: *u8 = channel.bounded(2);
  if (ch0 == 0 || ch1 == 0) {
    return 0;
  }
  let v: i32 = 0;
  let which: i32 = 0;
  debug.assert_eq_i32(channel.select_try_recv(ch0, ch1, &v, &which), 1);
  debug.assert_eq_i32(channel.send(ch1, 42), 0);
  debug.assert_eq_i32(channel.select_try_recv(ch0, ch1, &v, &which), 0);
  debug.assert_eq_i32(which, 1);
  debug.assert_eq_i32(v, 42);
  debug.assert_eq_i32(channel.send(ch0, 11), 0);
  debug.assert_eq_i32(channel.select_recv(ch0, ch1, &v, &which), 0);
  debug.assert_eq_i32(which, 0);
  debug.assert_eq_i32(v, 11);
  channel.close(ch0);
  channel.close(ch1);
  debug.assert_eq_i32(channel.select_try_recv(ch0, ch1, &v, &which), 0 - 1);
  channel.free(ch0);
  channel.free(ch1);
  return 0;
}
