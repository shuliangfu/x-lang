// STD-108：std.channel 双向混合 select 烟测（recv+send；Windows stub 时 skip）
const channel = import("std.channel");
const debug = import("core.debug");

function main(): i32 {
  let recv_ch: *u8 = channel.bounded(2);
  let send_ch: *u8 = channel.bounded(1);
  if (recv_ch == 0 || send_ch == 0) {
    return 0;
  }
  let v: i32 = 0;
  let is_send: i32 = 0;
  debug.assert_eq_i32(channel.send(send_ch, 999), 0);
  debug.assert_eq_i32(channel.select_try_mixed(recv_ch, send_ch, 88, &v, &is_send), 1);
  debug.assert_eq_i32(channel.send(recv_ch, 77), 0);
  debug.assert_eq_i32(channel.select_try_mixed(recv_ch, send_ch, 88, &v, &is_send), 0);
  debug.assert_eq_i32(is_send, 0);
  debug.assert_eq_i32(v, 77);
  debug.assert_eq_i32(channel.recv(send_ch, &v), 0);
  debug.assert_eq_i32(v, 999);
  debug.assert_eq_i32(channel.select_try_mixed(recv_ch, send_ch, 88, &v, &is_send), 0);
  debug.assert_eq_i32(is_send, 1);
  debug.assert_eq_i32(channel.recv(send_ch, &v), 0);
  debug.assert_eq_i32(v, 88);
  debug.assert_eq_i32(channel.send(recv_ch, 55), 0);
  debug.assert_eq_i32(channel.select_mixed(recv_ch, send_ch, 66, &v, &is_send), 0);
  debug.assert_eq_i32(is_send, 0);
  debug.assert_eq_i32(v, 55);
  channel.close(recv_ch);
  channel.close(send_ch);
  channel.free(recv_ch);
  channel.free(send_ch);
  return 0;
}
