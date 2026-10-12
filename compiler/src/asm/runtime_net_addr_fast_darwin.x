// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
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

// runtime_net_addr_fast_darwin.x — Darwin arm64 sockaddr helpers.
//
// The cold ensure path pure-asms src/asm/runtime_net_addr_fast.x (the
// pack) and this file (local, peer, and the two setters), then ld -r.
// It does not pass seeds/runtime_net_addr_fast.from_x.c to host cc.
// Linux and Windows keep that C seed.
//
// sockaddr_in is 16 bytes, measured on this Mac:
//   sin_len 0, sin_family 1 (AF_INET = 2), sin_port 2, sin_addr 4.
// The C seed writes family, port, and address and leaves every other
// byte alone, including sin_len. These setters do the same.
// getsockname and getpeername are libSystem. socklen_t is 4 bytes.
// A failure returns the i64 value -1. The 16-byte address lives on
// the heap so the frame does not have to hold it.
// PLATFORM: MACOS|DARWIN arm64

extern "C" function malloc(n: i64): *u8;
extern "C" function free(p: *u8): void;
extern "C" function memset(d: *u8, c: i32, n: i64): *u8;
extern "C" function getsockname(fd: i32, addr: *u8, len: *i32): i32;
extern "C" function getpeername(fd: i32, addr: *u8, len: *i32): i32;
extern "C" function net_sockaddr_in_pack_addr_port_c(sin_ptr: *u8): i64;

/** Write the last address byte. No further call, so the frame stays short.
 * @param p 16-byte sockaddr_in
 * @param addr host-order IPv4 address
 * PLATFORM: MACOS|DARWIN arm64
 */
function addr_b7(p: *u8, addr: i32): void {
  let i: i32 = 7;
  p[i] = (addr & 255) as u8;
}

/** Write address byte 6, then the last byte. One call only.
 * @param p 16-byte sockaddr_in
 * @param addr host-order IPv4 address
 * PLATFORM: MACOS|DARWIN arm64
 */
function addr_b6(p: *u8, addr: i32): void {
  let i: i32 = 6;
  p[i] = ((addr >> 8) & 255) as u8;
  addr_b7(p, addr);
}

/** Write address byte 5, then the rest of the address.
 * @param p 16-byte sockaddr_in
 * @param addr host-order IPv4 address
 * PLATFORM: MACOS|DARWIN arm64
 */
function addr_b5(p: *u8, addr: i32): void {
  let i: i32 = 5;
  p[i] = ((addr >> 16) & 255) as u8;
  addr_b6(p, addr);
}

/** Write address byte 4, then the rest of the address.
 * @param p 16-byte sockaddr_in
 * @param addr host-order IPv4 address
 * PLATFORM: MACOS|DARWIN arm64
 */
function addr_b4(p: *u8, addr: i32): void {
  let i: i32 = 4;
  p[i] = ((addr >> 24) & 255) as u8;
  addr_b5(p, addr);
}

/** Write the low port byte, then the address.
 * @param p 16-byte sockaddr_in
 * @param port host-order port
 * @param addr host-order IPv4 address
 * PLATFORM: MACOS|DARWIN arm64
 */
function addr_b3(p: *u8, port: i32, addr: i32): void {
  let i: i32 = 3;
  p[i] = (port & 255) as u8;
  addr_b4(p, addr);
}

/** Write the high port byte, then the low port byte and the address.
 * @param p 16-byte sockaddr_in
 * @param port host-order port
 * @param addr host-order IPv4 address
 * PLATFORM: MACOS|DARWIN arm64
 */
function addr_b2(p: *u8, port: i32, addr: i32): void {
  let i: i32 = 2;
  p[i] = ((port >> 8) & 255) as u8;
  addr_b3(p, port, addr);
}

/** Write family, port, and address. Byte 0 and bytes 8..15 stay as they were.
 * @param p 16-byte sockaddr_in
 * @param addr host-order IPv4 address
 * @param port host-order port
 * PLATFORM: MACOS|DARWIN arm64
 */
function addr_store_sin(p: *u8, addr: i32, port: i32): void {
  let i: i32 = 1;
  p[i] = 2 as u8;
  addr_b2(p, port, addr);
}

/** Fill a Darwin sockaddr_in for TCP bind and connect.
 * A null buffer returns without writing.
 * @param sin destination, at least 16 bytes, or null
 * @param addr_u32 host-order IPv4 address
 * @param port_u32 host-order port
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_tcp_set_addr_port_buf_c(sin: *u8, addr_u32: u32, port_u32: u32): void {
  if (sin == 0) { return; }
  addr_store_sin(sin, addr_u32 as i32, port_u32 as i32);
}

/** Fill a Darwin sockaddr_in for UDP bind and sendto.
 * Same bytes as the TCP setter.
 * @param sin destination, at least 16 bytes, or null
 * @param addr_u32 host-order IPv4 address
 * @param port_u32 host-order port
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_udp_set_addr_port_buf_c(sin: *u8, addr_u32: u32, port_u32: u32): void {
  net_tcp_set_addr_port_buf_c(sin, addr_u32, port_u32);
}

/** getsockname when peer is 0, otherwise getpeername.
 * The length local stays in this function so the caller stays small.
 * @param fd socket
 * @param peer 0 for the local address, any other value for the peer
 * @param buf 16-byte sockaddr_in
 * @return 0 on success, or the libSystem error return
 * PLATFORM: MACOS|DARWIN arm64
 */
function addr_call(fd: i32, peer: i32, buf: *u8): i32 {
  let k: i32 = 16;
  if (peer == 0) {
    unsafe { return getsockname(fd, buf, &k); }
  }
  unsafe { return getpeername(fd, buf, &k); }
  return 0 - 1;
}

/** Pack the buffer and release it.
 * @param buf heap sockaddr_in from addr_from_fd
 * @return packed address in the high 32 bits and port in the low 16
 * PLATFORM: MACOS|DARWIN arm64
 */
function addr_pack_free(buf: *u8): i64 {
  let outv: i64 = 0;
  unsafe { outv = net_sockaddr_in_pack_addr_port_c(buf); }
  unsafe { free(buf); }
  return outv;
}

/** Query a socket and pack the address.
 * Returns -1 when the query fails or the buffer cannot be allocated.
 * @param fd socket
 * @param peer 0 for the local address, any other value for the peer
 * @return packed address, or -1
 * PLATFORM: MACOS|DARWIN arm64
 */
function addr_from_fd(fd: i32, peer: i32): i64 {
  let buf: *u8 = 0;
  let status: i32 = 0;
  unsafe { buf = malloc(16); }
  if (buf == 0) { return 0 - 1; }
  unsafe { memset(buf, 0, 16); }
  status = addr_call(fd, peer, buf);
  if (status != 0) {
    unsafe { free(buf); }
    return 0 - 1;
  }
  return addr_pack_free(buf);
}

/** Local address of a socket, packed as (addr << 32) | port.
 * @param fd socket
 * @return packed address, or -1 when getsockname fails
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_tcp_local_addr_c(fd: i32): i64 {
  return addr_from_fd(fd, 0);
}

/** Peer address of a connected socket, packed as (addr << 32) | port.
 * @param fd socket
 * @return packed address, or -1 when getpeername fails
 * PLATFORM: MACOS|DARWIN arm64
 */
#[no_mangle]
export function net_tcp_peer_addr_c(fd: i32): i64 {
  return addr_from_fd(fd, 1);
}
