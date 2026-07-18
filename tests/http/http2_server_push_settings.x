// See implementation.
const http = import("std.http");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (http.server_push_settings_smoke() != 0) { return 1; }
  if (http.setting_enable_push() != 2) { return 2; }
  if (http.err_server_push_disabled() != -1243) { return 3; }
  return 0;
}
