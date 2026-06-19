/**
 * STD-SOCKETIO-001 烟测：cluster ring SIOA 快照同步 v15。
 */
const sio = import("std.socketio");

function main(): i32 {
  if (sio.cluster_ring_sync_smoke() != 0) {
    return 1;
  }
  if (sio.cluster_adapter_snapshot_bytes() <= 0) {
    return 2;
  }
  return 0;
}
