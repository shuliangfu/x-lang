/**
 * STD-SOCKETIO-001 烟测：room 广播 + hub 快照 v10。
 */
const sio = import("std.socketio");

function main(): i32 {
  if (sio.room_smoke() != 0) {
    return 1;
  }
  if (sio.room_registry_bytes() != 196) {
    return 2;
  }
  if (sio.ws_hub_snapshot_bytes() <= 0) {
    return 3;
  }
  return 0;
}
