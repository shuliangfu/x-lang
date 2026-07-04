// STD-HTTP-H2-v27：HTTP/2 v1 收口烟测（RST + 全局池 GOAWAY）
const http = import("std.http");

function main(): i32 {
  if (http.rst_stream_smoke() != 0) { return 1; }
  if (http.frame_rst_stream() != 3) { return 2; }
  if (http.err_rst_stream() != -1246) { return 3; }
  if (http.complete_smoke() != 0) { return 4; }
  return 0;
}
