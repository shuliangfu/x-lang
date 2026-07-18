// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-21：runtime_http_glue 产品源迁 seeds/runtime_http_glue.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// G-02f-105：+ method_has_body / set_timeouts / connect_timeout / send_all 薄门闩。
// G-02f-106：+ parse_url / transport close/send/recv / format / drain 薄门闩。
// G-02f-107：+ transport_start_tls 薄门闩。

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

export function runtime_http_glue_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-105：http helpers 门闩 ---- */



#[no_mangle]
export function http_set_timeouts(fd: i32, timeout_ms: u32): i32 {
  unsafe { return http_set_timeouts_impl(fd, timeout_ms); }
  return 0 - 1;
}

#[no_mangle]
export function http_connect_timeout(fd: i32, res: *u8, timeout_ms: u32): i32 {
  unsafe { return http_connect_timeout_impl(fd, res, timeout_ms); }
  return 0 - 1;
}

#[no_mangle]
export function shu_http_send_all(fd: i32, buf: *u8, len: i32, is_socket: i32): i32 {
  unsafe { return shu_http_send_all_impl(fd, buf, len, is_socket); }
  return 0 - 1;
}

/* ---- G-02f-106：url / transport / format 门闩 ---- */

#[no_mangle]
export function parse_http_url(url: *u8, url_len: i32, host_buf: *u8, host_cap: i32, port_buf: *u8, port_cap: i32,
                        path_buf: *u8, path_cap: i32, out_is_https: *i32): i32 {
  unsafe {
    return parse_http_url_impl(url, url_len, host_buf, host_cap, port_buf, port_cap, path_buf, path_cap,
                               out_is_https);
  }
  return 0 - 1;
}

#[no_mangle]
export function http_transport_close(tr: *u8): void {
  unsafe { http_transport_close_impl(tr); }
}

#[no_mangle]
export function http_transport_send_all(tr: *u8, data: *u8, len: i32): i32 {
  unsafe { return http_transport_send_all_impl(tr, data, len); }
  return 0 - 1;
}

#[no_mangle]
export function http_transport_recv_fill(tr: *u8, out_buf: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_transport_recv_fill_impl(tr, out_buf, out_cap, timeout_ms); }
  return 0 - 1;
}

#[no_mangle]
export function http_format_request(method: *u8, path_buf: *u8, host_buf: *u8, body_len: i32, req: *u8,
                             req_cap: i32): i32 {
  unsafe { return http_format_request_impl(method, path_buf, host_buf, body_len, req, req_cap); }
  return 0 - 1;
}

#[no_mangle]
export function http_drain_request(fd: i32): i32 {
  unsafe { return http_drain_request_impl(fd); }
  return 0 - 1;
}

export extern "C" function http_transport_start_tls_impl(tr: *u8, is_https: i32, host: *u8): i32;

/* ---- G-02f-107：tls start 门闩 ---- */

#[no_mangle]
export function http_transport_start_tls(tr: *u8, is_https: i32, host: *u8): i32 {
  unsafe { return http_transport_start_tls_impl(tr, is_https, host); }
  return 0 - 1;
}

// G-02f-112：+ http_request_timeout_ex_c 薄门闩（#if 花括号 #if-aware promote）。

export extern "C" function http_request_timeout_ex_c_impl(method: *u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out: *u8, out_cap: i32, timeout_ms: u32): i32;

/* ---- G-02f-112：http timeout client 门闩 ---- */

#[no_mangle]
export function http_request_timeout_ex_c(method: *u8, url: *u8, url_len: i32, body: *u8, body_len: i32, out: *u8, out_cap: i32, timeout_ms: u32): i32 {
  unsafe { return http_request_timeout_ex_c_impl(method, url, url_len, body, body_len, out, out_cap, timeout_ms); }
  return 0;
}

// G-02f-119：http_method_has_body 真迁 .x

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
