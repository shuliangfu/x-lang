// STD-HTTP-H2-v25：PING/PONG 连接保活烟测
const http = import("std.http");

function main(): i32 {
  if (http.ping_smoke() != 0) { return 1; }
  if (http.frame_ping() != 6) { return 2; }
  if (http.err_ping() != -1245) { return 3; }
  if (http.conn_ping_smoke() != 0) { return 4; }
  return 0;
}
