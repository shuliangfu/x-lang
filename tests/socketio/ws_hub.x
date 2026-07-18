/**
 * See implementation.
 */
const sio = import("std.socketio");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (sio.ws_hub_smoke() != 0) {
    return 1;
  }
  if (sio.ws_hub_bytes() != 200) {
    return 2;
  }
  return 0;
}
