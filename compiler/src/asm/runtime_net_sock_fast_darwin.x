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

// runtime_net_sock_fast_darwin.x — Darwin arm64 socket bridges.
//
// The cold ensure path pure-asms src/asm/runtime_net_sock_fast.x (the
// Winsock wrappers) and this file, then ld -r. It does not pass
// seeds/runtime_net_sock_fast.from_x.c to host cc. Linux and Windows
// keep that C seed, including the Cap walks.
//
// Darwin's Cap socket, bind, connect, listen, accept, sendto, recvfrom,
// poll, close, and fcntl are static-inline svc #0x80. This compiler
// cannot emit that. libSystem performs the same calls. fcntl itself is
// variadic, and this compiler puts the third argument in a register
// while Darwin reads it from the stack. ___fcntl takes the flags in
// the third register, so non-blocking mode goes through that symbol.
// Measured on this Mac: F_SETFL is 4, O_NONBLOCK is 4, SOL_SOCKET is
// 65535, SO_REUSEADDR is 4. AF_INET is 2, SOCK_STREAM is 1, SOCK_DGRAM
// is 2, IPPROTO_TCP is 6, IPPROTO_UDP is 17.
//
// net_tcp_errno_ptr, net_udp_errno_ptr, and net_ipv6_errno_ptr are
// already exported by std/net/tcp.x, udp.x, and ipv6.x. This file only
// keeps the _c names, which exist solely in the C seed. WSA startup is
// a no-op on Darwin, so the constructor attribute is not required.
// PLATFORM: MACOS|DARWIN arm64

extern "C" function malloc(n: i64): *u8;
extern "C" function free(p: *u8): void;
extern "C" function memset(d: *u8, c: i32, n: i64): *u8;
extern "C" function close(fd: i32): i32;
extern "C" function socket(domain: i32, kind: i32, protocol: i32): i32;
extern "C" function bind(fd: i32, addr: *u8, nlen: i32): i32;
extern "C" function listen(fd: i32, backlog: i32): i32;
extern "C" function connect(fd: i32, addr: *u8, nlen: i32): i32;
extern "C" function accept(fd: i32, addr: *u8, nlen: *i32): i32;
extern "C" function sendto(fd: i32, buf: *u8, nlen: i64, flg: i32, addr: *u8, alen: i32): i64;
extern "C" function recvfrom(fd: i32, buf: *u8, nlen: i64, flg: i32, addr: *u8, nlen: *i32): i64;
extern "C" function poll(fds: *u8, nfds: i32, timeout: i32): i32;
extern "C" function ___fcntl(fd: i32, cmd: i32, arg: i32): i32;
extern "C" function setsockopt(fd: i32, level: i32, opt: i32, val: *i32, nlen: i32): i32;
extern "C" function ___error(): *i32;
extern "C" function net_tcp_set_addr_port_buf_c(sin: *u8, addr_u32: u32, port_u32: u32): void;
extern "C" function net_udp_set_addr_port_buf_c(sin: *u8, addr_u32: u32, port_u32: u32): void;

/** errno slot used when a product object asks for the _c name.
 * @return pointer from ___error, or null if that call returns null
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_tcp_errno_ptr_c(): *i32 {
  unsafe { return ___error(); }
  return 0;
}

/** errno slot for the UDP _c name. Same pointer as the TCP face.
 * @return pointer from ___error
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_udp_errno_ptr_c(): *i32 {
  unsafe { return ___error(); }
  return 0;
}

/** errno slot for the IPv6 _c name. Same pointer as the TCP face.
 * @return pointer from ___error
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_ipv6_errno_ptr_c(): *i32 {
  unsafe { return ___error(); }
  return 0;
}

/** Winsock startup. Darwin has no Winsock, so this returns without work.
 * @return nothing
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_ensure_wsa_impl_c(): void {
  return;
}

/** Startup hook. The body is the same no-op as net_ensure_wsa_impl_c.
 * @return nothing
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_wsa_ctor_impl_c(): void {
  return;
}

/** poll. A null fd set or a non-positive count returns -1.
 * @param fds pollfd bytes, 8 bytes each on Darwin
 * @param nfds number of entries
 * @param timeout milliseconds, or -1 to wait
 * @return the poll result, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function xlang_sys_poll(fds: *u8, nfds: i32, timeout: i32): i32 {
  if (fds == 0) { return 0 - 1; }
  if (nfds <= 0) { return 0 - 1; }
  unsafe { return poll(fds, nfds, timeout); }
  return 0 - 1;
}

/** socket.
 * @param domain address family
 * @param kind socket type
 * @param protocol protocol number
 * @return the new fd, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function xlang_sys_socket(domain: i32, kind: i32, protocol: i32): i32 {
  unsafe { return socket(domain, kind, protocol); }
  return 0 - 1;
}

/** connect. A null address or a non-positive length returns -1.
 * @param sockfd socket
 * @param addr sockaddr bytes
 * @param addrlen length of addr
 * @return 0 on success, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function xlang_sys_connect(sockfd: i32, addr: *u8, addrlen: i32): i32 {
  if (addr == 0) { return 0 - 1; }
  if (addrlen <= 0) { return 0 - 1; }
  unsafe { return connect(sockfd, addr, addrlen); }
  return 0 - 1;
}

/** bind. A null address or a non-positive length returns -1.
 * @param sockfd socket
 * @param addr sockaddr bytes
 * @param addrlen length of addr
 * @return 0 on success, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function xlang_sys_bind(sockfd: i32, addr: *u8, addrlen: i32): i32 {
  if (addr == 0) { return 0 - 1; }
  if (addrlen <= 0) { return 0 - 1; }
  unsafe { return bind(sockfd, addr, addrlen); }
  return 0 - 1;
}

/** listen.
 * @param sockfd socket
 * @param backlog queue length
 * @return 0 on success, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function xlang_sys_listen(sockfd: i32, backlog: i32): i32 {
  unsafe { return listen(sockfd, backlog); }
  return 0 - 1;
}

/** accept. A null length pointer is passed through as a null length.
 * The length is an in-out i32. socklen_t on Darwin is 4 bytes.
 * @param sockfd listening socket
 * @param addr buffer for the peer, or null
 * @param addrlen in-out length, or null
 * @return the new fd, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function xlang_sys_accept(sockfd: i32, addr: *u8, addrlen: *i32): i32 {
  let k: i32 = 0;
  let r: i32 = 0;
  if (addrlen == 0) {
    unsafe { return accept(sockfd, addr, 0); }
  }
  k = addrlen[0];
  unsafe { r = accept(sockfd, addr, &k); }
  addrlen[0] = k;
  return r;
}

/** sendto. A negative length returns -1. A null buffer with a positive
 * length returns -1, matching the Darwin Cap check.
 * @param sockfd socket
 * @param buf bytes to send, or null when len is 0
 * @param len byte count
 * @param flg send flags
 * @param addr destination, or null
 * @param addrlen length of addr
 * @return bytes sent, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function xlang_sys_sendto(sockfd: i32, buf: *u8, len: i32, flg: i32, addr: *u8, addrlen: i32): i32 {
  let n: i64 = 0;
  if (len < 0) { return 0 - 1; }
  if (buf == 0) {
    if (len != 0) { return 0 - 1; }
  }
  unsafe { n = sendto(sockfd, buf, len as i64, flg, addr, addrlen); }
  return n as i32;
}

/** recvfrom. A negative length returns -1. A null buffer with a positive
 * length returns -1. The length pointer is in-out when it is not null.
 * @param sockfd socket
 * @param buf destination, or null when len is 0
 * @param len byte count
 * @param flg receive flags
 * @param addr peer buffer, or null
 * @param addrlen in-out length, or null
 * @return bytes received, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function xlang_sys_recvfrom(sockfd: i32, buf: *u8, len: i32, flg: i32, addr: *u8, addrlen: *i32): i32 {
  // Live pad: the in-out length slot must sit inside the frame.
  // PLATFORM: MACOS|DARWIN arm64
  let pad: u8[64] = [];
  pad[0] = 0;
  let k: i32 = 0;
  let n: i64 = 0;
  if (len < 0) { return 0 - 1; }
  if (buf == 0) {
    if (len != 0) { return 0 - 1; }
  }
  if (addrlen == 0) {
    unsafe { n = recvfrom(sockfd, buf, len as i64, flg, addr, 0); }
    return n as i32;
  }
  k = addrlen[0];
  unsafe { n = recvfrom(sockfd, buf, len as i64, flg, addr, &k); }
  addrlen[0] = k;
  return n as i32;
}

/** Set or clear non-blocking mode. The flags argument replaces the
 * file status flags: 4 when non-blocking, 0 when blocking.
 * @param fd socket
 * @param blocking 0 to set O_NONBLOCK, any other value to clear it
 * @return 0 on success, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_set_blocking_c(fd: i32, blocking: i32): i32 {
  let arg: i32 = 4;
  let r: i32 = 0;
  if (fd < 0) { return 0 - 1; }
  if (blocking != 0) { arg = 0; }
  unsafe { r = ___fcntl(fd, 4, arg); }
  if (r != 0) { return 0 - 1; }
  return 0;
}

/** Close a socket. A negative fd is a no-op and returns 0.
 * @param fd socket, or a negative value
 * @return 0 on success, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_close_socket_c(fd: i32): i32 {
  let r: i32 = 0;
  if (fd < 0) { return 0; }
  unsafe { r = close(fd); }
  if (r != 0) { return 0 - 1; }
  return 0;
}

/** Allocate and zero a 16-byte sockaddr.
 * @return the buffer, or null when malloc fails
 * PLATFORM: MACOS|DARWIN arm64
 */
function sock_new_sin(): *u8 {
  let p: *u8 = 0;
  unsafe { p = malloc(16); }
  if (p == 0) { return 0; }
  unsafe { memset(p, 0, 16); }
  return p;
}

/** Turn SO_REUSEADDR on. SOL_SOCKET is 65535 and SO_REUSEADDR is 4.
 * @param fd socket
 * @return 0 on success, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
function sock_reuse(fd: i32): i32 {
  // Live pad: the option-value slot must sit inside the frame.
  // PLATFORM: MACOS|DARWIN arm64
  let pad: u8[64] = [];
  pad[0] = 0;
  let bit: i32 = 1;
  unsafe { return setsockopt(fd, 65535, 4, &bit, 4); }
  return 0 - 1;
}

/** Set O_NONBLOCK with F_SETFL.
 * @param fd socket
 * @return 0 on success, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
function sock_nonblock(fd: i32): i32 {
  unsafe { return ___fcntl(fd, 4, 4); }
  return 0 - 1;
}

/** Close fd, free the sockaddr, and return -1.
 * @param fd socket to close
 * @param sin heap sockaddr
 * @return -1
 * PLATFORM: MACOS|DARWIN arm64
 */
function sock_abort(fd: i32, sin: *u8): i32 {
  net_close_socket_c(fd);
  unsafe { free(sin); }
  return 0 - 1;
}

/** Bind, then listen when kind is 0, then set non-blocking.
 * kind 0 is TCP. Any other kind is UDP and skips listen.
 * @param kind 0 for TCP listen, otherwise UDP bind
 * @param fd socket already created
 * @param sin 16-byte sockaddr
 * @return the fd, or -1 after closing it
 * PLATFORM: MACOS|DARWIN arm64
 */
function sock_bind_finish(kind: i32, fd: i32, sin: *u8): i32 {
  let r: i32 = 0;
  unsafe { r = bind(fd, sin, 16); }
  if (r != 0) { return sock_abort(fd, sin); }
  if (kind == 0) {
    unsafe { r = listen(fd, 128); }
    if (r != 0) { return sock_abort(fd, sin); }
  }
  r = sock_nonblock(fd);
  if (r != 0) { return sock_abort(fd, sin); }
  unsafe { free(sin); }
  return fd;
}

/** Open a TCP socket, enable reuse, and finish the listen.
 * @param sin filled sockaddr
 * @return the listening fd, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
function sock_tcp_open(sin: *u8): i32 {
  let fd: i32 = 0;
  let r: i32 = 0;
  unsafe { fd = socket(2, 1, 6); }
  if (fd < 0) { return sock_abort(fd, sin); }
  r = sock_reuse(fd);
  if (r != 0) { return sock_abort(fd, sin); }
  return sock_bind_finish(0, fd, sin);
}

/** Open a UDP socket, enable reuse, and finish the bind.
 * @param sin filled sockaddr
 * @return the bound fd, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
function sock_udp_open(sin: *u8): i32 {
  let fd: i32 = 0;
  let r: i32 = 0;
  unsafe { fd = socket(2, 2, 17); }
  if (fd < 0) { return sock_abort(fd, sin); }
  r = sock_reuse(fd);
  if (r != 0) { return sock_abort(fd, sin); }
  return sock_bind_finish(1, fd, sin);
}

/** Listen on TCP at the host-order address and port. The fd is non-blocking.
 * @param addr_u32 host-order IPv4 address
 * @param port_u32 host-order port
 * @return the listening fd, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_tcp_listen_c(addr_u32: u32, port_u32: u32): i32 {
  let sin: *u8 = sock_new_sin();
  if (sin == 0) { return 0 - 1; }
  unsafe { net_tcp_set_addr_port_buf_c(sin, addr_u32, port_u32); }
  return sock_tcp_open(sin);
}

/** Bind UDP at the host-order address and port. The fd is non-blocking.
 * @param addr_u32 host-order IPv4 address
 * @param port_u32 host-order port
 * @return the bound fd, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_udp_bind_c(addr_u32: u32, port_u32: u32): i32 {
  let sin: *u8 = sock_new_sin();
  if (sin == 0) { return 0 - 1; }
  unsafe { net_udp_set_addr_port_buf_c(sin, addr_u32, port_u32); }
  return sock_udp_open(sin);
}
