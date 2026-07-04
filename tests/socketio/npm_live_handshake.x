/**
 * STD-SOCKETIO-001 npm live：polling 握手 + /chat namespace CONNECT POST。
 */
const sio = import("std.socketio");

function main(): i32 {
  let base: u8[32] = [104, 116, 116, 112, 58, 47, 47, 49, 50, 55, 46, 48, 46, 48, 46, 49, 58, 49, 51,
    48, 48, 50, 0];
  let sid: u8[32] = [];
  let has_ws: i32 = 0;
  let n: i32 = sio.polling_handshake(&base[0], 22, &sid[0], 32, 8000, &has_ws);
  if (n <= 0) {
    return 1;
  }
  if (has_ws != 1) {
    return 2;
  }

  let ns_chat: u8[8] = [47, 99, 104, 97, 116, 0];
  let pkt: u8[16] = [];
  let pn: i32 = sio.encode_connect_ns_packet(&ns_chat[0], 5, &pkt[0], 16);
  if (pn <= 0) {
    return 3;
  }

  let ns_out: u8[24] = [];
  if (sio.parse_connect_ns(&pkt[0], pn, &ns_out[0], 24) != 5) {
    return 4;
  }

  let resp: u8[512] = [];
  let rn: i32 = sio.polling_post_packet(&base[0], 22, &sid[0], n, &pkt[0], pn, &resp[0], 512, 8000);
  if (rn <= 0) {
    return 5;
  }

  return 0;
}
