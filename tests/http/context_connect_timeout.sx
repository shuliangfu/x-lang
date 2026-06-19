// STD-095：map_http_c_result / request_timeout_ms_for_ctx 离线烟测（recv 超时见 http_timeout_smoke.c）
const http = import("std.http");
const context = import("std.context");
const err = import("std.error");

function main(): i32 {
  if (map_http_c_result(-1220) != http_err_timeout()) {
    return 1;
  }
  if (map_http_c_result(-1) != -1) {
    return 2;
  }
  let bg: Context = context.background();
  if (request_timeout_ms_for_ctx(bg) != 0) {
    return 3;
  }
  let cancelled: Context = context.with_cancel(bg);
  context.cancel(cancelled);
  if (request_timeout_ms_for_ctx(cancelled) != http_err_cancelled()) {
    context.free(cancelled);
    return 4;
  }
  context.free(cancelled);
  return 0;
}
