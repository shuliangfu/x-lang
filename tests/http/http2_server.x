// See implementation.
const http = import("std.http");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (http.server_smoke() != 0) { return 1; }
  if (http.server_is_available() == false) { return 2; }
  if (http.err_server() != -1240) { return 3; }
  if (http.err_server_tls() != -1241) { return 4; }
  return 0;
}
