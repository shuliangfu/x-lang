/**
 * STD-SOCKETIO-001 烟测：WS hub v9（sid 持久 + 多路复用 server emit）。
 */
const sio = import("std.socketio");

function main(): i32 {
  if (sio.ws_hub_smoke() != 0) {
    return 1;
  }
  if (sio.ws_hub_bytes() != 200) {
    return 2;
  }
  return 0;
}
