/**
 * STD-SOCKETIO-001 烟测：集群 session 合并 v13。
 */
const sio = import("std.socketio");

function main(): i32 {
  if (sio.cluster_sync_smoke() != 0) {
    return 1;
  }
  return 0;
}
