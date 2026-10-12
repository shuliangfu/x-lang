// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_net_addr_fast_linux.x — Linux sockaddr helpers for net_addr_fast.o.
// sockaddr_in: sin_family u16@0 (AF_INET=2), sin_port@2, sin_addr@4.
// PLATFORM: LINUX.

extern "C" function malloc(n: i64): *u8;
extern "C" function free(p: *u8): void;
extern "C" function memset(d: *u8, c: i32, n: i64): *u8;
extern "C" function getsockname(fd: i32, addr: *u8, len: *i32): i32;
extern "C" function getpeername(fd: i32, addr: *u8, len: *i32): i32;
extern "C" function net_sockaddr_in_pack_addr_port_c(sin_ptr: *u8): i64;

#[no_mangle]
export function net_tcp_set_addr_port_buf_c(sin: *u8, addr_u32: u32, port_u32: u32): void {
  let port: i32 = (port_u32 & 65535) as i32;
  let addr: i32 = addr_u32 as i32;
  sin[0] = 2;
  sin[1] = 0;
  sin[2] = ((port >> 8) & 255) as u8;
  sin[3] = (port & 255) as u8;
  sin[4] = ((addr >> 24) & 255) as u8;
  sin[5] = ((addr >> 16) & 255) as u8;
  sin[6] = ((addr >> 8) & 255) as u8;
  sin[7] = (addr & 255) as u8;
  let i: i32 = 8;
  while (i < 16) {
    sin[i] = 0;
    i = i + 1;
  }
}

#[no_mangle]
export function net_udp_set_addr_port_buf_c(sin: *u8, addr_u32: u32, port_u32: u32): void {
  net_tcp_set_addr_port_buf_c(sin, addr_u32, port_u32);
}

#[no_mangle]
export function net_tcp_local_addr_c(fd: i32): i64 {
  let p: *u8 = 0 as *u8;
  let len: i32 = 16;
  let rc: i32 = 0;
  unsafe { p = malloc(16); }
  if (p == (0 as *u8)) { return (0 - 1) as i64; }
  unsafe { memset(p, 0, 16); }
  unsafe { rc = getsockname(fd, p, &len); }
  if (rc != 0) {
    unsafe { free(p); }
    return (0 - 1) as i64;
  }
  let v: i64 = 0;
  unsafe { v = net_sockaddr_in_pack_addr_port_c(p); }
  unsafe { free(p); }
  return v;
}

#[no_mangle]
export function net_tcp_peer_addr_c(fd: i32): i64 {
  let p: *u8 = 0 as *u8;
  let len: i32 = 16;
  let rc: i32 = 0;
  unsafe { p = malloc(16); }
  if (p == (0 as *u8)) { return (0 - 1) as i64; }
  unsafe { memset(p, 0, 16); }
  unsafe { rc = getpeername(fd, p, &len); }
  if (rc != 0) {
    unsafe { free(p); }
    return (0 - 1) as i64;
  }
  let v: i64 = 0;
  unsafe { v = net_sockaddr_in_pack_addr_port_c(p); }
  unsafe { free(p); }
  return v;
}
