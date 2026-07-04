// STD-151：std.ffi 结构体 pack/unpack 与 i32 回调烟测
const ffi = import("std.ffi");

function main(): i32 {
  let buf: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  if (point_pack(&buf[0], 8, 3, 4) != 0) { return 1; }
  let pt: FfiPoint = FfiPoint { x: 0, y: 0 };
  if (point_unpack(&buf[0], 8, &pt) != 0) { return 2; }
  if (pt.x != 3 || pt.y != 4) { return 3; }
  if (point_pack(&buf[0], 4, 0, 0) != (0 - 4)) { return 4; }

  let cb: usize = cb_double_fn();
  if (invoke_cb(cb, 5) != 10) { return 5; }
  if (invoke_cb(0, 1) != (0 - 1)) { return 6; }
  return 0;
}
