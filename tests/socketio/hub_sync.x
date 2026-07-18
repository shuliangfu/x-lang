/**
 * See implementation.
 */
const sio = import("std.socketio");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (sio.hub_sync_smoke() != 0) {
    return 1;
  }
  if (sio.room_registry_snapshot_bytes() <= 0) {
    return 2;
  }
  return 0;
}
