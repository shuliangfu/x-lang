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

// std.net.ipv6 — F-04 v11：IPv6 TCP connect/listen
//
// See implementation.
// See implementation.
//
// See implementation.

const mem = import("core.mem");

export const AF_INET6: i32 = 10;
export const SOCK_STREAM: i32 = 1;
export const IPPROTO_TCP: i32 = 6;
export const SOL_SOCKET: i32 = 1;
export const SO_REUSEADDR: i32 = 2;
export const SO_ERROR: i32 = 4;
export const O_NONBLOCK: i32 = 2048;
/* See implementation. */
 * See implementation.
export const SOCKADDR_IN6_SIZE: u32 = 28;

/* See implementation. */
#[cfg(target_os = "linux")]
export const ERR_INPROGRESS: i32 = 115;

#[cfg(target_os = "linux")]
export const ERR_EAGAIN: i32 = 11;

#[cfg(target_os = "macos")]
export const ERR_INPROGRESS: i32 = 36;

#[cfg(target_os = "macos")]
export const ERR_EAGAIN: i32 = 35;

/* See implementation. */
allow(padding) struct SockAddrIn6 {
  sin6_family: u16;
  sin6_port: u16;
  sin6_flowinfo: u32;
  sin6_addr: u8[16];
}

/* See implementation. */
#[cfg(not(target_os = "windows"))]
allow(padding) struct PollFd { fd: i32; events: i16; revents: i16; }

extern "C" function socket(domain: i32, sock_type: i32, protocol: i32): i32;
extern "C" function connect(fd: i32, addr: *u8, addrlen: u32): i32;
extern "C" function bind(fd: i32, addr: *u8, addrlen: u32): i32;
extern "C" function listen(fd: i32, backlog: i32): i32;
extern "C" function setsockopt(fd: i32, level: i32, optname: i32, optval: *i32, optlen: u32): i32;
extern "C" function getsockopt(fd: i32, level: i32, optname: i32, optval: *i32, optlen: *u32): i32;
extern "C" function close(fd: i32): i32;
extern "C" function htons(hostshort: u16): u16;

#[cfg(not(target_os = "windows"))]
extern "C" function fcntl(fd: i32, cmd: i32, arg: i32): i32;

/* See implementation. */
#[cfg(not(target_os = "windows"))]
extern "C" function shux_sys_poll(fds: *u8, nfds: i32, timeout: i32): i32;

#[cfg(target_os = "linux")]
extern "C" function __errno_location(): *i32;

#[cfg(target_os = "macos")]
extern "C" function __error(): *i32;

/** See implementation for details. */
#[cfg(target_os = "linux")]
export function net_ipv6_errno_ptr(): *i32 {
  let p: *i32 = 0 as *i32;
  unsafe { p = __errno_location(); }
  return p;
}

#[cfg(target_os = "macos")]
/** Exported function `net_ipv6_errno_ptr`.
 * Implements `net_ipv6_errno_ptr`.
 * @return *i32
 */
export function net_ipv6_errno_ptr(): *i32 {
  let p: *i32 = 0 as *i32;
  unsafe { p = __error(); }
  return p;
}

#[cfg(target_os = "windows")]
extern "C" function WSAStartup(wVersionRequested: u16, lpWSAData: *u8): i32;

#[cfg(target_os = "windows")]
extern "C" function ioctlsocket(fd: i32, cmd: i32, arg: *u32): i32;

#[cfg(target_os = "windows")]
extern "C" function closesocket(fd: i32): i32;

#[cfg(target_os = "windows")]
let net_ipv6_wsa_done: i32 = 0;

/**
 * See implementation.
 */
#[cfg(target_os = "windows")]
export function net_ipv6_ensure_wsa_c(): i32 {
  if (net_ipv6_wsa_done != 0) {
    return 0;
  }
  unsafe { if (WSAStartup(514 as u16, 0 as *u8) != 0) {
    return -1;
  } }
  net_ipv6_wsa_done = 1;
  return 0;
}

/**
 * See implementation.
 */
#[cfg(target_os = "windows")]
export function net_ipv6_maybe_wsa_fail_c(): i32 {
  if (net_ipv6_ensure_wsa_c() != 0) {
    return -1;
  }
  return 0;
}

#[cfg(not(target_os = "windows"))]
/** Exported function `net_ipv6_maybe_wsa_fail_c`.
 * Implements `net_ipv6_maybe_wsa_fail_c`.
 * @return i32
 */
export function net_ipv6_maybe_wsa_fail_c(): i32 {
  return 0;
}

/**
 * See implementation.
 */
export function net_ipv6_sin_buf_ptr_c(p: *u8): *u8 {
  return p;
}

/* See implementation. */
extern function net_ipv6_set_addr_port_buf_c(sin: *u8, addr_16: *u8, port_u32: u32): void;

/**
 * See implementation.
 */
#[cfg(not(target_os = "windows"))]
export function net_ipv6_set_nonblock_c(fd: i32): i32 {
  let flags: i32 = 0;
  unsafe { flags = fcntl(fd, 3, 0); }
  if (flags < 0) {
    return -1;
  }
  unsafe { if (fcntl(fd, 4, flags | O_NONBLOCK) == 0) {
    return 0;
  } }
  return -1;
}

/**
 * See implementation.
 */
#[cfg(target_os = "windows")]
export function net_ipv6_set_nonblock_c(fd: i32): i32 {
  let one: u32 = 1;
  unsafe { if (ioctlsocket(fd, (0x80000000 | 0x40000000) as i32, &one) == 0) {
    return 0;
  } }
  return -1;
}

/**
 * See implementation.
 */
#[cfg(not(target_os = "windows"))]
export function net_ipv6_poll_writable_c(fd: i32, timeout_ms: u32): i32 {
  let pfd_mem: u8[8] = [];
  let pfd_ptr: *u8 = net_ipv6_sin_buf_ptr_c(&pfd_mem[0]);
  let p_fd: *i32 = (pfd_ptr + 0) as *i32;
  let p_events: *i16 = (pfd_ptr + 4) as *i16;
  let p_revents: *i16 = (pfd_ptr + 6) as *i16;
  let n: i32 = 0;
  p_fd[0] = fd;
  p_events[0] = 4 as i16; /* POLLOUT */
  p_revents[0] = 0 as i16;
  unsafe { n = shux_sys_poll(pfd_ptr, 1, timeout_ms as i32); }
  if (n <= 0 || (p_revents[0] & (24 as i16)) != 0) { /* POLLERR|POLLHUP */
    return -1;
  }
  return 0;
}

/**
 * See implementation.
 */
#[cfg(target_os = "windows")]
export function net_ipv6_poll_writable_c(fd: i32, timeout_ms: u32): i32 {
  return 0;
}

/**
 * See implementation.
 */
#[cfg(not(target_os = "windows"))]
export function net_ipv6_connect_retry_ok_c(): i32 {
  let ep: *i32 = 0 as *i32;
  let e: i32 = 0;
  ep = net_ipv6_errno_ptr();
  e = ep[0];
  if (e == ERR_INPROGRESS || e == ERR_EAGAIN) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 */
#[cfg(target_os = "windows")]
export function net_ipv6_connect_retry_ok_c(): i32 {
  return 1;
}

/**
 * See implementation.
 */
export function net_tcp_connect_ipv6_c(addr_16: *u8, port_u32: u32, timeout_ms: u32): i32 {
  let sin_mem: u8[28] = [];
  let sin_ptr: *u8 = net_ipv6_sin_buf_ptr_c(&sin_mem[0]);
  let fd: i32 = 0;
  let err: i32 = 0;
  let errlen: u32 = 4;
  if (net_ipv6_maybe_wsa_fail_c() != 0) {
    return -1;
  }
  if (addr_16 == 0) {
    return -1;
  }
  unsafe { net_ipv6_set_addr_port_buf_c(sin_ptr, addr_16, port_u32); }
  unsafe { fd = socket(AF_INET6, SOCK_STREAM, IPPROTO_TCP); }
  if (fd < 0) {
    return -1;
  }
  if (net_ipv6_set_nonblock_c(fd) != 0) {
    unsafe { close(fd); }
    return -1;
  }
  unsafe { if (connect(fd, sin_ptr, SOCKADDR_IN6_SIZE) != 0) {
    if (net_ipv6_connect_retry_ok_c() == 0) {
      close(fd);
      return -1;
    }
    if (net_ipv6_poll_writable_c(fd, timeout_ms) != 0) {
      close(fd);
      return -1;
    }
    err = 0;
    if (getsockopt(fd, SOL_SOCKET, SO_ERROR, &err, &errlen) != 0 || err != 0) {
      close(fd);
      return -1;
    }
  } }
  return fd;
}

/**
 * See implementation.
 */
export function net_tcp_listen_ipv6_c(addr_16: *u8, port_u32: u32): i32 {
  let sin_mem: u8[28] = [];
  let sin_ptr: *u8 = net_ipv6_sin_buf_ptr_c(&sin_mem[0]);
  let fd: i32 = 0;
  let one: i32 = 1;
  if (net_ipv6_maybe_wsa_fail_c() != 0) {
    return -1;
  }
  if (addr_16 == 0) {
    return -1;
  }
  unsafe { net_ipv6_set_addr_port_buf_c(sin_ptr, addr_16, port_u32); }
  unsafe { fd = socket(AF_INET6, SOCK_STREAM, IPPROTO_TCP); }
  if (fd < 0) {
    return -1;
  }
  unsafe { setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &one, 4 as u32); }
  unsafe { if (bind(fd, sin_ptr, SOCKADDR_IN6_SIZE) != 0) {
    close(fd);
    return -1;
  } }
  unsafe { if (listen(fd, 128) != 0) {
    close(fd);
    return -1;
  } }
  if (net_ipv6_set_nonblock_c(fd) != 0) {
    unsafe { close(fd); }
    return -1;
  }
  return fd;
}
