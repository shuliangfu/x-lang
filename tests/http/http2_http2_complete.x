// See implementation.
const http = import("std.http");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (http.rst_stream_smoke() != 0) { return 1; }
  if (http.frame_rst_stream() != 3) { return 2; }
  if (http.err_rst_stream() != -1246) { return 3; }
  if (http.complete_smoke() != 0) { return 4; }
  return 0;
}
