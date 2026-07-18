/**
 * See implementation.
 */
const sio = import("std.socketio");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (sio.cluster_sync_smoke() != 0) {
    return 1;
  }
  return 0;
}
