/**
 * See implementation.
 */
const sio = import("std.socketio");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (sio.node_golden_smoke() != 0) {
    return 1;
  }
  if (sio.reconnect_delay_ms(0, 5000) != 1000) {
    return 2;
  }
  if (sio.reconnect_delay_ms(1, 5000) != 2000) {
    return 3;
  }
  if (sio.reconnect_delay_ms(4, 5000) != 5000) {
    return 4;
  }
  return 0;
}
