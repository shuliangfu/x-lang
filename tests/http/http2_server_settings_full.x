// See implementation.
const http = import("std.http");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (http.server_settings_full_smoke() != 0) { return 1; }
  if (http.setting_header_table_size() != 1) { return 2; }
  if (http.setting_max_frame_size() != 5) { return 3; }
  if (http.settings_smoke() != 0) { return 4; }
  return 0;
}
