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

// std.net.dns — F-04 v10：DNS 解析（getaddrinfo FFI）
//
// 【文件职责】
// 从 net.c 迁出 net_resolve_ipv4_c / net_resolve_ipv4_ex_c / net_resolve_ipv6_ex_c。
//
// 【依赖】libc getaddrinfo/freeaddrinfo；Unix + Windows hosted。

const AF_INET: i32 = 2;
const AF_INET6: i32 = 10;
const SOCK_STREAM: i32 = 1;

/** getaddrinfo hints / result 布局（64-bit hosted ABI）。 */
allow(padding) struct AddrInfoHints {
  ai_flags: i32;
  ai_family: i32;
  ai_socktype: i32;
  ai_protocol: i32;
  ai_addrlen: u32;
  ai_addr: *u8;
  ai_canonname: *u8;
  ai_next: *u8;
}

allow(padding) struct AddrInfo {
  ai_flags: i32;
  ai_family: i32;
  ai_socktype: i32;
  ai_protocol: i32;
  ai_addrlen: u32;
  ai_addr: *u8;
  ai_canonname: *u8;
  ai_next: *AddrInfo;
}

/** IPv4 sockaddr 前缀（sin_addr 为网络序 u32）。 */
allow(padding) struct SockAddrIn {
  sin_family: u16;
  sin_port: u16;
  sin_addr: u32;
}

/** IPv6 sockaddr 前缀（sin6_addr 16 字节）。 */
allow(padding) struct SockAddrIn6 {
  sin6_family: u16;
  sin6_port: u16;
  sin6_flowinfo: u32;
  sin6_addr: u8[16];
}

/** 平台 AI_ADDRCONFIG 标志（分函数返回，避免多 cfg 同名 const 触发 typeck 异常）。 */
#[cfg(target_os = "linux")]
function net_dns_ai_addconfig_c(): i32 {
  return 32;
}

#[cfg(not(target_os = "linux"))]
function net_dns_ai_addconfig_c(): i32 {
  return 1024;
}

extern function getaddrinfo(node: *u8, service: *u8, hints_in: *u8, res: * *u8): i32;
extern function freeaddrinfo(res: *AddrInfo): void;
extern function ntohl(netlong: u32): u32;

#[cfg(target_os = "windows")]
extern function WSAStartup(wVersionRequested: u16, lpWSAData: *u8): i32;

#[cfg(target_os = "windows")]
let net_dns_wsa_done: i32 = 0;

/**
 * Windows：一次性 WSAStartup。
 */
#[cfg(target_os = "windows")]
function net_dns_ensure_wsa_c(): i32 {
  let rc: i32 = 0;
  if (net_dns_wsa_done != 0) {
    return 0;
  }
  unsafe { rc = WSAStartup(514 as u16, 0 as *u8); }
  if (rc != 0) {
    return -1;
  }
  net_dns_wsa_done = 1;
  return 0;
}

/**
 * 将 getaddrinfo 错误映射为 STD-029 resolve_err_* 常量。
 */
#[cfg(target_os = "linux")]
function net_map_gai_error_c(err: i32): i32 {
  if (err == (0 - 2)) {
    return 1;
  }
  if (err == (0 - 5)) {
    return 2;
  }
  if (err == (0 - 3)) {
    return 3;
  }
  return 4;
}

#[cfg(target_os = "macos")]
function net_map_gai_error_c(err: i32): i32 {
  if (err == 8) {
    return 1;
  }
  if (err == 7) {
    return 2;
  }
  if (err == 2) {
    return 3;
  }
  return 4;
}

#[cfg(target_os = "windows")]
function net_map_gai_error_c(err: i32): i32 {
  if (err == 11001) {
    return 1;
  }
  if (err == 11004) {
    return 2;
  }
  if (err == 11002) {
    return 3;
  }
  return 4;
}

/**
 * 清零 AddrInfoHints（48 字节 hosted 布局）。
 */
function net_dns_zero_hints_buf_c(hints: *u8): void {
  let i: i32 = 0;
  while (i < 48) {
    hints[i] = 0;
    i = i + 1;
  }
}

/**
 * 在 hints 缓冲（48 字节）写入 ai_flags / ai_family / ai_socktype（避免 let 初始化中的 as 触发 emit 失败）。
 */
function net_dns_fill_hints_inet_c(hints: *u8, family: i32, flags: i32): void {
  let p_flags: *i32 = (hints + 0) as *i32;
  let p_family: *i32 = (hints + 4) as *i32;
  let p_socktype: *i32 = (hints + 8) as *i32;
  net_dns_zero_hints_buf_c(hints);
  p_family[0] = family;
  p_socktype[0] = SOCK_STREAM;
  p_flags[0] = flags;
}

/**
 * Windows：解析前确保 WSA；非 Windows 恒为 0（顶层 cfg，避免函数体内 #[cfg] 触发 parse skip）。
 */
#[cfg(target_os = "windows")]
function net_dns_maybe_wsa_fail_c(): i32 {
  if (net_dns_ensure_wsa_c() != 0) {
    return -1;
  }
  return 0;
}

#[cfg(not(target_os = "windows"))]
function net_dns_maybe_wsa_fail_c(): i32 {
  return 0;
}

/**
 * hostname 解析为 IPv4 addr_u32；失败返回 0。
 */
function net_resolve_ipv4_c(hostname: *u8): u32 {
  let addr: u32 = 0;
  let err: i32 = 0;
  if (net_resolve_ipv4_ex_c(hostname, &addr, &err) != 0) {
    return 0 as u32;
  }
  return addr;
}

/**
 * 可诊断 IPv4 DNS：成功 0 + *out_addr；失败 -1 + resolve_err_*。
 */
function net_resolve_ipv4_ex_c(hostname: *u8, out_addr: *u32, out_err: *i32): i32 {
  let hints_mem: u8[48] = [];
  let res_head: *u8 = 0 as *u8;
  let res: *AddrInfo = 0 as *AddrInfo;
  let ga: i32 = 0;
  let addr_u32: u32 = 0;
  let sa: *SockAddrIn = 0 as *SockAddrIn;
  let rp: *AddrInfo = 0 as *AddrInfo;
  if (net_dns_maybe_wsa_fail_c() != 0) {
    if (out_addr != 0) { out_addr[0] = 0; }
    if (out_err != 0) { out_err[0] = 4; }
    return -1;
  }
  if (hostname == 0) {
    if (out_addr != 0) { out_addr[0] = 0; }
    if (out_err != 0) { out_err[0] = 4; }
    return -1;
  }
  net_dns_fill_hints_inet_c(&hints_mem[0], AF_INET, net_dns_ai_addconfig_c());
  unsafe { ga = getaddrinfo(hostname, 0 as *u8, &hints_mem[0], &res_head); }
  res = res_head as *AddrInfo;
  if (ga != 0 || res == 0) {
    if (out_addr != 0) { out_addr[0] = 0; }
    if (out_err != 0) { out_err[0] = net_map_gai_error_c(ga); }
    if (res != 0) { unsafe { freeaddrinfo(res); } }
    return -1;
  }
  rp = res;
  if (rp.ai_family == AF_INET && rp.ai_addr != 0 && rp.ai_addrlen >= 16 as u32) {
    sa = rp.ai_addr as *SockAddrIn;
    unsafe { addr_u32 = ntohl(sa.sin_addr); }
  }
  unsafe { freeaddrinfo(res); }
  if (addr_u32 == 0) {
    if (out_addr != 0) { out_addr[0] = 0; }
    if (out_err != 0) { out_err[0] = 2; }
    return -1;
  }
  if (out_addr != 0) { out_addr[0] = addr_u32; }
  if (out_err != 0) { out_err[0] = 0; }
  return 0;
}

/**
 * 可诊断 IPv6 DNS：成功 0 + out_addr_16；失败 -1 + resolve_err_*。
 */
function net_resolve_ipv6_ex_c(hostname: *u8, out_addr_16: *u8, out_err: *i32): i32 {
  let hints_mem: u8[48] = [];
  let res_head: *u8 = 0 as *u8;
  let res: *AddrInfo = 0 as *AddrInfo;
  let ga: i32 = 0;
  let sa6: *SockAddrIn6 = 0 as *SockAddrIn6;
  let rp: *AddrInfo = 0 as *AddrInfo;
  if (net_dns_maybe_wsa_fail_c() != 0) {
    if (out_err != 0) { out_err[0] = 4; }
    return -1;
  }
  if (hostname == 0 || out_addr_16 == 0) {
    if (out_err != 0) { out_err[0] = 4; }
    return -1;
  }
  let i0: i32 = 0;
  while (i0 < 16) {
    out_addr_16[i0] = 0;
    i0 = i0 + 1;
  }
  net_dns_fill_hints_inet_c(&hints_mem[0], AF_INET6, net_dns_ai_addconfig_c());
  unsafe { ga = getaddrinfo(hostname, 0 as *u8, &hints_mem[0], &res_head); }
  res = res_head as *AddrInfo;
  if (ga != 0 || res == 0) {
    if (out_err != 0) { out_err[0] = net_map_gai_error_c(ga); }
    if (res != 0) { unsafe { freeaddrinfo(res); } }
    return -1;
  }
  rp = res;
  if (rp.ai_family == AF_INET6 && rp.ai_addr != 0 && rp.ai_addrlen >= 28 as u32) {
    sa6 = rp.ai_addr as *SockAddrIn6;
    let i1: i32 = 0;
    while (i1 < 16) {
      out_addr_16[i1] = sa6.sin6_addr[i1];
      i1 = i1 + 1;
    }
  } else {
    if (out_err != 0) { out_err[0] = 2; }
    unsafe { freeaddrinfo(res); }
    return -1;
  }
  unsafe { freeaddrinfo(res); }
  if (out_err != 0) { out_err[0] = 0; }
  return 0;
}
