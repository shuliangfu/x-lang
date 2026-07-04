/**
 * STD-SOCKETIO-001 烟测：session 一体快照 + register_or_rebind v12。
 */
const sio = import("std.socketio");

function main(): i32 {
  if (sio.session_sync_smoke() != 0) {
    return 1;
  }
  if (sio.session_bundle_bytes() <= 0) {
    return 2;
  }
  return 0;
}
