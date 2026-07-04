/**
 * Cookbook ASYNC-03：channel 有界发送接收（async 生态配套）。
 */
const channel = import("std.channel");

function main(): i32 {
  let ch: *u8 = channel.bounded(2);
  if (ch == 0 as *u8) { return 0; }
  if (channel.send(ch, 42) != 0) { return 1; }
  let v: i32 = 0;
  if (channel.recv(ch, &v) != 0) { return 2; }
  if (v != 42) { return 3; }
  channel.close(ch);
  channel.free(ch);
  return 0;
}
