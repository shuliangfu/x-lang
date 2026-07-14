// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-20：runtime_net_addr_fast 产品源迁 seeds/runtime_net_addr_fast.from_x.c。
// G-02f-102：+ sockaddr pack。
// G-02f-151：net_sockaddr_in_pack_addr_port_c 真迁 .x
// sin_port@2 / sin_addr@4 网络序（Linux 与 Darwin 一致；Darwin 另有 sin_len@0）

export function runtime_net_addr_fast_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-151：net addr pack ---- */

// 网络序 u16/u32 → 主机序，再 pack (addr<<32)|port；避免 << 用 *4294967296
#[no_mangle]
export function net_sockaddr_in_pack_addr_port_c(sin_ptr: *u8): i64 {
  if (sin_ptr == 0) { return 0; }
  // sin_port 网络序 @2
  let p0: u32 = sin_ptr[2] as u32;
  let p1: u32 = sin_ptr[3] as u32;
  let port: u32 = p0 * 256 + p1;
  port = port & 65535;
  // sin_addr 网络序 @4
  let a0: u32 = sin_ptr[4] as u32;
  let a1: u32 = sin_ptr[5] as u32;
  let a2: u32 = sin_ptr[6] as u32;
  let a3: u32 = sin_ptr[7] as u32;
  let addr: u32 = a0 * 16777216 + a1 * 65536 + a2 * 256 + a3;
  let hi: i64 = addr as i64;
  let lo: i64 = port as i64;
  // (addr << 32) | port
  return hi * 4294967296 + lo;
}
