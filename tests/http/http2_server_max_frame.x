// See implementation.
const http = import("std.http");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (http.frame_capped_smoke() != 0) { return 1; }
  if (http.server_max_frame_smoke() != 0) { return 2; }
  if (http.frame_count_data_chunks(20000, 16384) != 2) { return 3; }
  return 0;
}
