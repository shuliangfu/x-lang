/**
 * STD-031 烟测：WebSocket Accept 金样 + TEXT 帧 round-trip + 握手缓冲校验。
 */
const ws = import("std.websocket");

function main(): i32 {
  // RFC 6455 金样：dGhlIHNhbXBsZSBub25jZQ== → s3pPLMBiTxaQ9kYGzzhZRbK+xOo=
  let key: u8[25] = [100, 71, 104, 108, 73, 72, 78, 104, 98, 88, 66, 115, 90, 83, 66, 117, 98, 50, 53, 106, 90, 81, 61, 61, 0];
  let accept: u8[32] = [];
  let key_len: i32 = 24;
  let n_acc: i32 = ws.ws_compute_accept(&key[0], key_len, &accept[0], 32);
  if (n_acc != 28) { return 1; }
  if (accept[0] != 115 || accept[1] != 51 || accept[27] != 61) { return 2; }

  // TEXT 帧 round-trip："hello"
  let payload: u8[5] = [104, 101, 108, 108, 111];
  let frame: u8[16] = [];
  let frame_len: i32 = ws.ws_encode_text_frame(&payload[0], 5, &frame[0], 16);
  if (frame_len != 11) { return 3; }
  let opcode: i32 = 0;
  let decoded: u8[8] = [];
  let dec_len: i32 = 0;
  if (ws.ws_decode_frame(&frame[0], frame_len, &opcode, &decoded[0], 8, &dec_len) != 0) { return 4; }
  if (opcode != 1) { return 5; }
  if (dec_len != 5) { return 6; }
  if (decoded[0] != 104 || decoded[4] != 111) { return 7; }

  // BINARY 帧 round-trip：{0x00, 0xFF, 0x42}
  let bin_pl: u8[3] = [0, 255, 66];
  let bin_frame: u8[12] = [];
  let bin_len: i32 = ws.ws_encode_binary_frame(&bin_pl[0], 3, &bin_frame[0], 12);
  if (bin_len != 9) { return 34; }
  opcode = 0;
  dec_len = 0;
  if (ws.ws_decode_frame(&bin_frame[0], bin_len, &opcode, &decoded[0], 8, &dec_len) != 0) { return 35; }
  if (opcode != ws.ws_opcode_binary() || dec_len != 3) { return 36; }
  if (decoded[0] != 0 || decoded[1] != 255 || decoded[2] != 66) { return 37; }

  // 服务端 BINARY 帧（无 MASK）
  let srv_bin: u8[2] = [1, 2];
  let srv_bin_frame: u8[6] = [];
  let srv_bin_len: i32 = ws.ws_encode_server_binary_frame(&srv_bin[0], 2, &srv_bin_frame[0], 6);
  if (srv_bin_len != 4) { return 38; }
  if (srv_bin_frame[0] != 0x82 || srv_bin_frame[1] != 2) { return 39; }
  opcode = 0;
  dec_len = 0;
  if (ws.ws_decode_frame(&srv_bin_frame[0], srv_bin_len, &opcode, &decoded[0], 8, &dec_len) != 0) { return 40; }
  if (opcode != ws.ws_opcode_binary() || dec_len != 2 || decoded[0] != 1) { return 41; }

  // 握手请求缓冲
  let host: u8[10] = [108, 111, 99, 97, 108, 104, 111, 115, 116, 0];
  let path: u8[4] = [47, 119, 115, 0];
  let req: u8[256] = [];
  let req_len: i32 = ws.ws_build_handshake_request(&host[0], &path[0], &key[0], &req[0], 256);
  if (req_len < 40) { return 8; }
  if (req[0] != 71) { return 9; }

  // 模拟 101 响应（86 字节有效载荷）
  let resp: u8[96] = [72, 84, 84, 80, 47, 49, 46, 49, 32, 49, 48, 49, 32, 83, 119, 105, 116, 99, 104, 105, 110, 103, 32, 80, 114, 111, 116, 111, 99, 111, 108, 115, 13, 10, 83, 101, 99, 45, 87, 101, 98, 83, 111, 99, 107, 101, 116, 45, 65, 99, 99, 101, 112, 116, 58, 32, 115, 51, 112, 80, 76, 77, 66, 105, 84, 120, 97, 81, 57, 107, 89, 71, 122, 122, 104, 90, 82, 98, 75, 43, 120, 79, 111, 61, 13, 10, 13, 10];
  if (ws.ws_validate_handshake_response(&resp[0], 88, &key[0], key_len) != 0) { return 10; }

  // PING 空负载 → decode opcode=9
  let empty: u8[1] = [0];
  let ping_frame: u8[8] = [];
  let ping_len: i32 = ws.ws_encode_ping_frame(&empty[0], 0, &ping_frame[0], 8);
  if (ping_len != 6) { return 11; }
  opcode = 0;
  dec_len = 0;
  if (ws.ws_decode_frame(&ping_frame[0], ping_len, &opcode, &decoded[0], 8, &dec_len) != 0) { return 12; }
  if (opcode != ws.ws_opcode_ping() || dec_len != 0) { return 13; }

  // PING "hi" → PONG echo round-trip
  let ping_pl: u8[2] = [104, 105];
  ping_len = ws.ws_encode_ping_frame(&ping_pl[0], 2, &ping_frame[0], 8);
  if (ping_len != 8) { return 14; }
  if (ws.ws_decode_frame(&ping_frame[0], ping_len, &opcode, &decoded[0], 8, &dec_len) != 0) { return 15; }
  if (opcode != ws.ws_opcode_ping() || dec_len != 2) { return 16; }
  let pong_frame: u8[8] = [];
  let pong_len: i32 = ws.ws_encode_pong_frame(&decoded[0], dec_len, &pong_frame[0], 8);
  if (pong_len != 8) { return 17; }
  if (ws.ws_decode_frame(&pong_frame[0], pong_len, &opcode, &decoded[0], 8, &dec_len) != 0) { return 18; }
  if (opcode != ws.ws_opcode_pong() || dec_len != 2 || decoded[0] != 104) { return 19; }

  // CLOSE status=1000（正常关闭）
  let close_frame: u8[12] = [];
  let close_len: i32 = ws.ws_encode_close_frame(1000, &empty[0], 0, &close_frame[0], 12);
  if (close_len != 8) { return 20; }
  if (ws.ws_decode_frame(&close_frame[0], close_len, &opcode, &decoded[0], 8, &dec_len) != 0) { return 21; }
  if (opcode != ws.ws_opcode_close() || dec_len != 2) { return 22; }
  if (decoded[0] != 3 || decoded[1] != 232) { return 23; }

  if (ws.ws_client_handshake_smoke() != 0) {
    return 24;
  }
  if (ws.ws_parse_url_smoke() != 0) {
    return 25;
  }

  // 服务端 Upgrade 请求校验 + Key 提取
  let srv_req: u8[160] = [71, 69, 84, 32, 47, 119, 115, 32, 72, 84, 84, 80, 47, 49, 46, 49, 13, 10, 72, 111, 115, 116, 58, 32, 108, 111, 99, 97, 108, 104, 111, 115, 116, 13, 10, 85, 112, 103, 114, 97, 100, 101, 58, 32, 119, 101, 98, 115, 111, 99, 107, 101, 116, 13, 10, 67, 111, 110, 110, 101, 99, 116, 105, 111, 110, 58, 32, 85, 112, 103, 114, 97, 100, 101, 13, 10, 83, 101, 99, 45, 87, 101, 98, 83, 111, 99, 107, 101, 116, 45, 75, 101, 121, 58, 32, 100, 71, 104, 108, 73, 72, 78, 104, 98, 88, 66, 115, 90, 83, 66, 117, 98, 50, 53, 106, 90, 81, 61, 61, 13, 10, 83, 101, 99, 45, 87, 101, 98, 83, 111, 99, 107, 101, 116, 45, 86, 101, 114, 115, 105, 111, 110, 58, 32, 49, 51, 13, 10, 13, 10];
  let srv_req_len: i32 = 156;
  if (ws.ws_validate_upgrade_request(&srv_req[0], srv_req_len) != 0) { return 26; }
  let extracted: u8[28] = [];
  let ext_len: i32 = ws.ws_extract_key_from_request(&srv_req[0], srv_req_len, &extracted[0], 28);
  if (ext_len != 24) { return 27; }
  if (extracted[0] != 100 || extracted[23] != 61) { return 28; }

  // 服务端 TEXT 帧（无 MASK）round-trip
  let srv_payload: u8[5] = [104, 101, 108, 108, 111];
  let srv_frame: u8[8] = [];
  let srv_frame_len: i32 = ws.ws_encode_server_text_frame(&srv_payload[0], 5, &srv_frame[0], 8);
  if (srv_frame_len != 7) { return 29; }
  if (srv_frame[0] != 0x81 || srv_frame[1] != 5) { return 30; }
  opcode = 0;
  dec_len = 0;
  if (ws.ws_decode_frame(&srv_frame[0], srv_frame_len, &opcode, &decoded[0], 8, &dec_len) != 0) { return 31; }
  if (opcode != 1 || dec_len != 5) { return 32; }

  if (ws.ws_server_accept_smoke() != 0) {
    return 33;
  }

  return 0;
}
