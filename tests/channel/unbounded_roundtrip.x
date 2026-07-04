// STD-044：无界 channel 扩容往返 + 关闭语义（Windows stub 时 skip）
const channel = import("std.channel");

function main(): i32 {
  let ch: *u8 = channel.unbounded();
  if (ch == 0 as *u8) {
    return 0;
  }
  if (channel.unbounded_is_closed(ch) != 0) {
    channel.free(ch);
    return 1;
  }
  let i: i32 = 0;
  while (i < 20) {
    if (channel.send_unbounded(ch, i) != 0) {
      channel.free(ch);
      return 2;
    }
    i = i + 1;
  }
  let sum: i32 = 0;
  let v: i32 = 0;
  let got: i32 = 0;
  while (got < 20) {
    let r: i32 = channel.try_recv_unbounded(ch, &v);
    if (r != 0) {
      channel.free(ch);
      return 3;
    }
    sum = sum + v;
    got = got + 1;
  }
  if (sum != 190) {
    channel.free(ch);
    return 4;
  }
  let e: i32 = channel.try_recv_unbounded(ch, &v);
  if (e != 1) {
    channel.free(ch);
    return 5;
  }
  channel.unbounded_close(ch);
  if (channel.unbounded_is_closed(ch) != 1) {
    channel.free(ch);
    return 6;
  }
  if (channel.send_unbounded(ch, 99) != -1) {
    channel.free(ch);
    return 7;
  }
  let c: i32 = channel.try_recv_unbounded(ch, &v);
  if (c != -1) {
    channel.free(ch);
    return 8;
  }
  channel.free(ch);
  return 0;
}
