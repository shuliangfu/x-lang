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

// runtime_net_udp_batch_darwin.x — Darwin arm64 UDP batch bridges.
//
// The cold ensure path pure-asms src/asm/runtime_net_udp_batch.x
// (the public wrappers) and this file (the bodies), then ld -r.
// It does not pass seeds/runtime_net_udp_batch.from_x.c to host cc.
// Linux and Windows keep that C seed, including the Cap walks.
//
// Darwin's Cap sendmmsg and recvmmsg are already sendto and recvfrom
// loops (xlang_net_cap.h). This compiler cannot emit the static-inline
// svc #0x80, so this file calls libSystem sendto, recvfrom, and poll.
// That is the same packet result as the Darwin Cap loop.
//
// sockaddr_in is 16 bytes, measured on this Mac:
//   sin_len 0, sin_family 1 (AF_INET = 2), sin_port 2, sin_addr 4.
// pollfd is 8 bytes: fd 0, events 4, revents 6.
// POLLIN is 1, POLLERR is 8, POLLHUP is 16.
// xlang_net_buf_t is 24 bytes: ptr 0, length 8, handle 16.
// EAGAIN is 35. A zero timeout waits forever; a nonzero timeout is
// passed to poll and a timeout returns -1.
//
// Each function keeps a single loop. Index loads copy the index into
// a local first. The 16-byte address buffer is malloc'd.
//
// This object is a user companion. It is not in the g05 compiler
// image. A missing object after pure-asm faults falls back to the
// C seed.
//
// PLATFORM: MACOS|DARWIN arm64.

/**
 * Fill bytes.
 * @param d *u8 — destination
 * @param c i32 — byte
 * @param n i64 — count
 * @return *u8 — destination
 * PLATFORM: POSIX
 */
export extern "C" function memset(d: *u8, c: i32, n: i64): *u8;

/**
 * Heap buffer.
 * @param n i64 — byte count
 * @return *u8 — buffer, or null
 * PLATFORM: POSIX
 */
export extern "C" function malloc(n: i64): *u8;

/**
 * Release a heap buffer.
 * @param p *u8 — buffer
 * PLATFORM: POSIX
 */
export extern "C" function free(p: *u8): void;

/**
 * Darwin errno slot. C's __error is Mach-O ___error.
 * @return *i32 — errno
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function ___error(): *i32;

/**
 * Send one datagram.
 * @param fd i32 — socket
 * @param buf *u8 — bytes
 * @param len i64 — count
 * @param flags i32 — 0
 * @param addr *u8 — sockaddr_in
 * @param alen i32 — 16
 * @return i64 — bytes, or -1
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function sendto(fd: i32, buf: *u8, len: i64, flags: i32, addr: *u8, alen: i32): i64;

/**
 * Receive one datagram. alen is in-out.
 * @param fd i32 — socket
 * @param buf *u8 — destination
 * @param len i64 — capacity
 * @param flags i32 — 0
 * @param addr *u8 — sockaddr_in
 * @param alen *i32 — capacity in, length out
 * @return i64 — bytes, or -1
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function recvfrom(fd: i32, buf: *u8, len: i64, flags: i32, addr: *u8, alen: *i32): i64;

/**
 * Wait until a socket is readable.
 * @param fds *u8 — one pollfd
 * @param nfds i32 — 1
 * @param timeout i32 — milliseconds, or -1
 * @return i32 — ready count, 0 on timeout, -1 on error
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function poll(fds: *u8, nfds: i32, timeout: i32): i32;

/**
 * Store one byte.
 * @param base *u8 — buffer
 * @param off i32 — index
 * @param v i32 — low 8 bits
 * PLATFORM: MACOS|DARWIN
 */
function udp_store_u8(base: *u8, off: i32, v: i32): void {
  let j: i32 = off;
  let b: i32 = v & 255;
  base[j] = b as u8;
}

/**
 * Load one byte.
 * @param base *u8 — buffer
 * @param off i32 — index
 * @return i32 — 0..255
 * PLATFORM: MACOS|DARWIN
 */
function udp_load_u8(base: *u8, off: i32): i32 {
  let j: i32 = off;
  let b: u8 = base[j];
  return b as i32;
}

/**
 * Store a little-endian i16.
 * @param base *u8 — buffer
 * @param off i32 — byte offset
 * @param v i32 — value
 * PLATFORM: MACOS|DARWIN
 */
function udp_store_le16(base: *u8, off: i32, v: i32): void {
  udp_store_u8(base, off, v);
  udp_store_u8(base, off + 1, v >> 8);
}

/**
 * Load a little-endian i16.
 * @param base *u8 — buffer
 * @param off i32 — byte offset
 * @return i32 — value
 * PLATFORM: MACOS|DARWIN
 */
function udp_load_le16(base: *u8, off: i32): i32 {
  let lo: i32 = udp_load_u8(base, off);
  let hi: i32 = udp_load_u8(base, off + 1);
  return lo + (hi << 8);
}

/**
 * Store a little-endian i32.
 * @param base *u8 — buffer
 * @param off i32 — byte offset
 * @param v i32 — value
 * PLATFORM: MACOS|DARWIN
 */
function udp_store_le32(base: *u8, off: i32, v: i32): void {
  udp_store_u8(base, off, v);
  udp_store_u8(base, off + 1, v >> 8);
  udp_store_u8(base, off + 2, v >> 16);
  udp_store_u8(base, off + 3, v >> 24);
}

/**
 * Store a big-endian i16. Used for sin_port.
 * @param base *u8 — buffer
 * @param off i32 — byte offset
 * @param v i32 — host value
 * PLATFORM: MACOS|DARWIN
 */
function udp_store_be16(base: *u8, off: i32, v: i32): void {
  udp_store_u8(base, off, v >> 8);
  udp_store_u8(base, off + 1, v);
}

/**
 * Load a big-endian i16.
 * @param base *u8 — buffer
 * @param off i32 — byte offset
 * @return i32 — host value
 * PLATFORM: MACOS|DARWIN
 */
function udp_load_be16(base: *u8, off: i32): i32 {
  let hi: i32 = udp_load_u8(base, off);
  let lo: i32 = udp_load_u8(base, off + 1);
  return (hi << 8) + lo;
}

/**
 * Store a big-endian i32. Bytes are written one at a time so a
 * negative host address still keeps its bits.
 * @param base *u8 — buffer
 * @param off i32 — byte offset
 * @param v i32 — host bits
 * PLATFORM: MACOS|DARWIN
 */
function udp_store_be32(base: *u8, off: i32, v: i32): void {
  udp_store_u8(base, off, v >> 24);
  udp_store_u8(base, off + 1, v >> 16);
  udp_store_u8(base, off + 2, v >> 8);
  udp_store_u8(base, off + 3, v);
}

/**
 * Load a big-endian i32. Each byte is 0..255, so the sum keeps the
 * original bits, including a high bit in the first byte.
 * @param base *u8 — buffer
 * @param off i32 — byte offset
 * @return i32 — host bits
 * PLATFORM: MACOS|DARWIN
 */
function udp_load_be32(base: *u8, off: i32): i32 {
  let b0: i32 = udp_load_u8(base, off);
  let b1: i32 = udp_load_u8(base, off + 1);
  let b2: i32 = udp_load_u8(base, off + 2);
  let b3: i32 = udp_load_u8(base, off + 3);
  return (b0 << 24) + (b1 << 16) + (b2 << 8) + b3;
}

/**
 * Load two little-endian bytes as a zero-extended i64.
 * Split out of the 4-byte load so that frame covers its spills.
 * @param base *u8 — buffer
 * @param off i32 — byte offset
 * @return i64 — low 16 bits
 * PLATFORM: MACOS|DARWIN
 */
function udp_load_le16_u(base: *u8, off: i32): i64 {
  let b0: i64 = udp_load_u8(base, off) as i64;
  let b1: i64 = udp_load_u8(base, off + 1) as i64;
  return b0 + (b1 << 8);
}

/**
 * Load four little-endian bytes as a zero-extended i64.
 * @param base *u8 — buffer
 * @param off i32 — byte offset
 * @return i64 — low 32 bits
 * PLATFORM: MACOS|DARWIN
 */
function udp_load_le32_u(base: *u8, off: i32): i64 {
  let lo: i64 = udp_load_le16_u(base, off);
  let hi: i64 = udp_load_le16_u(base, off + 2);
  return lo + (hi << 16);
}

/**
 * Load eight little-endian bytes. Used for a buffer pointer or length.
 * @param base *u8 — buffer
 * @param off i32 — byte offset
 * @return i64 — bits
 * PLATFORM: MACOS|DARWIN
 */
function udp_load_le64(base: *u8, off: i32): i64 {
  let lo: i64 = udp_load_le32_u(base, off);
  let hi: i64 = udp_load_le32_u(base, off + 4);
  return lo + (hi << 32);
}

/**
 * Current errno. Darwin EAGAIN is 35.
 * @return i32 — errno
 * PLATFORM: MACOS|DARWIN
 */
function udp_errno(): i32 {
  let slot: *i32 = 0;
  unsafe {
    slot = ___error();
  }
  if (slot == 0) {
    return 0;
  }
  return slot[0];
}

/**
 * Write one i32 into an array. The index is copied into a local first.
 * @param arr *i32 — destination
 * @param i i32 — index
 * @param v i32 — value
 * PLATFORM: MACOS|DARWIN
 */
function udp_out_i32(arr: *i32, i: i32, v: i32): void {
  let j: i32 = i;
  arr[j] = v;
}

/**
 * Read one i32 from an array.
 * @param arr *i32 — source
 * @param i i32 — index
 * @return i32 — value
 * PLATFORM: MACOS|DARWIN
 */
function udp_in_i32(arr: *i32, i: i32): i32 {
  let j: i32 = i;
  return arr[j];
}

/**
 * Pointer of buffer slot i. Each slot is 24 bytes.
 * @param bufs *u8 — xlang_net_buf_t array
 * @param i i32 — index
 * @return *u8 — data pointer
 * PLATFORM: MACOS|DARWIN
 */
function udp_buf_ptr(bufs: *u8, i: i32): *u8 {
  let off: i32 = i * 24;
  let bits: i64 = udp_load_le64(bufs, off);
  return bits as *u8;
}

/**
 * Length of buffer slot i.
 * @param bufs *u8 — xlang_net_buf_t array
 * @param i i32 — index
 * @return i64 — length
 * PLATFORM: MACOS|DARWIN
 */
function udp_buf_len(bufs: *u8, i: i32): i64 {
  let off: i32 = i * 24 + 8;
  return udp_load_le64(bufs, off);
}

/**
 * Write sin_len, AF_INET, port, and address into a zeroed sockaddr_in.
 * Split from the public impl so the frame covers these spills.
 * @param sin *u8 — 16-byte buffer, already zero
 * @param addr i32 — host-order IPv4 bits
 * @param port i32 — host-order port
 * PLATFORM: MACOS|DARWIN
 */
function udp_fill_sin(sin: *u8, addr: i32, port: i32): void {
  udp_store_u8(sin, 0, 16);
  udp_store_u8(sin, 1, 2);
  udp_store_be16(sin, 2, port);
  udp_store_be32(sin, 4, addr);
}

/**
 * Fill a 16-byte sockaddr_in.
 * @param sin *u8 — 16-byte buffer
 * @param addr_u32 u32 — host-order IPv4
 * @param port_u32 u32 — host-order port
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_udp_batch_set_addr_port_impl(sin: *u8, addr_u32: u32, port_u32: u32): void {
  unsafe {
    memset(sin, 0, 16);
  }
  udp_fill_sin(sin, addr_u32 as i32, port_u32 as i32);
}

/**
 * Poll one socket. timeout_ms 0 waits forever.
 * @param fd i32 — socket
 * @param timeout_ms u32 — milliseconds, or 0
 * @return i32 — 0 readable, -1 timeout or error
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_udp_batch_poll_readable_impl(fd: i32, timeout_ms: u32): i32 {
  let raw: i64 = 0;
  let p: *u8 = &raw as *u8;
  let t: i32 = 0 - 1;
  let n: i32 = 0;
  let rev: i32 = 0;
  udp_store_le32(p, 0, fd);
  udp_store_le16(p, 4, 1);
  if (timeout_ms != 0) {
    t = timeout_ms as i32;
  }
  unsafe {
    n = poll(p, 1, t);
  }
  if (n <= 0) {
    return 0 - 1;
  }
  rev = udp_load_le16(p, 6);
  if ((rev & 24) != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Receive one datagram into buf and write the peer address into sin.
 * @param fd i32 — socket
 * @param buf *u8 — destination
 * @param len i64 — capacity
 * @param sin *u8 — 16-byte sockaddr_in
 * @return i64 — bytes, or -1
 * PLATFORM: MACOS|DARWIN
 */
function udp_recv_one(fd: i32, buf: *u8, len: i64, sin: *u8): i64 {
  let alen: i32 = 16;
  let r: i64 = 0;
  if (buf == 0) {
    if (len != 0) {
      return 0 - 1;
    }
  }
  unsafe {
    memset(sin, 0, 16);
    r = recvfrom(fd, buf, len, 0, sin, &alen);
  }
  return r;
}

/**
 * Send one datagram.
 * @param fd i32 — socket
 * @param addr i32 — host-order IPv4 bits
 * @param port i32 — host-order port
 * @param buf *u8 — bytes
 * @param len i64 — count
 * @return i64 — bytes, or -1
 * PLATFORM: MACOS|DARWIN
 */
function udp_send_one(fd: i32, addr: i32, port: i32, buf: *u8, len: i64): i64 {
  let sin: *u8 = 0;
  let r: i64 = 0;
  if (buf == 0) {
    if (len != 0) {
      return 0 - 1;
    }
  }
  unsafe {
    sin = malloc(16);
  }
  if (sin == 0) {
    return 0 - 1;
  }
  xlang_udp_batch_set_addr_port_impl(sin, addr as u32, port as u32);
  unsafe {
    r = sendto(fd, buf, len, 0, sin, 16);
    free(sin);
  }
  return r;
}

/**
 * Zero out_sizes from index `from` up to n.
 * @param out *i32 — size array
 * @param from i32 — first index to clear
 * @param n i32 — end
 * PLATFORM: MACOS|DARWIN
 */
function udp_zero_sizes(out: *i32, from: i32, n: i32): void {
  let i: i32 = from;
  while (i < n) {
    udp_out_i32(out, i, 0);
    i = i + 1;
  }
}

/**
 * Receive the first of at most two datagrams.
 * Eight parameters keep every argument in a register. A 10-argument
 * function reads its stack arguments from the wrong slot once the
 * frame grows.
 * @param n i32 — 1 or 2
 * @param timeout_ms u32 — poll timeout, or 0 to skip poll
 * @param fd i32 — socket
 * @param buf *u8 — first buffer
 * @param len i64 — first capacity
 * @param out_sizes *i32 — byte counts
 * @param out_addrs *i32 — host-order addresses
 * @param out_ports *i32 — host-order ports
 * @return i32 — 1, 0 on EAGAIN, or -1
 * PLATFORM: MACOS|DARWIN
 */
function udp_recv_first(n: i32, timeout_ms: u32, fd: i32, buf: *u8, len: i64, out_sizes: *i32, out_addrs: *i32, out_ports: *i32): i32 {
  let sin: *u8 = 0;
  let r: i64 = 0;
  let err: i32 = 0;
  if (n <= 0) {
    return 0 - 1;
  }
  if (n > 2) {
    return 0 - 1;
  }
  if (out_sizes == 0) {
    return 0 - 1;
  }
  if (out_addrs == 0) {
    return 0 - 1;
  }
  if (out_ports == 0) {
    return 0 - 1;
  }
  if (timeout_ms != 0) {
    if (xlang_udp_batch_poll_readable_impl(fd, timeout_ms) != 0) {
      return 0 - 1;
    }
  }
  unsafe {
    sin = malloc(16);
  }
  if (sin == 0) {
    return 0 - 1;
  }
  r = udp_recv_one(fd, buf, len, sin);
  if (r < 0) {
    err = udp_errno();
    unsafe { free(sin); }
    if (err == 35) {
      return 0;
    }
    return 0 - 1;
  }
  udp_out_i32(out_sizes, 0, r as i32);
  udp_out_i32(out_addrs, 0, udp_load_be32(sin, 4));
  udp_out_i32(out_ports, 0, udp_load_be16(sin, 2));
  unsafe { free(sin); }
  return 1;
}

/**
 * Receive the second datagram when the first succeeded and n is 2.
 * @param got i32 — result of the first receive
 * @param n i32 — requested count
 * @param fd i32 — socket
 * @param buf *u8 — second buffer
 * @param len i64 — second capacity
 * @param out_sizes *i32 — byte counts
 * @param out_addrs *i32 — host-order addresses
 * @param out_ports *i32 — host-order ports
 * @return i32 — count, or the first result when no second packet is requested
 * PLATFORM: MACOS|DARWIN
 */
function udp_recv_rest(got: i32, n: i32, fd: i32, buf: *u8, len: i64, out_sizes: *i32, out_addrs: *i32, out_ports: *i32): i32 {
  let sin: *u8 = 0;
  let r: i64 = 0;
  if (got != 1) {
    return got;
  }
  if (n < 2) {
    return got;
  }
  unsafe {
    sin = malloc(16);
  }
  if (sin == 0) {
    return 0 - 1;
  }
  r = udp_recv_one(fd, buf, len, sin);
  if (r < 0) {
    unsafe { free(sin); }
    udp_zero_sizes(out_sizes, 1, n);
    return 1;
  }
  udp_out_i32(out_sizes, 1, r as i32);
  udp_out_i32(out_addrs, 1, udp_load_be32(sin, 4));
  udp_out_i32(out_ports, 1, udp_load_be16(sin, 2));
  unsafe { free(sin); }
  return 2;
}

/**
 * Send the first datagram. n outside 1..2 returns -1.
 * @param n i32 — 1 or 2
 * @param fd i32 — socket
 * @param addr i32 — host-order address bits
 * @param port i32 — host-order port
 * @param buf *u8 — bytes
 * @param len i64 — count
 * @return i32 — 1, or -1
 * PLATFORM: MACOS|DARWIN
 */
function udp_send_first(n: i32, fd: i32, addr: i32, port: i32, buf: *u8, len: i64): i32 {
  let r: i64 = 0;
  if (n <= 0) {
    return 0 - 1;
  }
  if (n > 2) {
    return 0 - 1;
  }
  r = udp_send_one(fd, addr, port, buf, len);
  if (r < 0) {
    return 0 - 1;
  }
  return 1;
}

/**
 * Send the second datagram when the first succeeded and n is 2.
 * @param sent i32 — result of the first send
 * @param n i32 — requested count
 * @param fd i32 — socket
 * @param addr i32 — host-order address bits
 * @param port i32 — host-order port
 * @param buf *u8 — bytes
 * @param len i64 — count
 * @return i32 — count
 * PLATFORM: MACOS|DARWIN
 */
function udp_send_rest(sent: i32, n: i32, fd: i32, addr: i32, port: i32, buf: *u8, len: i64): i32 {
  let r: i64 = 0;
  if (sent != 1) {
    return sent;
  }
  if (n < 2) {
    return sent;
  }
  r = udp_send_one(fd, addr, port, buf, len);
  if (r < 0) {
    return sent;
  }
  return 2;
}

/**
 * Receive at most two datagrams. timeout_ms 0 does not poll first.
 * @param fd i32 — socket
 * @param p0 *u8 — first buffer
 * @param l0 i64 — first capacity
 * @param p1 *u8 — second buffer
 * @param l1 i64 — second capacity
 * @param n i32 — 1 or 2
 * @param timeout_ms u32 — poll timeout, or 0 to skip poll
 * @param out_sizes *i32 — byte counts
 * @param out_addrs *i32 — host-order addresses
 * @param out_ports *i32 — host-order ports
 * @return i32 — count, 0 on EAGAIN, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_net_udp_recvmmsg2_c(fd: i32, p0: *u8, l0: i64, p1: *u8, l1: i64, n: i32, timeout_ms: u32, out_sizes: *i32, out_addrs: *i32, out_ports: *i32): i32 {
  let got: i32 = udp_recv_first(n, timeout_ms, fd, p0, l0, out_sizes, out_addrs, out_ports);
  return udp_recv_rest(got, n, fd, p1, l1, out_sizes, out_addrs, out_ports);
}

/**
 * Send at most two datagrams.
 * @param fd i32 — socket
 * @param a0 u32 — first host-order address
 * @param port0 u32 — first port
 * @param p0 *u8 — first bytes
 * @param l0 i64 — first length
 * @param a1 u32 — second host-order address
 * @param port1 u32 — second port
 * @param p1 *u8 — second bytes
 * @param l1 i64 — second length
 * @param n i32 — 1 or 2
 * @return i32 — count, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_net_udp_sendmmsg2_c(fd: i32, a0: u32, port0: u32, p0: *u8, l0: i64, a1: u32, port1: u32, p1: *u8, l1: i64, n: i32): i32 {
  let sent: i32 = udp_send_first(n, fd, a0 as i32, port0 as i32, p0, l0);
  return udp_send_rest(sent, n, fd, a1 as i32, port1 as i32, p1, l1);
}

/**
 * Receive up to n datagrams from a buffer table. n is 1..8.
 * @param fd i32 — socket
 * @param bufs *u8 — xlang_net_buf_t array
 * @param n i32 — count
 * @param out_sizes *i32 — byte counts
 * @param out_addrs *i32 — host-order addresses
 * @param out_ports *i32 — host-order ports
 * @return i32 — count, 0 on EAGAIN, or -1
 * PLATFORM: MACOS|DARWIN
 */
function udp_recv_buf_loop(fd: i32, bufs: *u8, n: i32, out_sizes: *i32, out_addrs: *i32, out_ports: *i32): i32 {
  let sin: *u8 = 0;
  let i: i32 = 0;
  unsafe {
    sin = malloc(16);
  }
  if (sin == 0) {
    return 0 - 1;
  }
  while (i < n) {
    let buf: *u8 = udp_buf_ptr(bufs, i);
    let len: i64 = udp_buf_len(bufs, i);
    let r: i64 = udp_recv_one(fd, buf, len, sin);
    if (r < 0) {
      let err: i32 = udp_errno();
      unsafe { free(sin); }
      if (i > 0) {
        udp_zero_sizes(out_sizes, i, n);
        return i;
      }
      if (err == 35) {
        return 0;
      }
      return 0 - 1;
    }
    udp_out_i32(out_sizes, i, r as i32);
    udp_out_i32(out_addrs, i, udp_load_be32(sin, 4));
    udp_out_i32(out_ports, i, udp_load_be16(sin, 2));
    i = i + 1;
  }
  unsafe { free(sin); }
  return n;
}

/**
 * Send up to n datagrams from a buffer table.
 * @param fd i32 — socket
 * @param addrs *i32 — host-order addresses
 * @param ports *i32 — host-order ports
 * @param bufs *u8 — xlang_net_buf_t array
 * @param n i32 — count
 * @return i32 — count, or -1
 * PLATFORM: MACOS|DARWIN
 */
function udp_send_buf_loop(fd: i32, addrs: *i32, ports: *i32, bufs: *u8, n: i32): i32 {
  let i: i32 = 0;
  while (i < n) {
    let addr: i32 = udp_in_i32(addrs, i);
    let port: i32 = udp_in_i32(ports, i);
    let buf: *u8 = udp_buf_ptr(bufs, i);
    let len: i64 = udp_buf_len(bufs, i);
    let r: i64 = udp_send_one(fd, addr, port, buf, len);
    if (r < 0) {
      if (i > 0) {
        return i;
      }
      return 0 - 1;
    }
    i = i + 1;
  }
  return n;
}

/**
 * Receive 1..8 datagrams from a buffer table.
 * @param fd i32 — socket
 * @param bufs *u8 — xlang_net_buf_t array
 * @param n i32 — 1..8
 * @param timeout_ms u32 — poll timeout, or 0 to skip poll
 * @param out_sizes *i32 — byte counts
 * @param out_addrs *i32 — host-order addresses
 * @param out_ports *i32 — host-order ports
 * @return i32 — count, 0 on EAGAIN, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_net_udp_recvmmsg_buf_c(fd: i32, bufs: *u8, n: i32, timeout_ms: u32, out_sizes: *i32, out_addrs: *i32, out_ports: *i32): i32 {
  if (n <= 0) {
    return 0 - 1;
  }
  if (n > 8) {
    return 0 - 1;
  }
  if (bufs == 0) {
    return 0 - 1;
  }
  if (out_sizes == 0) {
    return 0 - 1;
  }
  if (out_addrs == 0) {
    return 0 - 1;
  }
  if (out_ports == 0) {
    return 0 - 1;
  }
  if (timeout_ms != 0) {
    if (xlang_udp_batch_poll_readable_impl(fd, timeout_ms) != 0) {
      return 0 - 1;
    }
  }
  return udp_recv_buf_loop(fd, bufs, n, out_sizes, out_addrs, out_ports);
}

/**
 * Send 1..8 datagrams from a buffer table.
 * @param fd i32 — socket
 * @param addrs *i32 — host-order addresses
 * @param ports *i32 — host-order ports
 * @param bufs *u8 — xlang_net_buf_t array
 * @param n i32 — 1..8
 * @return i32 — count, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_net_udp_sendmmsg_buf_c(fd: i32, addrs: *i32, ports: *i32, bufs: *u8, n: i32): i32 {
  if (n <= 0) {
    return 0 - 1;
  }
  if (n > 8) {
    return 0 - 1;
  }
  if (addrs == 0) {
    return 0 - 1;
  }
  if (ports == 0) {
    return 0 - 1;
  }
  if (bufs == 0) {
    return 0 - 1;
  }
  return udp_send_buf_loop(fd, addrs, ports, bufs, n);
}
