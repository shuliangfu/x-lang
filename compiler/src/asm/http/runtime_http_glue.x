// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function http_set_timeouts_impl(fd: i32, timeout_ms: u32): i32;
export extern "C" function http_connect_timeout_impl(fd: i32, res: *u8, timeout_ms: u32): i32;
export extern "C" function shu_http_send_all_impl(fd: i32, buf: *u8, len: i32, is_socket: i32): i32;
export extern "C" function parse_http_url_impl(url: *u8, url_len: i32, host_buf: *u8, host_cap: i32, port_buf: *u8,
                                        port_cap: i32, path_buf: *u8, path_cap: i32, out_is_https: *i32): i32;
export extern "C" function http_transport_close_impl(tr: *u8): void;
export extern "C" function http_transport_send_all_impl(tr: *u8, data: *u8, len: i32): i32;
export extern "C" function http_transport_recv_fill_impl(tr: *u8, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32;
export extern "C" function http_format_request_impl(method: *u8, path_buf: *u8, host_buf: *u8, body_len: i32,
                                             req: *u8, req_cap: i32): i32;
export extern "C" function http_drain_request_impl(fd: i32): i32;

/** Exported function `runtime_http_glue_x_doc_anchor`.
 * Implements `runtime_http_glue_x_doc_anchor`.
 * @return i32
 */
export function runtime_http_glue_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */



#[no_mangle]
export function http_set_timeouts(fd: i32, timeout_ms: u32): i32 {
  unsafe { return http_set_timeouts_impl(fd, timeout_ms); }
  return 0 - 1;
}

/** Exported function `http_connect_timeout`.
 * Implements `http_connect_timeout`.
 * @param fd i32
 * @param res *u8
 * @param timeout_ms u32
 * @return i32
 */
#[no_mangle]
export function http_connect_timeout(fd: i32, res: *u8, timeout_ms: u32): i32 {
  unsafe { return http_connect_timeout_impl(fd, res, timeout_ms); }
  return 0 - 1;
}

/** Exported function `shu_http_send_all`.
 * Implements `shu_http_send_all`.
 * @param fd i32
 * @param buf *u8
 * @param len i32
 * @param is_socket i32
 * @return i32
 */
#[no_mangle]
export function shu_http_send_all(fd: i32, buf: *u8, len: i32, is_socket: i32): i32 {
  unsafe { return shu_http_send_all_impl(fd, buf, len, is_socket); }
  return 0 - 1;
}

/* See implementation. */

#[no_mangle]
export function parse_http_url(url: *u8, url_len: i32, host_buf: *u8, host_cap: i32, port_buf: *u8, port_cap: i32,
                        path_buf: *u8, path_cap: i32, out_is_https: *i32): i32 {
  unsafe {
    return parse_http_url_impl(url, url_len, host_buf, host_cap, port_buf, port_cap, path_buf, path_cap,
                               out_is_https);
  }
  return 0 - 1;
}

/** Exported function `http_transport_close`.
 * Implements `http_transport_close`.
 * @param tr *u8
 * @return void
 */
#[no_mangle]
export function http_transport_close(tr: *u8): void {
  unsafe { http_transport_close_impl(tr); }
}

/** Exported function `http_transport_send_all`.
 * Implements `http_transport_send_all`.
 * @param tr *u8
 * @param data *u8
 * @param len i32
 * @return i32
 */
#[no_mangle]
export function http_transport_send_all(tr: *u8, data: *u8, len: i32): i32 {
  unsafe { return http_transport_send_all_impl(tr, data, len); }
  return 0 - 1;
}

/** Exported function `http_transport_recv_fill`.
 * Implements `http_transport_recv_fill`.
 * @param tr *u8
 * @param out_buf *u8
 * @param out_cap i32
 * @param timeout_ms u32
 * @return i32
 */
#[no_mangle]
export function http_transport_recv_fill(tr: *u8, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_transport_recv_fill_impl(tr, out_buf, out_cap, timeout_ms); }
  return 0 - 1;
}

/** Function `http_format_request`.
 * Purpose: implements `http_format_request`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
export function http_format_request(method: *u8, path_buf: *u8, host_buf: *u8, body_len: i32, req: *u8,
                             req_cap: i32): i32 {
  unsafe { return http_format_request_impl(method, path_buf, host_buf, body_len, req, req_cap); }
  return 0 - 1;
}

/** Exported function `http_drain_request`.
 * Implements `http_drain_request`.
 * @param fd i32
 * @return i32
 */
#[no_mangle]
export function http_drain_request(fd: i32): i32 {
  unsafe { return http_drain_request_impl(fd); }
  return 0 - 1;
}

export extern "C" function http_transport_start_tls_impl(tr: *u8, is_https: i32, host: *u8): i32;

/* See implementation. */

#[no_mangle]
export function http_transport_start_tls(tr: *u8, is_https: i32, host: *u8): i32 {
  unsafe { return http_transport_start_tls_impl(tr, is_https, host); }
  return 0 - 1;
}

// See implementation.

export extern "C" function http_request_timeout_ex_c_impl(method: *u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out: *u8, out_cap: i32, timeout_ms: u32): i32;

/* See implementation. */

#[no_mangle]
export function http_request_timeout_ex_c(method: *u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_request_timeout_ex_c_impl(method, url, url_len, body, body_len, out, out_cap, timeout_ms); }
  return 0;
}

// http_method_has_body: see function docblock below.

/** Exported function `http_method_has_body`.
 * Implements `http_method_has_body`.
 * @param method *u8
 * @return i32
 */
#[no_mangle]
export function http_method_has_body(method: *u8): i32 {
  if (method == 0) { return 0; }
  // POST
  if (method[0] == 80 && method[1] == 79 && method[2] == 83 && method[3] == 84 && method[4] == 0) {
    return 1;
  }
  // PUT
  if (method[0] == 80 && method[1] == 85 && method[2] == 84 && method[3] == 0) {
    return 1;
  }
  // PATCH
  if (method[0] == 80 && method[1] == 65 && method[2] == 84 && method[3] == 67 && method[4] == 72 && method[5] == 0) {
    return 1;
  }
  return 0;
}
