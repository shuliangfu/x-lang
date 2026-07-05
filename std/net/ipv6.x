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

// std.net.ipv6 — F-04 v11：IPv6 TCP connect/listen
//
// 【文件职责】
// 从 net.c 迁出 net_tcp_connect_ipv6_c / net_tcp_listen_ipv6_c。
//
// 【依赖】libc socket/connect/bind/listen；Unix poll/fcntl，Windows select/ioctlsocket

const mem = import("core.mem");

const AF_INET6: i32 = 10;
const SOCK_STREAM: i32 = 1;
const IPPROTO_TCP: i32 = 6;
const SOL_SOCKET: i32 = 1;
const SO_REUSEADDR: i32 = 2;
const SO_ERROR: i32 = 4;
const O_NONBLOCK: i32 = 2048;
const POLLOUT: i16 = 4;
const POLLIN: i16 = 1;
const POLLERR: i16 = 8;
const POLLHUP: i16 = 16;
const SOCKADDR_IN6_SIZE: u32 = 28;

/** EINPROGRESS / EAGAIN（平台 errno）。 */
#[cfg(target_os = "linux")]
const ERR_INPROGRESS: i32 = 115;

#[cfg(target_os = "linux")]
const ERR_EAGAIN: i32 = 11;

#[cfg(target_os = "macos")]
const ERR_INPROGRESS: i32 = 36;

#[cfg(target_os = "macos")]
const ERR_EAGAIN: i32 = 35;

/** IPv6 sockaddr 前缀（布局文档；实现用 u8 缓冲 + 偏移访问）。 */
allow(padding) struct SockAddrIn6 {
  sin6_family: u16;
  sin6_port: u16;
  sin6_flowinfo: u32;
  sin6_addr: u8[16];
}

/** Unix pollfd（布局文档；实现用 u8 缓冲 + 偏移访问）。 */
#[cfg(not(target_os = "windows"))]
allow(padding) struct PollFd { fd: i32; events: i16; revents: i16; }

extern function socket(domain: i32, type: i32, protocol: i32): i32;
extern function connect(fd: i32, addr: *u8, addrlen: u32): i32;
extern function bind(fd: i32, addr: *u8, addrlen: u32): i32;
extern function listen(fd: i32, backlog: i32): i32;
extern function setsockopt(fd: i32, level: i32, optname: i32, optval: *i32, optlen: u32): i32;
extern function getsockopt(fd: i32, level: i32, optname: i32, optval: *i32, optlen: *u32): i32;
extern function close(fd: i32): i32;
extern function htons(hostshort: u16): u16;

#[cfg(not(target_os = "windows"))]
extern function fcntl(fd: i32, cmd: i32, arg: i32): i32;

#[cfg(not(target_os = "windows"))]
extern function poll(fds: *u8, nfds: u64, timeout: i32): i32;

#[cfg(target_os = "linux")]
extern function __errno_location(): *i32;

#[cfg(target_os = "macos")]
extern function __error(): *i32;

/** 平台无关 errno 指针获取：Linux 走 __errno_location，macOS/BSD 走 __error。
 * 【Why 根源治理】原 `#[cfg(not(windows))] extern __errno_location` 在 macOS 链接失败：
 * __errno_location 是 glibc 符号，macOS 用 __error()。错误 cfg 导致 net.o 引用
 * undefined `___errno_location`，~75 个测试链接失败。 */
#[cfg(target_os = "linux")]
function net_ipv6_errno_ptr(): *i32 {
  let p: *i32 = 0 as *i32;
  unsafe { p = __errno_location(); }
  return p;
}

#[cfg(target_os = "macos")]
function net_ipv6_errno_ptr(): *i32 {
  let p: *i32 = 0 as *i32;
  unsafe { p = __error(); }
  return p;
}

#[cfg(target_os = "windows")]
extern function WSAStartup(wVersionRequested: u16, lpWSAData: *u8): i32;

#[cfg(target_os = "windows")]
extern function ioctlsocket(fd: i32, cmd: i32, arg: *u32): i32;

#[cfg(target_os = "windows")]
extern function closesocket(fd: i32): i32;

#[cfg(target_os = "windows")]
let net_ipv6_wsa_done: i32 = 0;

/**
 * Windows：一次性 WSAStartup。
 */
#[cfg(target_os = "windows")]
function net_ipv6_ensure_wsa_c(): i32 {
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
 * Windows：连接前确保 WSA；非 Windows 恒为 0（顶层 cfg，避免函数体内 #[cfg] parse skip）。
 */
#[cfg(target_os = "windows")]
function net_ipv6_maybe_wsa_fail_c(): i32 {
  if (net_ipv6_ensure_wsa_c() != 0) {
    return -1;
  }
  return 0;
}

#[cfg(not(target_os = "windows"))]
function net_ipv6_maybe_wsa_fail_c(): i32 {
  return 0;
}

/**
 * 取栈上缓冲首地址（seed emit 不支持 call 实参内联 &buf[0]，经 helper 传递）。
 */
function net_ipv6_sin_buf_ptr_c(p: *u8): *u8 {
  return p;
}

/** IPv6 sockaddr 填充；实现见 net_import_alias.c（规避 asm u16 间接 store codegen 缺陷）。 */
extern function net_ipv6_set_addr_port_buf_c(sin: *u8, addr_16: *u8, port_u32: u32): void;

/**
 * 设 socket 非阻塞（Unix）。
 */
#[cfg(not(target_os = "windows"))]
function net_ipv6_set_nonblock_c(fd: i32): i32 {
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
 * 设 socket 非阻塞（Windows）。
 */
#[cfg(target_os = "windows")]
function net_ipv6_set_nonblock_c(fd: i32): i32 {
  let one: u32 = 1;
  unsafe { if (ioctlsocket(fd, (0x80000000 | 0x40000000) as i32, &one) == 0) {
    return 0;
  } }
  return -1;
}

/**
 * poll 可写直至 timeout_ms（Unix）。
 */
#[cfg(not(target_os = "windows"))]
function net_ipv6_poll_writable_c(fd: i32, timeout_ms: u32): i32 {
  let pfd_mem: u8[8] = [];
  let pfd_ptr: *u8 = net_ipv6_sin_buf_ptr_c(&pfd_mem[0]);
  let p_fd: *i32 = (pfd_ptr + 0) as *i32;
  let p_events: *i16 = (pfd_ptr + 4) as *i16;
  let p_revents: *i16 = (pfd_ptr + 6) as *i16;
  let n: i32 = 0;
  p_fd[0] = fd;
  p_events[0] = POLLOUT;
  p_revents[0] = 0 as i16;
  unsafe { n = poll(pfd_ptr, 1 as u64, timeout_ms as i32); }
  if (n <= 0 || (p_revents[0] & (POLLERR | POLLHUP)) != 0) {
    return -1;
  }
  return 0;
}

/**
 * poll 可写（Windows 桩：恒成功）。
 */
#[cfg(target_os = "windows")]
function net_ipv6_poll_writable_c(fd: i32, timeout_ms: u32): i32 {
  return 0;
}

/**
 * connect 失败时是否可继续等待（Unix：EINPROGRESS / EAGAIN）。
 */
#[cfg(not(target_os = "windows"))]
function net_ipv6_connect_retry_ok_c(): i32 {
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
 * connect 失败时是否可继续等待（Windows：非阻塞 connect 走 poll 路径）。
 */
#[cfg(target_os = "windows")]
function net_ipv6_connect_retry_ok_c(): i32 {
  return 1;
}

/**
 * TCP 连接 IPv6 addr:port；非阻塞 fd，失败 -1。
 */
function net_tcp_connect_ipv6_c(addr_16: *u8, port_u32: u32, timeout_ms: u32): i32 {
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
 * IPv6 TCP 监听；非阻塞 listener fd，失败 -1。
 */
function net_tcp_listen_ipv6_c(addr_16: *u8, port_u32: u32): i32 {
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
