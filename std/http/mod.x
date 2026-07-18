// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Full text: LICENSE.Apache-2.0

// See implementation.
//
// See implementation.
// See implementation.
const context = import("std.context");
const err = import("std.error");
const heap = import("std.heap");

/**
 * See implementation.
 * GET=0, POST=1, HEAD=2, PUT=3, DELETE=4, PATCH=5, OPTIONS=6。
 */
export enum Method {
  GET,
  POST,
  HEAD,
  PUT,
  DELETE,
  PATCH,
  OPTIONS
}

/** Exported function `method`.
 * Implements `method`.
 * @param m Method
 * @return u8
 */
export function method(m: Method): u8 {
  if (m == Method.POST) { return 1 as u8; }
  if (m == Method.HEAD) { return 2 as u8; }
  if (m == Method.PUT) { return 3 as u8; }
  if (m == Method.DELETE) { return 4 as u8; }
  if (m == Method.PATCH) { return 5 as u8; }
  if (m == Method.OPTIONS) { return 6 as u8; }
  return 0 as u8;
}

/** Exported function `method`.
 * Implements `method`.
 * @param tag u8
 * @return Method
 */
export function method(tag: u8): Method {
  if (tag == 1) { return Method.POST; }
  if (tag == 2) { return Method.HEAD; }
  if (tag == 3) { return Method.PUT; }
  if (tag == 4) { return Method.DELETE; }
  if (tag == 5) { return Method.PATCH; }
  if (tag == 6) { return Method.OPTIONS; }
  return Method.GET;
}

extern function http_get_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32): i32;
extern function http_post_c(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32): i32;
extern function http_head_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32): i32;
extern function http_put_c(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32): i32;
extern function http_delete_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32): i32;
extern function http_patch_c(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32): i32;
extern function http_options_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32): i32;
extern function http_get_timeout_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http_post_timeout_c(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http_head_timeout_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http_put_timeout_c(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http_delete_timeout_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http_patch_timeout_c(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http_options_timeout_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http_request_ex_c(method: *u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32): i32;
extern function http_request_method_c(method_u8: u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32): i32;
extern function http_request_method_timeout_c(method_u8: u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http_respond_get_ok_c(fd: i32, body: *u8, body_len: i32): i32;
extern function http_listen_c(addr_u32: u32, port_u32: u32, backlog: i32): i32;
extern function http_serve_one_c(listener_fd: i32, body: *u8, body_len: i32, timeout_ms: u32): i32;
extern function http_client_pool_create_c(host: *u8, host_len: i32, port: *u8, port_len: i32, max_conns: i32): i64;
extern function http_client_pool_destroy_c(pool_h: i64): void;
extern function http_client_pool_get_c(pool_h: i64, url: *u8, url_len: i32, out_buf: *u8, out_cap: i32): i32;
extern function http_parse_status_line_c(line: *u8, len: i32, out_code: *i32): i32;
extern function http_headers_body_offset_c(buf: *u8, len: i32, out_off: *i32): i32;
extern function http_has_chunked_encoding_c(buf: *u8, len: i32): i32;
extern function http_has_keep_alive_c(buf: *u8, len: i32): i32;
extern function http_decode_chunked_body_c(buf: *u8, len: i32, hdr_end: i32, out_body: *u8, out_cap: i32): i32;
extern function http_build_get_keep_alive_c(host: *u8, path: *u8, out: *u8, out_cap: i32): i32;
extern function http_is_upgrade_websocket_c(buf: *u8, len: i32): i32;
extern function http_build_ws_upgrade_101_c(accept: *u8, out: *u8, out_cap: i32): i32;
extern function http_is_https_available_c(): i32;
extern function http_https_smoke_c(): i32;

/** Exported function `err_tls_not_impl`.
 * Implements `err_tls_not_impl`.
 * @return i32
 */
export function err_tls_not_impl(): i32 { return -1221; }

/** Exported function `https_is_available`.
 * Implements `https_is_available`.
 * @return bool
 */
export function https_is_available(): bool {
  if (http_libc_is_https_available_c() != 0) { return true; }
  return false;
}

/** Exported function `https_smoke`.
 * Implements `https_smoke`.
 * @return i32
 */
export function https_smoke(): i32 {
  return http_libc_https_smoke_c();
}

/** Exported function `get`.
 * Implements `get`.
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @return i32
 */
export function get(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32): i32 {
  return http_libc_get_c(url, url_len, out_buf, out_cap);
}

/** HTTP POST。 */
export function post(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32): i32 {
  return http_libc_post_c(url, url_len, body, body_len, out_buf, out_cap);
}

/** HTTP HEAD。 */
export function head(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32): i32 {
  return http_libc_head_c(url, url_len, out_buf, out_cap);
}

/** Exported function `put`.
 * Implements `put`.
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @return i32
 */
export function put(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32): i32 {
  return http_libc_put_c(url, url_len, body, body_len, out_buf, out_cap);
}

/** HTTP DELETE。 */
export function delete(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32): i32 {
  return http_libc_delete_c(url, url_len, out_buf, out_cap);
}

/** Exported function `patch`.
 * Implements `patch`.
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @return i32
 */
export function patch(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32): i32 {
  return http_libc_patch_c(url, url_len, body, body_len, out_buf, out_cap);
}

/** HTTP OPTIONS。 */
export function options(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32): i32 {
  return http_libc_options_c(url, url_len, out_buf, out_cap);
}

/**
 * See implementation.
 * See implementation.
 */
export function client_request(method: Method, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32): i32 {
  return http_libc_request_method_c(method(method), url, url_len, body, body_len, out_buf, out_cap);
}

// ─── STD-HTTP-REQRESP：Request/Response v0 ───

/* See implementation. */
allow(padding) struct HttpRequest {
  method: Method;
  url: *u8;
  url_len: i32;
  body: *u8;
  body_len: i32;
  timeout_ms: u32;
}

/* See implementation. */
allow(padding) struct HttpResponse {
  status: i32;
  raw_len: i32;
  header_end: i32;
  body_len: i32;
  chunked: i32;
}

extern function http_response_parse_c(buf: *u8, len: i32, out_status: *i32, out_hdr_end: *i32, out_body_len: *i32, out_chunked: *i32): i32;
extern function http_response_parse_smoke_c(): i32;
extern function http_response_body_ptr_c(buf: *u8, hdr_end: i32): *u8;
extern function http_response_body_copy_c(buf: *u8, hdr_end: i32, body_len: i32, out: *u8, out_cap: i32): i32;
extern function http_response_body_owned_smoke_c(): i32;
extern function http_url_exceeds_string_cap_c(url_len: i32): i32;
extern function http_url_copy_c(src: *u8, len: i32, out: *u8, out_cap: i32): i32;
extern function http_url_owned_smoke_c(): i32;
extern function http_request_owned_smoke_c(): i32;

/* See implementation. */
allow(padding) struct HttpUrlOwned {
  ptr: *u8;
  len: i32;
}

/** Exported function `url_string_cap`.
 * Implements `url_string_cap`.
 * @return i32
 */
export function url_string_cap(): i32 { return 256; }

/* See implementation. */
allow(padding) struct HttpBodyOwned {
  ptr: *u8;
  len: i32;
}

/* See implementation. */
allow(padding) struct HttpBodyView {
  ptr: *u8;
  len: i32;
}

/**
 * See implementation.
 * See implementation.
 */
export function request_init(method: Method, url: *u8, url_len: i32, body: *u8, body_len: i32, timeout_ms: u32, out: *HttpRequest): void {
  out.method = method;
  out.url = url;
  out.url_len = url_len;
  out.body = body;
  out.body_len = body_len;
  out.timeout_ms = timeout_ms;
}

/** Exported function `parse_response`.
 * Implements `parse_response`.
 * @param buf *u8
 * @param raw_len i32
 * @param out *HttpResponse
 * @return i32
 */
export function parse_response(buf: *u8, raw_len: i32, out: *HttpResponse): i32 {
  let st: i32 = 0;
  let he: i32 = 0;
  let bl: i32 = 0;
  let ch: i32 = 0;
  if (http_libc_response_parse_c(buf, raw_len, &st, &he, &bl, &ch) != 0) { return -1; }
  out.status = st;
  out.raw_len = raw_len;
  out.header_end = he;
  out.body_len = bl;
  out.chunked = ch;
  return raw_len;
}

/**
 * See implementation.
 * See implementation.
 */
export function execute(req: HttpRequest, buf: *u8, buf_cap: i32, out: *HttpResponse): i32 {
  let n: i32 = 0;
  let m: u8 = method(req.method);
  if (req.timeout_ms > 0) {
    n = http_libc_request_method_timeout_c(m, req.url, req.url_len, req.body, req.body_len, buf, buf_cap, req.timeout_ms);
  } else {
    n = http_libc_request_method_c(m, req.url, req.url_len, req.body, req.body_len, buf, buf_cap);
  }
  if (n < 0) { return n; }
  return parse_response(buf, n, out);
}

/**
 * See implementation.
 */
export function response_body_decode(buf: *u8, resp: HttpResponse, out_body: *u8, out_cap: i32): i32 {
  if (resp.chunked != 0) {
    return decode_chunked_body(buf, resp.raw_len, resp.header_end, out_body, out_cap);
  }
  return resp.body_len;
}

/** Exported function `response_parse_smoke`.
 * Implements `response_parse_smoke`.
 * @return i32
 */
export function response_parse_smoke(): i32 {
  return http_libc_response_parse_smoke_c();
}

/** Exported function `respond_get_ok`.
 * Implements `respond_get_ok`.
 * @param fd i32
 * @param body *u8
 * @param body_len i32
 * @return i32
 */
export function respond_get_ok(fd: i32, body: *u8, body_len: i32): i32 {
  return http_libc_respond_get_ok_c(fd, body, body_len);
}

/** Exported function `listen`.
 * Implements `listen`.
 * @param addr_u32 u32
 * @param port_u32 u32
 * @param backlog i32
 * @return i32
 */
export function listen(addr_u32: u32, port_u32: u32, backlog: i32): i32 {
  return http_libc_listen_c(addr_u32, port_u32, backlog);
}

/** Exported function `serve_one`.
 * Implements `serve_one`.
 * @param listener_fd i32
 * @param body *u8
 * @param body_len i32
 * @param timeout_ms u32
 * @return i32
 */
export function serve_one(listener_fd: i32, body: *u8, body_len: i32, timeout_ms: u32): i32 {
  return http_libc_serve_one_c(listener_fd, body, body_len, timeout_ms);
}

/** Exported function `client_pool_create`.
 * Implements `client_pool_create`.
 * @param host *u8
 * @param host_len i32
 * @param port *u8
 * @param port_len i32
 * @param max_conns i32
 * @return i64
 */
export function client_pool_create(host: *u8, host_len: i32, port: *u8, port_len: i32, max_conns: i32): i64 {
  return http_libc_client_pool_create_c(host, host_len, port, port_len, max_conns);
}

/** Exported function `client_pool_destroy`.
 * Implements `client_pool_destroy`.
 * @param pool_h i64
 * @return void
 */
export function client_pool_destroy(pool_h: i64): void {
  http_libc_client_pool_destroy_c(pool_h);
}

/** Exported function `client_pool_get`.
 * Implements `client_pool_get`.
 * @param pool_h i64
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @return i32
 */
export function client_pool_get(pool_h: i64, url: *u8, url_len: i32, out_buf: *u8, out_cap: i32): i32 {
  return http_libc_client_pool_get_c(pool_h, url, url_len, out_buf, out_cap);
}

/** Exported function `parse_status_line`.
 * Implements `parse_status_line`.
 * @param line *u8
 * @param len i32
 * @param out_code *i32
 * @return i32
 */
export function parse_status_line(line: *u8, len: i32, out_code: *i32): i32 {
  return http_libc_parse_status_line_c(line, len, out_code);
}

/** Exported function `headers_body_offset`.
 * Implements `headers_body_offset`.
 * @param buf *u8
 * @param len i32
 * @param out_off *i32
 * @return i32
 */
export function headers_body_offset(buf: *u8, len: i32, out_off: *i32): i32 {
  return http_libc_headers_body_offset_c(buf, len, out_off);
}

/** Exported function `has_chunked_encoding`.
 * Implements `has_chunked_encoding`.
 * @param buf *u8
 * @param len i32
 * @return bool
 */
export function has_chunked_encoding(buf: *u8, len: i32): bool {
  if (http_libc_has_chunked_encoding_c(buf, len) != 0) { return true; }
  return false;
}

/** Exported function `has_keep_alive`.
 * Implements `has_keep_alive`.
 * @param buf *u8
 * @param len i32
 * @return bool
 */
export function has_keep_alive(buf: *u8, len: i32): bool {
  if (http_libc_has_keep_alive_c(buf, len) != 0) { return true; }
  return false;
}

/** Exported function `decode_chunked_body`.
 * Implements `decode_chunked_body`.
 * @param buf *u8
 * @param len i32
 * @param hdr_end i32
 * @param out_body *u8
 * @param out_cap i32
 * @return i32
 */
export function decode_chunked_body(buf: *u8, len: i32, hdr_end: i32, out_body: *u8, out_cap: i32): i32 {
  return http_libc_decode_chunked_body_c(buf, len, hdr_end, out_body, out_cap);
}

/** Exported function `is_upgrade_websocket`.
 * Query helper `is_upgrade_websocket`.
 * @param buf *u8
 * @param len i32
 * @return bool
 */
export function is_upgrade_websocket(buf: *u8, len: i32): bool {
  if (http_libc_is_upgrade_websocket_c(buf, len) != 0) { return true; }
  return false;
}

/** Exported function `build_ws_upgrade`.
 * Implements `build_ws_upgrade`.
 * @param accept *u8
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_ws_upgrade(accept: *u8, out: *u8, out_cap: i32): i32 {
  return http_libc_build_ws_upgrade_101_c(accept, out, out_cap);
}

/** Exported function `build_get_keep_alive`.
 * Implements `build_get_keep_alive`.
 * @param host *u8
 * @param path *u8
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_get_keep_alive(host: *u8, path: *u8, out: *u8, out_cap: i32): i32 {
  return http_libc_build_get_keep_alive_c(host, path, out, out_cap);
}

/* See implementation. */
export const HTTP_CTX_MS_CANCELLED: i32 = -1;
/* See implementation. */
export const HTTP_CTX_MS_EXPIRED: i32 = -2;

/** Exported function `timeout_ms_for_http`.
 * Implements `timeout_ms_for_http`.
 * @param ctx Context
 * @return i32
 */
export function timeout_ms_for_http(ctx: Context): i32 {
  if (context.is_cancelled(ctx) != 0) {
    return HTTP_CTX_MS_CANCELLED;
  }
  let rem: i64 = context.remaining_ns(ctx);
  let dl: i64 = context.deadline_ns(ctx);
  if (dl > 0 && rem <= 0) {
    return HTTP_CTX_MS_EXPIRED;
  }
  if (rem <= 0) {
    return 0;
  }
  let ms: i64 = rem / 1000000;
  if (ms <= 0) {
    return 1;
  }
  if (ms > 2147483647) {
    return 2147483647;
  }
  return ms as i32;
}

/** Exported function `ctx_check_for_http`.
 * Implements `ctx_check_for_http`.
 * @param ctx Context
 * @return i32
 */
export function ctx_check_for_http(ctx: Context): i32 {
  let tm: i32 = timeout_ms_for_http(ctx);
  if (tm == HTTP_CTX_MS_CANCELLED) {
    return err.http_err_cancelled();
  }
  if (tm == HTTP_CTX_MS_EXPIRED) {
    return err.http_err_timeout();
  }
  return 0;
}

/** Exported function `request_timeout_ms_for_ctx`.
 * Implements `request_timeout_ms_for_ctx`.
 * @param ctx Context
 * @return i32
 */
export function request_timeout_ms_for_ctx(ctx: Context): i32 {
  if (context.is_cancelled(ctx) != 0) {
    return err.http_err_cancelled();
  }
  let rem: i64 = context.remaining_ns(ctx);
  let dl: i64 = context.deadline_ns(ctx);
  if (dl > 0 && rem <= 0) {
    return err.http_err_timeout();
  }
  if (rem <= 0) {
    return 0;
  }
  let ms: i64 = rem / 1000000;
  if (ms <= 0) {
    return 1;
  }
  if (ms > 2147483647) {
    return 2147483647;
  }
  return ms as i32;
}

/** Exported function `map_http_c_result`.
 * Implements `map_http_c_result`.
 * @param c_code i32
 * @return i32
 */
export function map_http_c_result(c_code: i32): i32 {
  if (c_code == -1220) {
    return err.http_err_timeout();
  }
  if (c_code == err_tls_not_impl()) {
    return err_tls_not_impl();
  }
  return c_code;
}

/** Exported function `get_ctx`.
 * Query helper `get_ctx`.
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param ctx Context
 * @return i32
 */
export function get_ctx(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, ctx: Context): i32 {
  let chk: i32 = ctx_check_for_http(ctx);
  if (chk != 0) {
    return chk;
  }
  let tm: i32 = timeout_ms_for_http(ctx);
  return map_http_c_result(http_libc_get_timeout_c(url, url_len, out_buf, out_cap, tm as u32));
}

/** Exported function `post_ctx`.
 * Implements `post_ctx`.
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param ctx Context
 * @return i32
 */
export function post_ctx(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, ctx: Context): i32 {
  let chk: i32 = ctx_check_for_http(ctx);
  if (chk != 0) {
    return chk;
  }
  let tm: i32 = timeout_ms_for_http(ctx);
  return map_http_c_result(http_libc_post_timeout_c(url, url_len, body, body_len, out_buf, out_cap, tm as u32));
}

/** Exported function `head_ctx`.
 * Implements `head_ctx`.
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param ctx Context
 * @return i32
 */
export function head_ctx(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, ctx: Context): i32 {
  let chk: i32 = ctx_check_for_http(ctx);
  if (chk != 0) {
    return chk;
  }
  let tm: i32 = timeout_ms_for_http(ctx);
  return map_http_c_result(http_libc_head_timeout_c(url, url_len, out_buf, out_cap, tm as u32));
}

/** Exported function `put_ctx`.
 * Implements `put_ctx`.
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param ctx Context
 * @return i32
 */
export function put_ctx(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, ctx: Context): i32 {
  let chk: i32 = ctx_check_for_http(ctx);
  if (chk != 0) {
    return chk;
  }
  let tm: i32 = timeout_ms_for_http(ctx);
  return map_http_c_result(http_libc_put_timeout_c(url, url_len, body, body_len, out_buf, out_cap, tm as u32));
}

/** Exported function `delete_ctx`.
 * Implements `delete_ctx`.
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param ctx Context
 * @return i32
 */
export function delete_ctx(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, ctx: Context): i32 {
  let chk: i32 = ctx_check_for_http(ctx);
  if (chk != 0) {
    return chk;
  }
  let tm: i32 = timeout_ms_for_http(ctx);
  return map_http_c_result(http_libc_delete_timeout_c(url, url_len, out_buf, out_cap, tm as u32));
}

/** Exported function `patch_ctx`.
 * Implements `patch_ctx`.
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param ctx Context
 * @return i32
 */
export function patch_ctx(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, ctx: Context): i32 {
  let chk: i32 = ctx_check_for_http(ctx);
  if (chk != 0) {
    return chk;
  }
  let tm: i32 = timeout_ms_for_http(ctx);
  return map_http_c_result(http_libc_patch_timeout_c(url, url_len, body, body_len, out_buf, out_cap, tm as u32));
}

/** Exported function `options_ctx`.
 * Implements `options_ctx`.
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param ctx Context
 * @return i32
 */
export function options_ctx(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, ctx: Context): i32 {
  let chk: i32 = ctx_check_for_http(ctx);
  if (chk != 0) {
    return chk;
  }
  let tm: i32 = timeout_ms_for_http(ctx);
  return map_http_c_result(http_libc_options_timeout_c(url, url_len, out_buf, out_cap, tm as u32));
}

/** Exported function `client_request_ctx`.
 * Implements `client_request_ctx`.
 * @param method Method
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param ctx Context
 * @return i32
 */
export function client_request_ctx(method: Method, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, ctx: Context): i32 {
  let chk: i32 = ctx_check_for_http(ctx);
  if (chk != 0) {
    return chk;
  }
  let tm: i32 = timeout_ms_for_http(ctx);
  return map_http_c_result(http_libc_request_method_timeout_c(method(method), url, url_len, body, body_len, out_buf, out_cap, tm as u32));
}

// See implementation.

/**
 * See implementation.
 * See implementation.
 */
export function execute_ctx(req: HttpRequest, buf: *u8, buf_cap: i32, out: *HttpResponse, ctx: Context): i32 {
  let chk: i32 = ctx_check_for_http(ctx);
  if (chk != 0) {
    return chk;
  }
  let tm: i32 = timeout_ms_for_http(ctx);
  let m: u8 = method(req.method);
  let n: i32 = map_http_c_result(http_libc_request_method_timeout_c(m, req.url, req.url_len, req.body, req.body_len, buf, buf_cap, tm as u32));
  if (n < 0) {
    return n;
  }
  return parse_response(buf, n, out);
}

/** Exported function `response_body_view`.
 * Implements `response_body_view`.
 * @param buf *u8
 * @param resp HttpResponse
 * @return HttpBodyView
 */
export function response_body_view(buf: *u8, resp: HttpResponse): HttpBodyView {
  return HttpBodyView { ptr: http_libc_response_body_ptr_c(buf, resp.header_end), len: resp.body_len };
}

/**
 * See implementation.
 * See implementation.
 */
export function response_body_owned(buf: *u8, resp: HttpResponse, out: *HttpBodyOwned): i32 {
  let cap: i32 = 0;
  let p: *u8 = 0;
  let n: i32 = 0;
  if (resp.chunked != 0) {
    cap = resp.raw_len - resp.header_end;
    if (cap <= 0) {
      cap = 1;
    }
    p = heap.alloc(cap as usize);
    if (p == 0) {
      return -1;
    }
    n = decode_chunked_body(buf, resp.raw_len, resp.header_end, p, cap);
    if (n < 0) {
      heap.free(p);
      return -1;
    }
    out.ptr = p;
    out.len = n;
    return n;
  }
  if (resp.body_len <= 0) {
    out.ptr = 0;
    out.len = 0;
    return 0;
  }
  p = heap.alloc(resp.body_len as usize);
  if (p == 0) {
    return -1;
  }
  n = http_libc_response_body_copy_c(buf, resp.header_end, resp.body_len, p, resp.body_len);
  if (n < 0) {
    heap.free(p);
    return -1;
  }
  out.ptr = p;
  out.len = n;
  return n;
}

/** Exported function `body_owned_free`.
 * Memory management helper `body_owned_free`.
 * @param body HttpBodyOwned
 * @return void
 */
export function body_owned_free(body: HttpBodyOwned): void {
  if (body.ptr != 0) {
    heap.free(body.ptr);
  }
}

/** Exported function `url_exceeds_string_cap`.
 * Implements `url_exceeds_string_cap`.
 * @param url_len i32
 * @return bool
 */
export function url_exceeds_string_cap(url_len: i32): bool {
  if (http_libc_url_exceeds_string_cap_c(url_len) != 0) { return true; }
  return false;
}

/**
 * See implementation.
 * See implementation.
 */
export function url_owned_from_slice(src: *u8, src_len: i32, out: *HttpUrlOwned): i32 {
  let p: *u8 = 0;
  let n: i32 = 0;
  if (src_len <= 0) {
    out.ptr = 0;
    out.len = 0;
    return 0;
  }
  if (src == 0) {
    return -1;
  }
  p = heap.alloc(src_len as usize);
  if (p == 0) {
    return -1;
  }
  n = http_libc_url_copy_c(src, src_len, p, src_len);
  if (n < 0) {
    heap.free(p);
    return -1;
  }
  out.ptr = p;
  out.len = n;
  return n;
}

/** Exported function `url_owned_free`.
 * Memory management helper `url_owned_free`.
 * @param url HttpUrlOwned
 * @return void
 */
export function url_owned_free(url: HttpUrlOwned): void {
  if (url.ptr != 0) {
    heap.free(url.ptr);
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function request_bind_url_owned(method: Method, url: *HttpUrlOwned, body: *u8, body_len: i32, timeout_ms: u32, out: *HttpRequest): void {
  out.method = method;
  out.url = url.ptr;
  out.url_len = url.len;
  out.body = body;
  out.body_len = body_len;
  out.timeout_ms = timeout_ms;
}

/** Exported function `url_owned_smoke`.
 * Implements `url_owned_smoke`.
 * @return i32
 */
export function url_owned_smoke(): i32 {
  return http_libc_url_owned_smoke_c();
}

/* See implementation. */
allow(padding) struct HttpRequestOwned {
  method: Method;
  url: HttpUrlOwned;
  body: HttpBodyOwned;
  timeout_ms: u32;
}

/**
 * See implementation.
 * See implementation.
 */
export function request_owned_init(method: Method, url_src: *u8, url_len: i32, body_src: *u8, body_len: i32, timeout_ms: u32, out: *HttpRequestOwned): i32 {
  out.method = method;
  out.timeout_ms = timeout_ms;
  out.body.ptr = 0;
  out.body.len = 0;
  if (url_owned_from_slice(url_src, url_len, &out.url) < 0) {
    return -1;
  }
  if (body_len > 0) {
    let p: *u8 = 0;
    let n: i32 = 0;
    if (body_src == 0) {
      url_owned_free(out.url);
      out.url.ptr = 0;
      out.url.len = 0;
      return -1;
    }
    p = heap.alloc(body_len as usize);
    if (p == 0) {
      url_owned_free(out.url);
      out.url.ptr = 0;
      out.url.len = 0;
      return -1;
    }
    n = http_libc_url_copy_c(body_src, body_len, p, body_len);
    if (n < 0) {
      heap.free(p);
      url_owned_free(out.url);
      out.url.ptr = 0;
      out.url.len = 0;
      return -1;
    }
    out.body.ptr = p;
    out.body.len = n;
  }
  return 0;
}

/** Exported function `request_owned_free`.
 * Memory management helper `request_owned_free`.
 * @param req *HttpRequestOwned
 * @return void
 */
export function request_owned_free(req: *HttpRequestOwned): void {
  url_owned_free(req.url);
  body_owned_free(req.body);
  req.url.ptr = 0;
  req.url.len = 0;
  req.body.ptr = 0;
  req.body.len = 0;
}

/**
 * See implementation.
 * See implementation.
 */
export function execute_owned(req: *HttpRequestOwned, buf: *u8, buf_cap: i32, out: *HttpResponse): i32 {
  let view: HttpRequest = HttpRequest {
    method: req.method,
    url: req.url.ptr,
    url_len: req.url.len,
    body: req.body.ptr,
    body_len: req.body.len,
    timeout_ms: req.timeout_ms
  };
  return execute(view, buf, buf_cap, out);
}

/** Exported function `request_owned_smoke`.
 * Implements `request_owned_smoke`.
 * @return i32
 */
export function request_owned_smoke(): i32 {
  return http_libc_request_owned_smoke_c();
}

/** Exported function `response_body_owned_smoke`.
 * Implements `response_body_owned_smoke`.
 * @return i32
 */
export function response_body_owned_smoke(): i32 {
  return http_libc_response_body_owned_smoke_c();
}

/* See implementation. */
allow(padding) struct HttpResponseOwned {
  status: i32;
  body: HttpBodyOwned;
}

/**
 * See implementation.
 * See implementation.
 */
export function response_owned_from_parse(buf: *u8, resp: HttpResponse, out: *HttpResponseOwned): i32 {
  out.status = resp.status;
  return response_body_owned(buf, resp, &out.body);
}

/** Exported function `response_owned_free`.
 * Memory management helper `response_owned_free`.
 * @param resp *HttpResponseOwned
 * @return void
 */
export function response_owned_free(resp: *HttpResponseOwned): void {
  body_owned_free(resp.body);
  resp.body = HttpBodyOwned { ptr: 0, len: 0 };
}

/** Exported function `listen_on`.
 * Implements `listen_on`.
 * @param addr_u32 u32
 * @param port_u32 u32
 * @param backlog i32
 * @return i32
 */
export function listen_on(addr_u32: u32, port_u32: u32, backlog: i32): i32 {
  return listen(addr_u32, port_u32, backlog);
}

// See implementation.

/* See implementation. */
allow(padding) struct Http2FlowState {
  conn_window: i32;
  stream_window: i32;
}

/* See implementation. */
allow(padding) struct Http2FlowRecvState {
  conn_left: i32;
  stream_left: i32;
}

extern function http2_preface_len_c(): i32;
extern function http2_is_connection_preface_c(buf: *u8, len: i32): i32;
extern function http2_parse_frame_header_c(buf: *u8, len: i32, out_type: *i32, out_flags: *i32, out_stream_id: *i32, out_payload_len: *i32): i32;
extern function http2_build_settings_ack_c(out: *u8, out_cap: i32): i32;
extern function http2_build_settings_one_c(setting_id: i32, value: i32, out: *u8, out_cap: i32): i32;
extern function http2_wire_is_available_c(): i32;
extern function http2_client_is_available_c(): i32;
extern function http2_alpn_h2_len_c(): i32;
extern function http2_write_alpn_h2_c(out: *u8, out_cap: i32): i32;
extern function http2_smoke_c(): i32;
extern function http2_hpack_encode_indexed_c(index: i32, out: *u8, out_cap: i32): i32;
extern function http2_hpack_encode_literal_c(name_index: i32, value: *u8, value_len: i32, out: *u8, out_cap: i32): i32;
extern function http2_hpack_encode_get_request_c(authority: *u8, authority_len: i32, path: *u8, path_len: i32, is_https: i32, out: *u8, out_cap: i32): i32;
extern function http2_hpack_decode_status_c(block: *u8, block_len: i32, out_status: *i32): i32;
extern function http2_hpack_smoke_c(): i32;
extern function http2_hpack_dyn_reset_c(): void;
extern function http2_hpack_dyn_count_c(): i32;
extern function http2_hpack_encode_literal_incremental_c(name_index: i32, value: *u8, value_len: i32, out: *u8, out_cap: i32): i32;
extern function http2_hpack_encode_indexed_any_c(index: i32, out: *u8, out_cap: i32): i32;
extern function http2_hpack_encode_request_c(method_u8: u8, authority: *u8, authority_len: i32, path: *u8, path_len: i32, is_https: i32, out: *u8, out_cap: i32): i32;
extern function http2_hpack_dyn_smoke_c(): i32;
extern function http2_hpack_server_dyn_create_c(peer: *Http2PeerSettings): i64;
extern function http2_hpack_server_dyn_destroy_c(handle: i64): void;
extern function http2_hpack_server_dyn_set_table_size_h_c(handle: i64, size: i32): void;
extern function http2_hpack_server_dyn_max_size_h_c(handle: i64): i32;
extern function http2_hpack_server_dyn_count_h_c(handle: i64): i32;
extern function http2_hpack_server_encode_status_h_c(handle: i64, status: i32, out: *u8, out_cap: i32): i32;
extern function http2_hpack_server_dyn_smoke_c(): i32;
extern function http2_frame_payload_limit_c(max_frame_size: i32): i32;
extern function http2_frame_check_payload_c(payload_len: i32, max_frame_size: i32): i32;
extern function http2_frame_count_data_chunks_c(data_len: i32, max_frame_size: i32): i32;
extern function http2_frame_capped_smoke_c(): i32;
extern function http2_frame_goaway_c(): i32;
extern function http2_goaway_error_no_error_c(): i32;
extern function http2_err_goaway_c(): i32;
extern function http2_build_goaway_c(last_stream_id: i32, code: i32, out: *u8, out_cap: i32): i32;
extern function http2_parse_goaway_c(payload: *u8, plen: i32, out_last_stream: *i32, out_code: *i32): i32;
extern function http2_goaway_smoke_c(): i32;
extern function http2_frame_ping_c(): i32;
extern function http2_err_ping_c(): i32;
extern function http2_build_ping_c(opaque: *u8, out: *u8, out_cap: i32): i32;
extern function http2_build_ping_ack_c(opaque: *u8, out: *u8, out_cap: i32): i32;
extern function http2_parse_ping_c(payload: *u8, plen: i32, out_opaque: *u8): i32;
extern function http2_ping_opaque_match_c(a: *u8, b: *u8): i32;
extern function http2_ping_smoke_c(): i32;
extern function http2_frame_rst_stream_c(): i32;
extern function http2_rst_error_cancel_c(): i32;
extern function http2_err_rst_stream_c(): i32;
extern function http2_build_rst_stream_c(stream_id: i32, code: i32, out: *u8, out_cap: i32): i32;
extern function http2_parse_rst_stream_c(payload: *u8, plen: i32, out_code: *i32): i32;
extern function http2_rst_stream_smoke_c(): i32;
extern function http2_conn_reset_stream_c(conn: *Http2Conn, stream_id: i32, code: i32): i32;
extern function http2_http2_complete_smoke_c(): i32;
extern function http2_build_headers_frame_c(stream_id: i32, flags: i32, hpack: *u8, hpack_len: i32, out: *u8, out_cap: i32): i32;
extern function http2_build_data_frame_c(stream_id: i32, flags: i32, data: *u8, data_len: i32, out: *u8, out_cap: i32): i32;
extern function http2_build_get_headers_frame_c(authority: *u8, authority_len: i32, path: *u8, path_len: i32, is_https: i32, out: *u8, out_cap: i32): i32;
extern function http2_build_request_headers_frame_c(method_u8: u8, authority: *u8, authority_len: i32, path: *u8, path_len: i32, is_https: i32, has_body: i32, stream_id: i32, out: *u8, out_cap: i32): i32;
extern function http2_client_smoke_c(): i32;
extern function http2_network_is_available_c(): i32;
extern function http2_network_smoke_c(): i32;
extern function http_h2_get_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http_h2_request_c(method_u8: u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http_request_method_h2_c(method_u8: u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http2_hpack_huffman_decode_c(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32;
extern function http2_hpack_huffman_is_available_c(): i32;
extern function http2_hpack_huffman_smoke_c(): i32;
extern function http2_build_window_update_c(stream_id: i32, increment: i32, out: *u8, out_cap: i32): i32;
extern function http2_default_initial_window_c(): i32;
extern function http2_flow_control_smoke_c(): i32;
extern function http2_flow_state_init_c(st: *Http2FlowState): void;
extern function http2_flow_state_reset_stream_c(st: *Http2FlowState, initial_window: i32): void;
extern function http2_flow_state_apply_initial_window_c(st: *Http2FlowState, initial_window: i32): void;
extern function http2_flow_state_apply_window_update_c(st: *Http2FlowState, stream_id: i32, increment: i32): i32;
extern function http2_flow_state_max_send_c(st: *Http2FlowState, want: i32): i32;
extern function http2_flow_state_can_send_c(st: *Http2FlowState, want: i32): i32;
extern function http2_flow_state_consume_send_c(st: *Http2FlowState, nbytes: i32): i32;
extern function http2_parse_window_update_payload_c(payload: *u8, plen: i32, out_increment: *i32): i32;
extern function http2_flow_state_smoke_c(): i32;
extern function http2_flow_recv_init_c(st: *Http2FlowRecvState): void;
extern function http2_flow_recv_reset_stream_c(st: *Http2FlowRecvState, initial_window: i32): void;
extern function http2_flow_recv_on_data_c(st: *Http2FlowRecvState, nbytes: i32): i32;
extern function http2_flow_recv_release_c(st: *Http2FlowRecvState, stream_id: i32, nbytes: i32, out: *u8, out_cap: i32): i32;
extern function http2_flow_recv_smoke_c(): i32;
extern function http2_frame_push_promise_c(): i32;
extern function http2_is_push_promise_frame_c(ftype: i32): i32;
extern function http2_parse_push_promise_stream_c(payload: *u8, plen: i32, out_promised_id: *i32): i32;
extern function http2_is_h2c_upgrade_response_c(buf: *u8, len: i32): i32;
extern function http2_h2c_is_available_c(): i32;
extern function http2_push_h2c_smoke_c(): i32;
extern function http2_h2c_wire_is_available_c(): i32;
extern function http2_h2c_session_begin_c(out: *u8, out_cap: i32): i32;
extern function http2_push_collect_data_c(promised_id: i32, stream_id: i32, data: *u8, dlen: i32, inout_promised_id: *i32, acc: *u8, acc_cap: i32, acc_len: *i32): i32;

/* See implementation. */
allow(padding) struct Http2PushLast {
  promised_stream_id: i32;
  body_len: i32;
}

/* See implementation. */
allow(padding) struct Http2PushResource {
  promised_stream_id: i32;
  body_len: i32;
}

extern function http2_push_fetch_smoke_c(): i32;
extern function http2_push_last_reset_c(): void;
extern function http2_push_last_copy_c(out_meta: *Http2PushLast, out_body: *u8, out_cap: i32): i32;
extern function http2_push_network_smoke_c(): i32;
extern function http2_session_request_h2c_c(fd: i32, method_u8: u8, authority: *u8, authority_len: i32, path: *u8, path_len: i32, body: *u8, body_len: i32, out: *u8, out_cap: i32): i32;
extern function http2_h2c_network_smoke_c(): i32;
extern function http_h2c_get_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http_h2c_request_c(method_u8: u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http_request_method_h2c_c(method_u8: u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http_h2c_client_smoke_c(): i32;

/* See implementation. */
allow(padding) struct Http2StreamSlot {
  stream_id: i32;
  open: i32;
}

/* See implementation. */
allow(padding) struct Http2StreamRegistry {
  slots_blob: u8[64];
  count: i32;
  next_id: i32;
}

extern function http2_stream_registry_init_c(reg: *Http2StreamRegistry): void;
extern function http2_stream_registry_open_c(reg: *Http2StreamRegistry): i32;
extern function http2_stream_registry_close_c(reg: *Http2StreamRegistry, stream_id: i32): void;
extern function http2_stream_registry_is_open_c(reg: *Http2StreamRegistry, stream_id: i32): i32;
extern function http2_stream_registry_smoke_c(): i32;

/* See implementation. */
allow(padding) struct Http2PeerSettings {
  max_concurrent_streams: i32;
  initial_window_size: i32;
  settings_ack_sent: i32;
  enable_push: i32;
  header_table_size: i32;
  max_frame_size: i32;
  max_header_list_size: i32;
}

/* See implementation. */
allow(padding) struct Http2MultistreamClient {
  registry: Http2StreamRegistry;
  peer: Http2PeerSettings;
  flow: Http2FlowState;
  open_count: i32;
}

extern function http2_peer_settings_init_c(ps: *Http2PeerSettings): void;
extern function http2_settings_entry_count_c(plen: i32): i32;
extern function http2_parse_settings_entry_c(payload: *u8, plen: i32, entry_index: i32, out_id: *i32, out_value: *i32): i32;
extern function http2_peer_settings_apply_entry_c(ps: *Http2PeerSettings, setting_id: i32, value: i32): void;
extern function http2_peer_settings_consume_payload_c(payload: *u8, plen: i32, ps: *Http2PeerSettings): i32;
extern function http2_build_client_settings_c(max_streams: i32, initial_window: i32, out: *u8, out_cap: i32): i32;
extern function http2_build_client_settings_ex_c(max_streams: i32, initial_window: i32, enable_push: i32, out: *u8, out_cap: i32): i32;
extern function http2_build_client_settings_with_max_frame_c(max_streams: i32, initial_window: i32, enable_push: i32, max_frame_size: i32, out: *u8, out_cap: i32): i32;
extern function http2_build_server_settings_c(out: *u8, out_cap: i32): i32;
extern function http2_setting_enable_push_c(): i32;
extern function http2_setting_header_table_size_c(): i32;
extern function http2_setting_max_frame_size_c(): i32;
extern function http2_setting_max_header_list_size_c(): i32;
extern function http2_peer_settings_enable_push_c(ps: *Http2PeerSettings): i32;
extern function http2_peer_settings_header_table_size_c(ps: *Http2PeerSettings): i32;
extern function http2_peer_settings_max_frame_size_c(ps: *Http2PeerSettings): i32;
extern function http2_peer_settings_max_header_list_size_c(ps: *Http2PeerSettings): i32;
extern function http2_peer_settings_max_streams_c(ps: *Http2PeerSettings): i32;
extern function http2_peer_settings_initial_window_c(ps: *Http2PeerSettings): i32;
extern function http2_settings_smoke_c(): i32;
extern function http2_multistream_client_init_c(cli: *Http2MultistreamClient): void;
extern function http2_multistream_client_on_settings_c(cli: *Http2MultistreamClient, payload: *u8, plen: i32): i32;
extern function http2_multistream_client_open_stream_c(cli: *Http2MultistreamClient): i32;
extern function http2_multistream_client_close_stream_c(cli: *Http2MultistreamClient, stream_id: i32): void;
extern function http2_multistream_client_build_get_c(cli: *Http2MultistreamClient, stream_id: i32, authority: *u8, authority_len: i32, path: *u8, path_len: i32, out: *u8, out_cap: i32): i32;
extern function http2_multistream_client_build_parallel_get_c(cli: *Http2MultistreamClient, authority: *u8, authority_len: i32, path: *u8, path_len: i32, n_reqs: i32, out: *u8, out_cap: i32): i32;
extern function http2_multistream_client_smoke_c(): i32;

/* See implementation. */
allow(padding) struct Http2Conn {
  fd: i32;
  tls_ctx: i64;
  ready: i32;
  goaway_seen: i32;
  is_https: i32;
  ms: Http2MultistreamClient;
}

extern function http2_conn_init_c(conn: *Http2Conn): void;
extern function http2_conn_attach_h2c_c(fd: i32, conn: *Http2Conn): i32;
extern function http2_conn_attach_tls_c(tls_ctx: i64, conn: *Http2Conn): i32;
extern function http2_conn_is_ready_c(conn: *Http2Conn): i32;
extern function http2_conn_handshake_c(conn: *Http2Conn): i32;
extern function http2_conn_handshake_with_enable_push_c(conn: *Http2Conn, client_enable_push: i32): i32;
extern function http2_conn_handshake_with_max_frame_c(conn: *Http2Conn, client_max_frame_size: i32): i32;
extern function http2_conn_request_c(conn: *Http2Conn, method_u8: u8, authority: *u8, authority_len: i32, path: *u8, path_len: i32, body: *u8, body_len: i32, out: *u8, out_cap: i32): i32;
extern function http2_conn_close_c(conn: *Http2Conn): void;
extern function http2_conn_shutdown_graceful_c(conn: *Http2Conn, last_stream_id: i32, code: i32): void;
extern function http2_conn_read_goaway_c(conn: *Http2Conn, out_last_stream: *i32, out_code: *i32): i32;
extern function http2_conn_ping_c(conn: *Http2Conn, opaque: *u8): i32;
extern function http2_conn_goaway_seen_c(conn: *Http2Conn): i32;
extern function http2_conn_is_pool_reusable_c(conn: *Http2Conn): i32;
extern function http2_conn_goaway_smoke_c(): i32;
extern function http2_conn_ping_smoke_c(): i32;
extern function http2_conn_reuse_smoke_c(): i32;
extern function http2_conn_reuse_is_available_c(): i32;
extern function http2_conn_pool_create_h2c_c(host: *u8, host_len: i32, port: *u8, port_len: i32, max_conns: i32): i64;
extern function http2_conn_pool_create_h2_c(host: *u8, host_len: i32, port: *u8, port_len: i32, max_conns: i32): i64;
extern function http2_conn_pool_destroy_c(pool_h: i64): void;
extern function http2_conn_pool_request_c(pool_h: i64, method_u8: u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http_h2c_pool_get_c(pool_h: i64, url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http_h2_pool_get_c(pool_h: i64, url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http2_conn_pool_smoke_c(): i32;
extern function http2_conn_pool_goaway_smoke_c(): i32;
extern function http2_conn_pool_connect_count_c(pool_h: i64): i32;
extern function http2_conn_pool_is_available_c(): i32;
extern function http2_global_pool_create_c(max_entries: i32, max_conns_per_host: i32): i64;
extern function http2_global_pool_destroy_c(gpool_h: i64): void;
extern function http2_global_pool_get_c(gpool_h: i64, url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http2_global_pool_request_c(gpool_h: i64, method_u8: u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
extern function http2_global_pool_entry_count_c(gpool_h: i64): i32;
extern function http2_global_pool_connect_count_c(gpool_h: i64): i32;
extern function http2_global_pool_smoke_c(): i32;
extern function http2_global_pool_is_available_c(): i32;
extern function http2_serve_h2c_one_c(listener_fd: i32, body: *u8, body_len: i32, timeout_ms: u32): i32;
extern function http2_serve_h2c_one_with_goaway_c(listener_fd: i32, body: *u8, body_len: i32, last_stream_id: i32, timeout_ms: u32): i32;
extern function http2_server_serve_h2c_c(client_fd: i32, body: *u8, body_len: i32): i32;
extern function http2_server_serve_h2c_with_goaway_c(client_fd: i32, body: *u8, body_len: i32, last_stream_id: i32): i32;
extern function http2_serve_h2c_one_ping_echo_c(listener_fd: i32, timeout_ms: u32): i32;
extern function http2_server_serve_h2c_ping_echo_c(client_fd: i32): i32;
extern function http2_serve_h2c_one_with_push_c(listener_fd: i32, body: *u8, body_len: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32, timeout_ms: u32): i32;
extern function http2_server_serve_h2c_with_push_c(client_fd: i32, body: *u8, body_len: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32): i32;
extern function http2_server_serve_h2_with_push_c(tls_ctx: i64, body: *u8, body_len: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32): i32;
extern function http2_serve_h2_one_with_push_c(listener_fd: i32, srv_ctx_h: i64, body: *u8, body_len: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32, timeout_ms: u32): i32;
extern function http2_server_push_smoke_c(): i32;
extern function http2_server_push_tls_smoke_c(): i32;
extern function http2_server_push_settings_smoke_c(): i32;
extern function http2_server_settings_full_smoke_c(): i32;
extern function http2_server_hpack_dyn_smoke_c(): i32;
extern function http2_server_max_frame_smoke_c(): i32;
extern function http2_server_push_is_available_c(): i32;
extern function http2_serve_h2c_multi_one_c(listener_fd: i32, body: *u8, body_len: i32, max_requests: i32, timeout_ms: u32): i32;
extern function http2_server_serve_h2c_multi_c(client_fd: i32, body: *u8, body_len: i32, max_requests: i32): i32;
extern function http2_serve_h2c_multi_one_with_push_c(listener_fd: i32, body: *u8, body_len: i32, max_requests: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32, timeout_ms: u32): i32;
extern function http2_server_serve_h2c_multi_with_push_c(client_fd: i32, body: *u8, body_len: i32, max_requests: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32): i32;
extern function http2_serve_h2_multi_one_c(listener_fd: i32, srv_ctx_h: i64, body: *u8, body_len: i32, max_requests: i32, timeout_ms: u32): i32;
extern function http2_server_serve_h2_multi_c(tls_ctx: i64, body: *u8, body_len: i32, max_requests: i32): i32;
extern function http2_serve_h2_multi_one_with_push_c(listener_fd: i32, srv_ctx_h: i64, body: *u8, body_len: i32, max_requests: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32, timeout_ms: u32): i32;
extern function http2_server_serve_h2_multi_with_push_c(tls_ctx: i64, body: *u8, body_len: i32, max_requests: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32): i32;
extern function http2_server_multistream_push_smoke_c(): i32;
extern function http2_server_multistream_push_is_available_c(): i32;
extern function http2_server_multistream_smoke_c(): i32;
extern function http2_server_multistream_is_available_c(): i32;
extern function http2_server_smoke_c(): i32;
extern function http2_server_is_available_c(): i32;
extern function http2_serve_h2_one_c(listener_fd: i32, srv_ctx_h: i64, body: *u8, body_len: i32, timeout_ms: u32): i32;
extern function http2_server_serve_h2_c(tls_ctx: i64, body: *u8, body_len: i32): i32;
extern function http2_tls_server_ctx_create_c(cert_pem: *u8, cert_len: i32, key_pem: *u8, key_len: i32): i64;
extern function http2_tls_server_ctx_destroy_c(srv_ctx_h: i64): void;
extern function http2_hpack_decode_get_request_c(block: *u8, block_len: i32, out_is_get: *i32, out_path: *u8, path_cap: i32, out_path_len: *i32): i32;
extern function http2_hpack_encode_status_c(status: i32, out: *u8, out_cap: i32): i32;

// See implementation.

/** Exported function `http_libc_get_c`.
 * Implements `http_libc_get_c`.
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @return i32
 */
export function http_libc_get_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32): i32 {
  unsafe { return http_get_c(url, url_len, out_buf, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_post_c`.
 * Implements `http_libc_post_c`.
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @return i32
 */
export function http_libc_post_c(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32): i32 {
  unsafe { return http_post_c(url, url_len, body, body_len, out_buf, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_head_c`.
 * Implements `http_libc_head_c`.
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @return i32
 */
export function http_libc_head_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32): i32 {
  unsafe { return http_head_c(url, url_len, out_buf, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_put_c`.
 * Implements `http_libc_put_c`.
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @return i32
 */
export function http_libc_put_c(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32): i32 {
  unsafe { return http_put_c(url, url_len, body, body_len, out_buf, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_delete_c`.
 * Implements `http_libc_delete_c`.
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @return i32
 */
export function http_libc_delete_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32): i32 {
  unsafe { return http_delete_c(url, url_len, out_buf, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_patch_c`.
 * Implements `http_libc_patch_c`.
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @return i32
 */
export function http_libc_patch_c(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32): i32 {
  unsafe { return http_patch_c(url, url_len, body, body_len, out_buf, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_options_c`.
 * Implements `http_libc_options_c`.
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @return i32
 */
export function http_libc_options_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32): i32 {
  unsafe { return http_options_c(url, url_len, out_buf, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_get_timeout_c`.
 * Implements `http_libc_get_timeout_c`.
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http_libc_get_timeout_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_get_timeout_c(url, url_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_post_timeout_c`.
 * Implements `http_libc_post_timeout_c`.
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http_libc_post_timeout_c(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_post_timeout_c(url, url_len, body, body_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_head_timeout_c`.
 * Implements `http_libc_head_timeout_c`.
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http_libc_head_timeout_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_head_timeout_c(url, url_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_put_timeout_c`.
 * Implements `http_libc_put_timeout_c`.
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http_libc_put_timeout_c(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_put_timeout_c(url, url_len, body, body_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_delete_timeout_c`.
 * Implements `http_libc_delete_timeout_c`.
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http_libc_delete_timeout_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_delete_timeout_c(url, url_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_patch_timeout_c`.
 * Implements `http_libc_patch_timeout_c`.
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http_libc_patch_timeout_c(url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_patch_timeout_c(url, url_len, body, body_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_options_timeout_c`.
 * Implements `http_libc_options_timeout_c`.
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http_libc_options_timeout_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_options_timeout_c(url, url_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_request_ex_c`.
 * Implements `http_libc_request_ex_c`.
 * @param method *u8
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @return i32
 */
export function http_libc_request_ex_c(method: *u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32): i32 {
  unsafe { return http_request_ex_c(method, url, url_len, body, body_len, out_buf, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_request_method_c`.
 * Implements `http_libc_request_method_c`.
 * @param method_u8 u8
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @return i32
 */
export function http_libc_request_method_c(method_u8: u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32): i32 {
  unsafe { return http_request_method_c(method_u8, url, url_len, body, body_len, out_buf, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_request_method_timeout_c`.
 * Implements `http_libc_request_method_timeout_c`.
 * @param method_u8 u8
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http_libc_request_method_timeout_c(method_u8: u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_request_method_timeout_c(method_u8, url, url_len, body, body_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_respond_get_ok_c`.
 * Implements `http_libc_respond_get_ok_c`.
 * @param fd i32
 * @param body *u8
 * @param body_len i32
 * @return i32
 */
export function http_libc_respond_get_ok_c(fd: i32, body: *u8, body_len: i32): i32 {
  unsafe { return http_respond_get_ok_c(fd, body, body_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_listen_c`.
 * Implements `http_libc_listen_c`.
 * @param addr_u32 u32
 * @param port_u32 u32
 * @param backlog i32
 * @return i32
 */
export function http_libc_listen_c(addr_u32: u32, port_u32: u32, backlog: i32): i32 {
  unsafe { return http_listen_c(addr_u32, port_u32, backlog); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_serve_one_c`.
 * Implements `http_libc_serve_one_c`.
 * @param listener_fd i32
 * @param body *u8
 * @param body_len i32
 * @param timeout_ms u32
 * @return i32
 */
export function http_libc_serve_one_c(listener_fd: i32, body: *u8, body_len: i32, timeout_ms: u32): i32 {
  unsafe { return http_serve_one_c(listener_fd, body, body_len, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_client_pool_create_c`.
 * Implements `http_libc_client_pool_create_c`.
 * @param host *u8
 * @param host_len i32
 * @param port *u8
 * @param port_len i32
 * @param max_conns i32
 * @return i64
 */
export function http_libc_client_pool_create_c(host: *u8, host_len: i32, port: *u8, port_len: i32, max_conns: i32): i64 {
  unsafe { return http_client_pool_create_c(host, host_len, port, port_len, max_conns); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_client_pool_destroy_c`.
 * Implements `http_libc_client_pool_destroy_c`.
 * @param pool_h i64
 * @return void
 */
export function http_libc_client_pool_destroy_c(pool_h: i64): void {
  unsafe { http_client_pool_destroy_c(pool_h); }
}

/** Exported function `http_libc_client_pool_get_c`.
 * Implements `http_libc_client_pool_get_c`.
 * @param pool_h i64
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @return i32
 */
export function http_libc_client_pool_get_c(pool_h: i64, url: *u8, url_len: i32, out_buf: *u8, out_cap: i32): i32 {
  unsafe { return http_client_pool_get_c(pool_h, url, url_len, out_buf, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_parse_status_line_c`.
 * Implements `http_libc_parse_status_line_c`.
 * @param line *u8
 * @param len i32
 * @param out_code *i32
 * @return i32
 */
export function http_libc_parse_status_line_c(line: *u8, len: i32, out_code: *i32): i32 {
  unsafe { return http_parse_status_line_c(line, len, out_code); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_headers_body_offset_c`.
 * Implements `http_libc_headers_body_offset_c`.
 * @param buf *u8
 * @param len i32
 * @param out_off *i32
 * @return i32
 */
export function http_libc_headers_body_offset_c(buf: *u8, len: i32, out_off: *i32): i32 {
  unsafe { return http_headers_body_offset_c(buf, len, out_off); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_has_chunked_encoding_c`.
 * Implements `http_libc_has_chunked_encoding_c`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function http_libc_has_chunked_encoding_c(buf: *u8, len: i32): i32 {
  unsafe { return http_has_chunked_encoding_c(buf, len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_has_keep_alive_c`.
 * Implements `http_libc_has_keep_alive_c`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function http_libc_has_keep_alive_c(buf: *u8, len: i32): i32 {
  unsafe { return http_has_keep_alive_c(buf, len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_decode_chunked_body_c`.
 * Implements `http_libc_decode_chunked_body_c`.
 * @param buf *u8
 * @param len i32
 * @param hdr_end i32
 * @param out_body *u8
 * @param out_cap i32
 * @return i32
 */
export function http_libc_decode_chunked_body_c(buf: *u8, len: i32, hdr_end: i32, out_body: *u8, out_cap: i32): i32 {
  unsafe { return http_decode_chunked_body_c(buf, len, hdr_end, out_body, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_build_get_keep_alive_c`.
 * Implements `http_libc_build_get_keep_alive_c`.
 * @param host *u8
 * @param path *u8
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http_libc_build_get_keep_alive_c(host: *u8, path: *u8, out: *u8, out_cap: i32): i32 {
  unsafe { return http_build_get_keep_alive_c(host, path, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_is_upgrade_websocket_c`.
 * Implements `http_libc_is_upgrade_websocket_c`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function http_libc_is_upgrade_websocket_c(buf: *u8, len: i32): i32 {
  unsafe { return http_is_upgrade_websocket_c(buf, len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_build_ws_upgrade_101_c`.
 * Implements `http_libc_build_ws_upgrade_101_c`.
 * @param accept *u8
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http_libc_build_ws_upgrade_101_c(accept: *u8, out: *u8, out_cap: i32): i32 {
  unsafe { return http_build_ws_upgrade_101_c(accept, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_is_https_available_c`.
 * Implements `http_libc_is_https_available_c`.
 * @return i32
 */
export function http_libc_is_https_available_c(): i32 {
  unsafe { return http_is_https_available_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_https_smoke_c`.
 * Implements `http_libc_https_smoke_c`.
 * @return i32
 */
export function http_libc_https_smoke_c(): i32 {
  unsafe { return http_https_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_response_parse_c`.
 * Implements `http_libc_response_parse_c`.
 * @param buf *u8
 * @param len i32
 * @param out_status *i32
 * @param out_hdr_end *i32
 * @param out_body_len *i32
 * @param out_chunked *i32
 * @return i32
 */
export function http_libc_response_parse_c(buf: *u8, len: i32, out_status: *i32, out_hdr_end: *i32, out_body_len: *i32, out_chunked: *i32): i32 {
  unsafe { return http_response_parse_c(buf, len, out_status, out_hdr_end, out_body_len, out_chunked); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_response_parse_smoke_c`.
 * Implements `http_libc_response_parse_smoke_c`.
 * @return i32
 */
export function http_libc_response_parse_smoke_c(): i32 {
  unsafe { return http_response_parse_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_response_body_ptr_c`.
 * Implements `http_libc_response_body_ptr_c`.
 * @param buf *u8
 * @param hdr_end i32
 * @return *u8
 */
export function http_libc_response_body_ptr_c(buf: *u8, hdr_end: i32): *u8 {
  unsafe { return http_response_body_ptr_c(buf, hdr_end); }
  return 0 as *u8; // unreachable — typeck workaround
}

/** Exported function `http_libc_response_body_copy_c`.
 * Implements `http_libc_response_body_copy_c`.
 * @param buf *u8
 * @param hdr_end i32
 * @param body_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http_libc_response_body_copy_c(buf: *u8, hdr_end: i32, body_len: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http_response_body_copy_c(buf, hdr_end, body_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_response_body_owned_smoke_c`.
 * Implements `http_libc_response_body_owned_smoke_c`.
 * @return i32
 */
export function http_libc_response_body_owned_smoke_c(): i32 {
  unsafe { return http_response_body_owned_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_url_exceeds_string_cap_c`.
 * Implements `http_libc_url_exceeds_string_cap_c`.
 * @param url_len i32
 * @return i32
 */
export function http_libc_url_exceeds_string_cap_c(url_len: i32): i32 {
  unsafe { return http_url_exceeds_string_cap_c(url_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_url_copy_c`.
 * Implements `http_libc_url_copy_c`.
 * @param src *u8
 * @param len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http_libc_url_copy_c(src: *u8, len: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http_url_copy_c(src, len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_url_owned_smoke_c`.
 * Implements `http_libc_url_owned_smoke_c`.
 * @return i32
 */
export function http_libc_url_owned_smoke_c(): i32 {
  unsafe { return http_url_owned_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_request_owned_smoke_c`.
 * Implements `http_libc_request_owned_smoke_c`.
 * @return i32
 */
export function http_libc_request_owned_smoke_c(): i32 {
  unsafe { return http_request_owned_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_preface_len_c`.
 * Implements `http2_libc_preface_len_c`.
 * @return i32
 */
export function http2_libc_preface_len_c(): i32 {
  unsafe { return http2_preface_len_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_is_connection_preface_c`.
 * Implements `http2_libc_is_connection_preface_c`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function http2_libc_is_connection_preface_c(buf: *u8, len: i32): i32 {
  unsafe { return http2_is_connection_preface_c(buf, len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_parse_frame_header_c`.
 * Implements `http2_libc_parse_frame_header_c`.
 * @param buf *u8
 * @param len i32
 * @param out_type *i32
 * @param out_flags *i32
 * @param out_stream_id *i32
 * @param out_payload_len *i32
 * @return i32
 */
export function http2_libc_parse_frame_header_c(buf: *u8, len: i32, out_type: *i32, out_flags: *i32, out_stream_id: *i32, out_payload_len: *i32): i32 {
  unsafe { return http2_parse_frame_header_c(buf, len, out_type, out_flags, out_stream_id, out_payload_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_build_settings_ack_c`.
 * Implements `http2_libc_build_settings_ack_c`.
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_build_settings_ack_c(out: *u8, out_cap: i32): i32 {
  unsafe { return http2_build_settings_ack_c(out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_build_settings_one_c`.
 * Implements `http2_libc_build_settings_one_c`.
 * @param setting_id i32
 * @param value i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_build_settings_one_c(setting_id: i32, value: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_build_settings_one_c(setting_id, value, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_wire_is_available_c`.
 * Implements `http2_libc_wire_is_available_c`.
 * @return i32
 */
export function http2_libc_wire_is_available_c(): i32 {
  unsafe { return http2_wire_is_available_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_client_is_available_c`.
 * Implements `http2_libc_client_is_available_c`.
 * @return i32
 */
export function http2_libc_client_is_available_c(): i32 {
  unsafe { return http2_client_is_available_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_alpn_h2_len_c`.
 * Implements `http2_libc_alpn_h2_len_c`.
 * @return i32
 */
export function http2_libc_alpn_h2_len_c(): i32 {
  unsafe { return http2_alpn_h2_len_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_write_alpn_h2_c`.
 * Write path helper `http2_libc_write_alpn_h2_c`.
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_write_alpn_h2_c(out: *u8, out_cap: i32): i32 {
  unsafe { return http2_write_alpn_h2_c(out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_smoke_c`.
 * Implements `http2_libc_smoke_c`.
 * @return i32
 */
export function http2_libc_smoke_c(): i32 {
  unsafe { return http2_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_encode_indexed_c`.
 * Implements `http2_libc_hpack_encode_indexed_c`.
 * @param index i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_hpack_encode_indexed_c(index: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_hpack_encode_indexed_c(index, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_encode_literal_c`.
 * Implements `http2_libc_hpack_encode_literal_c`.
 * @param name_index i32
 * @param value *u8
 * @param value_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_hpack_encode_literal_c(name_index: i32, value: *u8, value_len: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_hpack_encode_literal_c(name_index, value, value_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_encode_get_request_c`.
 * Implements `http2_libc_hpack_encode_get_request_c`.
 * @param authority *u8
 * @param authority_len i32
 * @param path *u8
 * @param path_len i32
 * @param is_https i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_hpack_encode_get_request_c(authority: *u8, authority_len: i32, path: *u8, path_len: i32, is_https: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_hpack_encode_get_request_c(authority, authority_len, path, path_len, is_https, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_decode_status_c`.
 * Implements `http2_libc_hpack_decode_status_c`.
 * @param block *u8
 * @param block_len i32
 * @param out_status *i32
 * @return i32
 */
export function http2_libc_hpack_decode_status_c(block: *u8, block_len: i32, out_status: *i32): i32 {
  unsafe { return http2_hpack_decode_status_c(block, block_len, out_status); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_smoke_c`.
 * Implements `http2_libc_hpack_smoke_c`.
 * @return i32
 */
export function http2_libc_hpack_smoke_c(): i32 {
  unsafe { return http2_hpack_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_dyn_reset_c`.
 * Implements `http2_libc_hpack_dyn_reset_c`.
 * @return void
 */
export function http2_libc_hpack_dyn_reset_c(): void {
  unsafe { http2_hpack_dyn_reset_c(); }
}

/** Exported function `http2_libc_hpack_dyn_count_c`.
 * Implements `http2_libc_hpack_dyn_count_c`.
 * @return i32
 */
export function http2_libc_hpack_dyn_count_c(): i32 {
  unsafe { return http2_hpack_dyn_count_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_encode_literal_incremental_c`.
 * Implements `http2_libc_hpack_encode_literal_incremental_c`.
 * @param name_index i32
 * @param value *u8
 * @param value_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_hpack_encode_literal_incremental_c(name_index: i32, value: *u8, value_len: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_hpack_encode_literal_incremental_c(name_index, value, value_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_encode_indexed_any_c`.
 * Implements `http2_libc_hpack_encode_indexed_any_c`.
 * @param index i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_hpack_encode_indexed_any_c(index: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_hpack_encode_indexed_any_c(index, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_encode_request_c`.
 * Implements `http2_libc_hpack_encode_request_c`.
 * @param method_u8 u8
 * @param authority *u8
 * @param authority_len i32
 * @param path *u8
 * @param path_len i32
 * @param is_https i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_hpack_encode_request_c(method_u8: u8, authority: *u8, authority_len: i32, path: *u8, path_len: i32, is_https: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_hpack_encode_request_c(method_u8, authority, authority_len, path, path_len, is_https, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_dyn_smoke_c`.
 * Implements `http2_libc_hpack_dyn_smoke_c`.
 * @return i32
 */
export function http2_libc_hpack_dyn_smoke_c(): i32 {
  unsafe { return http2_hpack_dyn_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_server_dyn_create_c`.
 * Implements `http2_libc_hpack_server_dyn_create_c`.
 * @param peer *Http2PeerSettings
 * @return i64
 */
export function http2_libc_hpack_server_dyn_create_c(peer: *Http2PeerSettings): i64 {
  unsafe { return http2_hpack_server_dyn_create_c(peer); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_server_dyn_destroy_c`.
 * Implements `http2_libc_hpack_server_dyn_destroy_c`.
 * @param handle i64
 * @return void
 */
export function http2_libc_hpack_server_dyn_destroy_c(handle: i64): void {
  unsafe { http2_hpack_server_dyn_destroy_c(handle); }
}

/** Exported function `http2_libc_hpack_server_dyn_set_table_size_h_c`.
 * Implements `http2_libc_hpack_server_dyn_set_table_size_h_c`.
 * @param handle i64
 * @param size i32
 * @return void
 */
export function http2_libc_hpack_server_dyn_set_table_size_h_c(handle: i64, size: i32): void {
  unsafe { http2_hpack_server_dyn_set_table_size_h_c(handle, size); }
}

/** Exported function `http2_libc_hpack_server_dyn_max_size_h_c`.
 * Implements `http2_libc_hpack_server_dyn_max_size_h_c`.
 * @param handle i64
 * @return i32
 */
export function http2_libc_hpack_server_dyn_max_size_h_c(handle: i64): i32 {
  unsafe { return http2_hpack_server_dyn_max_size_h_c(handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_server_dyn_count_h_c`.
 * Implements `http2_libc_hpack_server_dyn_count_h_c`.
 * @param handle i64
 * @return i32
 */
export function http2_libc_hpack_server_dyn_count_h_c(handle: i64): i32 {
  unsafe { return http2_hpack_server_dyn_count_h_c(handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_server_encode_status_h_c`.
 * Implements `http2_libc_hpack_server_encode_status_h_c`.
 * @param handle i64
 * @param status i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_hpack_server_encode_status_h_c(handle: i64, status: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_hpack_server_encode_status_h_c(handle, status, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_server_dyn_smoke_c`.
 * Implements `http2_libc_hpack_server_dyn_smoke_c`.
 * @return i32
 */
export function http2_libc_hpack_server_dyn_smoke_c(): i32 {
  unsafe { return http2_hpack_server_dyn_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_frame_payload_limit_c`.
 * Implements `http2_libc_frame_payload_limit_c`.
 * @param max_frame_size i32
 * @return i32
 */
export function http2_libc_frame_payload_limit_c(max_frame_size: i32): i32 {
  unsafe { return http2_frame_payload_limit_c(max_frame_size); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_frame_check_payload_c`.
 * Implements `http2_libc_frame_check_payload_c`.
 * @param payload_len i32
 * @param max_frame_size i32
 * @return i32
 */
export function http2_libc_frame_check_payload_c(payload_len: i32, max_frame_size: i32): i32 {
  unsafe { return http2_frame_check_payload_c(payload_len, max_frame_size); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_frame_count_data_chunks_c`.
 * Implements `http2_libc_frame_count_data_chunks_c`.
 * @param data_len i32
 * @param max_frame_size i32
 * @return i32
 */
export function http2_libc_frame_count_data_chunks_c(data_len: i32, max_frame_size: i32): i32 {
  unsafe { return http2_frame_count_data_chunks_c(data_len, max_frame_size); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_frame_capped_smoke_c`.
 * Implements `http2_libc_frame_capped_smoke_c`.
 * @return i32
 */
export function http2_libc_frame_capped_smoke_c(): i32 {
  unsafe { return http2_frame_capped_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_frame_goaway_c`.
 * Implements `http2_libc_frame_goaway_c`.
 * @return i32
 */
export function http2_libc_frame_goaway_c(): i32 {
  unsafe { return http2_frame_goaway_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_goaway_error_no_error_c`.
 * Implements `http2_libc_goaway_error_no_error_c`.
 * @return i32
 */
export function http2_libc_goaway_error_no_error_c(): i32 {
  unsafe { return http2_goaway_error_no_error_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_err_goaway_c`.
 * Implements `http2_libc_err_goaway_c`.
 * @return i32
 */
export function http2_libc_err_goaway_c(): i32 {
  unsafe { return http2_err_goaway_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_build_goaway_c`.
 * Implements `http2_libc_build_goaway_c`.
 * @param last_stream_id i32
 * @param code i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_build_goaway_c(last_stream_id: i32, code: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_build_goaway_c(last_stream_id, code, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_parse_goaway_c`.
 * Implements `http2_libc_parse_goaway_c`.
 * @param payload *u8
 * @param plen i32
 * @param out_last_stream *i32
 * @param out_code *i32
 * @return i32
 */
export function http2_libc_parse_goaway_c(payload: *u8, plen: i32, out_last_stream: *i32, out_code: *i32): i32 {
  unsafe { return http2_parse_goaway_c(payload, plen, out_last_stream, out_code); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_goaway_smoke_c`.
 * Implements `http2_libc_goaway_smoke_c`.
 * @return i32
 */
export function http2_libc_goaway_smoke_c(): i32 {
  unsafe { return http2_goaway_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_frame_ping_c`.
 * Implements `http2_libc_frame_ping_c`.
 * @return i32
 */
export function http2_libc_frame_ping_c(): i32 {
  unsafe { return http2_frame_ping_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_err_ping_c`.
 * Implements `http2_libc_err_ping_c`.
 * @return i32
 */
export function http2_libc_err_ping_c(): i32 {
  unsafe { return http2_err_ping_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_build_ping_c`.
 * Implements `http2_libc_build_ping_c`.
 * @param opaque *u8
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_build_ping_c(opaque: *u8, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_build_ping_c(opaque, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_build_ping_ack_c`.
 * Implements `http2_libc_build_ping_ack_c`.
 * @param opaque *u8
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_build_ping_ack_c(opaque: *u8, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_build_ping_ack_c(opaque, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_parse_ping_c`.
 * Implements `http2_libc_parse_ping_c`.
 * @param payload *u8
 * @param plen i32
 * @param out_opaque *u8
 * @return i32
 */
export function http2_libc_parse_ping_c(payload: *u8, plen: i32, out_opaque: *u8): i32 {
  unsafe { return http2_parse_ping_c(payload, plen, out_opaque); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_ping_opaque_match_c`.
 * Implements `http2_libc_ping_opaque_match_c`.
 * @param a *u8
 * @param b *u8
 * @return i32
 */
export function http2_libc_ping_opaque_match_c(a: *u8, b: *u8): i32 {
  unsafe { return http2_ping_opaque_match_c(a, b); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_ping_smoke_c`.
 * Implements `http2_libc_ping_smoke_c`.
 * @return i32
 */
export function http2_libc_ping_smoke_c(): i32 {
  unsafe { return http2_ping_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_frame_rst_stream_c`.
 * Implements `http2_libc_frame_rst_stream_c`.
 * @return i32
 */
export function http2_libc_frame_rst_stream_c(): i32 {
  unsafe { return http2_frame_rst_stream_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_rst_error_cancel_c`.
 * Implements `http2_libc_rst_error_cancel_c`.
 * @return i32
 */
export function http2_libc_rst_error_cancel_c(): i32 {
  unsafe { return http2_rst_error_cancel_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_err_rst_stream_c`.
 * Implements `http2_libc_err_rst_stream_c`.
 * @return i32
 */
export function http2_libc_err_rst_stream_c(): i32 {
  unsafe { return http2_err_rst_stream_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_build_rst_stream_c`.
 * Implements `http2_libc_build_rst_stream_c`.
 * @param stream_id i32
 * @param code i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_build_rst_stream_c(stream_id: i32, code: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_build_rst_stream_c(stream_id, code, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_parse_rst_stream_c`.
 * Implements `http2_libc_parse_rst_stream_c`.
 * @param payload *u8
 * @param plen i32
 * @param out_code *i32
 * @return i32
 */
export function http2_libc_parse_rst_stream_c(payload: *u8, plen: i32, out_code: *i32): i32 {
  unsafe { return http2_parse_rst_stream_c(payload, plen, out_code); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_rst_stream_smoke_c`.
 * Implements `http2_libc_rst_stream_smoke_c`.
 * @return i32
 */
export function http2_libc_rst_stream_smoke_c(): i32 {
  unsafe { return http2_rst_stream_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_reset_stream_c`.
 * Implements `http2_libc_conn_reset_stream_c`.
 * @param conn *Http2Conn
 * @param stream_id i32
 * @param code i32
 * @return i32
 */
export function http2_libc_conn_reset_stream_c(conn: *Http2Conn, stream_id: i32, code: i32): i32 {
  unsafe { return http2_conn_reset_stream_c(conn, stream_id, code); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_http2_complete_smoke_c`.
 * Implements `http2_libc_http2_complete_smoke_c`.
 * @return i32
 */
export function http2_libc_http2_complete_smoke_c(): i32 {
  unsafe { return http2_http2_complete_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_build_headers_frame_c`.
 * Implements `http2_libc_build_headers_frame_c`.
 * @param stream_id i32
 * @param flags i32
 * @param hpack *u8
 * @param hpack_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_build_headers_frame_c(stream_id: i32, flags: i32, hpack: *u8, hpack_len: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_build_headers_frame_c(stream_id, flags, hpack, hpack_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_build_data_frame_c`.
 * Implements `http2_libc_build_data_frame_c`.
 * @param stream_id i32
 * @param flags i32
 * @param data *u8
 * @param data_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_build_data_frame_c(stream_id: i32, flags: i32, data: *u8, data_len: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_build_data_frame_c(stream_id, flags, data, data_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_build_get_headers_frame_c`.
 * Implements `http2_libc_build_get_headers_frame_c`.
 * @param authority *u8
 * @param authority_len i32
 * @param path *u8
 * @param path_len i32
 * @param is_https i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_build_get_headers_frame_c(authority: *u8, authority_len: i32, path: *u8, path_len: i32, is_https: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_build_get_headers_frame_c(authority, authority_len, path, path_len, is_https, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_build_request_headers_frame_c`.
 * Implements `http2_libc_build_request_headers_frame_c`.
 * @param method_u8 u8
 * @param authority *u8
 * @param authority_len i32
 * @param path *u8
 * @param path_len i32
 * @param is_https i32
 * @param has_body i32
 * @param stream_id i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_build_request_headers_frame_c(method_u8: u8, authority: *u8, authority_len: i32, path: *u8, path_len: i32, is_https: i32, has_body: i32, stream_id: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_build_request_headers_frame_c(method_u8, authority, authority_len, path, path_len, is_https, has_body, stream_id, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_client_smoke_c`.
 * Implements `http2_libc_client_smoke_c`.
 * @return i32
 */
export function http2_libc_client_smoke_c(): i32 {
  unsafe { return http2_client_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_network_is_available_c`.
 * Implements `http2_libc_network_is_available_c`.
 * @return i32
 */
export function http2_libc_network_is_available_c(): i32 {
  unsafe { return http2_network_is_available_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_network_smoke_c`.
 * Implements `http2_libc_network_smoke_c`.
 * @return i32
 */
export function http2_libc_network_smoke_c(): i32 {
  unsafe { return http2_network_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_h2_get_c`.
 * Implements `http_libc_h2_get_c`.
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http_libc_h2_get_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_h2_get_c(url, url_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_h2_request_c`.
 * Implements `http_libc_h2_request_c`.
 * @param method_u8 u8
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http_libc_h2_request_c(method_u8: u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_h2_request_c(method_u8, url, url_len, body, body_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_request_method_h2_c`.
 * Implements `http_libc_request_method_h2_c`.
 * @param method_u8 u8
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http_libc_request_method_h2_c(method_u8: u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_request_method_h2_c(method_u8, url, url_len, body, body_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_huffman_decode_c`.
 * Implements `http2_libc_hpack_huffman_decode_c`.
 * @param in *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_hpack_huffman_decode_c(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_hpack_huffman_decode_c(in, in_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_huffman_is_available_c`.
 * Implements `http2_libc_hpack_huffman_is_available_c`.
 * @return i32
 */
export function http2_libc_hpack_huffman_is_available_c(): i32 {
  unsafe { return http2_hpack_huffman_is_available_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_huffman_smoke_c`.
 * Implements `http2_libc_hpack_huffman_smoke_c`.
 * @return i32
 */
export function http2_libc_hpack_huffman_smoke_c(): i32 {
  unsafe { return http2_hpack_huffman_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_build_window_update_c`.
 * Implements `http2_libc_build_window_update_c`.
 * @param stream_id i32
 * @param increment i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_build_window_update_c(stream_id: i32, increment: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_build_window_update_c(stream_id, increment, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_default_initial_window_c`.
 * Implements `http2_libc_default_initial_window_c`.
 * @return i32
 */
export function http2_libc_default_initial_window_c(): i32 {
  unsafe { return http2_default_initial_window_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_flow_control_smoke_c`.
 * Implements `http2_libc_flow_control_smoke_c`.
 * @return i32
 */
export function http2_libc_flow_control_smoke_c(): i32 {
  unsafe { return http2_flow_control_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_flow_state_init_c`.
 * Implements `http2_libc_flow_state_init_c`.
 * @param st *Http2FlowState
 * @return void
 */
export function http2_libc_flow_state_init_c(st: *Http2FlowState): void {
  unsafe { http2_flow_state_init_c(st); }
}

/** Exported function `http2_libc_flow_state_reset_stream_c`.
 * Implements `http2_libc_flow_state_reset_stream_c`.
 * @param st *Http2FlowState
 * @param initial_window i32
 * @return void
 */
export function http2_libc_flow_state_reset_stream_c(st: *Http2FlowState, initial_window: i32): void {
  unsafe { http2_flow_state_reset_stream_c(st, initial_window); }
}

/** Exported function `http2_libc_flow_state_apply_initial_window_c`.
 * Implements `http2_libc_flow_state_apply_initial_window_c`.
 * @param st *Http2FlowState
 * @param initial_window i32
 * @return void
 */
export function http2_libc_flow_state_apply_initial_window_c(st: *Http2FlowState, initial_window: i32): void {
  unsafe { http2_flow_state_apply_initial_window_c(st, initial_window); }
}

/** Exported function `http2_libc_flow_state_apply_window_update_c`.
 * Implements `http2_libc_flow_state_apply_window_update_c`.
 * @param st *Http2FlowState
 * @param stream_id i32
 * @param increment i32
 * @return i32
 */
export function http2_libc_flow_state_apply_window_update_c(st: *Http2FlowState, stream_id: i32, increment: i32): i32 {
  unsafe { return http2_flow_state_apply_window_update_c(st, stream_id, increment); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_flow_state_max_send_c`.
 * Implements `http2_libc_flow_state_max_send_c`.
 * @param st *Http2FlowState
 * @param want i32
 * @return i32
 */
export function http2_libc_flow_state_max_send_c(st: *Http2FlowState, want: i32): i32 {
  unsafe { return http2_flow_state_max_send_c(st, want); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_flow_state_can_send_c`.
 * Implements `http2_libc_flow_state_can_send_c`.
 * @param st *Http2FlowState
 * @param want i32
 * @return i32
 */
export function http2_libc_flow_state_can_send_c(st: *Http2FlowState, want: i32): i32 {
  unsafe { return http2_flow_state_can_send_c(st, want); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_flow_state_consume_send_c`.
 * Implements `http2_libc_flow_state_consume_send_c`.
 * @param st *Http2FlowState
 * @param nbytes i32
 * @return i32
 */
export function http2_libc_flow_state_consume_send_c(st: *Http2FlowState, nbytes: i32): i32 {
  unsafe { return http2_flow_state_consume_send_c(st, nbytes); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_parse_window_update_payload_c`.
 * Implements `http2_libc_parse_window_update_payload_c`.
 * @param payload *u8
 * @param plen i32
 * @param out_increment *i32
 * @return i32
 */
export function http2_libc_parse_window_update_payload_c(payload: *u8, plen: i32, out_increment: *i32): i32 {
  unsafe { return http2_parse_window_update_payload_c(payload, plen, out_increment); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_flow_state_smoke_c`.
 * Implements `http2_libc_flow_state_smoke_c`.
 * @return i32
 */
export function http2_libc_flow_state_smoke_c(): i32 {
  unsafe { return http2_flow_state_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_flow_recv_init_c`.
 * Implements `http2_libc_flow_recv_init_c`.
 * @param st *Http2FlowRecvState
 * @return void
 */
export function http2_libc_flow_recv_init_c(st: *Http2FlowRecvState): void {
  unsafe { http2_flow_recv_init_c(st); }
}

/** Exported function `http2_libc_flow_recv_reset_stream_c`.
 * Implements `http2_libc_flow_recv_reset_stream_c`.
 * @param st *Http2FlowRecvState
 * @param initial_window i32
 * @return void
 */
export function http2_libc_flow_recv_reset_stream_c(st: *Http2FlowRecvState, initial_window: i32): void {
  unsafe { http2_flow_recv_reset_stream_c(st, initial_window); }
}

/** Exported function `http2_libc_flow_recv_on_data_c`.
 * Implements `http2_libc_flow_recv_on_data_c`.
 * @param st *Http2FlowRecvState
 * @param nbytes i32
 * @return i32
 */
export function http2_libc_flow_recv_on_data_c(st: *Http2FlowRecvState, nbytes: i32): i32 {
  unsafe { return http2_flow_recv_on_data_c(st, nbytes); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_flow_recv_release_c`.
 * Implements `http2_libc_flow_recv_release_c`.
 * @param st *Http2FlowRecvState
 * @param stream_id i32
 * @param nbytes i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_flow_recv_release_c(st: *Http2FlowRecvState, stream_id: i32, nbytes: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_flow_recv_release_c(st, stream_id, nbytes, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_flow_recv_smoke_c`.
 * Implements `http2_libc_flow_recv_smoke_c`.
 * @return i32
 */
export function http2_libc_flow_recv_smoke_c(): i32 {
  unsafe { return http2_flow_recv_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_frame_push_promise_c`.
 * Implements `http2_libc_frame_push_promise_c`.
 * @return i32
 */
export function http2_libc_frame_push_promise_c(): i32 {
  unsafe { return http2_frame_push_promise_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_is_push_promise_frame_c`.
 * Implements `http2_libc_is_push_promise_frame_c`.
 * @param ftype i32
 * @return i32
 */
export function http2_libc_is_push_promise_frame_c(ftype: i32): i32 {
  unsafe { return http2_is_push_promise_frame_c(ftype); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_parse_push_promise_stream_c`.
 * Implements `http2_libc_parse_push_promise_stream_c`.
 * @param payload *u8
 * @param plen i32
 * @param out_promised_id *i32
 * @return i32
 */
export function http2_libc_parse_push_promise_stream_c(payload: *u8, plen: i32, out_promised_id: *i32): i32 {
  unsafe { return http2_parse_push_promise_stream_c(payload, plen, out_promised_id); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_is_h2c_upgrade_response_c`.
 * Implements `http2_libc_is_h2c_upgrade_response_c`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function http2_libc_is_h2c_upgrade_response_c(buf: *u8, len: i32): i32 {
  unsafe { return http2_is_h2c_upgrade_response_c(buf, len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_h2c_is_available_c`.
 * Implements `http2_libc_h2c_is_available_c`.
 * @return i32
 */
export function http2_libc_h2c_is_available_c(): i32 {
  unsafe { return http2_h2c_is_available_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_push_h2c_smoke_c`.
 * Implements `http2_libc_push_h2c_smoke_c`.
 * @return i32
 */
export function http2_libc_push_h2c_smoke_c(): i32 {
  unsafe { return http2_push_h2c_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_h2c_wire_is_available_c`.
 * Implements `http2_libc_h2c_wire_is_available_c`.
 * @return i32
 */
export function http2_libc_h2c_wire_is_available_c(): i32 {
  unsafe { return http2_h2c_wire_is_available_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_h2c_session_begin_c`.
 * Implements `http2_libc_h2c_session_begin_c`.
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_h2c_session_begin_c(out: *u8, out_cap: i32): i32 {
  unsafe { return http2_h2c_session_begin_c(out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_push_collect_data_c`.
 * Implements `http2_libc_push_collect_data_c`.
 * @param promised_id i32
 * @param stream_id i32
 * @param data *u8
 * @param dlen i32
 * @param inout_promised_id *i32
 * @param acc *u8
 * @param acc_cap i32
 * @param acc_len *i32
 * @return i32
 */
export function http2_libc_push_collect_data_c(promised_id: i32, stream_id: i32, data: *u8, dlen: i32, inout_promised_id: *i32, acc: *u8, acc_cap: i32, acc_len: *i32): i32 {
  unsafe { return http2_push_collect_data_c(promised_id, stream_id, data, dlen, inout_promised_id, acc, acc_cap, acc_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_push_fetch_smoke_c`.
 * Implements `http2_libc_push_fetch_smoke_c`.
 * @return i32
 */
export function http2_libc_push_fetch_smoke_c(): i32 {
  unsafe { return http2_push_fetch_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_push_last_reset_c`.
 * Implements `http2_libc_push_last_reset_c`.
 * @return void
 */
export function http2_libc_push_last_reset_c(): void {
  unsafe { http2_push_last_reset_c(); }
}

/** Exported function `http2_libc_push_last_copy_c`.
 * Implements `http2_libc_push_last_copy_c`.
 * @param out_meta *Http2PushLast
 * @param out_body *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_push_last_copy_c(out_meta: *Http2PushLast, out_body: *u8, out_cap: i32): i32 {
  unsafe { return http2_push_last_copy_c(out_meta, out_body, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_push_network_smoke_c`.
 * Implements `http2_libc_push_network_smoke_c`.
 * @return i32
 */
export function http2_libc_push_network_smoke_c(): i32 {
  unsafe { return http2_push_network_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_session_request_h2c_c`.
 * Implements `http2_libc_session_request_h2c_c`.
 * @param fd i32
 * @param method_u8 u8
 * @param authority *u8
 * @param authority_len i32
 * @param path *u8
 * @param path_len i32
 * @param body *u8
 * @param body_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_session_request_h2c_c(fd: i32, method_u8: u8, authority: *u8, authority_len: i32, path: *u8, path_len: i32, body: *u8, body_len: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_session_request_h2c_c(fd, method_u8, authority, authority_len, path, path_len, body, body_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_h2c_network_smoke_c`.
 * Implements `http2_libc_h2c_network_smoke_c`.
 * @return i32
 */
export function http2_libc_h2c_network_smoke_c(): i32 {
  unsafe { return http2_h2c_network_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_h2c_get_c`.
 * Implements `http_libc_h2c_get_c`.
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http_libc_h2c_get_c(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_h2c_get_c(url, url_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_h2c_request_c`.
 * Implements `http_libc_h2c_request_c`.
 * @param method_u8 u8
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http_libc_h2c_request_c(method_u8: u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_h2c_request_c(method_u8, url, url_len, body, body_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_request_method_h2c_c`.
 * Implements `http_libc_request_method_h2c_c`.
 * @param method_u8 u8
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http_libc_request_method_h2c_c(method_u8: u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_request_method_h2c_c(method_u8, url, url_len, body, body_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_h2c_client_smoke_c`.
 * Implements `http_libc_h2c_client_smoke_c`.
 * @return i32
 */
export function http_libc_h2c_client_smoke_c(): i32 {
  unsafe { return http_h2c_client_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_stream_registry_init_c`.
 * Implements `http2_libc_stream_registry_init_c`.
 * @param reg *Http2StreamRegistry
 * @return void
 */
export function http2_libc_stream_registry_init_c(reg: *Http2StreamRegistry): void {
  unsafe { http2_stream_registry_init_c(reg); }
}

/** Exported function `http2_libc_stream_registry_open_c`.
 * Implements `http2_libc_stream_registry_open_c`.
 * @param reg *Http2StreamRegistry
 * @return i32
 */
export function http2_libc_stream_registry_open_c(reg: *Http2StreamRegistry): i32 {
  unsafe { return http2_stream_registry_open_c(reg); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_stream_registry_close_c`.
 * Implements `http2_libc_stream_registry_close_c`.
 * @param reg *Http2StreamRegistry
 * @param stream_id i32
 * @return void
 */
export function http2_libc_stream_registry_close_c(reg: *Http2StreamRegistry, stream_id: i32): void {
  unsafe { http2_stream_registry_close_c(reg, stream_id); }
}

/** Exported function `http2_libc_stream_registry_is_open_c`.
 * Implements `http2_libc_stream_registry_is_open_c`.
 * @param reg *Http2StreamRegistry
 * @param stream_id i32
 * @return i32
 */
export function http2_libc_stream_registry_is_open_c(reg: *Http2StreamRegistry, stream_id: i32): i32 {
  unsafe { return http2_stream_registry_is_open_c(reg, stream_id); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_stream_registry_smoke_c`.
 * Implements `http2_libc_stream_registry_smoke_c`.
 * @return i32
 */
export function http2_libc_stream_registry_smoke_c(): i32 {
  unsafe { return http2_stream_registry_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_peer_settings_init_c`.
 * Implements `http2_libc_peer_settings_init_c`.
 * @param ps *Http2PeerSettings
 * @return void
 */
export function http2_libc_peer_settings_init_c(ps: *Http2PeerSettings): void {
  unsafe { http2_peer_settings_init_c(ps); }
}

/** Exported function `http2_libc_settings_entry_count_c`.
 * Implements `http2_libc_settings_entry_count_c`.
 * @param plen i32
 * @return i32
 */
export function http2_libc_settings_entry_count_c(plen: i32): i32 {
  unsafe { return http2_settings_entry_count_c(plen); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_parse_settings_entry_c`.
 * Implements `http2_libc_parse_settings_entry_c`.
 * @param payload *u8
 * @param plen i32
 * @param entry_index i32
 * @param out_id *i32
 * @param out_value *i32
 * @return i32
 */
export function http2_libc_parse_settings_entry_c(payload: *u8, plen: i32, entry_index: i32, out_id: *i32, out_value: *i32): i32 {
  unsafe { return http2_parse_settings_entry_c(payload, plen, entry_index, out_id, out_value); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_peer_settings_apply_entry_c`.
 * Implements `http2_libc_peer_settings_apply_entry_c`.
 * @param ps *Http2PeerSettings
 * @param setting_id i32
 * @param value i32
 * @return void
 */
export function http2_libc_peer_settings_apply_entry_c(ps: *Http2PeerSettings, setting_id: i32, value: i32): void {
  unsafe { http2_peer_settings_apply_entry_c(ps, setting_id, value); }
}

/** Exported function `http2_libc_peer_settings_consume_payload_c`.
 * Implements `http2_libc_peer_settings_consume_payload_c`.
 * @param payload *u8
 * @param plen i32
 * @param ps *Http2PeerSettings
 * @return i32
 */
export function http2_libc_peer_settings_consume_payload_c(payload: *u8, plen: i32, ps: *Http2PeerSettings): i32 {
  unsafe { return http2_peer_settings_consume_payload_c(payload, plen, ps); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_build_client_settings_c`.
 * Implements `http2_libc_build_client_settings_c`.
 * @param max_streams i32
 * @param initial_window i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_build_client_settings_c(max_streams: i32, initial_window: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_build_client_settings_c(max_streams, initial_window, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_build_client_settings_ex_c`.
 * Implements `http2_libc_build_client_settings_ex_c`.
 * @param max_streams i32
 * @param initial_window i32
 * @param enable_push i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_build_client_settings_ex_c(max_streams: i32, initial_window: i32, enable_push: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_build_client_settings_ex_c(max_streams, initial_window, enable_push, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_build_client_settings_with_max_frame_c`.
 * Implements `http2_libc_build_client_settings_with_max_frame_c`.
 * @param max_streams i32
 * @param initial_window i32
 * @param enable_push i32
 * @param max_frame_size i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_build_client_settings_with_max_frame_c(max_streams: i32, initial_window: i32, enable_push: i32, max_frame_size: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_build_client_settings_with_max_frame_c(max_streams, initial_window, enable_push, max_frame_size, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_build_server_settings_c`.
 * Implements `http2_libc_build_server_settings_c`.
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_build_server_settings_c(out: *u8, out_cap: i32): i32 {
  unsafe { return http2_build_server_settings_c(out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_setting_enable_push_c`.
 * Implements `http2_libc_setting_enable_push_c`.
 * @return i32
 */
export function http2_libc_setting_enable_push_c(): i32 {
  unsafe { return http2_setting_enable_push_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_setting_header_table_size_c`.
 * Implements `http2_libc_setting_header_table_size_c`.
 * @return i32
 */
export function http2_libc_setting_header_table_size_c(): i32 {
  unsafe { return http2_setting_header_table_size_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_setting_max_frame_size_c`.
 * Implements `http2_libc_setting_max_frame_size_c`.
 * @return i32
 */
export function http2_libc_setting_max_frame_size_c(): i32 {
  unsafe { return http2_setting_max_frame_size_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_setting_max_header_list_size_c`.
 * Implements `http2_libc_setting_max_header_list_size_c`.
 * @return i32
 */
export function http2_libc_setting_max_header_list_size_c(): i32 {
  unsafe { return http2_setting_max_header_list_size_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_peer_settings_enable_push_c`.
 * Implements `http2_libc_peer_settings_enable_push_c`.
 * @param ps *Http2PeerSettings
 * @return i32
 */
export function http2_libc_peer_settings_enable_push_c(ps: *Http2PeerSettings): i32 {
  unsafe { return http2_peer_settings_enable_push_c(ps); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_peer_settings_header_table_size_c`.
 * Implements `http2_libc_peer_settings_header_table_size_c`.
 * @param ps *Http2PeerSettings
 * @return i32
 */
export function http2_libc_peer_settings_header_table_size_c(ps: *Http2PeerSettings): i32 {
  unsafe { return http2_peer_settings_header_table_size_c(ps); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_peer_settings_max_frame_size_c`.
 * Implements `http2_libc_peer_settings_max_frame_size_c`.
 * @param ps *Http2PeerSettings
 * @return i32
 */
export function http2_libc_peer_settings_max_frame_size_c(ps: *Http2PeerSettings): i32 {
  unsafe { return http2_peer_settings_max_frame_size_c(ps); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_peer_settings_max_header_list_size_c`.
 * Implements `http2_libc_peer_settings_max_header_list_size_c`.
 * @param ps *Http2PeerSettings
 * @return i32
 */
export function http2_libc_peer_settings_max_header_list_size_c(ps: *Http2PeerSettings): i32 {
  unsafe { return http2_peer_settings_max_header_list_size_c(ps); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_peer_settings_max_streams_c`.
 * Implements `http2_libc_peer_settings_max_streams_c`.
 * @param ps *Http2PeerSettings
 * @return i32
 */
export function http2_libc_peer_settings_max_streams_c(ps: *Http2PeerSettings): i32 {
  unsafe { return http2_peer_settings_max_streams_c(ps); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_peer_settings_initial_window_c`.
 * Implements `http2_libc_peer_settings_initial_window_c`.
 * @param ps *Http2PeerSettings
 * @return i32
 */
export function http2_libc_peer_settings_initial_window_c(ps: *Http2PeerSettings): i32 {
  unsafe { return http2_peer_settings_initial_window_c(ps); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_settings_smoke_c`.
 * Implements `http2_libc_settings_smoke_c`.
 * @return i32
 */
export function http2_libc_settings_smoke_c(): i32 {
  unsafe { return http2_settings_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_multistream_client_init_c`.
 * Implements `http2_libc_multistream_client_init_c`.
 * @param cli *Http2MultistreamClient
 * @return void
 */
export function http2_libc_multistream_client_init_c(cli: *Http2MultistreamClient): void {
  unsafe { http2_multistream_client_init_c(cli); }
}

/** Exported function `http2_libc_multistream_client_on_settings_c`.
 * Implements `http2_libc_multistream_client_on_settings_c`.
 * @param cli *Http2MultistreamClient
 * @param payload *u8
 * @param plen i32
 * @return i32
 */
export function http2_libc_multistream_client_on_settings_c(cli: *Http2MultistreamClient, payload: *u8, plen: i32): i32 {
  unsafe { return http2_multistream_client_on_settings_c(cli, payload, plen); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_multistream_client_open_stream_c`.
 * Implements `http2_libc_multistream_client_open_stream_c`.
 * @param cli *Http2MultistreamClient
 * @return i32
 */
export function http2_libc_multistream_client_open_stream_c(cli: *Http2MultistreamClient): i32 {
  unsafe { return http2_multistream_client_open_stream_c(cli); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_multistream_client_close_stream_c`.
 * Implements `http2_libc_multistream_client_close_stream_c`.
 * @param cli *Http2MultistreamClient
 * @param stream_id i32
 * @return void
 */
export function http2_libc_multistream_client_close_stream_c(cli: *Http2MultistreamClient, stream_id: i32): void {
  unsafe { http2_multistream_client_close_stream_c(cli, stream_id); }
}

/** Exported function `http2_libc_multistream_client_build_get_c`.
 * Implements `http2_libc_multistream_client_build_get_c`.
 * @param cli *Http2MultistreamClient
 * @param stream_id i32
 * @param authority *u8
 * @param authority_len i32
 * @param path *u8
 * @param path_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_multistream_client_build_get_c(cli: *Http2MultistreamClient, stream_id: i32, authority: *u8, authority_len: i32, path: *u8, path_len: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_multistream_client_build_get_c(cli, stream_id, authority, authority_len, path, path_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_multistream_client_build_parallel_get_c`.
 * Implements `http2_libc_multistream_client_build_parallel_get_c`.
 * @param cli *Http2MultistreamClient
 * @param authority *u8
 * @param authority_len i32
 * @param path *u8
 * @param path_len i32
 * @param n_reqs i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_multistream_client_build_parallel_get_c(cli: *Http2MultistreamClient, authority: *u8, authority_len: i32, path: *u8, path_len: i32, n_reqs: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_multistream_client_build_parallel_get_c(cli, authority, authority_len, path, path_len, n_reqs, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_multistream_client_smoke_c`.
 * Implements `http2_libc_multistream_client_smoke_c`.
 * @return i32
 */
export function http2_libc_multistream_client_smoke_c(): i32 {
  unsafe { return http2_multistream_client_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_init_c`.
 * Implements `http2_libc_conn_init_c`.
 * @param conn *Http2Conn
 * @return void
 */
export function http2_libc_conn_init_c(conn: *Http2Conn): void {
  unsafe { http2_conn_init_c(conn); }
}

/** Exported function `http2_libc_conn_attach_h2c_c`.
 * Implements `http2_libc_conn_attach_h2c_c`.
 * @param fd i32
 * @param conn *Http2Conn
 * @return i32
 */
export function http2_libc_conn_attach_h2c_c(fd: i32, conn: *Http2Conn): i32 {
  unsafe { return http2_conn_attach_h2c_c(fd, conn); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_attach_tls_c`.
 * Implements `http2_libc_conn_attach_tls_c`.
 * @param tls_ctx i64
 * @param conn *Http2Conn
 * @return i32
 */
export function http2_libc_conn_attach_tls_c(tls_ctx: i64, conn: *Http2Conn): i32 {
  unsafe { return http2_conn_attach_tls_c(tls_ctx, conn); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_is_ready_c`.
 * Read path helper `http2_libc_conn_is_ready_c`.
 * @param conn *Http2Conn
 * @return i32
 */
export function http2_libc_conn_is_ready_c(conn: *Http2Conn): i32 {
  unsafe { return http2_conn_is_ready_c(conn); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_handshake_c`.
 * Implements `http2_libc_conn_handshake_c`.
 * @param conn *Http2Conn
 * @return i32
 */
export function http2_libc_conn_handshake_c(conn: *Http2Conn): i32 {
  unsafe { return http2_conn_handshake_c(conn); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_handshake_with_enable_push_c`.
 * Implements `http2_libc_conn_handshake_with_enable_push_c`.
 * @param conn *Http2Conn
 * @param client_enable_push i32
 * @return i32
 */
export function http2_libc_conn_handshake_with_enable_push_c(conn: *Http2Conn, client_enable_push: i32): i32 {
  unsafe { return http2_conn_handshake_with_enable_push_c(conn, client_enable_push); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_handshake_with_max_frame_c`.
 * Implements `http2_libc_conn_handshake_with_max_frame_c`.
 * @param conn *Http2Conn
 * @param client_max_frame_size i32
 * @return i32
 */
export function http2_libc_conn_handshake_with_max_frame_c(conn: *Http2Conn, client_max_frame_size: i32): i32 {
  unsafe { return http2_conn_handshake_with_max_frame_c(conn, client_max_frame_size); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_request_c`.
 * Implements `http2_libc_conn_request_c`.
 * @param conn *Http2Conn
 * @param method_u8 u8
 * @param authority *u8
 * @param authority_len i32
 * @param path *u8
 * @param path_len i32
 * @param body *u8
 * @param body_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_conn_request_c(conn: *Http2Conn, method_u8: u8, authority: *u8, authority_len: i32, path: *u8, path_len: i32, body: *u8, body_len: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_conn_request_c(conn, method_u8, authority, authority_len, path, path_len, body, body_len, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_close_c`.
 * Implements `http2_libc_conn_close_c`.
 * @param conn *Http2Conn
 * @return void
 */
export function http2_libc_conn_close_c(conn: *Http2Conn): void {
  unsafe { http2_conn_close_c(conn); }
}

/** Exported function `http2_libc_conn_shutdown_graceful_c`.
 * Implements `http2_libc_conn_shutdown_graceful_c`.
 * @param conn *Http2Conn
 * @param last_stream_id i32
 * @param code i32
 * @return void
 */
export function http2_libc_conn_shutdown_graceful_c(conn: *Http2Conn, last_stream_id: i32, code: i32): void {
  unsafe { http2_conn_shutdown_graceful_c(conn, last_stream_id, code); }
}

/** Exported function `http2_libc_conn_read_goaway_c`.
 * Read path helper `http2_libc_conn_read_goaway_c`.
 * @param conn *Http2Conn
 * @param out_last_stream *i32
 * @param out_code *i32
 * @return i32
 */
export function http2_libc_conn_read_goaway_c(conn: *Http2Conn, out_last_stream: *i32, out_code: *i32): i32 {
  unsafe { return http2_conn_read_goaway_c(conn, out_last_stream, out_code); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_ping_c`.
 * Implements `http2_libc_conn_ping_c`.
 * @param conn *Http2Conn
 * @param opaque *u8
 * @return i32
 */
export function http2_libc_conn_ping_c(conn: *Http2Conn, opaque: *u8): i32 {
  unsafe { return http2_conn_ping_c(conn, opaque); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_goaway_seen_c`.
 * Implements `http2_libc_conn_goaway_seen_c`.
 * @param conn *Http2Conn
 * @return i32
 */
export function http2_libc_conn_goaway_seen_c(conn: *Http2Conn): i32 {
  unsafe { return http2_conn_goaway_seen_c(conn); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_is_pool_reusable_c`.
 * Implements `http2_libc_conn_is_pool_reusable_c`.
 * @param conn *Http2Conn
 * @return i32
 */
export function http2_libc_conn_is_pool_reusable_c(conn: *Http2Conn): i32 {
  unsafe { return http2_conn_is_pool_reusable_c(conn); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_goaway_smoke_c`.
 * Implements `http2_libc_conn_goaway_smoke_c`.
 * @return i32
 */
export function http2_libc_conn_goaway_smoke_c(): i32 {
  unsafe { return http2_conn_goaway_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_ping_smoke_c`.
 * Implements `http2_libc_conn_ping_smoke_c`.
 * @return i32
 */
export function http2_libc_conn_ping_smoke_c(): i32 {
  unsafe { return http2_conn_ping_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_reuse_smoke_c`.
 * Implements `http2_libc_conn_reuse_smoke_c`.
 * @return i32
 */
export function http2_libc_conn_reuse_smoke_c(): i32 {
  unsafe { return http2_conn_reuse_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_reuse_is_available_c`.
 * Implements `http2_libc_conn_reuse_is_available_c`.
 * @return i32
 */
export function http2_libc_conn_reuse_is_available_c(): i32 {
  unsafe { return http2_conn_reuse_is_available_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_pool_create_h2c_c`.
 * Implements `http2_libc_conn_pool_create_h2c_c`.
 * @param host *u8
 * @param host_len i32
 * @param port *u8
 * @param port_len i32
 * @param max_conns i32
 * @return i64
 */
export function http2_libc_conn_pool_create_h2c_c(host: *u8, host_len: i32, port: *u8, port_len: i32, max_conns: i32): i64 {
  unsafe { return http2_conn_pool_create_h2c_c(host, host_len, port, port_len, max_conns); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_pool_create_h2_c`.
 * Implements `http2_libc_conn_pool_create_h2_c`.
 * @param host *u8
 * @param host_len i32
 * @param port *u8
 * @param port_len i32
 * @param max_conns i32
 * @return i64
 */
export function http2_libc_conn_pool_create_h2_c(host: *u8, host_len: i32, port: *u8, port_len: i32, max_conns: i32): i64 {
  unsafe { return http2_conn_pool_create_h2_c(host, host_len, port, port_len, max_conns); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_pool_destroy_c`.
 * Implements `http2_libc_conn_pool_destroy_c`.
 * @param pool_h i64
 * @return void
 */
export function http2_libc_conn_pool_destroy_c(pool_h: i64): void {
  unsafe { http2_conn_pool_destroy_c(pool_h); }
}

/** Exported function `http2_libc_conn_pool_request_c`.
 * Implements `http2_libc_conn_pool_request_c`.
 * @param pool_h i64
 * @param method_u8 u8
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http2_libc_conn_pool_request_c(pool_h: i64, method_u8: u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http2_conn_pool_request_c(pool_h, method_u8, url, url_len, body, body_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_h2c_pool_get_c`.
 * Implements `http_libc_h2c_pool_get_c`.
 * @param pool_h i64
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http_libc_h2c_pool_get_c(pool_h: i64, url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_h2c_pool_get_c(pool_h, url, url_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http_libc_h2_pool_get_c`.
 * Implements `http_libc_h2_pool_get_c`.
 * @param pool_h i64
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http_libc_h2_pool_get_c(pool_h: i64, url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_h2_pool_get_c(pool_h, url, url_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_pool_smoke_c`.
 * Implements `http2_libc_conn_pool_smoke_c`.
 * @return i32
 */
export function http2_libc_conn_pool_smoke_c(): i32 {
  unsafe { return http2_conn_pool_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_pool_goaway_smoke_c`.
 * Implements `http2_libc_conn_pool_goaway_smoke_c`.
 * @return i32
 */
export function http2_libc_conn_pool_goaway_smoke_c(): i32 {
  unsafe { return http2_conn_pool_goaway_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_pool_connect_count_c`.
 * Implements `http2_libc_conn_pool_connect_count_c`.
 * @param pool_h i64
 * @return i32
 */
export function http2_libc_conn_pool_connect_count_c(pool_h: i64): i32 {
  unsafe { return http2_conn_pool_connect_count_c(pool_h); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_conn_pool_is_available_c`.
 * Implements `http2_libc_conn_pool_is_available_c`.
 * @return i32
 */
export function http2_libc_conn_pool_is_available_c(): i32 {
  unsafe { return http2_conn_pool_is_available_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_global_pool_create_c`.
 * Implements `http2_libc_global_pool_create_c`.
 * @param max_entries i32
 * @param max_conns_per_host i32
 * @return i64
 */
export function http2_libc_global_pool_create_c(max_entries: i32, max_conns_per_host: i32): i64 {
  unsafe { return http2_global_pool_create_c(max_entries, max_conns_per_host); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_global_pool_destroy_c`.
 * Implements `http2_libc_global_pool_destroy_c`.
 * @param gpool_h i64
 * @return void
 */
export function http2_libc_global_pool_destroy_c(gpool_h: i64): void {
  unsafe { http2_global_pool_destroy_c(gpool_h); }
}

/** Exported function `http2_libc_global_pool_get_c`.
 * Implements `http2_libc_global_pool_get_c`.
 * @param gpool_h i64
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http2_libc_global_pool_get_c(gpool_h: i64, url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http2_global_pool_get_c(gpool_h, url, url_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_global_pool_request_c`.
 * Implements `http2_libc_global_pool_request_c`.
 * @param gpool_h i64
 * @param method_u8 u8
 * @param url *u8
 * @param url_len i32
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function http2_libc_global_pool_request_c(gpool_h: i64, method_u8: u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http2_global_pool_request_c(gpool_h, method_u8, url, url_len, body, body_len, out_buf, out_cap, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_global_pool_entry_count_c`.
 * Implements `http2_libc_global_pool_entry_count_c`.
 * @param gpool_h i64
 * @return i32
 */
export function http2_libc_global_pool_entry_count_c(gpool_h: i64): i32 {
  unsafe { return http2_global_pool_entry_count_c(gpool_h); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_global_pool_connect_count_c`.
 * Implements `http2_libc_global_pool_connect_count_c`.
 * @param gpool_h i64
 * @return i32
 */
export function http2_libc_global_pool_connect_count_c(gpool_h: i64): i32 {
  unsafe { return http2_global_pool_connect_count_c(gpool_h); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_global_pool_smoke_c`.
 * Implements `http2_libc_global_pool_smoke_c`.
 * @return i32
 */
export function http2_libc_global_pool_smoke_c(): i32 {
  unsafe { return http2_global_pool_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_global_pool_is_available_c`.
 * Implements `http2_libc_global_pool_is_available_c`.
 * @return i32
 */
export function http2_libc_global_pool_is_available_c(): i32 {
  unsafe { return http2_global_pool_is_available_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_serve_h2c_one_c`.
 * Implements `http2_libc_serve_h2c_one_c`.
 * @param listener_fd i32
 * @param body *u8
 * @param body_len i32
 * @param timeout_ms u32
 * @return i32
 */
export function http2_libc_serve_h2c_one_c(listener_fd: i32, body: *u8, body_len: i32, timeout_ms: u32): i32 {
  unsafe { return http2_serve_h2c_one_c(listener_fd, body, body_len, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_serve_h2c_one_with_goaway_c`.
 * Implements `http2_libc_serve_h2c_one_with_goaway_c`.
 * @param listener_fd i32
 * @param body *u8
 * @param body_len i32
 * @param last_stream_id i32
 * @param timeout_ms u32
 * @return i32
 */
export function http2_libc_serve_h2c_one_with_goaway_c(listener_fd: i32, body: *u8, body_len: i32, last_stream_id: i32, timeout_ms: u32): i32 {
  unsafe { return http2_serve_h2c_one_with_goaway_c(listener_fd, body, body_len, last_stream_id, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_serve_h2c_c`.
 * Implements `http2_libc_server_serve_h2c_c`.
 * @param client_fd i32
 * @param body *u8
 * @param body_len i32
 * @return i32
 */
export function http2_libc_server_serve_h2c_c(client_fd: i32, body: *u8, body_len: i32): i32 {
  unsafe { return http2_server_serve_h2c_c(client_fd, body, body_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_serve_h2c_with_goaway_c`.
 * Implements `http2_libc_server_serve_h2c_with_goaway_c`.
 * @param client_fd i32
 * @param body *u8
 * @param body_len i32
 * @param last_stream_id i32
 * @return i32
 */
export function http2_libc_server_serve_h2c_with_goaway_c(client_fd: i32, body: *u8, body_len: i32, last_stream_id: i32): i32 {
  unsafe { return http2_server_serve_h2c_with_goaway_c(client_fd, body, body_len, last_stream_id); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_serve_h2c_one_ping_echo_c`.
 * Implements `http2_libc_serve_h2c_one_ping_echo_c`.
 * @param listener_fd i32
 * @param timeout_ms u32
 * @return i32
 */
export function http2_libc_serve_h2c_one_ping_echo_c(listener_fd: i32, timeout_ms: u32): i32 {
  unsafe { return http2_serve_h2c_one_ping_echo_c(listener_fd, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_serve_h2c_ping_echo_c`.
 * Implements `http2_libc_server_serve_h2c_ping_echo_c`.
 * @param client_fd i32
 * @return i32
 */
export function http2_libc_server_serve_h2c_ping_echo_c(client_fd: i32): i32 {
  unsafe { return http2_server_serve_h2c_ping_echo_c(client_fd); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_serve_h2c_one_with_push_c`.
 * Implements `http2_libc_serve_h2c_one_with_push_c`.
 * @param listener_fd i32
 * @param body *u8
 * @param body_len i32
 * @param authority *u8
 * @param authority_len i32
 * @param push_path *u8
 * @param push_path_len i32
 * @param push_body *u8
 * @param push_body_len i32
 * @param timeout_ms u32
 * @return i32
 */
export function http2_libc_serve_h2c_one_with_push_c(listener_fd: i32, body: *u8, body_len: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32, timeout_ms: u32): i32 {
  unsafe { return http2_serve_h2c_one_with_push_c(listener_fd, body, body_len, authority, authority_len, push_path, push_path_len, push_body, push_body_len, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_serve_h2c_with_push_c`.
 * Implements `http2_libc_server_serve_h2c_with_push_c`.
 * @param client_fd i32
 * @param body *u8
 * @param body_len i32
 * @param authority *u8
 * @param authority_len i32
 * @param push_path *u8
 * @param push_path_len i32
 * @param push_body *u8
 * @param push_body_len i32
 * @return i32
 */
export function http2_libc_server_serve_h2c_with_push_c(client_fd: i32, body: *u8, body_len: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32): i32 {
  unsafe { return http2_server_serve_h2c_with_push_c(client_fd, body, body_len, authority, authority_len, push_path, push_path_len, push_body, push_body_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_serve_h2_with_push_c`.
 * Implements `http2_libc_server_serve_h2_with_push_c`.
 * @param tls_ctx i64
 * @param body *u8
 * @param body_len i32
 * @param authority *u8
 * @param authority_len i32
 * @param push_path *u8
 * @param push_path_len i32
 * @param push_body *u8
 * @param push_body_len i32
 * @return i32
 */
export function http2_libc_server_serve_h2_with_push_c(tls_ctx: i64, body: *u8, body_len: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32): i32 {
  unsafe { return http2_server_serve_h2_with_push_c(tls_ctx, body, body_len, authority, authority_len, push_path, push_path_len, push_body, push_body_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_serve_h2_one_with_push_c`.
 * Implements `http2_libc_serve_h2_one_with_push_c`.
 * @param listener_fd i32
 * @param srv_ctx_h i64
 * @param body *u8
 * @param body_len i32
 * @param authority *u8
 * @param authority_len i32
 * @param push_path *u8
 * @param push_path_len i32
 * @param push_body *u8
 * @param push_body_len i32
 * @param timeout_ms u32
 * @return i32
 */
export function http2_libc_serve_h2_one_with_push_c(listener_fd: i32, srv_ctx_h: i64, body: *u8, body_len: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32, timeout_ms: u32): i32 {
  unsafe { return http2_serve_h2_one_with_push_c(listener_fd, srv_ctx_h, body, body_len, authority, authority_len, push_path, push_path_len, push_body, push_body_len, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_push_smoke_c`.
 * Implements `http2_libc_server_push_smoke_c`.
 * @return i32
 */
export function http2_libc_server_push_smoke_c(): i32 {
  unsafe { return http2_server_push_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_push_tls_smoke_c`.
 * Implements `http2_libc_server_push_tls_smoke_c`.
 * @return i32
 */
export function http2_libc_server_push_tls_smoke_c(): i32 {
  unsafe { return http2_server_push_tls_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_push_settings_smoke_c`.
 * Implements `http2_libc_server_push_settings_smoke_c`.
 * @return i32
 */
export function http2_libc_server_push_settings_smoke_c(): i32 {
  unsafe { return http2_server_push_settings_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_settings_full_smoke_c`.
 * Implements `http2_libc_server_settings_full_smoke_c`.
 * @return i32
 */
export function http2_libc_server_settings_full_smoke_c(): i32 {
  unsafe { return http2_server_settings_full_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_hpack_dyn_smoke_c`.
 * Implements `http2_libc_server_hpack_dyn_smoke_c`.
 * @return i32
 */
export function http2_libc_server_hpack_dyn_smoke_c(): i32 {
  unsafe { return http2_server_hpack_dyn_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_max_frame_smoke_c`.
 * Implements `http2_libc_server_max_frame_smoke_c`.
 * @return i32
 */
export function http2_libc_server_max_frame_smoke_c(): i32 {
  unsafe { return http2_server_max_frame_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_push_is_available_c`.
 * Implements `http2_libc_server_push_is_available_c`.
 * @return i32
 */
export function http2_libc_server_push_is_available_c(): i32 {
  unsafe { return http2_server_push_is_available_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_serve_h2c_multi_one_c`.
 * Implements `http2_libc_serve_h2c_multi_one_c`.
 * @param listener_fd i32
 * @param body *u8
 * @param body_len i32
 * @param max_requests i32
 * @param timeout_ms u32
 * @return i32
 */
export function http2_libc_serve_h2c_multi_one_c(listener_fd: i32, body: *u8, body_len: i32, max_requests: i32, timeout_ms: u32): i32 {
  unsafe { return http2_serve_h2c_multi_one_c(listener_fd, body, body_len, max_requests, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_serve_h2c_multi_c`.
 * Implements `http2_libc_server_serve_h2c_multi_c`.
 * @param client_fd i32
 * @param body *u8
 * @param body_len i32
 * @param max_requests i32
 * @return i32
 */
export function http2_libc_server_serve_h2c_multi_c(client_fd: i32, body: *u8, body_len: i32, max_requests: i32): i32 {
  unsafe { return http2_server_serve_h2c_multi_c(client_fd, body, body_len, max_requests); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_serve_h2c_multi_one_with_push_c`.
 * Implements `http2_libc_serve_h2c_multi_one_with_push_c`.
 * @param listener_fd i32
 * @param body *u8
 * @param body_len i32
 * @param max_requests i32
 * @param authority *u8
 * @param authority_len i32
 * @param push_path *u8
 * @param push_path_len i32
 * @param push_body *u8
 * @param push_body_len i32
 * @param timeout_ms u32
 * @return i32
 */
export function http2_libc_serve_h2c_multi_one_with_push_c(listener_fd: i32, body: *u8, body_len: i32, max_requests: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32, timeout_ms: u32): i32 {
  unsafe { return http2_serve_h2c_multi_one_with_push_c(listener_fd, body, body_len, max_requests, authority, authority_len, push_path, push_path_len, push_body, push_body_len, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_serve_h2c_multi_with_push_c`.
 * Implements `http2_libc_server_serve_h2c_multi_with_push_c`.
 * @param client_fd i32
 * @param body *u8
 * @param body_len i32
 * @param max_requests i32
 * @param authority *u8
 * @param authority_len i32
 * @param push_path *u8
 * @param push_path_len i32
 * @param push_body *u8
 * @param push_body_len i32
 * @return i32
 */
export function http2_libc_server_serve_h2c_multi_with_push_c(client_fd: i32, body: *u8, body_len: i32, max_requests: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32): i32 {
  unsafe { return http2_server_serve_h2c_multi_with_push_c(client_fd, body, body_len, max_requests, authority, authority_len, push_path, push_path_len, push_body, push_body_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_serve_h2_multi_one_c`.
 * Implements `http2_libc_serve_h2_multi_one_c`.
 * @param listener_fd i32
 * @param srv_ctx_h i64
 * @param body *u8
 * @param body_len i32
 * @param max_requests i32
 * @param timeout_ms u32
 * @return i32
 */
export function http2_libc_serve_h2_multi_one_c(listener_fd: i32, srv_ctx_h: i64, body: *u8, body_len: i32, max_requests: i32, timeout_ms: u32): i32 {
  unsafe { return http2_serve_h2_multi_one_c(listener_fd, srv_ctx_h, body, body_len, max_requests, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_serve_h2_multi_c`.
 * Implements `http2_libc_server_serve_h2_multi_c`.
 * @param tls_ctx i64
 * @param body *u8
 * @param body_len i32
 * @param max_requests i32
 * @return i32
 */
export function http2_libc_server_serve_h2_multi_c(tls_ctx: i64, body: *u8, body_len: i32, max_requests: i32): i32 {
  unsafe { return http2_server_serve_h2_multi_c(tls_ctx, body, body_len, max_requests); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_serve_h2_multi_one_with_push_c`.
 * Implements `http2_libc_serve_h2_multi_one_with_push_c`.
 * @param listener_fd i32
 * @param srv_ctx_h i64
 * @param body *u8
 * @param body_len i32
 * @param max_requests i32
 * @param authority *u8
 * @param authority_len i32
 * @param push_path *u8
 * @param push_path_len i32
 * @param push_body *u8
 * @param push_body_len i32
 * @param timeout_ms u32
 * @return i32
 */
export function http2_libc_serve_h2_multi_one_with_push_c(listener_fd: i32, srv_ctx_h: i64, body: *u8, body_len: i32, max_requests: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32, timeout_ms: u32): i32 {
  unsafe { return http2_serve_h2_multi_one_with_push_c(listener_fd, srv_ctx_h, body, body_len, max_requests, authority, authority_len, push_path, push_path_len, push_body, push_body_len, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_serve_h2_multi_with_push_c`.
 * Implements `http2_libc_server_serve_h2_multi_with_push_c`.
 * @param tls_ctx i64
 * @param body *u8
 * @param body_len i32
 * @param max_requests i32
 * @param authority *u8
 * @param authority_len i32
 * @param push_path *u8
 * @param push_path_len i32
 * @param push_body *u8
 * @param push_body_len i32
 * @return i32
 */
export function http2_libc_server_serve_h2_multi_with_push_c(tls_ctx: i64, body: *u8, body_len: i32, max_requests: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32): i32 {
  unsafe { return http2_server_serve_h2_multi_with_push_c(tls_ctx, body, body_len, max_requests, authority, authority_len, push_path, push_path_len, push_body, push_body_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_multistream_push_smoke_c`.
 * Implements `http2_libc_server_multistream_push_smoke_c`.
 * @return i32
 */
export function http2_libc_server_multistream_push_smoke_c(): i32 {
  unsafe { return http2_server_multistream_push_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_multistream_push_is_available_c`.
 * Implements `http2_libc_server_multistream_push_is_available_c`.
 * @return i32
 */
export function http2_libc_server_multistream_push_is_available_c(): i32 {
  unsafe { return http2_server_multistream_push_is_available_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_multistream_smoke_c`.
 * Implements `http2_libc_server_multistream_smoke_c`.
 * @return i32
 */
export function http2_libc_server_multistream_smoke_c(): i32 {
  unsafe { return http2_server_multistream_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_multistream_is_available_c`.
 * Implements `http2_libc_server_multistream_is_available_c`.
 * @return i32
 */
export function http2_libc_server_multistream_is_available_c(): i32 {
  unsafe { return http2_server_multistream_is_available_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_smoke_c`.
 * Implements `http2_libc_server_smoke_c`.
 * @return i32
 */
export function http2_libc_server_smoke_c(): i32 {
  unsafe { return http2_server_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_is_available_c`.
 * Implements `http2_libc_server_is_available_c`.
 * @return i32
 */
export function http2_libc_server_is_available_c(): i32 {
  unsafe { return http2_server_is_available_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_serve_h2_one_c`.
 * Implements `http2_libc_serve_h2_one_c`.
 * @param listener_fd i32
 * @param srv_ctx_h i64
 * @param body *u8
 * @param body_len i32
 * @param timeout_ms u32
 * @return i32
 */
export function http2_libc_serve_h2_one_c(listener_fd: i32, srv_ctx_h: i64, body: *u8, body_len: i32, timeout_ms: u32): i32 {
  unsafe { return http2_serve_h2_one_c(listener_fd, srv_ctx_h, body, body_len, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_server_serve_h2_c`.
 * Implements `http2_libc_server_serve_h2_c`.
 * @param tls_ctx i64
 * @param body *u8
 * @param body_len i32
 * @return i32
 */
export function http2_libc_server_serve_h2_c(tls_ctx: i64, body: *u8, body_len: i32): i32 {
  unsafe { return http2_server_serve_h2_c(tls_ctx, body, body_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_tls_server_ctx_create_c`.
 * Implements `http2_libc_tls_server_ctx_create_c`.
 * @param cert_pem *u8
 * @param cert_len i32
 * @param key_pem *u8
 * @param key_len i32
 * @return i64
 */
export function http2_libc_tls_server_ctx_create_c(cert_pem: *u8, cert_len: i32, key_pem: *u8, key_len: i32): i64 {
  unsafe { return http2_tls_server_ctx_create_c(cert_pem, cert_len, key_pem, key_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_tls_server_ctx_destroy_c`.
 * Implements `http2_libc_tls_server_ctx_destroy_c`.
 * @param srv_ctx_h i64
 * @return void
 */
export function http2_libc_tls_server_ctx_destroy_c(srv_ctx_h: i64): void {
  unsafe { http2_tls_server_ctx_destroy_c(srv_ctx_h); }
}

/** Exported function `http2_libc_hpack_decode_get_request_c`.
 * Implements `http2_libc_hpack_decode_get_request_c`.
 * @param block *u8
 * @param block_len i32
 * @param out_is_get *i32
 * @param out_path *u8
 * @param path_cap i32
 * @param out_path_len *i32
 * @return i32
 */
export function http2_libc_hpack_decode_get_request_c(block: *u8, block_len: i32, out_is_get: *i32, out_path: *u8, path_cap: i32, out_path_len: *i32): i32 {
  unsafe { return http2_hpack_decode_get_request_c(block, block_len, out_is_get, out_path, path_cap, out_path_len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `http2_libc_hpack_encode_status_c`.
 * Implements `http2_libc_hpack_encode_status_c`.
 * @param status i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function http2_libc_hpack_encode_status_c(status: i32, out: *u8, out_cap: i32): i32 {
  unsafe { return http2_hpack_encode_status_c(status, out, out_cap); }
  return 0; // unreachable — typeck workaround
}


/** Exported function `err_push_not_impl`.
 * Implements `err_push_not_impl`.
 * @return i32
 */
export function err_push_not_impl(): i32 { return -1233; }

/** Exported function `err_h2c_not_impl`.
 * Implements `err_h2c_not_impl`.
 * @return i32
 */
export function err_h2c_not_impl(): i32 { return -1234; }

/** Exported function `err_h2c_scheme`.
 * Implements `err_h2c_scheme`.
 * @return i32
 */
export function err_h2c_scheme(): i32 { return -1235; }

/** Exported function `err_max_streams`.
 * Implements `err_max_streams`.
 * @return i32
 */
export function err_max_streams(): i32 { return -1236; }

/** Exported function `err_conn_not_ready`.
 * Read path helper `err_conn_not_ready`.
 * @return i32
 */
export function err_conn_not_ready(): i32 { return -1237; }

/** Exported function `err_pool_scheme`.
 * Implements `err_pool_scheme`.
 * @return i32
 */
export function err_pool_scheme(): i32 { return -1238; }

/** Exported function `err_global_pool_full`.
 * Implements `err_global_pool_full`.
 * @return i32
 */
export function err_global_pool_full(): i32 { return -1239; }

/** Exported function `err_server`.
 * Implements `err_server`.
 * @return i32
 */
export function err_server(): i32 { return -1240; }

/** Exported function `err_server_push`.
 * Implements `err_server_push`.
 * @return i32
 */
export function err_server_push(): i32 { return -1242; }

/** Exported function `err_server_push_disabled`.
 * Implements `err_server_push_disabled`.
 * @return i32
 */
export function err_server_push_disabled(): i32 { return -1243; }

/** Exported function `err_goaway`.
 * Implements `err_goaway`.
 * @return i32
 */
export function err_goaway(): i32 { return -1244; }

/** Exported function `err_ping`.
 * Implements `err_ping`.
 * @return i32
 */
export function err_ping(): i32 { return -1245; }

/** Exported function `err_rst_stream`.
 * Implements `err_rst_stream`.
 * @return i32
 */
export function err_rst_stream(): i32 { return -1246; }

/** Exported function `err_server_tls`.
 * Implements `err_server_tls`.
 * @return i32
 */
export function err_server_tls(): i32 { return -1241; }

/** Exported function `err_flow_blocked`.
 * Implements `err_flow_blocked`.
 * @return i32
 */
export function err_flow_blocked(): i32 { return -1232; }

/** Exported function `err_network_h2`.
 * Implements `err_network_h2`.
 * @return i32
 */
export function err_network_h2(): i32 { return -1231; }

/** Exported function `err_not_impl`.
 * Implements `err_not_impl`.
 * @return i32
 */
export function err_not_impl(): i32 { return -1230; }

/** Exported function `frame_data`.
 * Implements `frame_data`.
 * @return i32
 */
export function frame_data(): i32 { return 0; }

/** Exported function `frame_headers`.
 * Implements `frame_headers`.
 * @return i32
 */
export function frame_headers(): i32 { return 1; }

/** Exported function `frame_settings`.
 * Implements `frame_settings`.
 * @return i32
 */
export function frame_settings(): i32 { return 4; }

/** Exported function `flag_end_stream`.
 * Implements `flag_end_stream`.
 * @return i32
 */
export function flag_end_stream(): i32 { return 1; }

/** Exported function `flag_end_headers`.
 * Implements `flag_end_headers`.
 * @return i32
 */
export function flag_end_headers(): i32 { return 4; }

/** Exported function `flag_ack`.
 * Implements `flag_ack`.
 * @return i32
 */
export function flag_ack(): i32 { return 1; }

/** SETTINGS MAX_CONCURRENT_STREAMS id（0x0003）。 */
export function setting_max_concurrent_streams(): i32 { return 3; }

/** SETTINGS INITIAL_WINDOW_SIZE id（0x0004）。 */
export function setting_initial_window_size(): i32 { return 4; }

/** SETTINGS ENABLE_PUSH id（0x0002；RFC 7540 §6.5.2）。 */
export function setting_enable_push(): i32 {
  return http2_libc_setting_enable_push_c();
}

/** SETTINGS HEADER_TABLE_SIZE id（0x0001）。 */
export function setting_header_table_size(): i32 {
  return http2_libc_setting_header_table_size_c();
}

/** SETTINGS MAX_FRAME_SIZE id（0x0005）。 */
export function setting_max_frame_size(): i32 {
  return http2_libc_setting_max_frame_size_c();
}

/** SETTINGS MAX_HEADER_LIST_SIZE id（0x0006）。 */
export function setting_max_header_list_size(): i32 {
  return http2_libc_setting_max_header_list_size_c();
}

/** Exported function `preface_len`.
 * Query helper `preface_len`.
 * @return i32
 */
export function preface_len(): i32 {
  return http2_libc_preface_len_c();
}

/** Exported function `is_connection_preface`.
 * Query helper `is_connection_preface`.
 * @param buf *u8
 * @param len i32
 * @return bool
 */
export function is_connection_preface(buf: *u8, len: i32): bool {
  if (http2_libc_is_connection_preface_c(buf, len) != 0) { return true; }
  return false;
}

/** Exported function `parse_frame_header`.
 * Implements `parse_frame_header`.
 * @param buf *u8
 * @param len i32
 * @param out_type *i32
 * @param out_flags *i32
 * @param out_stream_id *i32
 * @param out_payload_len *i32
 * @return i32
 */
export function parse_frame_header(buf: *u8, len: i32, out_type: *i32, out_flags: *i32, out_stream_id: *i32, out_payload_len: *i32): i32 {
  return http2_libc_parse_frame_header_c(buf, len, out_type, out_flags, out_stream_id, out_payload_len);
}

/** Exported function `build_settings_ack`.
 * Implements `build_settings_ack`.
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_settings_ack(out: *u8, out_cap: i32): i32 {
  return http2_libc_build_settings_ack_c(out, out_cap);
}

/** Exported function `build_settings_one`.
 * Implements `build_settings_one`.
 * @param setting_id i32
 * @param value i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_settings_one(setting_id: i32, value: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_build_settings_one_c(setting_id, value, out, out_cap);
}

/** Exported function `wire_is_available`.
 * Implements `wire_is_available`.
 * @return bool
 */
export function wire_is_available(): bool {
  if (http2_libc_wire_is_available_c() != 0) { return true; }
  return false;
}

/** Exported function `client_is_available`.
 * Implements `client_is_available`.
 * @return bool
 */
export function client_is_available(): bool {
  if (http2_libc_client_is_available_c() != 0) { return true; }
  return false;
}

/** Exported function `hpack_encode_indexed`.
 * Implements `hpack_encode_indexed`.
 * @param index i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function hpack_encode_indexed(index: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_hpack_encode_indexed_c(index, out, out_cap);
}

/** Exported function `hpack_encode_literal`.
 * Implements `hpack_encode_literal`.
 * @param name_index i32
 * @param value *u8
 * @param value_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function hpack_encode_literal(name_index: i32, value: *u8, value_len: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_hpack_encode_literal_c(name_index, value, value_len, out, out_cap);
}

/** Exported function `hpack_encode_get_request`.
 * Implements `hpack_encode_get_request`.
 * @param authority *u8
 * @param authority_len i32
 * @param path *u8
 * @param path_len i32
 * @param is_https i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function hpack_encode_get_request(authority: *u8, authority_len: i32, path: *u8, path_len: i32, is_https: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_hpack_encode_get_request_c(authority, authority_len, path, path_len, is_https, out, out_cap);
}

/** Exported function `hpack_dyn_reset`.
 * Implements `hpack_dyn_reset`.
 * @return void
 */
export function hpack_dyn_reset(): void {
  http2_libc_hpack_dyn_reset_c();
}

/** Exported function `hpack_dyn_count`.
 * Implements `hpack_dyn_count`.
 * @return i32
 */
export function hpack_dyn_count(): i32 {
  return http2_libc_hpack_dyn_count_c();
}

/** Exported function `hpack_encode_literal_incremental`.
 * Implements `hpack_encode_literal_incremental`.
 * @param name_index i32
 * @param value *u8
 * @param value_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function hpack_encode_literal_incremental(name_index: i32, value: *u8, value_len: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_hpack_encode_literal_incremental_c(name_index, value, value_len, out, out_cap);
}

/** Exported function `hpack_encode_indexed_any`.
 * Implements `hpack_encode_indexed_any`.
 * @param index i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function hpack_encode_indexed_any(index: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_hpack_encode_indexed_any_c(index, out, out_cap);
}

/** Exported function `hpack_encode_request`.
 * Implements `hpack_encode_request`.
 * @param method_u8 u8
 * @param authority *u8
 * @param authority_len i32
 * @param path *u8
 * @param path_len i32
 * @param is_https i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function hpack_encode_request(method_u8: u8, authority: *u8, authority_len: i32, path: *u8, path_len: i32, is_https: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_hpack_encode_request_c(method_u8, authority, authority_len, path, path_len, is_https, out, out_cap);
}

/** Exported function `hpack_dyn_smoke`.
 * Implements `hpack_dyn_smoke`.
 * @return i32
 */
export function hpack_dyn_smoke(): i32 {
  return http2_libc_hpack_dyn_smoke_c();
}

/** Exported function `hpack_server_dyn_create`.
 * Implements `hpack_server_dyn_create`.
 * @param peer *Http2PeerSettings
 * @return i64
 */
export function hpack_server_dyn_create(peer: *Http2PeerSettings): i64 {
  return http2_libc_hpack_server_dyn_create_c(peer);
}

/** Exported function `hpack_server_dyn_destroy`.
 * Implements `hpack_server_dyn_destroy`.
 * @param handle i64
 * @return void
 */
export function hpack_server_dyn_destroy(handle: i64): void {
  http2_libc_hpack_server_dyn_destroy_c(handle);
}

/** Exported function `hpack_server_dyn_set_table_size`.
 * Implements `hpack_server_dyn_set_table_size`.
 * @param handle i64
 * @param size i32
 * @return void
 */
export function hpack_server_dyn_set_table_size(handle: i64, size: i32): void {
  http2_libc_hpack_server_dyn_set_table_size_h_c(handle, size);
}

/** Exported function `hpack_server_dyn_max_size`.
 * Implements `hpack_server_dyn_max_size`.
 * @param handle i64
 * @return i32
 */
export function hpack_server_dyn_max_size(handle: i64): i32 {
  return http2_libc_hpack_server_dyn_max_size_h_c(handle);
}

/** Exported function `hpack_server_dyn_count`.
 * Implements `hpack_server_dyn_count`.
 * @param handle i64
 * @return i32
 */
export function hpack_server_dyn_count(handle: i64): i32 {
  return http2_libc_hpack_server_dyn_count_h_c(handle);
}

/** Exported function `hpack_server_encode_status`.
 * Implements `hpack_server_encode_status`.
 * @param handle i64
 * @param status i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function hpack_server_encode_status(handle: i64, status: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_hpack_server_encode_status_h_c(handle, status, out, out_cap);
}

/** Exported function `hpack_server_dyn_smoke`.
 * Implements `hpack_server_dyn_smoke`.
 * @return i32
 */
export function hpack_server_dyn_smoke(): i32 {
  return http2_libc_hpack_server_dyn_smoke_c();
}

/** Exported function `frame_payload_limit`.
 * Implements `frame_payload_limit`.
 * @param max_frame_size i32
 * @return i32
 */
export function frame_payload_limit(max_frame_size: i32): i32 {
  return http2_libc_frame_payload_limit_c(max_frame_size);
}

/** Exported function `frame_check_payload`.
 * Implements `frame_check_payload`.
 * @param payload_len i32
 * @param max_frame_size i32
 * @return i32
 */
export function frame_check_payload(payload_len: i32, max_frame_size: i32): i32 {
  return http2_libc_frame_check_payload_c(payload_len, max_frame_size);
}

/** Exported function `frame_count_data_chunks`.
 * Implements `frame_count_data_chunks`.
 * @param data_len i32
 * @param max_frame_size i32
 * @return i32
 */
export function frame_count_data_chunks(data_len: i32, max_frame_size: i32): i32 {
  return http2_libc_frame_count_data_chunks_c(data_len, max_frame_size);
}

/** Exported function `frame_capped_smoke`.
 * Implements `frame_capped_smoke`.
 * @return i32
 */
export function frame_capped_smoke(): i32 {
  return http2_libc_frame_capped_smoke_c();
}

/** Exported function `frame_goaway`.
 * Implements `frame_goaway`.
 * @return i32
 */
export function frame_goaway(): i32 {
  return http2_libc_frame_goaway_c();
}

/** Exported function `goaway_error_no_error`.
 * Implements `goaway_error_no_error`.
 * @return i32
 */
export function goaway_error_no_error(): i32 {
  return http2_libc_goaway_error_no_error_c();
}

/** Exported function `build_goaway`.
 * Implements `build_goaway`.
 * @param last_stream_id i32
 * @param code i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_goaway(last_stream_id: i32, code: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_build_goaway_c(last_stream_id, code, out, out_cap);
}

/** Exported function `parse_goaway`.
 * Implements `parse_goaway`.
 * @param payload *u8
 * @param plen i32
 * @param out_last_stream *i32
 * @param out_code *i32
 * @return i32
 */
export function parse_goaway(payload: *u8, plen: i32, out_last_stream: *i32, out_code: *i32): i32 {
  return http2_libc_parse_goaway_c(payload, plen, out_last_stream, out_code);
}

/** Exported function `goaway_smoke`.
 * Implements `goaway_smoke`.
 * @return i32
 */
export function goaway_smoke(): i32 {
  return http2_libc_goaway_smoke_c();
}

/** Exported function `frame_ping`.
 * Implements `frame_ping`.
 * @return i32
 */
export function frame_ping(): i32 {
  return http2_libc_frame_ping_c();
}

/** Exported function `build_ping`.
 * Implements `build_ping`.
 * @param opaque *u8
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_ping(opaque: *u8, out: *u8, out_cap: i32): i32 {
  return http2_libc_build_ping_c(opaque, out, out_cap);
}

/** Exported function `build_ping_ack`.
 * Implements `build_ping_ack`.
 * @param opaque *u8
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_ping_ack(opaque: *u8, out: *u8, out_cap: i32): i32 {
  return http2_libc_build_ping_ack_c(opaque, out, out_cap);
}

/** Exported function `parse_ping`.
 * Implements `parse_ping`.
 * @param payload *u8
 * @param plen i32
 * @param out_opaque *u8
 * @return i32
 */
export function parse_ping(payload: *u8, plen: i32, out_opaque: *u8): i32 {
  return http2_libc_parse_ping_c(payload, plen, out_opaque);
}

/** Exported function `ping_smoke`.
 * Implements `ping_smoke`.
 * @return i32
 */
export function ping_smoke(): i32 {
  return http2_libc_ping_smoke_c();
}

/** Exported function `frame_rst_stream`.
 * Implements `frame_rst_stream`.
 * @return i32
 */
export function frame_rst_stream(): i32 {
  return http2_libc_frame_rst_stream_c();
}

/** Exported function `rst_error_cancel`.
 * Implements `rst_error_cancel`.
 * @return i32
 */
export function rst_error_cancel(): i32 {
  return http2_libc_rst_error_cancel_c();
}

/** Exported function `build_rst_stream`.
 * Implements `build_rst_stream`.
 * @param stream_id i32
 * @param code i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_rst_stream(stream_id: i32, code: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_build_rst_stream_c(stream_id, code, out, out_cap);
}

/** Exported function `parse_rst_stream`.
 * Implements `parse_rst_stream`.
 * @param payload *u8
 * @param plen i32
 * @param out_code *i32
 * @return i32
 */
export function parse_rst_stream(payload: *u8, plen: i32, out_code: *i32): i32 {
  return http2_libc_parse_rst_stream_c(payload, plen, out_code);
}

/** Exported function `rst_stream_smoke`.
 * Implements `rst_stream_smoke`.
 * @return i32
 */
export function rst_stream_smoke(): i32 {
  return http2_libc_rst_stream_smoke_c();
}

/** Exported function `hpack_decode_status`.
 * Implements `hpack_decode_status`.
 * @param block *u8
 * @param block_len i32
 * @param out_status *i32
 * @return i32
 */
export function hpack_decode_status(block: *u8, block_len: i32, out_status: *i32): i32 {
  return http2_libc_hpack_decode_status_c(block, block_len, out_status);
}

/** Exported function `hpack_decode_get_request`.
 * Implements `hpack_decode_get_request`.
 * @param block *u8
 * @param block_len i32
 * @param out_is_get *i32
 * @param out_path *u8
 * @param path_cap i32
 * @param out_path_len *i32
 * @return i32
 */
export function hpack_decode_get_request(block: *u8, block_len: i32, out_is_get: *i32, out_path: *u8, path_cap: i32, out_path_len: *i32): i32 {
  return http2_libc_hpack_decode_get_request_c(block, block_len, out_is_get, out_path, path_cap, out_path_len);
}

/** Exported function `hpack_encode_status`.
 * Implements `hpack_encode_status`.
 * @param status i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function hpack_encode_status(status: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_hpack_encode_status_c(status, out, out_cap);
}

/** Exported function `build_headers_frame`.
 * Implements `build_headers_frame`.
 * @param stream_id i32
 * @param flags i32
 * @param hpack *u8
 * @param hpack_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_headers_frame(stream_id: i32, flags: i32, hpack: *u8, hpack_len: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_build_headers_frame_c(stream_id, flags, hpack, hpack_len, out, out_cap);
}

/** Exported function `build_data_frame`.
 * Implements `build_data_frame`.
 * @param stream_id i32
 * @param flags i32
 * @param data *u8
 * @param data_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_data_frame(stream_id: i32, flags: i32, data: *u8, data_len: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_build_data_frame_c(stream_id, flags, data, data_len, out, out_cap);
}

/** Exported function `build_get_headers_frame`.
 * Implements `build_get_headers_frame`.
 * @param authority *u8
 * @param authority_len i32
 * @param path *u8
 * @param path_len i32
 * @param is_https i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_get_headers_frame(authority: *u8, authority_len: i32, path: *u8, path_len: i32, is_https: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_build_get_headers_frame_c(authority, authority_len, path, path_len, is_https, out, out_cap);
}

/**
 * See implementation.
 * See implementation.
 */
export function build_request_headers_frame(method_u8: u8, authority: *u8, authority_len: i32, path: *u8, path_len: i32, is_https: i32, has_body: i32, stream_id: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_build_request_headers_frame_c(method_u8, authority, authority_len, path, path_len, is_https, has_body, stream_id, out, out_cap);
}

/** Exported function `hpack_smoke`.
 * Implements `hpack_smoke`.
 * @return i32
 */
export function hpack_smoke(): i32 {
  return http2_libc_hpack_smoke_c();
}

/** Exported function `client_smoke`.
 * Implements `client_smoke`.
 * @return i32
 */
export function client_smoke(): i32 {
  return http2_libc_client_smoke_c();
}

/** Exported function `network_is_available`.
 * Implements `network_is_available`.
 * @return bool
 */
export function network_is_available(): bool {
  if (http2_libc_network_is_available_c() != 0) { return true; }
  return false;
}

/** Exported function `network_smoke`.
 * Implements `network_smoke`.
 * @return i32
 */
export function network_smoke(): i32 {
  return http2_libc_network_smoke_c();
}

/**
 * See implementation.
 * See implementation.
 */
export function h2_get(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  return http_libc_h2_get_c(url, url_len, out_buf, out_cap, timeout_ms);
}

/**
 * See implementation.
 * See implementation.
 */
export function h2_request(method: Method, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  return http_libc_h2_request_c(method(method), url, url_len, body, body_len, out_buf, out_cap, timeout_ms);
}

/**
 * See implementation.
 */
export function client_request_h2(method: Method, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  return http_libc_request_method_h2_c(method(method), url, url_len, body, body_len, out_buf, out_cap, timeout_ms);
}

/**
 * See implementation.
 * See implementation.
 */
export function h2c_get(url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  return http_libc_h2c_get_c(url, url_len, out_buf, out_cap, timeout_ms);
}

/**
 * See implementation.
 * See implementation.
 */
export function h2c_request(method: Method, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  return http_libc_h2c_request_c(method(method), url, url_len, body, body_len, out_buf, out_cap, timeout_ms);
}

/**
 * See implementation.
 */
export function client_request_h2c(method: Method, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  return http_libc_request_method_h2c_c(method(method), url, url_len, body, body_len, out_buf, out_cap, timeout_ms);
}

/**
 * See implementation.
 */
export function conn_pool_create_h2c(host: *u8, host_len: i32, port: *u8, port_len: i32, max_conns: i32): i64 {
  return http2_libc_conn_pool_create_h2c_c(host, host_len, port, port_len, max_conns);
}

/**
 * See implementation.
 */
export function conn_pool_create_h2(host: *u8, host_len: i32, port: *u8, port_len: i32, max_conns: i32): i64 {
  return http2_libc_conn_pool_create_h2_c(host, host_len, port, port_len, max_conns);
}

/** Exported function `conn_pool_destroy`.
 * Implements `conn_pool_destroy`.
 * @param pool_h i64
 * @return void
 */
export function conn_pool_destroy(pool_h: i64): void {
  http2_libc_conn_pool_destroy_c(pool_h);
}

/**
 * See implementation.
 * See implementation.
 */
export function conn_pool_request(pool_h: i64, method: Method, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  return http2_libc_conn_pool_request_c(pool_h, method(method), url, url_len, body, body_len, out_buf, out_cap, timeout_ms);
}

/** Exported function `h2c_pool_get`.
 * Implements `h2c_pool_get`.
 * @param pool_h i64
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function h2c_pool_get(pool_h: i64, url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  return http_libc_h2c_pool_get_c(pool_h, url, url_len, out_buf, out_cap, timeout_ms);
}

/** Exported function `h2_pool_get`.
 * Implements `h2_pool_get`.
 * @param pool_h i64
 * @param url *u8
 * @param url_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
export function h2_pool_get(pool_h: i64, url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  return http_libc_h2_pool_get_c(pool_h, url, url_len, out_buf, out_cap, timeout_ms);
}

/** Exported function `conn_pool_is_available`.
 * Implements `conn_pool_is_available`.
 * @return bool
 */
export function conn_pool_is_available(): bool {
  if (http2_libc_conn_pool_is_available_c() != 0) { return true; }
  return false;
}

/** Exported function `conn_pool_smoke`.
 * Implements `conn_pool_smoke`.
 * @return i32
 */
export function conn_pool_smoke(): i32 {
  return http2_libc_conn_pool_smoke_c();
}

/** Exported function `conn_pool_goaway_smoke`.
 * Implements `conn_pool_goaway_smoke`.
 * @return i32
 */
export function conn_pool_goaway_smoke(): i32 {
  return http2_libc_conn_pool_goaway_smoke_c();
}

/** Exported function `conn_pool_connect_count`.
 * Implements `conn_pool_connect_count`.
 * @param pool_h i64
 * @return i32
 */
export function conn_pool_connect_count(pool_h: i64): i32 {
  return http2_libc_conn_pool_connect_count_c(pool_h);
}

/**
 * See implementation.
 * See implementation.
 */
export function global_pool_create(max_entries: i32, max_conns_per_host: i32): i64 {
  return http2_libc_global_pool_create_c(max_entries, max_conns_per_host);
}

/** Exported function `global_pool_destroy`.
 * Implements `global_pool_destroy`.
 * @param gpool_h i64
 * @return void
 */
export function global_pool_destroy(gpool_h: i64): void {
  http2_libc_global_pool_destroy_c(gpool_h);
}

/**
 * See implementation.
 * See implementation.
 */
export function global_pool_get(gpool_h: i64, url: *u8, url_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  return http2_libc_global_pool_get_c(gpool_h, url, url_len, out_buf, out_cap, timeout_ms);
}

/**
 * See implementation.
 * See implementation.
 */
export function global_pool_request(gpool_h: i64, method: Method, url: *u8, url_len: i32, body: *u8, body_len: i32, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  return http2_libc_global_pool_request_c(gpool_h, method(method), url, url_len, body, body_len, out_buf, out_cap, timeout_ms);
}

/** Exported function `global_pool_entry_count`.
 * Implements `global_pool_entry_count`.
 * @param gpool_h i64
 * @return i32
 */
export function global_pool_entry_count(gpool_h: i64): i32 {
  return http2_libc_global_pool_entry_count_c(gpool_h);
}

/** Exported function `global_pool_connect_count`.
 * Implements `global_pool_connect_count`.
 * @param gpool_h i64
 * @return i32
 */
export function global_pool_connect_count(gpool_h: i64): i32 {
  return http2_libc_global_pool_connect_count_c(gpool_h);
}

/** Exported function `global_pool_is_available`.
 * Implements `global_pool_is_available`.
 * @return bool
 */
export function global_pool_is_available(): bool {
  if (http2_libc_global_pool_is_available_c() != 0) { return true; }
  return false;
}

/** Exported function `global_pool_smoke`.
 * Implements `global_pool_smoke`.
 * @return i32
 */
export function global_pool_smoke(): i32 {
  return http2_libc_global_pool_smoke_c();
}

/** Exported function `complete_smoke`.
 * Implements `complete_smoke`.
 * @return i32
 */
export function complete_smoke(): i32 {
  return http2_libc_http2_complete_smoke_c();
}

/**
 * See implementation.
 * See implementation.
 */
export function serve_h2c_one(listener_fd: i32, body: *u8, body_len: i32, timeout_ms: u32): i32 {
  return http2_libc_serve_h2c_one_c(listener_fd, body, body_len, timeout_ms);
}

/**
 * See implementation.
 * See implementation.
 */
export function serve_h2c_one_with_goaway(listener_fd: i32, body: *u8, body_len: i32, last_stream_id: i32, timeout_ms: u32): i32 {
  return http2_libc_serve_h2c_one_with_goaway_c(listener_fd, body, body_len, last_stream_id, timeout_ms);
}

/** Exported function `server_serve_h2c`.
 * Implements `server_serve_h2c`.
 * @param client_fd i32
 * @param body *u8
 * @param body_len i32
 * @return i32
 */
export function server_serve_h2c(client_fd: i32, body: *u8, body_len: i32): i32 {
  return http2_libc_server_serve_h2c_c(client_fd, body, body_len);
}

/** Exported function `server_serve_h2c_with_goaway`.
 * Implements `server_serve_h2c_with_goaway`.
 * @param client_fd i32
 * @param body *u8
 * @param body_len i32
 * @param last_stream_id i32
 * @return i32
 */
export function server_serve_h2c_with_goaway(client_fd: i32, body: *u8, body_len: i32, last_stream_id: i32): i32 {
  return http2_libc_server_serve_h2c_with_goaway_c(client_fd, body, body_len, last_stream_id);
}

/** Exported function `serve_h2c_one_ping_echo`.
 * Implements `serve_h2c_one_ping_echo`.
 * @param listener_fd i32
 * @param timeout_ms u32
 * @return i32
 */
export function serve_h2c_one_ping_echo(listener_fd: i32, timeout_ms: u32): i32 {
  return http2_libc_serve_h2c_one_ping_echo_c(listener_fd, timeout_ms);
}

/** Exported function `server_serve_h2c_ping_echo`.
 * Implements `server_serve_h2c_ping_echo`.
 * @param client_fd i32
 * @return i32
 */
export function server_serve_h2c_ping_echo(client_fd: i32): i32 {
  return http2_libc_server_serve_h2c_ping_echo_c(client_fd);
}

/**
 * See implementation.
 * See implementation.
 */
export function serve_h2c_one_with_push(listener_fd: i32, body: *u8, body_len: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32, timeout_ms: u32): i32 {
  return http2_libc_serve_h2c_one_with_push_c(listener_fd, body, body_len, authority, authority_len, push_path, push_path_len, push_body, push_body_len, timeout_ms);
}

/** Exported function `server_serve_h2c_with_push`.
 * Implements `server_serve_h2c_with_push`.
 * @param client_fd i32
 * @param body *u8
 * @param body_len i32
 * @param authority *u8
 * @param authority_len i32
 * @param push_path *u8
 * @param push_path_len i32
 * @param push_body *u8
 * @param push_body_len i32
 * @return i32
 */
export function server_serve_h2c_with_push(client_fd: i32, body: *u8, body_len: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32): i32 {
  return http2_libc_server_serve_h2c_with_push_c(client_fd, body, body_len, authority, authority_len, push_path, push_path_len, push_body, push_body_len);
}

/** Exported function `server_push_is_available`.
 * Implements `server_push_is_available`.
 * @return bool
 */
export function server_push_is_available(): bool {
  if (http2_libc_server_push_is_available_c() != 0) { return true; }
  return false;
}

/** Exported function `server_push_smoke`.
 * Implements `server_push_smoke`.
 * @return i32
 */
export function server_push_smoke(): i32 {
  return http2_libc_server_push_smoke_c();
}

/** Exported function `server_push_tls_smoke`.
 * Implements `server_push_tls_smoke`.
 * @return i32
 */
export function server_push_tls_smoke(): i32 {
  return http2_libc_server_push_tls_smoke_c();
}

/** Exported function `server_push_settings_smoke`.
 * Implements `server_push_settings_smoke`.
 * @return i32
 */
export function server_push_settings_smoke(): i32 {
  return http2_libc_server_push_settings_smoke_c();
}

/** Exported function `server_settings_full_smoke`.
 * Implements `server_settings_full_smoke`.
 * @return i32
 */
export function server_settings_full_smoke(): i32 {
  return http2_libc_server_settings_full_smoke_c();
}

/** Exported function `server_hpack_dyn_smoke`.
 * Implements `server_hpack_dyn_smoke`.
 * @return i32
 */
export function server_hpack_dyn_smoke(): i32 {
  return http2_libc_server_hpack_dyn_smoke_c();
}

/** Exported function `server_max_frame_smoke`.
 * Implements `server_max_frame_smoke`.
 * @return i32
 */
export function server_max_frame_smoke(): i32 {
  return http2_libc_server_max_frame_smoke_c();
}

/** Exported function `conn_goaway_smoke`.
 * Implements `conn_goaway_smoke`.
 * @return i32
 */
export function conn_goaway_smoke(): i32 {
  return http2_libc_conn_goaway_smoke_c();
}

/** Exported function `conn_ping_smoke`.
 * Implements `conn_ping_smoke`.
 * @return i32
 */
export function conn_ping_smoke(): i32 {
  return http2_libc_conn_ping_smoke_c();
}

/**
 * See implementation.
 * See implementation.
 */
export function serve_h2c_multi_one(listener_fd: i32, body: *u8, body_len: i32, max_requests: i32, timeout_ms: u32): i32 {
  return http2_libc_serve_h2c_multi_one_c(listener_fd, body, body_len, max_requests, timeout_ms);
}

/** Exported function `server_serve_h2c_multi`.
 * Implements `server_serve_h2c_multi`.
 * @param client_fd i32
 * @param body *u8
 * @param body_len i32
 * @param max_requests i32
 * @return i32
 */
export function server_serve_h2c_multi(client_fd: i32, body: *u8, body_len: i32, max_requests: i32): i32 {
  return http2_libc_server_serve_h2c_multi_c(client_fd, body, body_len, max_requests);
}

/**
 * See implementation.
 * See implementation.
 */
export function serve_h2c_multi_one_with_push(listener_fd: i32, body: *u8, body_len: i32, max_requests: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32, timeout_ms: u32): i32 {
  return http2_libc_serve_h2c_multi_one_with_push_c(listener_fd, body, body_len, max_requests, authority, authority_len, push_path, push_path_len, push_body, push_body_len, timeout_ms);
}

/** Exported function `server_serve_h2c_multi_with_push`.
 * Implements `server_serve_h2c_multi_with_push`.
 * @param client_fd i32
 * @param body *u8
 * @param body_len i32
 * @param max_requests i32
 * @param authority *u8
 * @param authority_len i32
 * @param push_path *u8
 * @param push_path_len i32
 * @param push_body *u8
 * @param push_body_len i32
 * @return i32
 */
export function server_serve_h2c_multi_with_push(client_fd: i32, body: *u8, body_len: i32, max_requests: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32): i32 {
  return http2_libc_server_serve_h2c_multi_with_push_c(client_fd, body, body_len, max_requests, authority, authority_len, push_path, push_path_len, push_body, push_body_len);
}

/** Exported function `server_is_available`.
 * Implements `server_is_available`.
 * @return bool
 */
export function server_is_available(): bool {
  if (http2_libc_server_is_available_c() != 0) { return true; }
  return false;
}

/** Exported function `server_smoke`.
 * Implements `server_smoke`.
 * @return i32
 */
export function server_smoke(): i32 {
  return http2_libc_server_smoke_c();
}

/**
 * See implementation.
 * See implementation.
 */
export function tls_server_ctx_create(cert_pem: *u8, cert_len: i32, key_pem: *u8, key_len: i32): i64 {
  return http2_libc_tls_server_ctx_create_c(cert_pem, cert_len, key_pem, key_len);
}

/** Exported function `tls_server_ctx_destroy`.
 * Implements `tls_server_ctx_destroy`.
 * @param srv_ctx_h i64
 * @return void
 */
export function tls_server_ctx_destroy(srv_ctx_h: i64): void {
  http2_libc_tls_server_ctx_destroy_c(srv_ctx_h);
}

/**
 * accept + TLS + h2 GET serve（200 + body）。
 * See implementation.
 */
export function serve_h2_one(listener_fd: i32, srv_ctx_h: i64, body: *u8, body_len: i32, timeout_ms: u32): i32 {
  return http2_libc_serve_h2_one_c(listener_fd, srv_ctx_h, body, body_len, timeout_ms);
}

/**
 * See implementation.
 * See implementation.
 */
export function serve_h2_one_with_push(listener_fd: i32, srv_ctx_h: i64, body: *u8, body_len: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32, timeout_ms: u32): i32 {
  return http2_libc_serve_h2_one_with_push_c(listener_fd, srv_ctx_h, body, body_len, authority, authority_len, push_path, push_path_len, push_body, push_body_len, timeout_ms);
}

/** Exported function `server_serve_h2`.
 * Implements `server_serve_h2`.
 * @param tls_ctx i64
 * @param body *u8
 * @param body_len i32
 * @return i32
 */
export function server_serve_h2(tls_ctx: i64, body: *u8, body_len: i32): i32 {
  return http2_libc_server_serve_h2_c(tls_ctx, body, body_len);
}

/** Exported function `server_serve_h2_with_push`.
 * Implements `server_serve_h2_with_push`.
 * @param tls_ctx i64
 * @param body *u8
 * @param body_len i32
 * @param authority *u8
 * @param authority_len i32
 * @param push_path *u8
 * @param push_path_len i32
 * @param push_body *u8
 * @param push_body_len i32
 * @return i32
 */
export function server_serve_h2_with_push(tls_ctx: i64, body: *u8, body_len: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32): i32 {
  return http2_libc_server_serve_h2_with_push_c(tls_ctx, body, body_len, authority, authority_len, push_path, push_path_len, push_body, push_body_len);
}

/**
 * See implementation.
 */
export function serve_h2_multi_one(listener_fd: i32, srv_ctx_h: i64, body: *u8, body_len: i32, max_requests: i32, timeout_ms: u32): i32 {
  return http2_libc_serve_h2_multi_one_c(listener_fd, srv_ctx_h, body, body_len, max_requests, timeout_ms);
}

/** Exported function `server_serve_h2_multi`.
 * Implements `server_serve_h2_multi`.
 * @param tls_ctx i64
 * @param body *u8
 * @param body_len i32
 * @param max_requests i32
 * @return i32
 */
export function server_serve_h2_multi(tls_ctx: i64, body: *u8, body_len: i32, max_requests: i32): i32 {
  return http2_libc_server_serve_h2_multi_c(tls_ctx, body, body_len, max_requests);
}

/**
 * See implementation.
 */
export function serve_h2_multi_one_with_push(listener_fd: i32, srv_ctx_h: i64, body: *u8, body_len: i32, max_requests: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32, timeout_ms: u32): i32 {
  return http2_libc_serve_h2_multi_one_with_push_c(listener_fd, srv_ctx_h, body, body_len, max_requests, authority, authority_len, push_path, push_path_len, push_body, push_body_len, timeout_ms);
}

/** Exported function `server_serve_h2_multi_with_push`.
 * Implements `server_serve_h2_multi_with_push`.
 * @param tls_ctx i64
 * @param body *u8
 * @param body_len i32
 * @param max_requests i32
 * @param authority *u8
 * @param authority_len i32
 * @param push_path *u8
 * @param push_path_len i32
 * @param push_body *u8
 * @param push_body_len i32
 * @return i32
 */
export function server_serve_h2_multi_with_push(tls_ctx: i64, body: *u8, body_len: i32, max_requests: i32, authority: *u8, authority_len: i32, push_path: *u8, push_path_len: i32, push_body: *u8, push_body_len: i32): i32 {
  return http2_libc_server_serve_h2_multi_with_push_c(tls_ctx, body, body_len, max_requests, authority, authority_len, push_path, push_path_len, push_body, push_body_len);
}

/** Exported function `server_multistream_is_available`.
 * Implements `server_multistream_is_available`.
 * @return bool
 */
export function server_multistream_is_available(): bool {
  if (http2_libc_server_multistream_is_available_c() != 0) { return true; }
  return false;
}

/** Exported function `server_multistream_smoke`.
 * Implements `server_multistream_smoke`.
 * @return i32
 */
export function server_multistream_smoke(): i32 {
  return http2_libc_server_multistream_smoke_c();
}

/** Exported function `server_multistream_push_is_available`.
 * Implements `server_multistream_push_is_available`.
 * @return bool
 */
export function server_multistream_push_is_available(): bool {
  if (http2_libc_server_multistream_push_is_available_c() != 0) { return true; }
  return false;
}

/** Exported function `server_multistream_push_smoke`.
 * Implements `server_multistream_push_smoke`.
 * @return i32
 */
export function server_multistream_push_smoke(): i32 {
  return http2_libc_server_multistream_push_smoke_c();
}

/** Exported function `h2c_client_smoke`.
 * Implements `h2c_client_smoke`.
 * @return i32
 */
export function h2c_client_smoke(): i32 {
  return http_libc_h2c_client_smoke_c();
}

/** Exported function `registry_max`.
 * Implements `registry_max`.
 * @return i32
 */
export function registry_max(): i32 { return 8; }

/** Exported function `init`.
 * Implements `init`.
 * @param reg *Http2StreamRegistry
 * @return void
 */
export function init(reg: *Http2StreamRegistry): void {
  http2_libc_stream_registry_init_c(reg);
}

/** Exported function `open`.
 * Implements `open`.
 * @param reg *Http2StreamRegistry
 * @return i32
 */
export function open(reg: *Http2StreamRegistry): i32 {
  return http2_libc_stream_registry_open_c(reg);
}

/** Exported function `close`.
 * Implements `close`.
 * @param reg *Http2StreamRegistry
 * @param stream_id i32
 * @return void
 */
export function close(reg: *Http2StreamRegistry, stream_id: i32): void {
  http2_libc_stream_registry_close_c(reg, stream_id);
}

/** Exported function `is_open`.
 * Query helper `is_open`.
 * @param reg *Http2StreamRegistry
 * @param stream_id i32
 * @return bool
 */
export function is_open(reg: *Http2StreamRegistry, stream_id: i32): bool {
  if (http2_libc_stream_registry_is_open_c(reg, stream_id) != 0) { return true; }
  return false;
}

/** Exported function `registry_smoke`.
 * Implements `registry_smoke`.
 * @return i32
 */
export function registry_smoke(): i32 {
  return http2_libc_stream_registry_smoke_c();
}

/** Exported function `peer_settings_init`.
 * Implements `peer_settings_init`.
 * @param ps *Http2PeerSettings
 * @return void
 */
export function peer_settings_init(ps: *Http2PeerSettings): void {
  http2_libc_peer_settings_init_c(ps);
}

/** Exported function `settings_entry_count`.
 * Implements `settings_entry_count`.
 * @param plen i32
 * @return i32
 */
export function settings_entry_count(plen: i32): i32 {
  return http2_libc_settings_entry_count_c(plen);
}

/** Exported function `parse_settings_entry`.
 * Implements `parse_settings_entry`.
 * @param payload *u8
 * @param plen i32
 * @param entry_index i32
 * @param out_id *i32
 * @param out_value *i32
 * @return i32
 */
export function parse_settings_entry(payload: *u8, plen: i32, entry_index: i32, out_id: *i32, out_value: *i32): i32 {
  return http2_libc_parse_settings_entry_c(payload, plen, entry_index, out_id, out_value);
}

/** Exported function `peer_settings_apply_entry`.
 * Implements `peer_settings_apply_entry`.
 * @param ps *Http2PeerSettings
 * @param setting_id i32
 * @param value i32
 * @return void
 */
export function peer_settings_apply_entry(ps: *Http2PeerSettings, setting_id: i32, value: i32): void {
  http2_libc_peer_settings_apply_entry_c(ps, setting_id, value);
}

/** Exported function `peer_settings_consume_payload`.
 * Implements `peer_settings_consume_payload`.
 * @param payload *u8
 * @param plen i32
 * @param ps *Http2PeerSettings
 * @return i32
 */
export function peer_settings_consume_payload(payload: *u8, plen: i32, ps: *Http2PeerSettings): i32 {
  return http2_libc_peer_settings_consume_payload_c(payload, plen, ps);
}

/** Exported function `build_client_settings`.
 * Implements `build_client_settings`.
 * @param max_streams i32
 * @param initial_window i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_client_settings(max_streams: i32, initial_window: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_build_client_settings_c(max_streams, initial_window, out, out_cap);
}

/** Exported function `build_client_settings_ex`.
 * Implements `build_client_settings_ex`.
 * @param max_streams i32
 * @param initial_window i32
 * @param enable_push i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_client_settings_ex(max_streams: i32, initial_window: i32, enable_push: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_build_client_settings_ex_c(max_streams, initial_window, enable_push, out, out_cap);
}

/** Exported function `build_client_settings_with_max_frame`.
 * Implements `build_client_settings_with_max_frame`.
 * @param max_streams i32
 * @param initial_window i32
 * @param enable_push i32
 * @param max_frame_size i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_client_settings_with_max_frame(max_streams: i32, initial_window: i32, enable_push: i32, max_frame_size: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_build_client_settings_with_max_frame_c(max_streams, initial_window, enable_push, max_frame_size, out, out_cap);
}

/** Exported function `build_server_settings`.
 * Implements `build_server_settings`.
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_server_settings(out: *u8, out_cap: i32): i32 {
  return http2_libc_build_server_settings_c(out, out_cap);
}

/** Exported function `peer_settings_enable_push`.
 * Implements `peer_settings_enable_push`.
 * @param ps *Http2PeerSettings
 * @return bool
 */
export function peer_settings_enable_push(ps: *Http2PeerSettings): bool {
  if (http2_libc_peer_settings_enable_push_c(ps) != 0) { return true; }
  return false;
}

/** Exported function `peer_settings_header_table_size`.
 * Implements `peer_settings_header_table_size`.
 * @param ps *Http2PeerSettings
 * @return i32
 */
export function peer_settings_header_table_size(ps: *Http2PeerSettings): i32 {
  return http2_libc_peer_settings_header_table_size_c(ps);
}

/** Exported function `peer_settings_max_frame_size`.
 * Implements `peer_settings_max_frame_size`.
 * @param ps *Http2PeerSettings
 * @return i32
 */
export function peer_settings_max_frame_size(ps: *Http2PeerSettings): i32 {
  return http2_libc_peer_settings_max_frame_size_c(ps);
}

/** Exported function `peer_settings_max_header_list_size`.
 * Implements `peer_settings_max_header_list_size`.
 * @param ps *Http2PeerSettings
 * @return i32
 */
export function peer_settings_max_header_list_size(ps: *Http2PeerSettings): i32 {
  return http2_libc_peer_settings_max_header_list_size_c(ps);
}

/** Exported function `peer_settings_max_streams`.
 * Implements `peer_settings_max_streams`.
 * @param ps *Http2PeerSettings
 * @return i32
 */
export function peer_settings_max_streams(ps: *Http2PeerSettings): i32 {
  return http2_libc_peer_settings_max_streams_c(ps);
}

/** Exported function `peer_settings_initial_window`.
 * Implements `peer_settings_initial_window`.
 * @param ps *Http2PeerSettings
 * @return i32
 */
export function peer_settings_initial_window(ps: *Http2PeerSettings): i32 {
  return http2_libc_peer_settings_initial_window_c(ps);
}

/** Exported function `settings_smoke`.
 * Implements `settings_smoke`.
 * @return i32
 */
export function settings_smoke(): i32 {
  return http2_libc_settings_smoke_c();
}

/** Exported function `client_init`.
 * Implements `client_init`.
 * @param cli *Http2MultistreamClient
 * @return void
 */
export function client_init(cli: *Http2MultistreamClient): void {
  http2_libc_multistream_client_init_c(cli);
}

/** Exported function `client_on_settings`.
 * Implements `client_on_settings`.
 * @param cli *Http2MultistreamClient
 * @param payload *u8
 * @param plen i32
 * @return i32
 */
export function client_on_settings(cli: *Http2MultistreamClient, payload: *u8, plen: i32): i32 {
  return http2_libc_multistream_client_on_settings_c(cli, payload, plen);
}

/** Exported function `client_open`.
 * Implements `client_open`.
 * @param cli *Http2MultistreamClient
 * @return i32
 */
export function client_open(cli: *Http2MultistreamClient): i32 {
  return http2_libc_multistream_client_open_stream_c(cli);
}

/** Exported function `client_close`.
 * Implements `client_close`.
 * @param cli *Http2MultistreamClient
 * @param stream_id i32
 * @return void
 */
export function client_close(cli: *Http2MultistreamClient, stream_id: i32): void {
  http2_libc_multistream_client_close_stream_c(cli, stream_id);
}

/** Exported function `client_get`.
 * Implements `client_get`.
 * @param cli *Http2MultistreamClient
 * @param stream_id i32
 * @param authority *u8
 * @param authority_len i32
 * @param path *u8
 * @param path_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function client_get(cli: *Http2MultistreamClient, stream_id: i32, authority: *u8, authority_len: i32, path: *u8, path_len: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_multistream_client_build_get_c(cli, stream_id, authority, authority_len, path, path_len, out, out_cap);
}

/** Exported function `client_parallel_get`.
 * Implements `client_parallel_get`.
 * @param cli *Http2MultistreamClient
 * @param authority *u8
 * @param authority_len i32
 * @param path *u8
 * @param path_len i32
 * @param n_reqs i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function client_parallel_get(cli: *Http2MultistreamClient, authority: *u8, authority_len: i32, path: *u8, path_len: i32, n_reqs: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_multistream_client_build_parallel_get_c(cli, authority, authority_len, path, path_len, n_reqs, out, out_cap);
}

/** Exported function `multistream_client_smoke`.
 * Implements `multistream_client_smoke`.
 * @return i32
 */
export function multistream_client_smoke(): i32 {
  return http2_libc_multistream_client_smoke_c();
}

/** Exported function `conn_reuse_is_available`.
 * Implements `conn_reuse_is_available`.
 * @return bool
 */
export function conn_reuse_is_available(): bool {
  if (http2_libc_conn_reuse_is_available_c() != 0) { return true; }
  return false;
}

/** Exported function `conn_init`.
 * Implements `conn_init`.
 * @param conn *Http2Conn
 * @return void
 */
export function conn_init(conn: *Http2Conn): void {
  http2_libc_conn_init_c(conn);
}

/** Exported function `conn_attach_h2c`.
 * Implements `conn_attach_h2c`.
 * @param fd i32
 * @param conn *Http2Conn
 * @return i32
 */
export function conn_attach_h2c(fd: i32, conn: *Http2Conn): i32 {
  return http2_libc_conn_attach_h2c_c(fd, conn);
}

/** Exported function `conn_attach_tls`.
 * Implements `conn_attach_tls`.
 * @param tls_ctx i64
 * @param conn *Http2Conn
 * @return i32
 */
export function conn_attach_tls(tls_ctx: i64, conn: *Http2Conn): i32 {
  return http2_libc_conn_attach_tls_c(tls_ctx, conn);
}

/** Exported function `conn_is_ready`.
 * Read path helper `conn_is_ready`.
 * @param conn *Http2Conn
 * @return bool
 */
export function conn_is_ready(conn: *Http2Conn): bool {
  if (http2_libc_conn_is_ready_c(conn) != 0) { return true; }
  return false;
}

/** Exported function `conn_handshake`.
 * Implements `conn_handshake`.
 * @param conn *Http2Conn
 * @return i32
 */
export function conn_handshake(conn: *Http2Conn): i32 {
  return http2_libc_conn_handshake_c(conn);
}

/** Exported function `conn_handshake_with_enable_push`.
 * Implements `conn_handshake_with_enable_push`.
 * @param conn *Http2Conn
 * @param client_enable_push i32
 * @return i32
 */
export function conn_handshake_with_enable_push(conn: *Http2Conn, client_enable_push: i32): i32 {
  return http2_libc_conn_handshake_with_enable_push_c(conn, client_enable_push);
}

/** Exported function `conn_handshake_with_max_frame`.
 * Implements `conn_handshake_with_max_frame`.
 * @param conn *Http2Conn
 * @param client_max_frame_size i32
 * @return i32
 */
export function conn_handshake_with_max_frame(conn: *Http2Conn, client_max_frame_size: i32): i32 {
  return http2_libc_conn_handshake_with_max_frame_c(conn, client_max_frame_size);
}

/**
 * See implementation.
 * See implementation.
 */
export function conn_request(conn: *Http2Conn, method: Method, authority: *u8, authority_len: i32, path: *u8, path_len: i32, body: *u8, body_len: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_conn_request_c(conn, method(method), authority, authority_len, path, path_len, body, body_len, out, out_cap);
}

/** Exported function `conn_close`.
 * Implements `conn_close`.
 * @param conn *Http2Conn
 * @return void
 */
export function conn_close(conn: *Http2Conn): void {
  http2_libc_conn_close_c(conn);
}

/**
 * See implementation.
 */
export function conn_shutdown_graceful(conn: *Http2Conn, last_stream_id: i32, code: i32): void {
  http2_libc_conn_shutdown_graceful_c(conn, last_stream_id, code);
}

/** Exported function `conn_read_goaway`.
 * Read path helper `conn_read_goaway`.
 * @param conn *Http2Conn
 * @param out_last_stream *i32
 * @param out_code *i32
 * @return i32
 */
export function conn_read_goaway(conn: *Http2Conn, out_last_stream: *i32, out_code: *i32): i32 {
  return http2_libc_conn_read_goaway_c(conn, out_last_stream, out_code);
}

/** Exported function `conn_ping`.
 * Implements `conn_ping`.
 * @param conn *Http2Conn
 * @param opaque *u8
 * @return i32
 */
export function conn_ping(conn: *Http2Conn, opaque: *u8): i32 {
  return http2_libc_conn_ping_c(conn, opaque);
}

/** Exported function `conn_goaway_seen`.
 * Implements `conn_goaway_seen`.
 * @param conn *Http2Conn
 * @return bool
 */
export function conn_goaway_seen(conn: *Http2Conn): bool {
  if (http2_libc_conn_goaway_seen_c(conn) != 0) { return true; }
  return false;
}

/** Exported function `conn_is_pool_reusable`.
 * Implements `conn_is_pool_reusable`.
 * @param conn *Http2Conn
 * @return bool
 */
export function conn_is_pool_reusable(conn: *Http2Conn): bool {
  if (http2_libc_conn_is_pool_reusable_c(conn) != 0) { return true; }
  return false;
}

/** Exported function `conn_reset_stream`.
 * Implements `conn_reset_stream`.
 * @param conn *Http2Conn
 * @param stream_id i32
 * @param code i32
 * @return i32
 */
export function conn_reset_stream(conn: *Http2Conn, stream_id: i32, code: i32): i32 {
  return http2_libc_conn_reset_stream_c(conn, stream_id, code);
}

/** Exported function `conn_reuse_smoke`.
 * Implements `conn_reuse_smoke`.
 * @return i32
 */
export function conn_reuse_smoke(): i32 {
  return http2_libc_conn_reuse_smoke_c();
}

/** Exported function `alpn_h2_len`.
 * Query helper `alpn_h2_len`.
 * @return i32
 */
export function alpn_h2_len(): i32 {
  return http2_libc_alpn_h2_len_c();
}

/** Exported function `write_alpn_h2`.
 * Write path helper `write_alpn_h2`.
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function write_alpn_h2(out: *u8, out_cap: i32): i32 {
  return http2_libc_write_alpn_h2_c(out, out_cap);
}

/** Exported function `smoke`.
 * Implements `smoke`.
 * @return i32
 */
export function smoke(): i32 {
  return http2_libc_smoke_c();
}

/** Exported function `frame_window_update`.
 * Implements `frame_window_update`.
 * @return i32
 */
export function frame_window_update(): i32 { return 8; }

/** Exported function `default_initial_window`.
 * Implements `default_initial_window`.
 * @return i32
 */
export function default_initial_window(): i32 {
  return http2_libc_default_initial_window_c();
}

/** Exported function `build_window_update`.
 * Implements `build_window_update`.
 * @param stream_id i32
 * @param increment i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function build_window_update(stream_id: i32, increment: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_build_window_update_c(stream_id, increment, out, out_cap);
}

/** Exported function `hpack_huffman_decode`.
 * Implements `hpack_huffman_decode`.
 * @param in *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function hpack_huffman_decode(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_hpack_huffman_decode_c(in, in_len, out, out_cap);
}

/** Exported function `hpack_huffman_is_available`.
 * Implements `hpack_huffman_is_available`.
 * @return bool
 */
export function hpack_huffman_is_available(): bool {
  if (http2_libc_hpack_huffman_is_available_c() != 0) { return true; }
  return false;
}

/** Exported function `hpack_huffman_smoke`.
 * Implements `hpack_huffman_smoke`.
 * @return i32
 */
export function hpack_huffman_smoke(): i32 {
  return http2_libc_hpack_huffman_smoke_c();
}

/** Exported function `flow_control_smoke`.
 * Implements `flow_control_smoke`.
 * @return i32
 */
export function flow_control_smoke(): i32 {
  return http2_libc_flow_control_smoke_c();
}

/** Exported function `flow_state_init`.
 * Implements `flow_state_init`.
 * @param st *Http2FlowState
 * @return void
 */
export function flow_state_init(st: *Http2FlowState): void {
  http2_libc_flow_state_init_c(st);
}

/** Exported function `flow_state_reset_stream`.
 * Implements `flow_state_reset_stream`.
 * @param st *Http2FlowState
 * @param initial_window i32
 * @return void
 */
export function flow_state_reset_stream(st: *Http2FlowState, initial_window: i32): void {
  http2_libc_flow_state_reset_stream_c(st, initial_window);
}

/** Exported function `flow_state_apply_initial_window`.
 * Implements `flow_state_apply_initial_window`.
 * @param st *Http2FlowState
 * @param initial_window i32
 * @return void
 */
export function flow_state_apply_initial_window(st: *Http2FlowState, initial_window: i32): void {
  http2_libc_flow_state_apply_initial_window_c(st, initial_window);
}

/**
 * See implementation.
 * See implementation.
 */
export function flow_state_apply_window_update(st: *Http2FlowState, stream_id: i32, increment: i32): i32 {
  return http2_libc_flow_state_apply_window_update_c(st, stream_id, increment);
}

/** Exported function `flow_state_max_send`.
 * Implements `flow_state_max_send`.
 * @param st *Http2FlowState
 * @param want i32
 * @return i32
 */
export function flow_state_max_send(st: *Http2FlowState, want: i32): i32 {
  return http2_libc_flow_state_max_send_c(st, want);
}

/** Exported function `flow_state_can_send`.
 * Implements `flow_state_can_send`.
 * @param st *Http2FlowState
 * @param want i32
 * @return bool
 */
export function flow_state_can_send(st: *Http2FlowState, want: i32): bool {
  if (http2_libc_flow_state_can_send_c(st, want) != 0) { return true; }
  return false;
}

/**
 * See implementation.
 * See implementation.
 */
export function flow_state_consume_send(st: *Http2FlowState, nbytes: i32): i32 {
  return http2_libc_flow_state_consume_send_c(st, nbytes);
}

/** Exported function `parse_window_update_payload`.
 * Implements `parse_window_update_payload`.
 * @param payload *u8
 * @param plen i32
 * @param out_increment *i32
 * @return i32
 */
export function parse_window_update_payload(payload: *u8, plen: i32, out_increment: *i32): i32 {
  return http2_libc_parse_window_update_payload_c(payload, plen, out_increment);
}

/** Exported function `flow_state_smoke`.
 * Implements `flow_state_smoke`.
 * @return i32
 */
export function flow_state_smoke(): i32 {
  return http2_libc_flow_state_smoke_c();
}

/** Exported function `frame_push_promise`.
 * Implements `frame_push_promise`.
 * @return i32
 */
export function frame_push_promise(): i32 {
  return http2_libc_frame_push_promise_c();
}

/** Exported function `is_push_promise_frame`.
 * Query helper `is_push_promise_frame`.
 * @param ftype i32
 * @return bool
 */
export function is_push_promise_frame(ftype: i32): bool {
  if (http2_libc_is_push_promise_frame_c(ftype) != 0) { return true; }
  return false;
}

/** Exported function `parse_push_promise_stream`.
 * Implements `parse_push_promise_stream`.
 * @param payload *u8
 * @param plen i32
 * @param out_promised_id *i32
 * @return i32
 */
export function parse_push_promise_stream(payload: *u8, plen: i32, out_promised_id: *i32): i32 {
  return http2_libc_parse_push_promise_stream_c(payload, plen, out_promised_id);
}

/** Exported function `is_h2c_upgrade_response`.
 * Query helper `is_h2c_upgrade_response`.
 * @param buf *u8
 * @param len i32
 * @return bool
 */
export function is_h2c_upgrade_response(buf: *u8, len: i32): bool {
  if (http2_libc_is_h2c_upgrade_response_c(buf, len) != 0) { return true; }
  return false;
}

/** Exported function `h2c_is_available`.
 * Implements `h2c_is_available`.
 * @return bool
 */
export function h2c_is_available(): bool {
  if (http2_libc_h2c_is_available_c() != 0) { return true; }
  return false;
}

/** Exported function `push_h2c_smoke`.
 * Implements `push_h2c_smoke`.
 * @return i32
 */
export function push_h2c_smoke(): i32 {
  return http2_libc_push_h2c_smoke_c();
}

/** Exported function `h2c_wire_is_available`.
 * Implements `h2c_wire_is_available`.
 * @return bool
 */
export function h2c_wire_is_available(): bool {
  if (http2_libc_h2c_wire_is_available_c() != 0) { return true; }
  return false;
}

/** Exported function `h2c_session_begin`.
 * Implements `h2c_session_begin`.
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function h2c_session_begin(out: *u8, out_cap: i32): i32 {
  return http2_libc_h2c_session_begin_c(out, out_cap);
}

/** Exported function `push_fetch_smoke`.
 * Implements `push_fetch_smoke`.
 * @return i32
 */
export function push_fetch_smoke(): i32 {
  return http2_libc_push_fetch_smoke_c();
}

/** Exported function `push_last_reset`.
 * Implements `push_last_reset`.
 * @return void
 */
export function push_last_reset(): void {
  http2_libc_push_last_reset_c();
}

/** Exported function `push_last_copy`.
 * Implements `push_last_copy`.
 * @param out_meta *Http2PushLast
 * @param out_body *u8
 * @param out_cap i32
 * @return i32
 */
export function push_last_copy(out_meta: *Http2PushLast, out_body: *u8, out_cap: i32): i32 {
  return http2_libc_push_last_copy_c(out_meta, out_body, out_cap);
}

/**
 * See implementation.
 * See implementation.
 */
export function push_last_body_owned(out_meta: *Http2PushLast, out_body: *HttpBodyOwned): i32 {
  let tmp: u8[4096] = [];
  let n: i32 = 0;
  let p: *u8 = 0;
  let copied: i32 = 0;
  n = push_last_copy(out_meta, &tmp[0], 4096);
  if (n < 0) {
    return -1;
  }
  if (n == 0) {
    out_body.ptr = 0;
    out_body.len = 0;
    return 0;
  }
  p = heap.alloc(n as usize);
  if (p == 0) {
    return -1;
  }
  copied = http_libc_url_copy_c(&tmp[0], n, p, n);
  if (copied < 0) {
    heap.free(p);
    return -1;
  }
  out_body.ptr = p;
  out_body.len = n;
  return n;
}

/** Exported function `push_network_smoke`.
 * Implements `push_network_smoke`.
 * @return i32
 */
export function push_network_smoke(): i32 {
  return http2_libc_push_network_smoke_c();
}

/** Exported function `h2c_network_smoke`.
 * Implements `h2c_network_smoke`.
 * @return i32
 */
export function h2c_network_smoke(): i32 {
  return http2_libc_h2c_network_smoke_c();
}

/** Exported function `flow_recv_init`.
 * Implements `flow_recv_init`.
 * @param st *Http2FlowRecvState
 * @return void
 */
export function flow_recv_init(st: *Http2FlowRecvState): void {
  http2_libc_flow_recv_init_c(st);
}

/** Exported function `flow_recv_reset_stream`.
 * Implements `flow_recv_reset_stream`.
 * @param st *Http2FlowRecvState
 * @param initial_window i32
 * @return void
 */
export function flow_recv_reset_stream(st: *Http2FlowRecvState, initial_window: i32): void {
  http2_libc_flow_recv_reset_stream_c(st, initial_window);
}

/** Exported function `flow_recv_on_data`.
 * Implements `flow_recv_on_data`.
 * @param st *Http2FlowRecvState
 * @param nbytes i32
 * @return i32
 */
export function flow_recv_on_data(st: *Http2FlowRecvState, nbytes: i32): i32 {
  return http2_libc_flow_recv_on_data_c(st, nbytes);
}

/** Exported function `flow_recv_release`.
 * Implements `flow_recv_release`.
 * @param st *Http2FlowRecvState
 * @param stream_id i32
 * @param nbytes i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function flow_recv_release(st: *Http2FlowRecvState, stream_id: i32, nbytes: i32, out: *u8, out_cap: i32): i32 {
  return http2_libc_flow_recv_release_c(st, stream_id, nbytes, out, out_cap);
}

/** Exported function `flow_recv_smoke`.
 * Implements `flow_recv_smoke`.
 * @return i32
 */
export function flow_recv_smoke(): i32 {
  return http2_libc_flow_recv_smoke_c();
}
