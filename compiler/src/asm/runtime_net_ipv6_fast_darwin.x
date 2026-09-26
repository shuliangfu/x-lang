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

// runtime_net_ipv6_fast_darwin.x — Darwin arm64 IPv6 socket bridges.
//
// The cold ensure path pure-asms src/asm/runtime_net_ipv6_fast.x (the
// public wrappers) and this file, then ld -r. It does not pass
// seeds/runtime_net_ipv6_fast.from_x.c to host cc. Linux and Windows
// keep that C seed, including the Cap walks.
//
// Darwin's Cap socket, connect, bind, listen, poll, close, and fcntl
// are static-inline svc #0x80. This compiler cannot emit that.
// libSystem performs the same calls. Non-blocking mode uses ___fcntl,
// because fcntl is variadic and Darwin reads the third argument from
// the stack.
//
// sockaddr_in6 is 28 bytes, measured on this Mac:
//   sin6_len 0, sin6_family 1 (AF_INET6 = 30), sin6_port 2,
//   sin6_flowinfo 4, sin6_addr 8, sin6_scope_id 24.
// The setter writes sin6_len 28, unlike the IPv4 setter which leaves
// sin_len alone. EINPROGRESS is 36. EAGAIN is 35. POLLOUT is 4,
// POLLERR is 8, POLLHUP is 16. F_SETFL and O_NONBLOCK are both 4.
// SOL_SOCKET is 65535. SO_REUSEADDR is 4.
// PLATFORM: MACOS|DARWIN arm64

extern "C" function malloc(n: i64): *u8;
extern "C" function free(p: *u8): void;
extern "C" function memset(d: *u8, c: i32, n: i64): *u8;
extern "C" function close(fd: i32): i32;
extern "C" function socket(domain: i32, kind: i32, protocol: i32): i32;
extern "C" function bind(fd: i32, addr: *u8, nlen: i32): i32;
extern "C" function listen(fd: i32, backlog: i32): i32;
extern "C" function connect(fd: i32, addr: *u8, nlen: i32): i32;
extern "C" function poll(fds: *u8, nfds: i32, timeout: i32): i32;
extern "C" function setsockopt(fd: i32, level: i32, opt: i32, val: *i32, nlen: i32): i32;
extern "C" function ___fcntl(fd: i32, cmd: i32, arg: i32): i32;
extern "C" function ___error(): *i32;

/** Winsock startup. Darwin returns 0 without doing work.
 * @return 0
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_ipv6_ensure_wsa_c_impl_c(): i32 {
  return 0;
}

/** Close a socket. A failed close returns -1.
 * @param fd socket
 * @return 0 on success, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_ipv6_close_socket_c_impl_c(fd: i32): i32 {
  let r: i32 = 0;
  unsafe { r = close(fd); }
  if (r != 0) { return 0 - 1; }
  return 0;
}

/** Set O_NONBLOCK through ___fcntl. F_SETFL and O_NONBLOCK are both 4.
 * @param fd socket
 * @return 0 on success, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_ipv6_set_nonblock_c_impl_c(fd: i32): i32 {
  let r: i32 = 0;
  unsafe { r = ___fcntl(fd, 4, 4); }
  if (r != 0) { return 0 - 1; }
  return 0;
}

/** Poll until the socket is writable, or the timeout elapses.
 * pollfd is 8 bytes: fd at 0, POLLOUT (4) at 4, revents at 6.
 * POLLERR or POLLHUP returns -1. timeout_ms is passed through.
 * @param fd socket
 * @param timeout_ms milliseconds to wait
 * @return 0 when writable, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_ipv6_poll_writable_c_impl_c(fd: i32, timeout_ms: u32): i32 {
  let raw: i64 = 0;
  let p: *u8 = &raw as *u8;
  let n: i32 = 0;
  let rev: i32 = 0;
  let i: i32 = 0;
  i = 0;
  p[i] = (fd & 255) as u8;
  i = 1;
  p[i] = ((fd >> 8) & 255) as u8;
  i = 2;
  p[i] = ((fd >> 16) & 255) as u8;
  i = 3;
  p[i] = ((fd >> 24) & 255) as u8;
  i = 4;
  p[i] = 4 as u8;
  unsafe { n = poll(p, 1, timeout_ms as i32); }
  if (n <= 0) { return 0 - 1; }
  i = 6;
  rev = p[i] as i32;
  i = 7;
  rev = rev + ((p[i] as i32) * 256);
  if ((rev & 24) != 0) { return 0 - 1; }
  return 0;
}

/** 1 when errno is EINPROGRESS (36) or EAGAIN (35).
 * @return 1 if a non-blocking connect should wait, otherwise 0
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_ipv6_connect_retry_ok_c_impl_c(): i32 {
  let slot: *i32 = 0;
  let e: i32 = 0;
  unsafe { slot = ___error(); }
  if (slot == 0) { return 0; }
  e = slot[0];
  if (e == 36) { return 1; }
  if (e == 35) { return 1; }
  return 0;
}

/** Copy 16 address bytes to offset 8 of a sockaddr_in6.
 * The index is a local so the store does not use a parameter as the index.
 * @param sin destination, already checked non-null
 * @param addr 16-byte IPv6 address
 * PLATFORM: MACOS|DARWIN arm64
 */
function ipv6_copy_addr(sin: *u8, addr: *u8): void {
  let i: i32 = 0;
  while (i < 16) {
    let s: i32 = i;
    let d: i32 = i + 8;
    sin[d] = addr[s];
    i = i + 1;
  }
}

/** Fill a Darwin sockaddr_in6. sin6_len is set to 28.
 * A null buffer or a null address returns without writing.
 * @param sin destination, at least 28 bytes, or null
 * @param addr_16 16-byte IPv6 address, or null
 * @param port_u32 host-order port
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_ipv6_set_addr_port_buf_c(sin: *u8, addr_16: *u8, port_u32: u32): void {
  let port: i32 = 0;
  let i: i32 = 0;
  if (sin == 0) { return; }
  if (addr_16 == 0) { return; }
  unsafe { memset(sin, 0, 28); }
  port = port_u32 as i32;
  i = 0;
  sin[i] = 28 as u8;
  i = 1;
  sin[i] = 30 as u8;
  i = 2;
  sin[i] = ((port >> 8) & 255) as u8;
  i = 3;
  sin[i] = (port & 255) as u8;
  ipv6_copy_addr(sin, addr_16);
}

/** Close fd, free the sockaddr, and return -1.
 * @param fd socket to close
 * @param sin heap sockaddr_in6
 * @return -1
 * PLATFORM: MACOS|DARWIN arm64
 */
function ipv6_fail(fd: i32, sin: *u8): i32 {
  net_ipv6_close_socket_c_impl_c(fd);
  unsafe { free(sin); }
  return 0 - 1;
}

/** Connect a non-blocking TCP socket to a filled sockaddr_in6.
 * An in-progress connect waits until the socket is writable.
 * @param fd socket
 * @param sin 28-byte sockaddr_in6
 * @param timeout_ms milliseconds to wait when the connect is in progress
 * @return the fd, or -1 after closing it
 * PLATFORM: MACOS|DARWIN arm64
 */
function ipv6_connect_finish(fd: i32, sin: *u8, timeout_ms: u32): i32 {
  let r: i32 = 0;
  unsafe { r = connect(fd, sin, 28); }
  if (r != 0) {
    if (net_ipv6_connect_retry_ok_c_impl_c() == 0) { return ipv6_fail(fd, sin); }
    if (net_ipv6_poll_writable_c_impl_c(fd, timeout_ms) != 0) { return ipv6_fail(fd, sin); }
  }
  unsafe { free(sin); }
  return fd;
}

/** Open a non-blocking IPv6 TCP connection.
 * A null address returns -1.
 * @param addr_16 16-byte IPv6 address
 * @param port_u32 host-order port
 * @param timeout_ms milliseconds to wait when the connect is in progress
 * @return the connected fd, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_tcp_connect_ipv6_c(addr_16: *u8, port_u32: u32, timeout_ms: u32): i32 {
  let sin: *u8 = 0;
  let fd: i32 = 0;
  if (addr_16 == 0) { return 0 - 1; }
  if (net_ipv6_ensure_wsa_c_impl_c() != 0) { return 0 - 1; }
  unsafe { sin = malloc(28); }
  if (sin == 0) { return 0 - 1; }
  net_ipv6_set_addr_port_buf_c(sin, addr_16, port_u32);
  unsafe { fd = socket(30, 1, 6); }
  if (fd < 0) {
    unsafe { free(sin); }
    return 0 - 1;
  }
  if (net_ipv6_set_nonblock_c_impl_c(fd) != 0) { return ipv6_fail(fd, sin); }
  return ipv6_connect_finish(fd, sin, timeout_ms);
}

/** Enable SO_REUSEADDR. Failure is ignored by the caller, matching the C seed.
 * @param fd socket
 * PLATFORM: MACOS|DARWIN arm64
 */
function ipv6_reuse(fd: i32): void {
  let bit: i32 = 1;
  unsafe { setsockopt(fd, 65535, 4, &bit, 4); }
}

/** Bind, listen, and set non-blocking. Each step is one call plus the abort.
 * @param fd socket already created
 * @param sin filled sockaddr_in6
 * @return the listening fd, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
function ipv6_listen_arm(fd: i32, sin: *u8): i32 {
  let r: i32 = 0;
  unsafe { r = listen(fd, 128); }
  if (r != 0) { return ipv6_fail(fd, sin); }
  if (net_ipv6_set_nonblock_c_impl_c(fd) != 0) { return ipv6_fail(fd, sin); }
  unsafe { free(sin); }
  return fd;
}

/** Bind the socket, then arm the listen.
 * @param fd socket
 * @param sin filled sockaddr_in6
 * @return the listening fd, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
function ipv6_listen_bind(fd: i32, sin: *u8): i32 {
  let r: i32 = 0;
  unsafe { r = bind(fd, sin, 28); }
  if (r != 0) { return ipv6_fail(fd, sin); }
  return ipv6_listen_arm(fd, sin);
}

/** Open an IPv6 TCP socket and enable reuse.
 * @param sin filled sockaddr_in6
 * @return the listening fd, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
function ipv6_listen_open(sin: *u8): i32 {
  let fd: i32 = 0;
  unsafe { fd = socket(30, 1, 6); }
  if (fd < 0) {
    unsafe { free(sin); }
    return 0 - 1;
  }
  ipv6_reuse(fd);
  return ipv6_listen_bind(fd, sin);
}

/** Allocate and fill a sockaddr_in6.
 * @param addr_16 16-byte address
 * @param port_u32 host-order port
 * @return the buffer, or null
 * PLATFORM: MACOS|DARWIN arm64
 */
function ipv6_listen_sin(addr_16: *u8, port_u32: u32): *u8 {
  let sin: *u8 = 0;
  unsafe { sin = malloc(28); }
  if (sin == 0) { return 0; }
  net_ipv6_set_addr_port_buf_c(sin, addr_16, port_u32);
  return sin;
}

/** Listen on IPv6 TCP. The returned fd is non-blocking.
 * A null address returns -1.
 * @param addr_16 16-byte IPv6 address
 * @param port_u32 host-order port
 * @return the listening fd, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_tcp_listen_ipv6_c(addr_16: *u8, port_u32: u32): i32 {
  let sin: *u8 = 0;
  if (addr_16 == 0) { return 0 - 1; }
  if (net_ipv6_ensure_wsa_c_impl_c() != 0) { return 0 - 1; }
  sin = ipv6_listen_sin(addr_16, port_u32);
  if (sin == 0) { return 0 - 1; }
  return ipv6_listen_open(sin);
}
