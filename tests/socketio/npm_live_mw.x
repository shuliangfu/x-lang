/**
 * STD-SOCKETIO-001 npm mw live：WS 直连 /chat → auth → mw_ping/mw_pong（中间件 gate）。
 */
const sio = import("std.socketio");

function main(): i32 {
  let base: u8[32] = [104, 116, 116, 112, 58, 47, 47, 49, 50, 55, 46, 48, 46, 48, 46, 49, 58, 49, 51,
    48, 48, 53, 0];
  let ns_chat: u8[8] = [47, 99, 104, 97, 116, 0];
  let tok: u8[8] = [115, 104, 117, 120, 0];
  let ev_mw: u8[16] = [109, 119, 95, 112, 105, 110, 103, 0];
  let url: u8[128] = [];
  let out_ev: u8[16] = [];
  let out_data: u8[16] = [];
  let dlen: i32 = 0;
  if (sio.client_ws_fresh_ns_mw_roundtrip(&base[0], 22, &ns_chat[0], 5, &tok[0], 4, &ev_mw[0], 7,
    &url[0], 128, &out_ev[0], 16, &out_data[0], 16, &dlen, 10000) != 0) {
    return 3;
  }
  if (out_ev[0] != 109 || dlen != 2 || out_data[0] != 111) {
    return 4;
  }
  return 0;
}
