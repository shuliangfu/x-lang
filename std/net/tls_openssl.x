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

// std.net.tls_openssl — F-04 v8：OpenSSL TLS 客户端/服务端（libssl FFI）
//
// 【文件职责】
// 从 tls_openssl.inc.c 迁出的 STD-030/083 OpenSSL 实现：握手、读写、ALPN、烟测。
//
// 【依赖】
// - libssl/libcrypto：-lssl -lcrypto（runtime_link_abi 见 shu_net_tls_openssl_marker）
// - net.c：net_set_blocking_c、net_tcp_connect_blocking_c、net_close_socket_c
// - libc：calloc/free、getenv/atoi、strlen

const mem = import("core.mem");

/** OpenSSL 初始化标志。 */
const OPENSSL_INIT_LOAD_SSL_STRINGS: u64 = 0x00000001;
const OPENSSL_INIT_LOAD_CRYPTO_STRINGS: u64 = 0x00000002;
const SSL_VERIFY_NONE: i32 = 0;
const SSL_TLSEXT_ERR_OK: i32 = 0;

/** TLS 最后错误码（本模块路径）。 */
let shu_tls_last_error: i32 = 0;

/** 后端名 "openssl"（NUL 结尾）。 */
let TLS_BACKEND_NAME: u8[8] = [111, 112, 101, 110, 115, 115, 108, 0];

/** 链接 marker：runtime 按需 -lssl -lcrypto。 */
let shu_net_tls_openssl_marker: u8[8] = [111, 112, 101, 110, 115, 115, 108, 0];

/** OpenSSL 会话：fd + SSL* + SSL_CTX*。 */
allow(padding) struct TlsOpensslSess {
  fd: i32;
  ssl: *u8;
  ctx: *u8;
}

/** OpenSSL 服务端共享 SSL_CTX。 */
allow(padding) struct TlsOpensslServerCtx {
  ctx: *u8;
}

extern "C" function calloc(nmemb: usize, size: usize): *u8;
extern "C" function free(ptr: *u8): void;
extern "C" function getenv(name: *u8): *u8;
extern "C" function atoi(s: *u8): i32;
extern "C" function strlen(s: *u8): usize;
extern "C" function strstr(haystack: *u8, needle: *u8): *u8;

extern function net_set_blocking_c(fd: i32, blocking: i32): i32;
extern function net_tcp_connect_blocking_c(addr_u32: u32, port_u32: u32, timeout_ms: u32): i32;
extern function net_close_socket_c(fd: i32): i32;

extern "C" function OPENSSL_init_ssl(opts: u64, settings: *u8): i32;
extern "C" function TLS_client_method(): *u8;
extern "C" function TLS_server_method(): *u8;
extern "C" function SSL_CTX_new(method: *u8): *u8;
extern "C" function SSL_CTX_free(ctx: *u8): void;
extern "C" function SSL_CTX_set_verify(ctx: *u8, mode: i32, cb: *u8): void;
extern "C" function SSL_CTX_set_alpn_protos(ctx: *u8, protos: *u8, protos_len: u32): i32;
extern "C" function SSL_new(ctx: *u8): *u8;
extern "C" function SSL_free(ssl: *u8): void;
extern "C" function SSL_set_fd(ssl: *u8, fd: i32): i32;
extern "C" function SSL_set_tlsext_host_name(ssl: *u8, name: *u8): i32;
extern "C" function SSL_connect(ssl: *u8): i32;
extern "C" function SSL_accept(ssl: *u8): i32;
extern "C" function SSL_shutdown(ssl: *u8): i32;
extern "C" function SSL_read(ssl: *u8, buf: *u8, cap: i32): i32;
extern "C" function SSL_write(ssl: *u8, buf: *u8, len: i32): i32;
extern "C" function SSL_get0_alpn_selected(ssl: *u8, out: * *u8, out_len: *u32): void;
extern "C" function BIO_new_mem_buf(buf: *u8, len: i32): *u8;
extern "C" function BIO_free(bio: *u8): void;
extern "C" function PEM_read_bio_X509(bio: *u8, x: * *u8, cb: *u8, u: *u8): *u8;
extern "C" function PEM_read_bio_PrivateKey(bio: *u8, x: * *u8, cb: *u8, u: *u8): *u8;
extern "C" function X509_free(x: *u8): void;
extern "C" function EVP_PKEY_free(k: *u8): void;
extern "C" function SSL_CTX_use_certificate(ctx: *u8, cert: *u8): i32;
extern "C" function SSL_CTX_use_PrivateKey(ctx: *u8, key: *u8): i32;

/**
 * handle 转 TlsOpensslSess*；0 返回 0。
 */
function tls_openssl_sess_ptr(handle: i64): *TlsOpensslSess {
  if (handle == 0) {
    return 0;
  }
  return handle as usize as *TlsOpensslSess;
}

/**
 * TLS 后端是否可用；OpenSSL 恒 1。
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
 * 从内存 PEM 创建 TLS 服务端上下文（v8：无 ALPN select 回调）。
 */
function net_tls_server_ctx_create_mem_c(cert_pem: *u8, cert_len: i32, key_pem: *u8, key_len: i32): i64 {
  let srv: *TlsOpensslServerCtx = 0 as *TlsOpensslServerCtx;
  let cert_bio: *u8 = 0 as *u8;
  let key_bio: *u8 = 0 as *u8;
  let cert: *u8 = 0 as *u8;
  let pkey: *u8 = 0 as *u8;
  shu_tls_last_error = 0;
  if (cert_pem == 0 || cert_len <= 0 || key_pem == 0 || key_len <= 0) {
    shu_tls_last_error = -2;
    return 0 as i64;
  }
  if (unsafe { OPENSSL_init_ssl(OPENSSL_INIT_LOAD_SSL_STRINGS | OPENSSL_INIT_LOAD_CRYPTO_STRINGS,
      0 as *u8) } == 0) {
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { srv = calloc(1, 8) as *TlsOpensslServerCtx; }
  if (srv == 0) {
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { srv.ctx = SSL_CTX_new(TLS_server_method()); }
  if (srv.ctx == 0) {
    unsafe { free(srv as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { SSL_CTX_set_verify(srv.ctx, SSL_VERIFY_NONE, 0 as *u8); }
  unsafe { cert_bio = BIO_new_mem_buf(cert_pem, cert_len); }
  unsafe { key_bio = BIO_new_mem_buf(key_pem, key_len); }
  if (cert_bio == 0 || key_bio == 0) {
    if (cert_bio != 0) { unsafe { BIO_free(cert_bio); } }
    if (key_bio != 0) { unsafe { BIO_free(key_bio); } }
    unsafe { SSL_CTX_free(srv.ctx); }
    unsafe { free(srv as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { cert = PEM_read_bio_X509(cert_bio, 0 as * *u8, 0 as *u8, 0 as *u8); }
  unsafe { pkey = PEM_read_bio_PrivateKey(key_bio, 0 as * *u8, 0 as *u8, 0 as *u8); }
  unsafe { BIO_free(cert_bio); }
  unsafe { BIO_free(key_bio); }
  if (cert == 0 || pkey == 0 ||
      unsafe { SSL_CTX_use_certificate(srv.ctx, cert) } != 1 ||
      unsafe { SSL_CTX_use_PrivateKey(srv.ctx, pkey) } != 1) {
    if (cert != 0) { unsafe { X509_free(cert); } }
    if (pkey != 0) { unsafe { EVP_PKEY_free(pkey); } }
    unsafe { SSL_CTX_free(srv.ctx); }
    unsafe { free(srv as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { X509_free(cert); }
  unsafe { EVP_PKEY_free(pkey); }
  return srv as usize as i64;
}

/**
 * 释放 TLS 服务端上下文。
 */
function net_tls_server_ctx_destroy_c(srv_ctx_h: i64): void {
  let srv: *TlsOpensslServerCtx = srv_ctx_h as usize as *TlsOpensslServerCtx;
  if (srv == 0) {
    return;
  }
  if (srv.ctx != 0) {
    unsafe { SSL_CTX_free(srv.ctx); }
  }
  unsafe { free(srv as *u8); }
}

/**
 * 在已 accept 的 TCP fd 上完成 TLS 服务端握手。
 */
function net_tls_accept_server_c(srv_ctx_h: i64, fd: i32): i64 {
  let srv: *TlsOpensslServerCtx = srv_ctx_h as usize as *TlsOpensslServerCtx;
  let sess: *TlsOpensslSess = 0 as *TlsOpensslSess;
  let ssl: *u8 = 0 as *u8;
  let rc: i32 = 0;
  shu_tls_last_error = 0;
  if (srv == 0 || srv.ctx == 0 || fd < 0) {
    shu_tls_last_error = -2;
    return 0 as i64;
  }
  unsafe { sess = calloc(1, 24) as *TlsOpensslSess; }
  if (sess == 0) {
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { ssl = SSL_new(srv.ctx); }
  if (ssl == 0) {
    unsafe { free(sess as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { SSL_set_fd(ssl, fd); }
  unsafe { net_set_blocking_c(fd, 1); }
  unsafe { rc = SSL_accept(ssl); }
  if (rc != 1) {
    unsafe { SSL_free(ssl); }
    unsafe { free(sess as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  sess.fd = fd;
  sess.ssl = ssl;
  sess.ctx = 0 as *u8;
  return sess as usize as i64;
}

/**
 * TLS 客户端握手（SNI）；失败返回 0。
 */
function net_tls_connect_client_c(fd: i32, sni: *u8): i64 {
  let sess: *TlsOpensslSess = 0 as *TlsOpensslSess;
  let ctx: *u8 = 0 as *u8;
  let ssl: *u8 = 0 as *u8;
  let rc: i32 = 0;
  shu_tls_last_error = 0;
  if (fd < 0) {
    shu_tls_last_error = -2;
    return 0 as i64;
  }
  if (sni == 0 || sni[0] == 0) {
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  if (unsafe { OPENSSL_init_ssl(OPENSSL_INIT_LOAD_SSL_STRINGS | OPENSSL_INIT_LOAD_CRYPTO_STRINGS,
      0 as *u8) } == 0) {
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { sess = calloc(1, 24) as *TlsOpensslSess; }
  if (sess == 0) {
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { ctx = SSL_CTX_new(TLS_client_method()); }
  if (ctx == 0) {
    unsafe { free(sess as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { SSL_CTX_set_verify(ctx, SSL_VERIFY_NONE, 0 as *u8); }
  unsafe { ssl = SSL_new(ctx); }
  if (ssl == 0) {
    unsafe { SSL_CTX_free(ctx); }
    unsafe { free(sess as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { SSL_set_fd(ssl, fd); }
  if (unsafe { SSL_set_tlsext_host_name(ssl, sni) } != 1) {
    unsafe { SSL_free(ssl); }
    unsafe { SSL_CTX_free(ctx); }
    unsafe { free(sess as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { net_set_blocking_c(fd, 1); }
  unsafe { rc = SSL_connect(ssl); }
  if (rc != 1) {
    unsafe { SSL_free(ssl); }
    unsafe { SSL_CTX_free(ctx); }
    unsafe { free(sess as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  sess.fd = fd;
  sess.ssl = ssl;
  sess.ctx = ctx;
  shu_tls_last_error = 0;
  return sess as usize as i64;
}

/**
 * 带 ALPN 的 TLS 客户端握手。
 */
function net_tls_connect_client_alpn_c(fd: i32, sni: *u8, alpn_wire: *u8, alpn_wire_len: i32): i64 {
  let sess: *TlsOpensslSess = 0 as *TlsOpensslSess;
  let ctx: *u8 = 0 as *u8;
  let ssl: *u8 = 0 as *u8;
  let rc: i32 = 0;
  shu_tls_last_error = 0;
  if (fd < 0 || alpn_wire == 0 || alpn_wire_len <= 0) {
    shu_tls_last_error = -2;
    return 0 as i64;
  }
  if (sni == 0 || sni[0] == 0) {
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  if (unsafe { OPENSSL_init_ssl(OPENSSL_INIT_LOAD_SSL_STRINGS | OPENSSL_INIT_LOAD_CRYPTO_STRINGS,
      0 as *u8) } == 0) {
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { sess = calloc(1, 24) as *TlsOpensslSess; }
  if (sess == 0) {
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { ctx = SSL_CTX_new(TLS_client_method()); }
  if (ctx == 0) {
    unsafe { free(sess as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { SSL_CTX_set_verify(ctx, SSL_VERIFY_NONE, 0 as *u8); }
  if (unsafe { SSL_CTX_set_alpn_protos(ctx, alpn_wire, alpn_wire_len as u32) } != 0) {
    unsafe { SSL_CTX_free(ctx); }
    unsafe { free(sess as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { ssl = SSL_new(ctx); }
  if (ssl == 0) {
    unsafe { SSL_CTX_free(ctx); }
    unsafe { free(sess as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { SSL_set_fd(ssl, fd); }
  if (unsafe { SSL_set_tlsext_host_name(ssl, sni) } != 1) {
    unsafe { SSL_free(ssl); }
    unsafe { SSL_CTX_free(ctx); }
    unsafe { free(sess as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  unsafe { net_set_blocking_c(fd, 1); }
  unsafe { rc = SSL_connect(ssl); }
  if (rc != 1) {
    unsafe { SSL_free(ssl); }
    unsafe { SSL_CTX_free(ctx); }
    unsafe { free(sess as *u8); }
    shu_tls_last_error = -1;
    return 0 as i64;
  }
  sess.fd = fd;
  sess.ssl = ssl;
  sess.ctx = ctx;
  shu_tls_last_error = 0;
  return sess as usize as i64;
}

/**
 * 读取协商 ALPN 协议名；返回长度，写入 out（可 NULL）。
 */
function net_tls_alpn_selected_c(ctx_handle: i64, out: *u8, out_cap: i32): i32 {
  let sess: *TlsOpensslSess = tls_openssl_sess_ptr(ctx_handle);
  let sel: *u8 = 0 as *u8;
  let len: u32 = 0;
  let n: i32 = 0;
  if (sess == 0 || sess.ssl == 0) {
    shu_tls_last_error = -2;
    return -1;
  }
  unsafe { SSL_get0_alpn_selected(sess.ssl, &sel, &len); }
  if (len == 0) {
    return 0;
  }
  if (out != 0 && out_cap > 0) {
    n = len as i32;
    if (n > out_cap) {
      n = out_cap;
    }
    mem.mem_copy(out, sel, n);
  }
  return len as i32;
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
  let sess: *TlsOpensslSess = tls_openssl_sess_ptr(ctx_handle);
  if (sess == 0) {
    return 0;
  }
  if (sess.ssl != 0) {
    unsafe { SSL_shutdown(sess.ssl); }
    unsafe { SSL_free(sess.ssl); }
  }
  if (sess.ctx != 0) {
    unsafe { SSL_CTX_free(sess.ctx); }
  }
  unsafe { free(sess as *u8); }
  shu_tls_last_error = 0;
  return 0;
}

/**
 * TLS 读；失败 -1/-2。
 */
function net_tls_read_c(ctx_handle: i64, buf: *u8, cap: i32): i32 {
  let sess: *TlsOpensslSess = tls_openssl_sess_ptr(ctx_handle);
  let n: i32 = 0;
  if (sess == 0 || sess.ssl == 0) {
    shu_tls_last_error = -2;
    return -2;
  }
  if (buf == 0 || cap <= 0) {
    shu_tls_last_error = -2;
    return -2;
  }
  unsafe { n = SSL_read(sess.ssl, buf, cap); }
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
  let sess: *TlsOpensslSess = tls_openssl_sess_ptr(ctx_handle);
  let n: i32 = 0;
  if (sess == 0 || sess.ssl == 0) {
    shu_tls_last_error = -2;
    return -2;
  }
  if (buf == 0 || len <= 0) {
    shu_tls_last_error = -2;
    return -2;
  }
  unsafe { n = SSL_write(sess.ssl, buf, len); }
  if (n <= 0) {
    shu_tls_last_error = -1;
    return -1;
  }
  shu_tls_last_error = 0;
  return n;
}

/** 127.0.0.1 主机序 addr_u32（与 net 测试一致）。 */
const ADDR_LOOPBACK: u32 = 0x7f000001;

/** 烟测用字面量（NUL 结尾）。 */
let LOCALHOST: u8[10] = [108, 111, 99, 97, 108, 104, 111, 115, 116, 0];
let HTTP_TAG: u8[5] = [72, 84, 84, 80, 0];
let HTML_TAG: u8[5] = [104, 116, 109, 108, 0];
let HTML_TAG_U: u8[5] = [72, 84, 77, 76, 0];
let ENV_SHUX_TLS_PORT: u8[20] = [83, 72, 85, 88, 95, 84, 76, 83, 95, 83, 77, 79, 75, 69, 95, 80, 79, 82, 84, 0];

/**
 * OpenSSL 烟测：连接 SHUX_TLS_SMOKE_PORT 上 s_server，握手并读 HTTP 前缀。
 */
function net_tls_openssl_smoke_c(): i32 {
  let port_env: *u8 = 0 as *u8;
  let port: i32 = 0;
  let fd: i32 = 0;
  let ctx: i64 = 0;
  let n: i32 = 0;
  let buf: u8[64] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let req: u8[16] = [71, 69, 84, 32, 47, 13, 10, 13, 10, 0, 0, 0, 0, 0, 0, 0];
  let name: *u8 = net_tls_backend_name_c();
  if (name == 0 || name[0] != 111) {
    return 1;
  }
  unsafe { port_env = getenv(&ENV_SHUX_TLS_PORT[0]); }
  port = 0;
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
  if (net_tls_write_c(ctx, &req[0], 8) <= 0) {
    net_tls_close_c(ctx);
    unsafe { net_close_socket_c(fd); }
    return 5;
  }
  n = net_tls_read_c(ctx, &buf[0], 63);
  if (n <= 0) {
    net_tls_close_c(ctx);
    unsafe { net_close_socket_c(fd); }
    return 6;
  }
  buf[n] = 0;
  if (unsafe { strstr(&buf[0], &HTTP_TAG[0]) } == 0 &&
      unsafe { strstr(&buf[0], &HTML_TAG[0]) } == 0 &&
      unsafe { strstr(&buf[0], &HTML_TAG_U[0]) } == 0) {
    net_tls_close_c(ctx);
    unsafe { net_close_socket_c(fd); }
    return 7;
  }
  if (net_tls_close_c(ctx) != 0) {
    unsafe { net_close_socket_c(fd); }
    return 8;
  }
  unsafe { net_close_socket_c(fd); }
  return 0;
}

/**
 * mbedTLS 烟测：OpenSSL 构建下不可用。
 */
function net_tls_mbedtls_smoke_c(): i32 {
  return -9;
}
