// STD-108：std.channel N 路混合 select 烟测（recv/recv/send；Windows stub 时 skip）
const channel = import("std.channel");
const debug = import("core.debug");

function main(): i32 {
  let ch0: *u8 = channel.bounded(2);
  let ch1: *u8 = channel.bounded(2);
  let ch2: *u8 = channel.bounded(1);
  if (ch0 == 0 || ch1 == 0 || ch2 == 0) {
    return 0;
  }
  let slots: i64[4] = [];
  let dirs: i32[4] = [];
  channel.select_chs_set(&slots[0], 0, ch0);
  channel.select_dirs_set(&dirs[0], 0, 0);
  channel.select_chs_set(&slots[0], 1, ch1);
  channel.select_dirs_set(&dirs[0], 1, 0);
  channel.select_chs_set(&slots[0], 2, ch2);
  channel.select_dirs_set(&dirs[0], 2, 1);
  let v: i32 = 0;
  let which: i32 = 0;
  let is_send: i32 = 0;
  debug.assert_eq_i32(channel.send(ch2, 111), 0);
  debug.assert_eq_i32(channel.select_try_mixed_n(&slots[0], &dirs[0], 3, 99, &v, &which, &is_send), 1);
  debug.assert_eq_i32(channel.send(ch1, 42), 0);
  debug.assert_eq_i32(channel.select_try_mixed_n(&slots[0], &dirs[0], 3, 99, &v, &which, &is_send), 0);
  debug.assert_eq_i32(is_send, 0);
  debug.assert_eq_i32(which, 1);
  debug.assert_eq_i32(v, 42);
  debug.assert_eq_i32(channel.recv(ch2, &v), 0);
  debug.assert_eq_i32(v, 111);
  debug.assert_eq_i32(channel.select_try_mixed_n(&slots[0], &dirs[0], 3, 99, &v, &which, &is_send), 0);
  debug.assert_eq_i32(is_send, 1);
  debug.assert_eq_i32(which, 2);
  debug.assert_eq_i32(channel.recv(ch2, &v), 0);
  debug.assert_eq_i32(v, 99);
  channel.close(ch0);
  channel.close(ch1);
  channel.close(ch2);
  channel.free(ch0);
  channel.free(ch1);
  channel.free(ch2);
  return 0;
}
