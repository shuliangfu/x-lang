// See implementation.
const http = import("std.http");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (http.conn_pool_goaway_smoke() != 0) { return 1; }
  return 0;
}
