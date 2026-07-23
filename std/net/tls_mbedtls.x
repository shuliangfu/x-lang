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
//
// See implementation.
// See implementation.
// See implementation.
// - net.c：net_set_blocking_c、net_tcp_connect_blocking_c、net_close_socket_c
// - libc：calloc/free、getenv/atoi、strlen、memcpy

const mem = import("core.mem");

/* See implementation. */
export const SZ_SSL_CTX: usize = 896;
export const SZ_SSL_CONF: usize = 384;
export const SZ_X509_CRT: usize = 1408;
export const SZ_PK_CTX: usize = 640;

/* See implementation. */
export const MBEDTLS_SSL_IS_CLIENT: i32 = 0;
export const MBEDTLS_SSL_IS_SERVER: i32 = 1;
export const MBEDTLS_SSL_TRANSPORT_STREAM: i32 = 0;
export const MBEDTLS_SSL_PRESET_DEFAULT: i32 = 0;
export const MBEDTLS_SSL_VERIFY_NONE: i32 = 0;
export const MBEDTLS_ERR_SSL_WANT_READ: i32 = (0 - 26880);
export const MBEDTLS_ERR_SSL_WANT_WRITE: i32 = (0 - 26752);
export const PSA_SUCCESS: i32 = 0;
export const PSA_ERROR_BAD_STATE: i32 = (0 - 137);

/* See implementation. */
allow(padding) struct AlpnPtr3 {
  p0: *u8;
  p1: *u8;
  p2: *u8;
}
allow(padding) struct AlpnPtr2 {
  p0: *u8;
  p1: *u8;
}

/* See implementation. */
allow(padding) struct TlsMbedtlsSess {
  fd: i32;
  has_conf: i32;
  ssl: u8[896];
  conf: u8[384];
}

/* See implementation. */
allow(padding) struct TlsMbedtlsServerCtx {
  conf: u8[384];
  cert: u8[1408];
  key: u8[640];
  ready: i32;
}

/* See implementation. */
let shu_tls_last_error: i32 = 0;

/* See implementation. */
let TLS_BACKEND_NAME: u8[8] = [109, 101, 100, 116, 108, 115, 0, 0];

/* See implementation. */
let shu_net_tls_mbedtls_marker: u8[8] = [109, 101, 100, 116, 108, 115, 0, 0];

/* See implementation. */
let ALPN_H2: u8[3] = [104, 50, 0];
let ALPN_HTTP11: u8[9] = [104, 116, 116, 112, 47, 49, 46, 49, 0];

extern "C" function calloc(nmemb: usize, size: usize): *u8;
extern "C" function free(ptr: *u8): void;
extern "C" function getenv(name: *u8): *u8;
extern "C" function atoi(s: *u8): i32;
extern "C" function strlen(s: *u8): usize;

extern function net_set_blocking_c(fd: i32, blocking: i32): i32;
extern function net_tcp_connect_blocking_c(addr_u32: u32, port_u32: u32, timeout_ms: u32): i32;
extern function net_close_socket_c(fd: i32): i32;

extern function shu_mbedtls_ssl_bind_fd_c(ssl: *u8, fd_ptr: *i32): void;

extern "C" function psa_crypto_init(): i32;
extern "C" function mbedtls_ssl_config_init(conf: *u8): void;
extern "C" function mbedtls_ssl_config_defaults(conf: *u8, endpoint: i32, transport: i32, preset: i32): i32;
extern "C" function mbedtls_ssl_config_free(conf: *u8): void;
extern "C" function mbedtls_ssl_conf_authmode(conf: *u8, mode: i32): void;
extern "C" function mbedtls_ssl_conf_alpn_protocols(conf: *u8, protos: * *u8): i32;
extern "C" function mbedtls_ssl_init(ssl: *u8): void;
extern "C" function mbedtls_ssl_setup(ssl: *u8, conf: *u8): i32;
extern "C" function mbedtls_ssl_set_hostname(ssl: *u8, name: *u8): i32;
extern "C" function mbedtls_ssl_handshake(ssl: *u8): i32;
extern "C" function mbedtls_ssl_get_alpn_protocol(ssl: *u8): *u8;
extern "C" function mbedtls_ssl_close_notify(ssl: *u8): i32;
extern "C" function mbedtls_ssl_free(ssl: *u8): void;
extern "C" function mbedtls_ssl_read(ssl: *u8, buf: *u8, len: usize): i32;
extern "C" function mbedtls_ssl_write(ssl: *u8, buf: *u8, len: usize): i32;
extern "C" function mbedtls_x509_crt_init(crt: *u8): void;
extern "C" function mbedtls_x509_crt_parse(crt: *u8, buf: *u8, buflen: usize): i32;
extern "C" function mbedtls_x509_crt_free(crt: *u8): void;
extern "C" function mbedtls_pk_init(pk: *u8): void;
extern "C" function mbedtls_pk_parse_key(pk: *u8, key: *u8, keylen: usize, pwd: *u8, pwdlen: usize, f_rng: *u8, p_rng: *u8): i32;
extern "C" function mbedtls_pk_free(pk: *u8): void;
extern "C" function mbedtls_ssl_conf_own_cert(conf: *u8, cert: *u8, pk: *u8): i32;

/**
 * See implementation.
 */
export function tls_mbedtls_sess_ptr(handle: i64): *TlsMbedtlsSess {
  if (handle == 0) {
    return 0 as *TlsMbedtlsSess;
  }
  return handle as usize as *TlsMbedtlsSess;
}

/**
 * See implementation.
 */
export function tls_mbedtls_psa_init(): i32 {
  let st: i32 = 0;
  unsafe { st = psa_crypto_init(); }
  if (st == PSA_SUCCESS || st == PSA_ERROR_BAD_STATE) {
    return 0;
  }
  return -1;
}

/**
 * See implementation.
 */
export function net_tls_is_available_c(): i32 {
  return 1;
}

/**
 * See implementation.
 */
export function net_tls_backend_name_c(): *u8 {
  return &TLS_BACKEND_NAME[0];
}

/**
 * See implementation.
 */
export function net_tls_last_error_c(): i32 {
  return shu_tls_last_error;
}

/**
 * See implementation.
 */
export function tls_mbedtls_free_sess(sess: *TlsMbedtlsSess): void {
  if (sess == 0) {
    return;
  }
  unsafe { mbedtls_ssl_free(&sess.ssl[0]); }
  if (sess.has_conf != 0) {
    unsafe { mbedtls_ssl_config_free(&sess.conf[0]); }
  }
  unsafe { free(sess as *u8); }
}

/**
 * See implementation.
 */
export function tls_mbedtls_handshake_loop(ssl: *u8): i32 {
  let ret: i32 = 0;
  loop {
    unsafe { ret = mbedtls_ssl_handshake(ssl); }
    if (ret == 0) {
      return 0;
    }
    if (ret != MBEDTLS_ERR_SSL_WANT_READ && ret != MBEDTLS_ERR_SSL_WANT_WRITE) {
      return ret;
    }
  }
}

/**
 * See implementation.
 */
export function net_tls_connect_client_c(fd: i32, sni: *u8): i64 {
  let sess: *TlsMbedtlsSess = 0 as *TlsMbedtlsSess;
  let ret: i32 = 0;
  shu_tls_last_error = 0;
  if (fd < 0) {
    shu_tls_last_error = -2;
    return 0 as i64;
  }
  if (sni == 0 || sni[0] == 0) {
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  if (tls_mbedtls_psa_init() != 0) {
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { sess = calloc(1, 1296) as *TlsMbedtlsSess; }
  if (sess == 0) {
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  sess.fd = fd;
  sess.has_conf = 1;
  unsafe { mbedtls_ssl_config_init(&sess.conf[0]); }
  unsafe { ret = mbedtls_ssl_config_defaults(&sess.conf[0], MBEDTLS_SSL_IS_CLIENT,
      MBEDTLS_SSL_TRANSPORT_STREAM, MBEDTLS_SSL_PRESET_DEFAULT);
  }
  if (ret != 0) {
    tls_mbedtls_free_sess(sess);
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { mbedtls_ssl_conf_authmode(&sess.conf[0], MBEDTLS_SSL_VERIFY_NONE); }
  unsafe { mbedtls_ssl_init(&sess.ssl[0]); }
  unsafe { ret = mbedtls_ssl_setup(&sess.ssl[0], &sess.conf[0]); }
  if (ret != 0) {
    tls_mbedtls_free_sess(sess);
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  let _u_rc_0: i32 = 0;
  unsafe { _u_rc_0 = mbedtls_ssl_set_hostname(&sess.ssl[0], sni); }
  if (_u_rc_0 != 0) {
    tls_mbedtls_free_sess(sess);
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { shu_mbedtls_ssl_bind_fd_c(&sess.ssl[0], &sess.fd); }
  unsafe { net_set_blocking_c(fd, 1); }
  if (tls_mbedtls_handshake_loop(&sess.ssl[0]) != 0) {
    tls_mbedtls_free_sess(sess);
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  shu_tls_last_error = 0;
  return sess as usize as i64;
}

/**
 * See implementation.
 */
export function net_tls_connect_client_alpn_c(fd: i32, sni: *u8, alpn_wire: *u8, alpn_wire_len: i32): i64 {
  let sess: *TlsMbedtlsSess = 0 as *TlsMbedtlsSess;
  let ret: i32 = 0;
  shu_tls_last_error = 0;
  if (fd < 0) {
    shu_tls_last_error = -2;
    return 0 as i64;
  }
  if (sni == 0 || sni[0] == 0) {
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  if (tls_mbedtls_psa_init() != 0) {
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { sess = calloc(1, 1296) as *TlsMbedtlsSess; }
  if (sess == 0) {
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  sess.fd = fd;
  sess.has_conf = 1;
  unsafe { mbedtls_ssl_config_init(&sess.conf[0]); }
  unsafe { ret = mbedtls_ssl_config_defaults(&sess.conf[0], MBEDTLS_SSL_IS_CLIENT,
      MBEDTLS_SSL_TRANSPORT_STREAM, MBEDTLS_SSL_PRESET_DEFAULT);
  }
  if (ret != 0) {
    tls_mbedtls_free_sess(sess);
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { mbedtls_ssl_conf_authmode(&sess.conf[0], MBEDTLS_SSL_VERIFY_NONE); }
  let alpn_list: AlpnPtr3 = AlpnPtr3 { p0: &ALPN_H2[0]; p1: &ALPN_HTTP11[0]; p2: 0 as *u8; };
  let _u_rc_1: i32 = 0;
  unsafe { _u_rc_1 = mbedtls_ssl_conf_alpn_protocols(&sess.conf[0], &alpn_list.p0); }
  if (_u_rc_1 != 0) {
    tls_mbedtls_free_sess(sess);
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { mbedtls_ssl_init(&sess.ssl[0]); }
  unsafe { ret = mbedtls_ssl_setup(&sess.ssl[0], &sess.conf[0]); }
  if (ret != 0) {
    tls_mbedtls_free_sess(sess);
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  let _u_rc_2: i32 = 0;
  unsafe { _u_rc_2 = mbedtls_ssl_set_hostname(&sess.ssl[0], sni); }
  if (_u_rc_2 != 0) {
    tls_mbedtls_free_sess(sess);
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { shu_mbedtls_ssl_bind_fd_c(&sess.ssl[0], &sess.fd); }
  unsafe { net_set_blocking_c(fd, 1); }
  if (tls_mbedtls_handshake_loop(&sess.ssl[0]) != 0) {
    tls_mbedtls_free_sess(sess);
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  shu_tls_last_error = 0;
  return sess as usize as i64;
}

/**
 * See implementation.
 */
export function net_tls_alpn_selected_c(ctx_handle: i64, out: *u8, out_cap: i32): i32 {
  let sess: *TlsMbedtlsSess = tls_mbedtls_sess_ptr(ctx_handle);
  let sel: *u8 = 0 as *u8;
  let len: i32 = 0;
  let n: i32 = 0;
  if (sess == 0) {
    shu_tls_last_error = -2;
    return -1;
  }
  unsafe { sel = mbedtls_ssl_get_alpn_protocol(&sess.ssl[0]); }
  if (sel == 0 || sel[0] == 0) {
    return 0;
  }
  unsafe { len = strlen(sel) as i32; }
  if (out != 0 && out_cap > 0) {
    n = len;
    if (n > out_cap) {
      n = out_cap;
    }
    mem.mem_copy(out, sel, n);
  }
  return len;
}

/**
 * See implementation.
 */
export function net_tls_alpn_is_h2_c(ctx_handle: i64): i32 {
  let buf: u8[4] = [0, 0, 0, 0];
  let n: i32 = net_tls_alpn_selected_c(ctx_handle, &buf[0], 4);
  if (n == 2 && buf[0] == 104 && buf[1] == 50) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 */
export function net_tls_close_c(ctx_handle: i64): i32 {
  let sess: *TlsMbedtlsSess = tls_mbedtls_sess_ptr(ctx_handle);
  if (sess == 0) {
    return 0;
  }
  unsafe { mbedtls_ssl_close_notify(&sess.ssl[0]); }
  tls_mbedtls_free_sess(sess);
  shu_tls_last_error = 0;
  return 0;
}

/**
 * See implementation.
 */
export function net_tls_read_c(ctx_handle: i64, buf: *u8, cap: i32): i32 {
  let sess: *TlsMbedtlsSess = tls_mbedtls_sess_ptr(ctx_handle);
  let n: i32 = 0;
  if (sess == 0) {
    shu_tls_last_error = -2;
    return -2;
  }
  if (buf == 0 || cap <= 0) {
    shu_tls_last_error = -2;
    return -2;
  }
  loop {
    unsafe { n = mbedtls_ssl_read(&sess.ssl[0], buf, cap); }
    if (n != MBEDTLS_ERR_SSL_WANT_READ && n != MBEDTLS_ERR_SSL_WANT_WRITE) {
      break;
    }
  }
  if (n <= 0) {
    shu_tls_last_error = -1;
    return -1;
  }
  shu_tls_last_error = 0;
  return n;
}

/**
 * See implementation.
 */
export function net_tls_write_c(ctx_handle: i64, buf: *u8, len: i32): i32 {
  let sess: *TlsMbedtlsSess = tls_mbedtls_sess_ptr(ctx_handle);
  let n: i32 = 0;
  if (sess == 0) {
    shu_tls_last_error = -2;
    return -2;
  }
  if (buf == 0 || len <= 0) {
    shu_tls_last_error = -2;
    return -2;
  }
  loop {
    unsafe { n = mbedtls_ssl_write(&sess.ssl[0], buf, len); }
    if (n != MBEDTLS_ERR_SSL_WANT_READ && n != MBEDTLS_ERR_SSL_WANT_WRITE) {
      break;
    }
  }
  if (n <= 0) {
    shu_tls_last_error = -1;
    return -1;
  }
  shu_tls_last_error = 0;
  return n;
}

/* See implementation. */
export const ADDR_LOOPBACK: u32 = 0x7f000001;

/* See implementation. */
let LOCALHOST: u8[10] = [108, 111, 99, 97, 108, 104, 111, 115, 116, 0];
let ENV_XLANG_TLS_PORT: u8[20] = [83, 72, 85, 88, 95, 84, 76, 83, 95, 83, 77, 79, 75, 69, 95, 80, 79, 82, 84, 0];

/**
 * See implementation.
 */
export function net_tls_mbedtls_smoke_c(): i32 {
  let port_env: *u8 = 0 as *u8;
  let port: i32 = 0;
  let fd: i32 = 0;
  let ctx: i64 = 0;
  let name: *u8 = net_tls_backend_name_c();
  if (name == 0 || name[0] != 109) {
    return 1;
  }
  unsafe { port_env = getenv(&ENV_XLANG_TLS_PORT[0]); }
  if (port_env != 0) {
    unsafe { port = atoi(port_env); }
  }
  if (port <= 0 || port > 65535) {
    return 2;
  }
  unsafe { fd = net_tcp_connect_blocking_c(ADDR_LOOPBACK, port as u32, 5000); }
  if (fd < 0) {
    return 3;
  }
  ctx = net_tls_connect_client_c(fd, &LOCALHOST[0]);
  if (ctx == 0) {
    unsafe { net_close_socket_c(fd); }
    return 4;
  }
  if (net_tls_close_c(ctx) != 0) {
    unsafe { net_close_socket_c(fd); }
    return 5;
  }
  unsafe { net_close_socket_c(fd); }
  return 0;
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
export function tls_mbedtls_server_free(srv: *TlsMbedtlsServerCtx): void {
  if (srv == 0) {
    return;
  }
  unsafe { mbedtls_pk_free(&srv.key[0]); }
  unsafe { mbedtls_x509_crt_free(&srv.cert[0]); }
  unsafe { mbedtls_ssl_config_free(&srv.conf[0]); }
}

/**
 * See implementation.
 */
export function net_tls_server_ctx_create_mem_c(cert_pem: *u8, cert_len: i32, key_pem: *u8, key_len: i32): i64 {
  let srv: *TlsMbedtlsServerCtx = 0 as *TlsMbedtlsServerCtx;
  let ret: i32 = 0;
  shu_tls_last_error = 0;
  if (cert_pem == 0 || cert_len <= 0 || key_pem == 0 || key_len <= 0) {
    shu_tls_last_error = -2;
    return 0 as i64;
  }
  if (tls_mbedtls_psa_init() != 0) {
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { srv = calloc(1, 2448) as *TlsMbedtlsServerCtx; }
  if (srv == 0) {
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { mbedtls_ssl_config_init(&srv.conf[0]); }
  unsafe { mbedtls_x509_crt_init(&srv.cert[0]); }
  unsafe { mbedtls_pk_init(&srv.key[0]); }
  unsafe { ret = mbedtls_ssl_config_defaults(&srv.conf[0], MBEDTLS_SSL_IS_SERVER,
      MBEDTLS_SSL_TRANSPORT_STREAM, MBEDTLS_SSL_PRESET_DEFAULT);
  }
  if (ret != 0) {
    tls_mbedtls_server_free(srv);
    unsafe { free(srv as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { mbedtls_ssl_conf_authmode(&srv.conf[0], MBEDTLS_SSL_VERIFY_NONE); }
  let alpn_list: AlpnPtr2 = AlpnPtr2 { p0: &ALPN_H2[0]; p1: 0 as *u8; };
  let _u_rc_3: i32 = 0;
  unsafe { _u_rc_3 = mbedtls_ssl_conf_alpn_protocols(&srv.conf[0], &alpn_list.p0); }
  if (_u_rc_3 != 0) {
    tls_mbedtls_server_free(srv);
    unsafe { free(srv as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  let _u_rc_4: i32 = 0;
  unsafe { _u_rc_4 = mbedtls_x509_crt_parse(&srv.cert[0], cert_pem, cert_len); }
  if (_u_rc_4 != 0) {
    tls_mbedtls_server_free(srv);
    unsafe { free(srv as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  let _u_rc_5: i32 = 0;
  unsafe { _u_rc_5 = mbedtls_pk_parse_key(&srv.key[0], key_pem, key_len, 0 as *u8, 0, 0 as *u8, 0 as *u8); }
  if (_u_rc_5 != 0) {
    tls_mbedtls_server_free(srv);
    unsafe { free(srv as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  let own_rc: i32 = 0;
  unsafe { own_rc = mbedtls_ssl_conf_own_cert(&srv.conf[0], &srv.cert[0], &srv.key[0]); }
  if (own_rc != 0) {
    tls_mbedtls_server_free(srv);
    unsafe { free(srv as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  srv.ready = 1;
  return srv as usize as i64;
}

/**
 * See implementation.
 */
function net_tls_server_ctx_destroy_c(srv_ctx_h: i64): void {
  let srv: *TlsMbedtlsServerCtx = srv_ctx_h as usize as *TlsMbedtlsServerCtx;
  if (srv == 0) {
    return;
  }
  tls_mbedtls_server_free(srv);
  unsafe { free(srv as *u8); }
}

/**
 * See implementation.
 */
function net_tls_accept_server_c(srv_ctx_h: i64, fd: i32): i64 {
  let srv: *TlsMbedtlsServerCtx = srv_ctx_h as usize as *TlsMbedtlsServerCtx;
  let sess: *TlsMbedtlsSess = 0 as *TlsMbedtlsSess;
  let ret: i32 = 0;
  shu_tls_last_error = 0;
  if (srv == 0 || srv.ready == 0 || fd < 0) {
    shu_tls_last_error = -2;
    return 0 as i64;
  }
  unsafe { sess = calloc(1, 1296) as *TlsMbedtlsSess; }
  if (sess == 0) {
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  sess.fd = fd;
  sess.has_conf = 0;
  unsafe { mbedtls_ssl_init(&sess.ssl[0]); }
  unsafe { ret = mbedtls_ssl_setup(&sess.ssl[0], &srv.conf[0]); }
  if (ret != 0) {
    unsafe { mbedtls_ssl_free(&sess.ssl[0]); }
    unsafe { free(sess as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { shu_mbedtls_ssl_bind_fd_c(&sess.ssl[0], &sess.fd); }
  unsafe { net_set_blocking_c(fd, 1); }
  if (tls_mbedtls_handshake_loop(&sess.ssl[0]) != 0) {
    unsafe { mbedtls_ssl_free(&sess.ssl[0]); }
    unsafe { free(sess as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  return sess as usize as i64;
}
