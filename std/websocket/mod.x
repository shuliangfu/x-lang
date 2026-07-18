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
/* See implementation. */
const ws_codec = import("std.net.ws_codec");
/* See implementation. */
const ws_io = import("std.net.ws_io");
/* See implementation. */
const tls = import("std.net.tls_stub");

extern function net_close_socket_c(fd: i32): i32;

/* See implementation. */
allow(padding) struct WsStream {
  fd: i32;
  tls_ctx: i64;
}

/** Exported function `ws_err_ok`.
 * Implements `ws_err_ok`.
 * @return i32
 */
export function ws_err_ok(): i32 { return 0; }
/** Exported function `ws_err_io`.
 * Implements `ws_err_io`.
 * @return i32
 */
export function ws_err_io(): i32 { return -1; }
/** Exported function `ws_err_handshake`.
 * Implements `ws_err_handshake`.
 * @return i32
 */
export function ws_err_handshake(): i32 { return -2; }
/** Exported function `ws_err_null`.
 * Implements `ws_err_null`.
 * @return i32
 */
export function ws_err_null(): i32 { return -3; }
/** Exported function `ws_err_tls_not_impl`.
 * Implements `ws_err_tls_not_impl`.
 * @return i32
 */
export function ws_err_tls_not_impl(): i32 { return -1221; }

/** Exported function `ws_timeout_ms_from_ctx`.
 * Implements `ws_timeout_ms_from_ctx`.
 * @param ctx Context
 * @return i32
 */
export function ws_timeout_ms_from_ctx(ctx: Context): i32 {
  if (context.is_cancelled(ctx) != 0) {
    return err.net_err_cancelled();
  }
  let rem: i64 = context.remaining_ns(ctx);
  let dl: i64 = context.deadline_ns(ctx);
  if (dl > 0 && rem <= 0) {
    return err.net_err_timeout();
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

/** Exported function `ws_ctx_check`.
 * Implements `ws_ctx_check`.
 * @param ctx Context
 * @return i32
 */
export function ws_ctx_check(ctx: Context): i32 {
  let tm: i32 = ws_timeout_ms_from_ctx(ctx);
  if (tm == err.net_err_cancelled()) {
    return tm;
  }
  if (tm == err.net_err_timeout()) {
    return tm;
  }
  return 0;
}

/** Exported function `ws_map_c_result`.
 * Implements `ws_map_c_result`.
 * @param c_code i32
 * @return i32
 */
export function ws_map_c_result(c_code: i32): i32 {
  if (c_code == ws_err_tls_not_impl()) {
    return ws_err_tls_not_impl();
  }
  return c_code;
}

/** Exported function `ws_opcode_text`.
 * Implements `ws_opcode_text`.
 * @return i32
 */
export function ws_opcode_text(): i32 { return 1; }
/** Exported function `ws_opcode_binary`.
 * Implements `ws_opcode_binary`.
 * @return i32
 */
export function ws_opcode_binary(): i32 { return 2; }
/** Exported function `ws_opcode_close`.
 * Implements `ws_opcode_close`.
 * @return i32
 */
export function ws_opcode_close(): i32 { return 8; }
/** Exported function `ws_opcode_ping`.
 * Implements `ws_opcode_ping`.
 * @return i32
 */
export function ws_opcode_ping(): i32 { return 9; }
/** Exported function `ws_opcode_pong`.
 * Implements `ws_opcode_pong`.
 * @return i32
 */
export function ws_opcode_pong(): i32 { return 10; }

/** Exported function `wss_is_available`.
 * Implements `wss_is_available`.
 * @return bool
 */
export function wss_is_available(): bool {
  if (ws_io.net_ws_tls_is_available_c() != 0) { return true; }
  return false;
}

/** Exported function `ws_compute_accept`.
 * Implements `ws_compute_accept`.
 * @param key *u8
 * @param key_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function ws_compute_accept(key: *u8, key_len: i32, out: *u8, out_cap: i32): i32 {
  return ws_codec.net_ws_compute_accept_c(key, key_len, out, out_cap);
}

/** Exported function `ws_build_handshake_request`.
 * Implements `ws_build_handshake_request`.
 * @param host *u8
 * @param path *u8
 * @param key *u8
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function ws_build_handshake_request(host: *u8, path: *u8, key: *u8, out: *u8, out_cap: i32): i32 {
  return ws_codec.net_ws_handshake_request_c(host, path, key, out, out_cap);
}

/** Exported function `ws_validate_handshake_response`.
 * Implements `ws_validate_handshake_response`.
 * @param resp *u8
 * @param resp_len i32
 * @param key *u8
 * @param key_len i32
 * @return i32
 */
export function ws_validate_handshake_response(resp: *u8, resp_len: i32, key: *u8, key_len: i32): i32 {
  return ws_codec.net_ws_validate_handshake_c(resp, resp_len, key, key_len);
}

/** Exported function `ws_encode_text_frame`.
 * Implements `ws_encode_text_frame`.
 * @param payload *u8
 * @param payload_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function ws_encode_text_frame(payload: *u8, payload_len: i32, out: *u8, out_cap: i32): i32 {
  return ws_codec.net_ws_encode_text_frame_c(payload, payload_len, out, out_cap);
}

/** Exported function `ws_encode_binary_frame`.
 * Implements `ws_encode_binary_frame`.
 * @param payload *u8
 * @param payload_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function ws_encode_binary_frame(payload: *u8, payload_len: i32, out: *u8, out_cap: i32): i32 {
  return ws_codec.net_ws_encode_binary_frame_c(payload, payload_len, out, out_cap);
}

/** Exported function `ws_encode_ping_frame`.
 * Implements `ws_encode_ping_frame`.
 * @param payload *u8
 * @param payload_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function ws_encode_ping_frame(payload: *u8, payload_len: i32, out: *u8, out_cap: i32): i32 {
  return ws_codec.net_ws_encode_ping_frame_c(payload, payload_len, out, out_cap);
}

/** Exported function `ws_encode_pong_frame`.
 * Implements `ws_encode_pong_frame`.
 * @param payload *u8
 * @param payload_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function ws_encode_pong_frame(payload: *u8, payload_len: i32, out: *u8, out_cap: i32): i32 {
  return ws_codec.net_ws_encode_pong_frame_c(payload, payload_len, out, out_cap);
}

/**
 * See implementation.
 * See implementation.
 */
export function ws_encode_close_frame(status_code: i32, reason: *u8, reason_len: i32, out: *u8, out_cap: i32): i32 {
  return ws_codec.net_ws_encode_close_frame_c(status_code, reason, reason_len, out, out_cap);
}

/* See implementation. */
export function ws_decode_frame(buf: *u8, buf_len: i32, out_opcode: *i32, out_payload: *u8,
  out_payload_cap: i32, out_payload_len: *i32): i32 {
  return ws_codec.net_ws_decode_frame_c(buf, buf_len, out_opcode, out_payload, out_payload_cap, out_payload_len);
}

/** Exported function `ws_generate_key`.
 * Implements `ws_generate_key`.
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function ws_generate_key(out: *u8, out_cap: i32): i32 {
  return ws_codec.net_ws_generate_key_c(out, out_cap);
}

/**
 * See implementation.
 * See implementation.
 */
export function ws_parse_url(url: *u8, url_len: i32, host: *u8, host_cap: i32, path: *u8, path_cap: i32,
  out_port: *u32, out_secure: *i32): i32 {
  if (url == 0 || host == 0 || path == 0 || out_port == 0) { return ws_err_null(); }
  return ws_codec.net_ws_parse_url_c(url, url_len, host, host_cap, path, path_cap, out_port, out_secure);
}

/**
 * See implementation.
 * See implementation.
 */
export function ws_client_handshake(fd: i32, host: *u8, path: *u8, key: *u8, key_len: i32, timeout_ms: u32): i32 {
  if (fd < 0 || host == 0 || path == 0) { return ws_err_null(); }
  return ws_io.net_ws_client_handshake_c(fd, host, path, key, key_len, timeout_ms);
}

/** Exported function `ws_client_handshake_ctx`.
 * Implements `ws_client_handshake_ctx`.
 * @param fd i32
 * @param host *u8
 * @param path *u8
 * @param key *u8
 * @param key_len i32
 * @param ctx Context
 * @return i32
 */
export function ws_client_handshake_ctx(fd: i32, host: *u8, path: *u8, key: *u8, key_len: i32, ctx: Context): i32 {
  let chk: i32 = ws_ctx_check(ctx);
  if (chk != 0) {
    return chk;
  }
  let tm: i32 = ws_timeout_ms_from_ctx(ctx);
  return ws_io.net_ws_client_handshake_c(fd, host, path, key, key_len, tm as u32);
}

/**
 * See implementation.
 * See implementation.
 */
export function ws_connect(host: *u8, port: u32, path: *u8, key: *u8, key_len: i32, timeout_ms: u32): WsStream {
  let bad: WsStream = WsStream { fd: -1, tls_ctx: 0 };
  let zero: i64 = 0;
  if (host == 0 || path == 0) { return bad; }
  let fd: i32 = ws_io.net_ws_connect_c(host, port, path, key, key_len, timeout_ms);
  return WsStream { fd: fd, tls_ctx: zero };
}

/**
 * See implementation.
 */
export function ws_connect_ctx_fd(host: *u8, port: u32, path: *u8, key: *u8, key_len: i32, ctx: Context): i32 {
  let tm: i32 = ws_timeout_ms_from_ctx(ctx);
  if (tm < 0) {
    return tm;
  }
  if (host == 0 || path == 0) {
    return ws_err_null();
  }
  return ws_io.net_ws_connect_c(host, port, path, key, key_len, tm as u32);
}

/** Exported function `ws_connect_ctx`.
 * Implements `ws_connect_ctx`.
 * @param host *u8
 * @param port u32
 * @param path *u8
 * @param key *u8
 * @param key_len i32
 * @param ctx Context
 * @return WsStream
 */
export function ws_connect_ctx(host: *u8, port: u32, path: *u8, key: *u8, key_len: i32, ctx: Context): WsStream {
  let zero: i64 = 0;
  let fd: i32 = ws_connect_ctx_fd(host, port, path, key, key_len, ctx);
  return WsStream { fd: fd, tls_ctx: zero };
}

/**
 * See implementation.
 * See implementation.
 */
export function ws_connect_tls(host: *u8, port: u32, path: *u8, key: *u8, key_len: i32, timeout_ms: u32): WsStream {
  let bad: WsStream = WsStream { fd: -1, tls_ctx: 0 };
  let tls: i64 = 0;
  let fd: i32 = 0;
  if (host == 0 || path == 0) { return bad; }
  fd = ws_io.net_ws_connect_tls_c(host, port, path, key, key_len, timeout_ms, &tls);
  if (fd < 0) { return bad; }
  return WsStream { fd: fd, tls_ctx: tls };
}

/** Exported function `ws_connect_tls_ctx_fd`.
 * Implements `ws_connect_tls_ctx_fd`.
 * @param host *u8
 * @param port u32
 * @param path *u8
 * @param key *u8
 * @param key_len i32
 * @param ctx Context
 * @param out_tls *i64
 * @return i32
 */
export function ws_connect_tls_ctx_fd(host: *u8, port: u32, path: *u8, key: *u8, key_len: i32, ctx: Context, out_tls: *i64): i32 {
  let tm: i32 = ws_timeout_ms_from_ctx(ctx);
  if (tm < 0) {
    return tm;
  }
  if (host == 0 || path == 0 || out_tls == 0) {
    return ws_err_null();
  }
  return ws_map_c_result(ws_io.net_ws_connect_tls_c(host, port, path, key, key_len, tm as u32, out_tls));
}

/** Exported function `ws_connect_tls_ctx`.
 * Implements `ws_connect_tls_ctx`.
 * @param host *u8
 * @param port u32
 * @param path *u8
 * @param key *u8
 * @param key_len i32
 * @param ctx Context
 * @return WsStream
 */
export function ws_connect_tls_ctx(host: *u8, port: u32, path: *u8, key: *u8, key_len: i32, ctx: Context): WsStream {
  let tls: i64 = 0;
  let fd: i32 = ws_connect_tls_ctx_fd(host, port, path, key, key_len, ctx, &tls);
  if (fd < 0) {
    return WsStream { fd: fd, tls_ctx: 0 };
  }
  return WsStream { fd: fd, tls_ctx: tls };
}

/**
 * See implementation.
 * See implementation.
 */
export function ws_connect_url(url: *u8, url_len: i32, key: *u8, key_len: i32, timeout_ms: u32): WsStream {
  let bad: WsStream = WsStream { fd: -1, tls_ctx: 0 };
  let fd: i32 = -1;
  let tls: i64 = 0;
  if (url == 0) { return bad; }
  if (ws_io.net_ws_connect_url_c(url, url_len, key, key_len, timeout_ms, &fd, &tls) != ws_err_ok()) {
    return bad;
  }
  return WsStream { fd: fd, tls_ctx: tls };
}

/**
 * See implementation.
 * See implementation.
 */
export function ws_connect_url_ctx(url: *u8, url_len: i32, key: *u8, key_len: i32, ctx: Context, out_fd: *i32, out_tls: *i64): i32 {
  let tm: i32 = ws_timeout_ms_from_ctx(ctx);
  if (tm < 0) {
    return tm;
  }
  if (url == 0 || out_fd == 0 || out_tls == 0) {
    return ws_err_null();
  }
  return ws_map_c_result(ws_io.net_ws_connect_url_c(url, url_len, key, key_len, tm as u32, out_fd, out_tls));
}

/** Exported function `ws_connect_url_ctx_stream`.
 * Implements `ws_connect_url_ctx_stream`.
 * @param url *u8
 * @param url_len i32
 * @param key *u8
 * @param key_len i32
 * @param ctx Context
 * @return WsStream
 */
export function ws_connect_url_ctx_stream(url: *u8, url_len: i32, key: *u8, key_len: i32, ctx: Context): WsStream {
  let bad: WsStream = WsStream { fd: -1, tls_ctx: 0 };
  let fd: i32 = -1;
  let tls: i64 = 0;
  if (ws_connect_url_ctx(url, url_len, key, key_len, ctx, &fd, &tls) != ws_err_ok()) {
    if (fd < 0) {
      return WsStream { fd: fd, tls_ctx: 0 };
    }
    return bad;
  }
  return WsStream { fd: fd, tls_ctx: tls };
}

/** Exported function `ws_write_text`.
 * Write path helper `ws_write_text`.
 * @param stream WsStream
 * @param payload *u8
 * @param payload_len i32
 * @return i32
 */
export function ws_write_text(stream: WsStream, payload: *u8, payload_len: i32): i32 {
  if (stream.fd < 0) { return ws_err_io(); }
  return ws_io.net_ws_write_text_c(stream.fd, stream.tls_ctx, payload, payload_len);
}

/** Exported function `ws_write_binary`.
 * Write path helper `ws_write_binary`.
 * @param stream WsStream
 * @param payload *u8
 * @param payload_len i32
 * @return i32
 */
export function ws_write_binary(stream: WsStream, payload: *u8, payload_len: i32): i32 {
  if (stream.fd < 0) { return ws_err_io(); }
  return ws_io.net_ws_write_binary_c(stream.fd, stream.tls_ctx, payload, payload_len);
}

/** Exported function `ws_write_text_ctx`.
 * Write path helper `ws_write_text_ctx`.
 * @param stream WsStream
 * @param payload *u8
 * @param payload_len i32
 * @param ctx Context
 * @return i32
 */
export function ws_write_text_ctx(stream: WsStream, payload: *u8, payload_len: i32, ctx: Context): i32 {
  let chk: i32 = ws_ctx_check(ctx);
  if (chk != 0) {
    return chk;
  }
  return ws_write_text(stream, payload, payload_len);
}

/** Exported function `ws_write_binary_ctx`.
 * Write path helper `ws_write_binary_ctx`.
 * @param stream WsStream
 * @param payload *u8
 * @param payload_len i32
 * @param ctx Context
 * @return i32
 */
export function ws_write_binary_ctx(stream: WsStream, payload: *u8, payload_len: i32, ctx: Context): i32 {
  let chk: i32 = ws_ctx_check(ctx);
  if (chk != 0) {
    return chk;
  }
  return ws_write_binary(stream, payload, payload_len);
}

/* See implementation. */
export function ws_read_frame(stream: WsStream, out_opcode: *i32, out_payload: *u8, out_cap: i32,
  out_payload_len: *i32, timeout_ms: u32): i32 {
  if (stream.fd < 0) { return ws_err_io(); }
  return ws_io.net_ws_read_frame_c(stream.fd, stream.tls_ctx, out_opcode, out_payload, out_cap, out_payload_len, timeout_ms);
}

/* See implementation. */
export function ws_read_frame_ctx(stream: WsStream, out_opcode: *i32, out_payload: *u8, out_cap: i32,
  out_payload_len: *i32, ctx: Context): i32 {
  let chk: i32 = ws_ctx_check(ctx);
  if (chk != 0) {
    return chk;
  }
  let tm: i32 = ws_timeout_ms_from_ctx(ctx);
  return ws_read_frame(stream, out_opcode, out_payload, out_cap, out_payload_len, tm as u32);
}

/** Exported function `ws_close`.
 * Implements `ws_close`.
 * @param stream WsStream
 * @return i32
 */
export function ws_close(stream: WsStream): i32 {
  let zero: i64 = 0;
  if (stream.tls_ctx != zero) {
    tls.net_tls_close_c(stream.tls_ctx);
  }
  if (stream.fd < 0) { return ws_err_ok(); }
  unsafe { return net_close_socket_c(stream.fd); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ws_extract_key_from_request`.
 * Implements `ws_extract_key_from_request`.
 * @param req *u8
 * @param req_len i32
 * @param out_key *u8
 * @param out_cap i32
 * @return i32
 */
export function ws_extract_key_from_request(req: *u8, req_len: i32, out_key: *u8, out_cap: i32): i32 {
  if (req == 0 || out_key == 0) { return ws_err_null(); }
  return ws_codec.net_ws_extract_key_from_request_c(req, req_len, out_key, out_cap);
}

/** Exported function `ws_validate_upgrade_request`.
 * Implements `ws_validate_upgrade_request`.
 * @param req *u8
 * @param req_len i32
 * @return i32
 */
export function ws_validate_upgrade_request(req: *u8, req_len: i32): i32 {
  if (req == 0) { return ws_err_null(); }
  return ws_codec.net_ws_validate_upgrade_request_c(req, req_len);
}

/**
 * See implementation.
 * See implementation.
 */
export function ws_server_accept(fd: i32, tls_ctx: i64, req: *u8, req_len: i32, timeout_ms: u32): i32 {
  if (fd < 0 || req == 0) { return ws_err_null(); }
  return ws_io.net_ws_server_accept_request_c(fd, tls_ctx, req, req_len, timeout_ms);
}

/** Exported function `ws_server_accept_ctx`.
 * Implements `ws_server_accept_ctx`.
 * @param fd i32
 * @param tls_ctx i64
 * @param req *u8
 * @param req_len i32
 * @param ctx Context
 * @return i32
 */
export function ws_server_accept_ctx(fd: i32, tls_ctx: i64, req: *u8, req_len: i32, ctx: Context): i32 {
  let chk: i32 = ws_ctx_check(ctx);
  if (chk != 0) {
    return chk;
  }
  let tm: i32 = ws_timeout_ms_from_ctx(ctx);
  return ws_server_accept(fd, tls_ctx, req, req_len, tm as u32);
}

/** Exported function `ws_server_handshake`.
 * Implements `ws_server_handshake`.
 * @param fd i32
 * @param tls_ctx i64
 * @param timeout_ms u32
 * @return i32
 */
export function ws_server_handshake(fd: i32, tls_ctx: i64, timeout_ms: u32): i32 {
  if (fd < 0) { return ws_err_null(); }
  return ws_io.net_ws_server_handshake_c(fd, tls_ctx, timeout_ms);
}

/** Exported function `ws_server_handshake_ctx`.
 * Implements `ws_server_handshake_ctx`.
 * @param fd i32
 * @param tls_ctx i64
 * @param ctx Context
 * @return i32
 */
export function ws_server_handshake_ctx(fd: i32, tls_ctx: i64, ctx: Context): i32 {
  let chk: i32 = ws_ctx_check(ctx);
  if (chk != 0) {
    return chk;
  }
  let tm: i32 = ws_timeout_ms_from_ctx(ctx);
  return ws_server_handshake(fd, tls_ctx, tm as u32);
}

/** Exported function `ws_encode_server_text_frame`.
 * Implements `ws_encode_server_text_frame`.
 * @param payload *u8
 * @param payload_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function ws_encode_server_text_frame(payload: *u8, payload_len: i32, out: *u8, out_cap: i32): i32 {
  return ws_codec.net_ws_encode_server_text_frame_c(payload, payload_len, out, out_cap);
}

/** Exported function `ws_encode_server_binary_frame`.
 * Implements `ws_encode_server_binary_frame`.
 * @param payload *u8
 * @param payload_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function ws_encode_server_binary_frame(payload: *u8, payload_len: i32, out: *u8, out_cap: i32): i32 {
  return ws_codec.net_ws_encode_server_binary_frame_c(payload, payload_len, out, out_cap);
}

/** Exported function `ws_server_write_text`.
 * Write path helper `ws_server_write_text`.
 * @param fd i32
 * @param tls_ctx i64
 * @param payload *u8
 * @param payload_len i32
 * @return i32
 */
export function ws_server_write_text(fd: i32, tls_ctx: i64, payload: *u8, payload_len: i32): i32 {
  if (fd < 0) { return ws_err_io(); }
  return ws_io.net_ws_write_server_text_c(fd, tls_ctx, payload, payload_len);
}

/** Exported function `ws_server_write_binary`.
 * Write path helper `ws_server_write_binary`.
 * @param fd i32
 * @param tls_ctx i64
 * @param payload *u8
 * @param payload_len i32
 * @return i32
 */
export function ws_server_write_binary(fd: i32, tls_ctx: i64, payload: *u8, payload_len: i32): i32 {
  if (fd < 0) { return ws_err_io(); }
  return ws_io.net_ws_write_server_binary_c(fd, tls_ctx, payload, payload_len);
}

/** Exported function `ws_client_handshake_smoke`.
 * Implements `ws_client_handshake_smoke`.
 * @return i32
 */
export function ws_client_handshake_smoke(): i32 {
  return ws_io.net_ws_client_handshake_smoke_c();
}

/** Exported function `ws_parse_url_smoke`.
 * Implements `ws_parse_url_smoke`.
 * @return i32
 */
export function ws_parse_url_smoke(): i32 {
  return ws_codec.net_ws_parse_url_smoke_c();
}

/** Exported function `ws_server_accept_smoke`.
 * Implements `ws_server_accept_smoke`.
 * @return i32
 */
export function ws_server_accept_smoke(): i32 {
  return ws_io.net_ws_server_accept_smoke_c();
}

/** Exported function `ws_is_implemented`.
 * Implements `ws_is_implemented`.
 * @return i32
 */
export function ws_is_implemented(): i32 { return 1; }
