/**
 * STD-SOCKETIO-001 烟测：hub + room 跨进程快照同步 v11。
 */
const sio = import("std.socketio");

function main(): i32 {
  if (sio.hub_sync_smoke() != 0) {
    return 1;
  }
  if (sio.room_registry_snapshot_bytes() <= 0) {
    return 2;
  }
  return 0;
}
