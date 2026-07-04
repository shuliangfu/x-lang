// STD-HTTP-H2-v6：接收侧流控 + server push + h2c 升级识别烟测（离线）
const http = import("std.http");

function main(): i32 {
  if (http.flow_recv_smoke() != 0) { return 1; }
  if (http.push_h2c_smoke() != 0) { return 2; }
  if (http.push_fetch_smoke() != 0) { return 14; }
  if (http.err_push_not_impl() != -1233) { return 3; }
  if (http.err_h2c_not_impl() != -1234) { return 4; }
  if (http.h2c_is_available() == false) { return 15; }
  if (http.h2c_wire_is_available() == false) { return 15; }

  let preface: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  if (http.h2c_session_begin(&preface[0], 32) != 24) { return 16; }
  if (http.is_connection_preface(&preface[0], 24) == false) { return 17; }

  let recv: Http2FlowRecvState = Http2FlowRecvState { conn_left: 0, stream_left: 0 };
  http.flow_recv_init(&recv);
  if (recv.conn_left != 65535) { return 6; }
  if (http.flow_recv_on_data(&recv, 1000) != 0) { return 7; }
  if (recv.conn_left != 64535) { return 8; }

  let wu: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  if (http.flow_recv_release(&recv, 1, 1000, &wu[0], 16) != 13) { return 9; }

  if (http.is_push_promise_frame(http.frame_push_promise()) == false) { return 10; }

  let upgrade: u8[64] = [72, 84, 84, 80, 47, 49, 46, 49, 32, 49, 48, 49, 32, 83, 119, 105,
    116, 99, 104, 105, 110, 103, 32, 80, 114, 111, 116, 111, 99, 111, 108, 115, 13, 10,
    85, 112, 103, 114, 97, 100, 101, 58, 32, 104, 50, 99, 13, 10, 13, 10];
  if (http.is_h2c_upgrade_response(&upgrade[0], 46) == false) { return 11; }

  let pp: u8[4] = [0, 0, 0, 8];
  let promised: i32 = 0;
  if (http.parse_push_promise_stream(&pp[0], 4, &promised) != 0) { return 12; }
  if (promised != 8) { return 13; }

  return 0;
}
