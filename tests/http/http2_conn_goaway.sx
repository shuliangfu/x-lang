// STD-HTTP-H2-v24：GOAWAY 连接优雅关闭烟测
const http = import("std.http");

function main(): i32 {
  if (http.goaway_smoke() != 0) { return 1; }
  if (http.frame_goaway() != 7) { return 2; }
  if (http.err_goaway() != -1244) { return 3; }
  if (http.conn_goaway_smoke() != 0) { return 4; }
  return 0;
}
