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
/**
 * Address family for IPv6 DNS hints (`AF_INET6`).
 * PLATFORM: LINUX=10 / MACOS=30 / WINDOWS=23 — same ABI table as std.url /
 * std.net.ipv6; Linux-only 10 breaks Darwin getaddrinfo IPv6 family checks.
 */
#[cfg(target_os = "linux")]
export const AF_INET6: i32 = 10;
#[cfg(target_os = "macos")]
export const AF_INET6: i32 = 30;
#[cfg(target_os = "windows")]
export const AF_INET6: i32 = 23;
export const SOCK_STREAM: i32 = 1;

/* See implementation. */
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

/* See implementation. */
allow(padding) struct SockAddrIn {
  sin_family: u16;
  sin_port: u16;
  sin_addr: u32;
}

/* See implementation. */
allow(padding) struct SockAddrIn6 {
  sin6_family: u16;
  sin6_port: u16;
  sin6_flowinfo: u32;
  sin6_addr: u8[16];
}

/** Exported function `net_dns_ai_addconfig_c`.
 * Implements `net_dns_ai_addconfig_c`.
 * @return i32
 */
#[cfg(target_os = "linux")]
export function net_dns_ai_addconfig_c(): i32 {
  return 32;
}

/** Exported function `net_dns_ai_addconfig_c`.
 * Implements `net_dns_ai_addconfig_c`.
 * @return i32
 */
#[cfg(not(target_os = "linux"))]
export function net_dns_ai_addconfig_c(): i32 {
  return 1024;
}

/**
 * Cap residual 9.1.7 slice2: DNS resolve faces (body in runtime_net_dns_fast).
 * Linux Cap has no libc getaddrinfo; Windows still uses Winsock in the C twin.
 * PLATFORM: SHARED export name / LINUX Cap body.
 */
extern "C" function xlang_dns_cap_resolve_ipv4(hostname: *u8, out_addr: *u32, out_err: *i32): i32;
extern "C" function xlang_dns_cap_resolve_ipv6(hostname: *u8, out_addr_16: *u8, out_err: *i32): i32;

#[cfg(target_os = "windows")]
extern "C" function WSAStartup(wVersionRequested: u16, lpWSAData: *u8): i32;

#[cfg(target_os = "windows")]
let net_dns_wsa_done: i32 = 0;

/**
 * See implementation.
 * See implementation.
 * See implementation.
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
 * See implementation.
 */
#[cfg(target_os = "linux")]
export function net_map_gai_error_c(err: i32): i32 {
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

/** Exported function `net_map_gai_error_c`.
 * Implements `net_map_gai_error_c`.
 * @param err i32
 * @return i32
 */
#[cfg(target_os = "macos")]
export function net_map_gai_error_c(err: i32): i32 {
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

/** Exported function `net_map_gai_error_c`.
 * Implements `net_map_gai_error_c`.
 * @param err i32
 * @return i32
 */
#[cfg(target_os = "windows")]
export function net_map_gai_error_c(err: i32): i32 {
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
 * See implementation.
 */
export function net_dns_zero_hints_buf_c(hints: *u8): void {
  let i: i32 = 0;
  while (i < 48) {
    hints[i] = 0;
    i = i + 1;
  }
}

/**
 * See implementation.
 */
export function net_dns_fill_hints_inet_c(hints: *u8, family: i32, flags: i32): void {
  let p_flags: *i32 = (hints + 0) as *i32;
  let p_family: *i32 = (hints + 4) as *i32;
  let p_socktype: *i32 = (hints + 8) as *i32;
  net_dns_zero_hints_buf_c(hints);
  p_family[0] = family;
  p_socktype[0] = SOCK_STREAM;
  p_flags[0] = flags;
}

/**
 * See implementation.
 * See implementation.
 */
#[cfg(target_os = "windows")]
function net_dns_maybe_wsa_fail_c(): i32 {
  if (net_dns_ensure_wsa_c() != 0) {
    return -1;
  }
  return 0;
}

/** Exported function `net_dns_maybe_wsa_fail_c`.
 * Implements `net_dns_maybe_wsa_fail_c`.
 * @return i32
 */
#[cfg(not(target_os = "windows"))]
export function net_dns_maybe_wsa_fail_c(): i32 {
  return 0;
}

/**
 * See implementation.
 */
export function net_resolve_ipv4_c(hostname: *u8): u32 {
  let addr: u32 = 0;
  let err: i32 = 0;
  if (net_resolve_ipv4_ex_c(hostname, &addr, &err) != 0) {
    return 0 as u32;
  }
  return addr;
}

/**
 * Resolve hostname to IPv4 (host-order u32).
 * Cap residual 9.1.7 slice2: delegates to xlang_dns_cap_resolve_ipv4 (no getaddrinfo).
 * @param hostname NUL-C host; null rejected
 * @param out_addr host-order IPv4 or 0
 * @param out_err product map 0/1/2/3/4
 * @return 0 ok, -1 fail
 * PLATFORM: SHARED contract / LINUX Cap body in dns_fast
 */
export function net_resolve_ipv4_ex_c(hostname: *u8, out_addr: *u32, out_err: *i32): i32 {
  if (net_dns_maybe_wsa_fail_c() != 0) {
    if (out_addr != 0) { out_addr[0] = 0; }
    if (out_err != 0) { out_err[0] = 4; }
    return -1;
  }
  unsafe {
    return xlang_dns_cap_resolve_ipv4(hostname, out_addr, out_err);
  }
}

/**
 * Resolve hostname to IPv6 (16 network-order bytes).
 * Cap residual 9.1.7 slice2: delegates to xlang_dns_cap_resolve_ipv6 (no getaddrinfo).
 * @param hostname NUL-C host; null rejected
 * @param out_addr_16 16-byte buffer
 * @param out_err product map 0/1/2/3/4
 * @return 0 ok, -1 fail
 * PLATFORM: SHARED contract / LINUX Cap body in dns_fast
 */
export function net_resolve_ipv6_ex_c(hostname: *u8, out_addr_16: *u8, out_err: *i32): i32 {
  if (net_dns_maybe_wsa_fail_c() != 0) {
    if (out_err != 0) { out_err[0] = 4; }
    return -1;
  }
  if (hostname == 0 || out_addr_16 == 0) {
    if (out_err != 0) { out_err[0] = 4; }
    return -1;
  }
  unsafe {
    return xlang_dns_cap_resolve_ipv6(hostname, out_addr_16, out_err);
  }
}
