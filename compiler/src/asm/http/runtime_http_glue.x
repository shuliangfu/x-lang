// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-21：runtime_http_glue 产品源迁 seeds/runtime_http_glue.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// G-02f-105：+ method_has_body / set_timeouts / connect_timeout / send_all 薄门闩。

extern "C" function http_method_has_body_impl(method: *u8): i32;
extern "C" function http_set_timeouts_impl(fd: i32, timeout_ms: u32): i32;
extern "C" function http_connect_timeout_impl(fd: i32, res: *u8, timeout_ms: u32): i32;
extern "C" function shu_http_send_all_impl(fd: i32, buf: *u8, len: i32, is_socket: i32): i32;

function runtime_http_glue_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-105：http helpers 门闩 ---- */

#[no_mangle]
function http_method_has_body(method: *u8): i32 {
  unsafe {
    return http_method_has_body_impl(method);
  }
  return 0;
}

#[no_mangle]
function http_set_timeouts(fd: i32, timeout_ms: u32): i32 {
  unsafe {
    return http_set_timeouts_impl(fd, timeout_ms);
  }
  return 0 - 1;
}

#[no_mangle]
function http_connect_timeout(fd: i32, res: *u8, timeout_ms: u32): i32 {
  unsafe {
    return http_connect_timeout_impl(fd, res, timeout_ms);
  }
  return 0 - 1;
}

#[no_mangle]
function shu_http_send_all(fd: i32, buf: *u8, len: i32, is_socket: i32): i32 {
  unsafe {
    return shu_http_send_all_impl(fd, buf, len, is_socket);
  }
  return 0 - 1;
}
