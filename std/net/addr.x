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

// std.net.addr — F-04 v11：TCP local/peer 地址查询
//
// 【文件职责】
// 从 net.c 迁出 net_tcp_local_addr_c / net_tcp_peer_addr_c。
//
// 【依赖】libc getsockname/getpeername、ntohl/ntohs

const AF_INET: i32 = 2;

/** IPv4 sockaddr 前缀（sin_addr 网络序 u32）。 */
allow(padding) struct SockAddrIn {
  sin_family: u16;
  sin_port: u16;
  sin_addr: u32;
}

extern "C" function ntohl(netlong: u32): u32;
extern "C" function ntohs(netshort: u16): u16;

#[cfg(not(target_os = "windows"))]
extern "C" function getsockname(fd: i32, addr: *u8, addrlen: *u32): i32;

#[cfg(not(target_os = "windows"))]
extern "C" function getpeername(fd: i32, addr: *u8, addrlen: *u32): i32;

#[cfg(target_os = "windows")]
extern "C" function getsockname(fd: i32, addr: *u8, addrlen: *i32): i32;

#[cfg(target_os = "windows")]
extern "C" function getpeername(fd: i32, addr: *u8, addrlen: *i32): i32;

/**
 * 取栈上 sockaddr 缓冲首地址（seed emit 不支持 call 实参内联 &buf[0]，经 helper 传递）。
 */
function net_sockaddr_in_buf_ptr_c(p: *u8): *u8 {
  return p;
}

/**
 * 从 16 字节 sockaddr_in 缓冲读取 addr/port 并打包为 (addr_u32<<32)|port_u32。
 */
function net_sockaddr_in_pack_addr_port_c(sin_ptr: *u8): i64 {
  let p_port: *u16 = (sin_ptr + 2) as *u16;
  let p_addr: *u32 = (sin_ptr + 4) as *u32;
  let a: u32 = 0;
  let p: u32 = 0;
  unsafe { a = ntohl(p_addr[0]); }
  unsafe { p = ntohs(p_port[0]) as u32; }
  return ((a as i64) << 32) | (p & 0xffff) as i64;
}

/**
 * 获取 TCP 本地地址与端口；成功 (addr_u32<<32)|port_u32，失败 -1。
 */
#[cfg(not(target_os = "windows"))]
function net_tcp_local_addr_c(fd: i32): i64 {
  let sin_mem: u8[16] = [];
  let len: u32 = 16;
  let sin_ptr: *u8 = net_sockaddr_in_buf_ptr_c(&sin_mem[0]);
  let rc: i32 = 0;
  unsafe { rc = getsockname(fd, sin_ptr, &len); }
  if (rc != 0) {
    return (0 - 1) as i64;
  }
  return net_sockaddr_in_pack_addr_port_c(sin_ptr);
}

#[cfg(target_os = "windows")]
function net_tcp_local_addr_c(fd: i32): i64 {
  let sin_mem: u8[16] = [];
  let len_i: i32 = 16;
  let sin_ptr: *u8 = net_sockaddr_in_buf_ptr_c(&sin_mem[0]);
  let rc: i32 = 0;
  unsafe { rc = getsockname(fd, sin_ptr, &len_i); }
  if (rc != 0) {
    return (0 - 1) as i64;
  }
  return net_sockaddr_in_pack_addr_port_c(sin_ptr);
}

/**
 * 获取 TCP 远端地址与端口；成功 (addr_u32<<32)|port_u32，失败 -1。
 */
#[cfg(not(target_os = "windows"))]
function net_tcp_peer_addr_c(fd: i32): i64 {
  let sin_mem: u8[16] = [];
  let len: u32 = 16;
  let sin_ptr: *u8 = net_sockaddr_in_buf_ptr_c(&sin_mem[0]);
  let rc: i32 = 0;
  unsafe { rc = getpeername(fd, sin_ptr, &len); }
  if (rc != 0) {
    return (0 - 1) as i64;
  }
  return net_sockaddr_in_pack_addr_port_c(sin_ptr);
}

#[cfg(target_os = "windows")]
function net_tcp_peer_addr_c(fd: i32): i64 {
  let sin_mem: u8[16] = [];
  let len_i: i32 = 16;
  let sin_ptr: *u8 = net_sockaddr_in_buf_ptr_c(&sin_mem[0]);
  let rc: i32 = 0;
  unsafe { rc = getpeername(fd, sin_ptr, &len_i); }
  if (rc != 0) {
    return (0 - 1) as i64;
  }
  return net_sockaddr_in_pack_addr_port_c(sin_ptr);
}
