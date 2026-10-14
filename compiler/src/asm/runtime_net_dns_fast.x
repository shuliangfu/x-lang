// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_net_dns_fast.x — Darwin|Linux pure-asm faces for net_dns_fast.o.
// Cap residual 9.1.7: this file calls xlang_dns_cap_resolve_*. The bodies
// stay in seeds/runtime_net_dns_fast.from_x.c (xlang_dns_cap.h). The Darwin
// and Linux product object ld -r's that export-only seed so the two names
// are defined. std/net/dns.x uses the same extern contract.
// PLATFORM: SHARED faces. MACOS|DARWIN|LINUX pure-asm + C cap export.

extern "C" function xlang_dns_cap_resolve_ipv4(hostname: *u8, out_addr: *u32, out_err: *i32): i32;
extern "C" function xlang_dns_cap_resolve_ipv6(hostname: *u8, out_addr_16: *u8, out_err: *i32): i32;

/** Anchor for codegen discovery of this TU. @return i32 always 0 */
#[no_mangle]
export function runtime_net_dns_fast_x_doc_anchor(): i32 {
  return 0;
}

#[cfg(target_os = "linux")]
#[no_mangle]
export function net_dns_ai_addconfig_c(): i32 {
  return 32;
}

#[cfg(not(target_os = "linux"))]
#[no_mangle]
export function net_dns_ai_addconfig_c(): i32 {
  return 1024;
}

#[no_mangle]
export function net_dns_map_gai_error_c(err: i32): i32 {
  if (err == 1) { return 1; }
  if (err == 2) { return 2; }
  if (err == 3) { return 3; }
  return 4;
}

#[no_mangle]
export function net_dns_ensure_wsa_c(): i32 {
  return 0;
}

#[no_mangle]
export function net_resolve_ipv4_c(hostname: *u8): u32 {
  let addr: u32 = 0;
  let err: i32 = 0;
  if (net_resolve_ipv4_ex_c(hostname, &addr, &err) != 0) {
    return 0 as u32;
  }
  return addr;
}

#[no_mangle]
export function net_resolve_ipv4_ex_c(hostname: *u8, out_addr: *u32, out_err: *i32): i32 {
  unsafe {
    return xlang_dns_cap_resolve_ipv4(hostname, out_addr, out_err);
  }
}

#[no_mangle]
export function net_resolve_ipv6_ex_c(hostname: *u8, out_addr_16: *u8, out_err: *i32): i32 {
  unsafe {
    return xlang_dns_cap_resolve_ipv6(hostname, out_addr_16, out_err);
  }
}
