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
// See implementation.
//
// See implementation.
// See implementation.

/* See implementation. */
let shu_tls_last_error: i32 = 0;

/* See implementation. */
let TLS_STUB_BACKEND_NAME: u8[5] = [115, 116, 117, 98, 0];

/**
 * See implementation.
 * See implementation.
 */
export function net_tls_is_available_c(): i32 {
  return 0;
}

/**
 * See implementation.
 */
export function net_tls_backend_name_c(): *u8 {
  return &TLS_STUB_BACKEND_NAME[0];
}

/**
 * See implementation.
 * See implementation.
 */
export function net_tls_connect_client_c(fd: i32, sni: *u8): i64 {
  let _ign_sni: *u8 = sni;
  shu_tls_last_error = 0;
  if (fd < 0) {
    shu_tls_last_error = -2;
    return 0 as i64;
  }
  shu_tls_last_error = -9;
  return 0 as i64;
}

/**
 * See implementation.
 */
export function net_tls_close_c(ctx_handle: i64): i32 {
  let _ign: i64 = ctx_handle;
  shu_tls_last_error = 0;
  return 0;
}

/**
 * See implementation.
 */
export function net_tls_read_c(ctx_handle: i64, buf: *u8, cap: i32): i32 {
  let _ign0: i64 = ctx_handle;
  let _ign1: *u8 = buf;
  let _ign2: i32 = cap;
  shu_tls_last_error = -9;
  return -9;
}

/**
 * See implementation.
 */
export function net_tls_write_c(ctx_handle: i64, buf: *u8, len: i32): i32 {
  let _ign0: i64 = ctx_handle;
  let _ign1: *u8 = buf;
  let _ign2: i32 = len;
  shu_tls_last_error = -9;
  return -9;
}

/**
 * See implementation.
 */
export function net_tls_openssl_smoke_c(): i32 {
  return -9;
}

/**
 * See implementation.
 */
export function net_tls_mbedtls_smoke_c(): i32 {
  return -9;
}

/**
 * See implementation.
 */
export function net_tls_connect_client_alpn_c(fd: i32, sni: *u8, alpn_wire: *u8, alpn_wire_len: i32): i64 {
  let _ign0: *u8 = alpn_wire;
  let _ign1: i32 = alpn_wire_len;
  return net_tls_connect_client_c(fd, sni);
}

/**
 * See implementation.
 */
export function net_tls_alpn_selected_c(ctx_handle: i64, out: *u8, out_cap: i32): i32 {
  let _ign0: i64 = ctx_handle;
  let _ign1: *u8 = out;
  let _ign2: i32 = out_cap;
  shu_tls_last_error = 0;
  return 0;
}

/**
 * See implementation.
 */
export function net_tls_alpn_is_h2_c(ctx_handle: i64): i32 {
  let _ign: i64 = ctx_handle;
  return 0;
}

/**
 * See implementation.
 */
export function net_tls_server_ctx_create_mem_c(cert_pem: *u8, cert_len: i32, key_pem: *u8, key_len: i32): i64 {
  let _ign0: *u8 = cert_pem;
  let _ign1: i32 = cert_len;
  let _ign2: *u8 = key_pem;
  let _ign3: i32 = key_len;
  shu_tls_last_error = -9;
  return 0 as i64;
}

/**
 * See implementation.
 */
export function net_tls_server_ctx_destroy_c(srv_ctx_h: i64): void {
  let _ign: i64 = srv_ctx_h;
}

/**
 * See implementation.
 */
export function net_tls_accept_server_c(srv_ctx_h: i64, fd: i32): i64 {
  let _ign0: i64 = srv_ctx_h;
  let _ign1: i32 = fd;
  shu_tls_last_error = -9;
  return 0 as i64;
}

/**
 * See implementation.
 */
export function net_tls_last_error_c(): i32 {
  return shu_tls_last_error;
}
