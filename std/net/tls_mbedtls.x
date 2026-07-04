// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// std.net.tls_mbedtls — F-04 v9：mbedTLS TLS 客户端/服务端（libmbedtls FFI）
//
// 【文件职责】
// 从 tls_mbedtls.inc.c 迁出的 STD-085 mbedTLS 实现：握手、读写、ALPN、烟测。
//
// 【依赖】
// - libmbedtls：-lmbedtls -lmbedx509 -lmbedcrypto（runtime_link_abi 见 shu_net_tls_mbedtls_marker）
// - tls_mbedtls_bio.c：shu_mbedtls_ssl_bind_fd_c（BIO fn ptr 胶层）
// - net.c：net_set_blocking_c、net_tcp_connect_blocking_c、net_close_socket_c
// - libc：calloc/free、getenv/atoi、strlen、memcpy

const mem = import("core.mem");

/** mbedTLS 结构体字节容量（Homebrew mbedtls 4.x + margin）。 */
const SZ_SSL_CTX: usize = 896;
const SZ_SSL_CONF: usize = 384;
const SZ_X509_CRT: usize = 1408;
const SZ_PK_CTX: usize = 640;

/** mbedTLS / PSA 常量。 */
const MBEDTLS_SSL_IS_CLIENT: i32 = 0;
const MBEDTLS_SSL_IS_SERVER: i32 = 1;
const MBEDTLS_SSL_TRANSPORT_STREAM: i32 = 0;
const MBEDTLS_SSL_PRESET_DEFAULT: i32 = 0;
const MBEDTLS_SSL_VERIFY_NONE: i32 = 0;
const MBEDTLS_ERR_SSL_WANT_READ: i32 = (0 - 26880);
const MBEDTLS_ERR_SSL_WANT_WRITE: i32 = (0 - 26752);
const PSA_SUCCESS: i32 = 0;
const PSA_ERROR_BAD_STATE: i32 = (0 - 137);

/** ALPN 指针列表（h2 + http/1.1 + NULL / h2 + NULL）。 */
allow(padding) struct AlpnPtr3 {
  p0: *u8;
  p1: *u8;
  p2: *u8;
}
allow(padding) struct AlpnPtr2 {
  p0: *u8;
  p1: *u8;
}

/** mbedTLS 会话：fd + ssl/conf 嵌入块。 */
allow(padding) struct TlsMbedtlsSess {
  fd: i32;
  has_conf: i32;
  ssl: u8[896];
  conf: u8[384];
}

/** mbedTLS 服务端共享上下文。 */
allow(padding) struct TlsMbedtlsServerCtx {
  conf: u8[384];
  cert: u8[1408];
  key: u8[640];
  ready: i32;
}

/** TLS 最后错误码（本模块路径）。 */
let shu_tls_last_error: i32 = 0;

/** 后端名 "mbedtls"（NUL 结尾）。 */
let TLS_BACKEND_NAME: u8[8] = [109, 101, 100, 116, 108, 115, 0, 0];

/** 链接 marker：runtime 按需 -lmbedtls*。 */
let shu_net_tls_mbedtls_marker: u8[8] = [109, 101, 100, 116, 108, 115, 0, 0];

/** ALPN 协议名（NUL 结尾）。 */
let ALPN_H2: u8[3] = [104, 50, 0];
let ALPN_HTTP11: u8[9] = [104, 116, 116, 112, 47, 49, 46, 49, 0];

extern function calloc(nmemb: usize, size: usize): *u8;
extern function free(ptr: *u8): void;
extern function getenv(name: *u8): *u8;
extern function atoi(s: *u8): i32;
extern function strlen(s: *u8): usize;

extern function net_set_blocking_c(fd: i32, blocking: i32): i32;
extern function net_tcp_connect_blocking_c(addr_u32: u32, port_u32: u32, timeout_ms: u32): i32;
extern function net_close_socket_c(fd: i32): i32;

extern function shu_mbedtls_ssl_bind_fd_c(ssl: *u8, fd_ptr: *i32): void;

extern function psa_crypto_init(): i32;
extern function mbedtls_ssl_config_init(conf: *u8): void;
extern function mbedtls_ssl_config_defaults(conf: *u8, endpoint: i32, transport: i32, preset: i32): i32;
extern function mbedtls_ssl_config_free(conf: *u8): void;
extern function mbedtls_ssl_conf_authmode(conf: *u8, mode: i32): void;
extern function mbedtls_ssl_conf_alpn_protocols(conf: *u8, protos: * *u8): i32;
extern function mbedtls_ssl_init(ssl: *u8): void;
extern function mbedtls_ssl_setup(ssl: *u8, conf: *u8): i32;
extern function mbedtls_ssl_set_hostname(ssl: *u8, name: *u8): i32;
extern function mbedtls_ssl_handshake(ssl: *u8): i32;
extern function mbedtls_ssl_get_alpn_protocol(ssl: *u8): *u8;
extern function mbedtls_ssl_close_notify(ssl: *u8): i32;
extern function mbedtls_ssl_free(ssl: *u8): void;
extern function mbedtls_ssl_read(ssl: *u8, buf: *u8, len: usize): i32;
extern function mbedtls_ssl_write(ssl: *u8, buf: *u8, len: usize): i32;
extern function mbedtls_x509_crt_init(crt: *u8): void;
extern function mbedtls_x509_crt_parse(crt: *u8, buf: *u8, buflen: usize): i32;
extern function mbedtls_x509_crt_free(crt: *u8): void;
extern function mbedtls_pk_init(pk: *u8): void;
extern function mbedtls_pk_parse_key(pk: *u8, key: *u8, keylen: usize, pwd: *u8, pwdlen: usize, f_rng: *u8, p_rng: *u8): i32;
extern function mbedtls_pk_free(pk: *u8): void;
extern function mbedtls_ssl_conf_own_cert(conf: *u8, cert: *u8, pk: *u8): i32;

/**
 * handle 转 TlsMbedtlsSess*；0 返回 0。
 */
function tls_mbedtls_sess_ptr(handle: i64): *TlsMbedtlsSess {
  if (handle == 0) {
    return 0;
  }
  return handle as usize as *TlsMbedtlsSess;
}

/**
 * PSA 初始化；BAD_STATE 视为已初始化。
 */
function tls_mbedtls_psa_init(): i32 {
  let st: i32 = 0;
  unsafe { st = psa_crypto_init(); }
  if (st == PSA_SUCCESS || st == PSA_ERROR_BAD_STATE) {
    return 0;
  }
  return -1;
}

/**
 * TLS 后端是否可用；mbedTLS 恒 1。
 */
function net_tls_is_available_c(): i32 {
  return 1;
}

/**
 * TLS 后端名称（NUL 结尾）。
 */
function net_tls_backend_name_c(): *u8 {
  return &TLS_BACKEND_NAME[0];
}

/**
 * 读取 TLS 最后一次错误码。
 */
function net_tls_last_error_c(): i32 {
  return shu_tls_last_error;
}

/**
 * 释放会话 ssl/conf 并 free 结构体。
 */
function tls_mbedtls_free_sess(sess: *TlsMbedtlsSess): void {
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
 * 阻塞直至 handshake 完成或失败。
 */
function tls_mbedtls_handshake_loop(ssl: *u8): i32 {
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
 * TLS 客户端握手（SNI）；失败返回 0。
 */
function net_tls_connect_client_c(fd: i32, sni: *u8): i64 {
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
  if (unsafe { mbedtls_ssl_set_hostname(&sess.ssl[0], sni) } != 0) {
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
 * 带 ALPN（h2 + http/1.1）的 TLS 客户端握手。
 */
function net_tls_connect_client_alpn_c(fd: i32, sni: *u8, alpn_wire: *u8, alpn_wire_len: i32): i64 {
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
  if (unsafe { mbedtls_ssl_conf_alpn_protocols(&sess.conf[0], &alpn_list.p0) } != 0) {
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
  if (unsafe { mbedtls_ssl_set_hostname(&sess.ssl[0], sni) } != 0) {
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
 * 读取协商 ALPN 协议名；返回长度，写入 out（可 NULL）。
 */
function net_tls_alpn_selected_c(ctx_handle: i64, out: *u8, out_cap: i32): i32 {
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
 * 协商协议是否为 h2。
 */
function net_tls_alpn_is_h2_c(ctx_handle: i64): i32 {
  let buf: u8[4] = [0, 0, 0, 0];
  let n: i32 = net_tls_alpn_selected_c(ctx_handle, &buf[0], 4);
  if (n == 2 && buf[0] == 104 && buf[1] == 50) {
    return 1;
  }
  return 0;
}

/**
 * 关闭 TLS 会话。
 */
function net_tls_close_c(ctx_handle: i64): i32 {
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
 * TLS 读；失败 -1/-2。
 */
function net_tls_read_c(ctx_handle: i64, buf: *u8, cap: i32): i32 {
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
 * TLS 写；失败 -1/-2。
 */
function net_tls_write_c(ctx_handle: i64, buf: *u8, len: i32): i32 {
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

/** 127.0.0.1 主机序。 */
const ADDR_LOOPBACK: u32 = 0x7f000001;

/** 烟测字面量。 */
let LOCALHOST: u8[10] = [108, 111, 99, 97, 108, 104, 111, 115, 116, 0];
let ENV_SHUX_TLS_PORT: u8[20] = [83, 72, 85, 88, 95, 84, 76, 83, 95, 83, 77, 79, 75, 69, 95, 80, 79, 82, 84, 0];

/**
 * mbedTLS 烟测：连接 SHUX_TLS_SMOKE_PORT 上 s_server 并完成握手。
 */
function net_tls_mbedtls_smoke_c(): i32 {
  let port_env: *u8 = 0 as *u8;
  let port: i32 = 0;
  let fd: i32 = 0;
  let ctx: i64 = 0;
  let name: *u8 = net_tls_backend_name_c();
  if (name == 0 || name[0] != 109) {
    return 1;
  }
  unsafe { port_env = getenv(&ENV_SHUX_TLS_PORT[0]); }
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
 * OpenSSL 烟测：mbedTLS 构建下不可用。
 */
function net_tls_openssl_smoke_c(): i32 {
  return -9;
}

/**
 * 释放服务端上下文内部 mbedTLS 对象。
 */
function tls_mbedtls_server_free(srv: *TlsMbedtlsServerCtx): void {
  if (srv == 0) {
    return;
  }
  unsafe { mbedtls_pk_free(&srv.key[0]); }
  unsafe { mbedtls_x509_crt_free(&srv.cert[0]); }
  unsafe { mbedtls_ssl_config_free(&srv.conf[0]); }
}

/**
 * 从内存 PEM 创建 TLS 服务端上下文（ALPN h2）；失败返回 0。
 */
function net_tls_server_ctx_create_mem_c(cert_pem: *u8, cert_len: i32, key_pem: *u8, key_len: i32): i64 {
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
  if (unsafe { mbedtls_ssl_conf_alpn_protocols(&srv.conf[0], &alpn_list.p0) } != 0) {
    tls_mbedtls_server_free(srv);
    unsafe { free(srv as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  if (unsafe { mbedtls_x509_crt_parse(&srv.cert[0], cert_pem, cert_len) } != 0) {
    tls_mbedtls_server_free(srv);
    unsafe { free(srv as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  if (unsafe { mbedtls_pk_parse_key(&srv.key[0], key_pem, key_len, 0 as *u8, 0, 0 as *u8, 0 as *u8) } != 0) {
    tls_mbedtls_server_free(srv);
    unsafe { free(srv as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  if (unsafe { mbedtls_ssl_conf_own_cert(&srv.conf[0], &srv.cert[0], &srv.key[0]) != 0) {
    tls_mbedtls_server_free(srv);
    unsafe { free(srv as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  srv.ready = 1;
  return srv as usize as i64;
}

/**
 * 释放 TLS 服务端上下文。
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
 * 在已 accept 的 TCP fd 上完成 TLS 服务端握手；失败返回 0。
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
