// See implementation.
const http = import("std.http");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (http.server_push_tls_smoke() != 0) { return 1; }
  if (http.server_push_is_available() == false) { return 2; }
  if (http.err_server_push() != -1242) { return 3; }
  return 0;
}
