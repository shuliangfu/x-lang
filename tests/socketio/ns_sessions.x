/**
 * STD-SOCKETIO-001 烟测：多 namespace 并发会话 v8。
 */
const sio = import("std.socketio");

function main(): i32 {
  if (sio.ns_sessions_smoke() != 0) {
    return 1;
  }
  if (sio.ns_sessions_bytes() != 36) {
    return 2;
  }
  return 0;
}
