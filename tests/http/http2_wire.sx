// STD-HTTP-H2：HTTP/2 v0 线格式烟测（preface / 帧头 / SETTINGS ACK）
const http = import("std.http");

function main(): i32 {
  if (http.smoke() != 0) { return 1; }
  if (http.preface_len() != 24) { return 2; }
  if (http.wire_is_available() == false) { return 3; }
  if (http.client_is_available() == false) { return 4; }

  // RFC 7540 §3.5 preface 前 8 字节 "PRI * HT"
  let pre8: u8[8] = [80, 82, 73, 32, 42, 32, 72, 84];
  if (http.is_connection_preface(&pre8[0], 8) == true) { return 5; }

  let ack: u8[9] = [0, 0, 0, 0, 0, 0, 0, 0, 0];
  if (http.build_settings_ack(&ack[0], 9) != 9) { return 6; }
  let ftype: i32 = 0;
  let flags: i32 = 0;
  let sid: i32 = 0;
  let plen: i32 = 0;
  if (http.parse_frame_header(&ack[0], 9, &ftype, &flags, &sid, &plen) != 0) { return 7; }
  if (ftype != http.frame_settings()) { return 8; }
  if (flags != http.flag_ack()) { return 9; }
  if (sid != 0 || plen != 0) { return 10; }

  let settings: u8[15] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  if (http.build_settings_one(http.setting_max_concurrent_streams(), 64, &settings[0], 15) != 15) {
    return 11;
  }
  ftype = 0;
  flags = 0;
  sid = 0;
  plen = 0;
  if (http.parse_frame_header(&settings[0], 9, &ftype, &flags, &sid, &plen) != 0) { return 12; }
  if (plen != 6) { return 13; }

  let alpn: u8[4] = [0, 0, 0, 0];
  if (http.write_alpn_h2(&alpn[0], 4) != http.alpn_h2_len()) { return 14; }
  if (alpn[0] != 104 || alpn[1] != 50) { return 15; }

  if (http.err_not_impl() != -1230) { return 16; }

  return 0;
}
