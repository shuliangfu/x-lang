// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Shared sockaddr pack. Darwin arm64 local, peer, and setters live in
// runtime_net_addr_fast_darwin.x. Linux and Windows keep the C seed
// for those four functions. The pack shifts by 32; a multiply by 2^32
// is folded to 0 by the asm backend.
// PLATFORM: SHARED pack. MACOS|DARWIN arm64 setters are the other file.
// runtime_net_addr_fast_x_doc_anchor: see function docblock below.

/** Exported function `runtime_net_addr_fast_x_doc_anchor`.
 * Implements `runtime_net_addr_fast_x_doc_anchor`.
 * @return i32
 */
export function runtime_net_addr_fast_x_doc_anchor(): i32 {
  return 0;
}

/* ---- sockaddr_in pack: port at bytes 2..3, addr at bytes 4..7 ---- */

/** Pack a sockaddr_in into (addr << 32) | port.
 * Both Linux and Darwin keep sin_port at offset 2 and sin_addr at offset 4,
 * so the same byte reads serve both. A null buffer returns 0.
 * The shift is required: the literal 2^32 does not fit in an i32 and the
 * asm backend folds a multiply by that literal to 0.
 * @param sin_ptr 16-byte sockaddr_in, or null
 * @return packed address and port, or 0 when sin_ptr is null
 * PLATFORM: SHARED
 */
#[no_mangle]
export function net_sockaddr_in_pack_addr_port_c(sin_ptr: *u8): i64 {
  if (sin_ptr == 0) { return 0; }
  let p0: u32 = sin_ptr[2] as u32;
  let p1: u32 = sin_ptr[3] as u32;
  let port: u32 = p0 * 256 + p1;
  port = port & 65535;
  let a0: u32 = sin_ptr[4] as u32;
  let a1: u32 = sin_ptr[5] as u32;
  let a2: u32 = sin_ptr[6] as u32;
  let a3: u32 = sin_ptr[7] as u32;
  let addr: u32 = a0 * 16777216 + a1 * 65536 + a2 * 256 + a3;
  let hi: i64 = addr as i64;
  let lo: i64 = port as i64;
  return (hi << 32) + lo;
}
