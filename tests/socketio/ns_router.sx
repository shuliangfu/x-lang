/**
 * STD-SOCKETIO-001 烟测：多 namespace 路由 v7。
 */
const sio = import("std.socketio");

function main(): i32 {
  if (sio.ns_router_smoke() != 0) {
    return 1;
  }

  if (sio.ns_router_bytes() != 132) {
    return 2;
  }

  let ns_chat: u8[8] = [47, 99, 104, 97, 116, 0];
  let pkt: u8[16] = [];
  let n: i32 = sio.encode_connect_ns_packet(&ns_chat[0], 5, &pkt[0], 16);
  if (n <= 0) {
    return 3;
  }

  let ns_out: u8[24] = [];
  if (sio.parse_connect_ns(&pkt[0], n, &ns_out[0], 24) != 5) {
    return 4;
  }
  if (ns_out[1] != 99) {
    return 5;
  }

  return 0;
}
