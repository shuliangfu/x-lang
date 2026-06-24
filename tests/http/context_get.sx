// STD-094：std.http get_ctx/post_ctx/head_ctx + Context 烟测（离线，不依赖真实网络）
const http = import("std.http");
const context = import("std.context");
const err = import("std.error");

function main(): i32 {
  let bg: Context = context.background();
  // "http://x/" — 仅用于参数占位，取消/过期路径不会真正建连
  let url: u8[11] = [104, 116, 116, 112, 58, 47, 47, 120, 47, 0, 0];
  let buf: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let body: u8[1] = [0];

  let cancelled: Context = context.with_cancel(bg);
  context.cancel(cancelled);
  if (get_ctx(&url[0], 10, &buf[0], 8, cancelled) != http_err_cancelled()) {
    return 1;
  }
  if (post_ctx(&url[0], 10, &body[0], 0, &buf[0], 8, cancelled) != http_err_cancelled()) {
    return 2;
  }
  if (head_ctx(&url[0], 10, &buf[0], 8, cancelled) != http_err_cancelled()) {
    return 3;
  }

  let expired: Context = context.with_deadline(bg, 1);
  if (get_ctx(&url[0], 10, &buf[0], 8, expired) != http_err_timeout()) {
    return 4;
  }
  if (post_ctx(&url[0], 10, &body[0], 0, &buf[0], 8, expired) != http_err_timeout()) {
    return 5;
  }
  if (head_ctx(&url[0], 10, &buf[0], 8, expired) != http_err_timeout()) {
    return 6;
  }

  if (timeout_ms_for_http(bg) != 0) {
    return 7;
  }
  if (ctx_check_for_http(bg) != 0) {
    return 8;
  }

  context.free(cancelled);
  context.free(expired);
  return 0;
}
