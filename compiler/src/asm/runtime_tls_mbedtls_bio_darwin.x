// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
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

// runtime_tls_mbedtls_bio_darwin.x — Darwin arm64 mbedTLS BIO callbacks.
//
// The cold ensure path pure-asms src/asm/runtime_tls_mbedtls_bio.x
// (the public send/recv wrappers) and this file (the _impl bodies and
// the bind), then ld -r. It does not pass
// seeds/runtime_tls_mbedtls_bio.from_x.c to host cc. Linux and Windows
// keep that C seed, including the Cap sendto/recvfrom walks.
//
// This compiler cannot emit the static-inline svc #0x80 walks in
// xlang_net_cap.h, so Darwin calls libSystem send and recv. A function
// name used as a pointer value makes this compiler exit 139, so
// xlang_mbedtls_ssl_bind_fd_c takes the two callbacks with dlsym of
// RTLD_DEFAULT and passes those pointers to mbedtls_ssl_set_bio.
//
// Error numbers below were measured against Homebrew mbed TLS 4.1.0
// (MBEDTLS_VERSION_STRING "4.1.0") and Darwin errno:
//   EAGAIN and EWOULDBLOCK are both 35
//   MBEDTLS_ERR_SSL_WANT_WRITE     -26752  (-0x6880)
//   MBEDTLS_ERR_SSL_WANT_READ      -26880  (-0x6900)
//   MBEDTLS_ERR_SSL_INTERNAL_ERROR -27648  (-0x6C00)
//   MBEDTLS_ERR_SSL_CONN_EOF       -29312  (-0x7280)
//
// This object is a user companion. It is not in the g05 compiler
// image. A missing object after pure-asm faults falls back to the
// C seed.
//
// PLATFORM: MACOS|DARWIN arm64.

/**
 * Send bytes on a connected socket. Same byte result as send().
 * @param fd i32 — socket
 * @param buf *u8 — bytes
 * @param len i64 — count
 * @param flags i32 — 0 for this BIO
 * @return i64 — bytes sent, or -1
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function send(fd: i32, buf: *u8, len: i64, flags: i32): i64;

/**
 * Receive bytes on a connected socket. Same byte result as recv().
 * @param fd i32 — socket
 * @param buf *u8 — destination
 * @param len i64 — capacity
 * @param flags i32 — 0 for this BIO
 * @return i64 — bytes read, 0 on EOF, or -1
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function recv(fd: i32, buf: *u8, len: i64, flags: i32): i64;

/**
 * Darwin errno slot. C's __error is Mach-O ___error, so the .x
 * spelling is ___error: this compiler adds one underscore only when
 * the identifier does not already start with one.
 * @return *i32 — pointer to the thread's errno
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function ___error(): *i32;

/**
 * Look up an exported symbol. RTLD_DEFAULT is the pointer value -2.
 * @param handle *u8 — RTLD_DEFAULT
 * @param name *u8 — symbol name without a leading underscore
 * @return *u8 — address, or null
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function dlsym(handle: *u8, name: *u8): *u8;

/**
 * Bind BIO callbacks. Implemented by libmbedtls.
 * @param ssl *u8 — mbedtls_ssl_context
 * @param bio *u8 — pointer to the connected fd
 * @param f_send *u8 — send callback
 * @param f_recv *u8 — recv callback
 * @param f_timeout *u8 — null for a blocking handshake
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function mbedtls_ssl_set_bio(ssl: *u8, bio: *u8, f_send: *u8, f_recv: *u8, f_timeout: *u8): void;

/**
 * Current errno. Darwin EAGAIN and EWOULDBLOCK are both 35.
 * @return i32 — errno, or 0 when the slot is missing
 * PLATFORM: MACOS|DARWIN
 */
function tls_errno(): i32 {
  let slot: *i32 = 0;
  unsafe {
    slot = ___error();
  }
  if (slot == 0) {
    return 0;
  }
  return slot[0];
}

/**
 * Load the int fd stored at ctx.
 * @param ctx *u8 — pointer to an int fd
 * @return i32 — file descriptor
 * PLATFORM: MACOS|DARWIN
 */
function tls_load_fd(ctx: *u8): i32 {
  let slot: *i32 = ctx as *i32;
  return slot[0];
}

/**
 * RTLD_DEFAULT as a pointer. The value is -2.
 * @return *u8 — handle for dlsym
 * PLATFORM: MACOS|DARWIN
 */
function tls_rtld_default(): *u8 {
  let n: i64 = 0 - 2;
  return n as *u8;
}

/**
 * BIO send. EAGAIN maps to MBEDTLS_ERR_SSL_WANT_WRITE (-26752).
 * Any other failure maps to MBEDTLS_ERR_SSL_INTERNAL_ERROR (-27648).
 * @param ctx *u8 — pointer to the connected fd
 * @param buf *u8 — bytes to send
 * @param len usize — byte count
 * @return i32 — bytes sent, or a negative mbedTLS code
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_mbedtls_bio_send_impl(ctx: *u8, buf: *u8, len: usize): i32 {
  let fd: i32 = tls_load_fd(ctx);
  let n: i64 = len as i64;
  let r: i64 = 0;
  unsafe {
    r = send(fd, buf, n, 0);
  }
  if (r < 0) {
    if (tls_errno() == 35) {
      return 0 - 26752;
    }
    return 0 - 27648;
  }
  return r as i32;
}

/**
 * BIO recv. EAGAIN maps to MBEDTLS_ERR_SSL_WANT_READ (-26880).
 * A zero read maps to MBEDTLS_ERR_SSL_CONN_EOF (-29312).
 * Any other failure maps to MBEDTLS_ERR_SSL_INTERNAL_ERROR (-27648).
 * @param ctx *u8 — pointer to the connected fd
 * @param buf *u8 — destination
 * @param len usize — capacity
 * @return i32 — bytes read, or a negative mbedTLS code
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_mbedtls_bio_recv_impl(ctx: *u8, buf: *u8, len: usize): i32 {
  let fd: i32 = tls_load_fd(ctx);
  let n: i64 = len as i64;
  let r: i64 = 0;
  unsafe {
    r = recv(fd, buf, n, 0);
  }
  if (r < 0) {
    if (tls_errno() == 35) {
      return 0 - 26880;
    }
    return 0 - 27648;
  }
  if (r == 0) {
    return 0 - 29312;
  }
  return r as i32;
}

/**
 * Bind ssl to a connected TCP fd. The callbacks are the public
 * wrappers, looked up by name because a function name used as a
 * pointer makes this compiler exit 139.
 * @param ssl *u8 — mbedtls_ssl_context
 * @param fd *u8 — pointer to the int fd
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_mbedtls_ssl_bind_fd_c(ssl: *u8, fd: *u8): void {
  let send_fn: *u8 = 0;
  let recv_fn: *u8 = 0;
  let handle: *u8 = tls_rtld_default();
  unsafe {
    send_fn = dlsym(handle, "xlang_mbedtls_bio_send");
    recv_fn = dlsym(handle, "xlang_mbedtls_bio_recv");
    mbedtls_ssl_set_bio(ssl, fd, send_fn, recv_fn, 0);
  }
}
