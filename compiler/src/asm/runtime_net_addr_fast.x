// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// G-02f-102：+ sockaddr pack。
// See implementation.
// runtime_net_addr_fast_x_doc_anchor: see function docblock below.

/** Exported function `runtime_net_addr_fast_x_doc_anchor`.
 * Implements `runtime_net_addr_fast_x_doc_anchor`.
 * @return i32
 */
export function runtime_net_addr_fast_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-151：net addr pack ---- */

// net_sockaddr_in_pack_addr_port_c: see function docblock below.
/** Exported function `net_sockaddr_in_pack_addr_port_c`.
 * Implements `net_sockaddr_in_pack_addr_port_c`.
 * @param sin_ptr *u8
 * @return i64
 */
#[no_mangle]
export function net_sockaddr_in_pack_addr_port_c(sin_ptr: *u8): i64 {
  if (sin_ptr == 0) { return 0; }
  // See implementation.
  let p0: u32 = sin_ptr[2] as u32;
  let p1: u32 = sin_ptr[3] as u32;
  let port: u32 = p0 * 256 + p1;
  port = port & 65535;
  // See implementation.
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
