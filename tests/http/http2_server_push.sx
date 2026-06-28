// STD-HTTP-H2-v17：h2c server push 响应烟测（离线 + C fork 集成）
const http = import("std.http");

function main(): i32 {
  if (http.server_push_smoke() != 0) { return 1; }
  if (http.server_push_is_available() == false) { return 2; }
  if (http.err_server_push() != -1242) { return 3; }
  return 0;
}
