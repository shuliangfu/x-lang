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

export const AF_INET: i32 = 2;

/* See implementation. */
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
 * See implementation.
 */
export function net_sockaddr_in_buf_ptr_c(p: *u8): *u8 {
  return p;
}

/**
 * See implementation.
 */
export function net_sockaddr_in_pack_addr_port_c(sin_ptr: *u8): i64 {
  let p_port: *u16 = (sin_ptr + 2) as *u16;
  let p_addr: *u32 = (sin_ptr + 4) as *u32;
  let a: u32 = 0;
  let p: u32 = 0;
  unsafe { a = ntohl(p_addr[0]); }
  unsafe { p = ntohs(p_port[0]) as u32; }
  return ((a as i64) << 32) | (p & 0xffff) as i64;
}

/**
 * See implementation.
 */
#[cfg(not(target_os = "windows"))]
export function net_tcp_local_addr_c(fd: i32): i64 {
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

/** Exported function `net_tcp_local_addr_c`.
 * Implements `net_tcp_local_addr_c`.
 * @param fd i32
 * @return i64
 */
#[cfg(target_os = "windows")]
export function net_tcp_local_addr_c(fd: i32): i64 {
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
 * See implementation.
 */
#[cfg(not(target_os = "windows"))]
export function net_tcp_peer_addr_c(fd: i32): i64 {
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

/** Exported function `net_tcp_peer_addr_c`.
 * Implements `net_tcp_peer_addr_c`.
 * @param fd i32
 * @return i64
 */
#[cfg(target_os = "windows")]
export function net_tcp_peer_addr_c(fd: i32): i64 {
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
