// STD-HTTP-H2-v20：server push ENABLE_PUSH 协商 / 软拒绝烟测
const http = import("std.http");

function main(): i32 {
  if (http.server_push_settings_smoke() != 0) { return 1; }
  if (http.setting_enable_push() != 2) { return 2; }
  if (http.err_server_push_disabled() != -1243) { return 3; }
  return 0;
}
