// See implementation.
const http = import("std.http");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (http.goaway_smoke() != 0) { return 1; }
  if (http.frame_goaway() != 7) { return 2; }
  if (http.err_goaway() != -1244) { return 3; }
  if (http.conn_goaway_smoke() != 0) { return 4; }
  return 0;
}
