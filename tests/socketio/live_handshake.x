/**
 * See implementation.
 * See implementation.
 */
const sio = import("std.socketio");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let base: u8[32] = [104, 116, 116, 112, 58, 47, 47, 49, 50, 55, 46, 48, 46, 48, 46, 49, 58, 49, 51,
    48, 48, 49, 0];
  let sid: u8[16] = [];
  let has_ws: i32 = 0;
  let n: i32 = sio.polling_handshake(&base[0], 22, &sid[0], 16, 5000, &has_ws);
  if (n != 5) {
    return 1;
  }
  if (sid[0] != 108 || sid[4] != 49) {
    return 2;
  }
  if (has_ws != 1) {
    return 3;
  }
  return 0;
}
