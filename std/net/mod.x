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
// See implementation.
// See implementation.
const driver = import("std.io.driver");
const io = import("std.io");
const io_backend = import("std.io.backend");
const context = import("std.context");
const err = import("std.error");
/* See implementation. */
const tls_plat = import("std.net.tls_stub");
/* See implementation. */
const tcp_pool_plat = import("std.net.tcp_pool");
// See implementation.
extern function net_tcp_connect_c(addr_u32: u32, port_u32: u32, timeout_ms: u32): i32;
/* See implementation. */
extern function net_tcp_connect_blocking_c(addr_u32: u32, port_u32: u32, timeout_ms: u32): i32;
extern function net_tcp_listen_c(addr_u32: u32, port_u32: u32): i32;
extern function net_accept_c(listener_fd: i32, timeout_ms: u32): i32;
/* See implementation. */
extern function net_accept_many_c(listener_fd: i32, out_fds: *i32, n: i32, timeout_ms: u32): i32;
/* See implementation. */
extern function net_run_accept_workers_c(listener_fd: i32, n_workers: i32, timeout_ms: u32): i32;
/* See implementation. */
extern function net_connect_many_c(addr_u32: u32, port_u32: u32, out_fds: *i32, n: i32, timeout_ms: u32): i32;
extern function net_close_socket_c(fd: i32): i32;
/* See implementation. */
extern function net_set_blocking_c(fd: i32, blocking: i32): i32;
extern function net_udp_bind_c(addr_u32: u32, port_u32: u32): i32;
extern function net_udp_send_to_c(fd: i32, addr_u32: u32, port_u32: u32, buf: *u8, len: usize): i32;
extern function net_udp_recv_from_c(fd: i32, buf: *u8, len: usize, timeout_ms: u32, out_addr_u32: *u32, out_port_u32: *u32): i32;
/* See implementation. */
extern function net_udp_recv_many_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, n: i32, timeout_ms: u32, out_sizes: *i32, out_addrs: *u32, out_ports: *u32): i32;
/* See implementation. */
extern function net_udp_send_many_c(fd: i32, a0: u32, port0: u32, p0: *u8, l0: usize, a1: u32, port1: u32, p1: *u8, l1: usize, n: i32): i32;
/* See implementation. */
extern function net_udp_recv_many_buf_c(fd: i32, bufs: *Buffer, n: i32, timeout_ms: u32, out_sizes: *i32, out_addrs: *u32, out_ports: *u32): i32;
/* See implementation. */
extern function net_udp_send_many_buf_c(fd: i32, addrs: *u32, ports: *u32, bufs: *Buffer, n: i32): i32;
extern function net_tcp_local_addr_c(fd: i32): i64;
extern function net_tcp_peer_addr_c(fd: i32): i64;
extern function net_tcp_connect_ipv6_c(addr_16: *u8, port_u32: u32, timeout_ms: u32): i32;
extern function net_tcp_listen_ipv6_c(addr_16: *u8, port_u32: u32): i32;
extern function net_resolve_ipv4_c(hostname: *u8): u32;
/* See implementation. */
extern function net_resolve_ipv4_ex_c(hostname: *u8, out_addr: *u32, out_err: *i32): i32;
/* See implementation. */
extern function net_resolve_ipv6_ex_c(hostname: *u8, out_addr_16: *u8, out_err: *i32): i32;
/* See implementation. */
extern function net_stream_read_batch_provided_c(stream_fd: i32, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): i32;
/* See implementation. */
extern function net_tls_alpn_h2_http1_wire_c(out: *u8, out_cap: i32): i32;
// See implementation.
export struct Ipv4Addr {
  a: u8
  b: u8
  c: u8
  d: u8
}
/** Exported function `addr_to_packed`.
 * Implements `addr_to_packed`.
 * @param addr Ipv4Addr
 * @return u32
 */
export function addr_to_packed(addr: Ipv4Addr): u32 {
  let a: u32 = (addr.a as u32);
  let b: u32 = (addr.b as u32);
  let c: u32 = (addr.c as u32);
  let d: u32 = (addr.d as u32);
  return ((a << 24) | (b << 16) | (c << 8) | d) as u32;
}
/** Exported function `packed_to_ipv4`.
 * Implements `packed_to_ipv4`.
 * @param u u32
 * @return Ipv4Addr
 */
export function packed_to_ipv4(u: u32): Ipv4Addr {
  let hi: u32 = ((u >> 24) & 255) as u32;
  let b1: u32 = ((u >> 16) & 255) as u32;
  let b2: u32 = ((u >> 8) & 255) as u32;
  let lo: u32 = (u & 255) as u32;
  return Ipv4Addr { a: (hi as u8), b: (b1 as u8), c: (b2 as u8), d: (lo as u8) };
}
// See implementation.
export struct SocketAddrV4 {
  addr: Ipv4Addr
  port: u32
}
// See implementation.
export struct TcpStream {
  fd: i32
}
// See implementation.
export struct TcpListener {
  fd: i32
}
/** Exported function `connect`.
 * Implements `connect`.
 * @param addr Ipv4Addr
 * @param port u32
 * @param timeout_ms u32
 * @return TcpStream
 */
export function connect(addr: Ipv4Addr, port: u32, timeout_ms: u32): TcpStream {
  let fd: i32 = 0;
  unsafe {
    fd = net_tcp_connect_c(addr_to_packed(addr), port, timeout_ms);
  }
  return TcpStream { fd: fd };
}
/** Exported function `connect_blocking`.
 * Implements `connect_blocking`.
 * @param addr Ipv4Addr
 * @param port u32
 * @param timeout_ms u32
 * @return TcpStream
 */
export function connect_blocking(addr: Ipv4Addr, port: u32, timeout_ms: u32): TcpStream {
  let fd: i32 = 0;
  unsafe {
    fd = net_tcp_connect_blocking_c(addr_to_packed(addr), port, timeout_ms);
  }
  return TcpStream { fd: fd };
}
/** Exported function `listen`.
 * Implements `listen`.
 * @param addr Ipv4Addr
 * @param port u32
 * @return TcpListener
 */
export function listen(addr: Ipv4Addr, port: u32): TcpListener {
  let fd: i32 = 0;
  unsafe {
    fd = net_tcp_listen_c(addr_to_packed(addr), port);
  }
  return TcpListener { fd: fd };
}
/** Exported function `accept`.
 * Implements `accept`.
 * @param listener TcpListener
 * @param timeout_ms u32
 * @return TcpStream
 */
export function accept(listener: TcpListener, timeout_ms: u32): TcpStream {
  let fd: i32 = 0;
  unsafe {
    fd = net_accept_c(listener.fd, timeout_ms);
  }
  return TcpStream { fd: fd };
}
/** Exported function `close_stream`.
 * Implements `close_stream`.
 * @param stream TcpStream
 * @return i32
 */
export function close_stream(stream: TcpStream): i32 {
  unsafe { return net_close_socket_c(stream.fd); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `set_blocking`.
 * Implements `set_blocking`.
 * @param stream TcpStream
 * @param blocking i32
 * @return i32
 */
export function set_blocking(stream: TcpStream, blocking: i32): i32 {
  unsafe { return net_set_blocking_c(stream.fd, blocking); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `read_batch`.
 * Read path helper `read_batch`.
 * @param stream TcpStream
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @param p2 *u8
 * @param l2 usize
 * @param p3 *u8
 * @param l3 usize
 * @param n i32
 * @param timeout_ms u32
 * @return i32
 */
export function read_batch(stream: TcpStream, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): i32 {
  let h: usize = io_backend.handle_from_fd(stream.fd, 0);
  let bufs: Buffer[4] = [
    Buffer { ptr: p0, length: l0, handle: h },
    Buffer { ptr: p1, length: l1, handle: h },
    Buffer { ptr: p2, length: l2, handle: h },
    Buffer { ptr: p3, length: l3, handle: h }
  ];
  return driver.submit_read_batch(bufs, n, timeout_ms);
}
/** Exported function `write_batch`.
 * Write path helper `write_batch`.
 * @param stream TcpStream
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @param p2 *u8
 * @param l2 usize
 * @param p3 *u8
 * @param l3 usize
 * @param n i32
 * @param timeout_ms u32
 * @return i32
 */
export function write_batch(stream: TcpStream, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): i32 {
  let h: usize = io_backend.handle_from_fd(stream.fd, 0);
  let bufs: Buffer[4] = [
    Buffer { ptr: p0, length: l0, handle: h },
    Buffer { ptr: p1, length: l1, handle: h },
    Buffer { ptr: p2, length: l2, handle: h },
    Buffer { ptr: p3, length: l3, handle: h }
  ];
  return driver.submit_write_batch(bufs, n, timeout_ms);
}
/** Exported function `read_batch_buf`.
 * Read path helper `read_batch_buf`.
 * @param stream TcpStream
 * @param buffers *Buffer
 * @param n i32
 * @param timeout_ms u32
 * @return i32
 */
export function read_batch_buf(stream: TcpStream, buffers: *Buffer, n: i32, timeout_ms: u32): i32 {
  let h: usize = io_backend.handle_from_fd(stream.fd, 0);
  return driver.submit_read_batch_buf(h, buffers, n, timeout_ms);
}
/** Exported function `write_batch_buf`.
 * Write path helper `write_batch_buf`.
 * @param stream TcpStream
 * @param buffers *Buffer
 * @param n i32
 * @param timeout_ms u32
 * @return i32
 */
export function write_batch_buf(stream: TcpStream, buffers: *Buffer, n: i32, timeout_ms: u32): i32 {
  let h: usize = io_backend.handle_from_fd(stream.fd, 0);
  return driver.submit_write_batch_buf(h, buffers, n, timeout_ms);
}
/** Exported function `read_fixed`.
 * Read path helper `read_fixed`.
 * @param stream TcpStream
 * @param buf_index u32
 * @param offset usize
 * @param len usize
 * @param timeout_ms u32
 * @return i32
 */
export function read_fixed(stream: TcpStream, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): i32 {
  return io.read_fixed_fd(stream.fd, buf_index, offset, len, timeout_ms);
}
/** Exported function `write_fixed`.
 * Write path helper `write_fixed`.
 * @param stream TcpStream
 * @param buf_index u32
 * @param offset usize
 * @param len usize
 * @param timeout_ms u32
 * @return i32
 */
export function write_fixed(stream: TcpStream, buf_index: u32, offset: usize, len: usize, timeout_ms: u32): i32 {
  return io.write_fixed_fd(stream.fd, buf_index, offset, len, timeout_ms);
}
/** Exported function `read_batch_provided`.
 * Read path helper `read_batch_provided`.
 * @param stream TcpStream
 * @param n i32
 * @param timeout_ms u32
 * @param out_bids *u32
 * @param out_lens *u32
 * @return i32
 */
export function read_batch_provided(stream: TcpStream, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): i32 {
  unsafe { return net_stream_read_batch_provided_c(stream.fd, n, timeout_ms, out_bids, out_lens); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `close_listener`.
 * Implements `close_listener`.
 * @param listener TcpListener
 * @return i32
 */
export function close_listener(listener: TcpListener): i32 {
  unsafe { return net_close_socket_c(listener.fd); }
  return 0; // unreachable — typeck workaround
}
/**
 * See implementation.
 * See implementation.
 */
export function run_accept_workers(listener: TcpListener, n_workers: i32, timeout_ms: u32): i32 {
  unsafe { return net_run_accept_workers_c(listener.fd, n_workers, timeout_ms); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `local_addr`.
 * Implements `local_addr`.
 * @param stream TcpStream
 * @return SocketAddrV4
 */
export function local_addr(stream: TcpStream): SocketAddrV4 {
  let pk: i64 = 0;
  unsafe {
    pk = net_tcp_local_addr_c(stream.fd);
  }
  if (pk < 0) { return SocketAddrV4 { addr: packed_to_ipv4(0 as u32), port: 0 as u32 }; }
  let addr_u32: u32 = (((pk >> 32) & 4294967295) as u32);
  let port_u32: u32 = ((pk & 65535) as u32);
  return SocketAddrV4 { addr: packed_to_ipv4(addr_u32), port: port_u32 };
}
/** Exported function `peer_addr`.
 * Implements `peer_addr`.
 * @param stream TcpStream
 * @return SocketAddrV4
 */
export function peer_addr(stream: TcpStream): SocketAddrV4 {
  let pk: i64 = 0;
  unsafe {
    pk = net_tcp_peer_addr_c(stream.fd);
  }
  if (pk < 0) { return SocketAddrV4 { addr: packed_to_ipv4(0 as u32), port: 0 as u32 }; }
  let addr_u32: u32 = (((pk >> 32) & 4294967295) as u32);
  let port_u32: u32 = ((pk & 65535) as u32);
  return SocketAddrV4 { addr: packed_to_ipv4(addr_u32), port: port_u32 };
}
/** Exported function `listener_local_addr`.
 * Implements `listener_local_addr`.
 * @param listener TcpListener
 * @return SocketAddrV4
 */
export function listener_local_addr(listener: TcpListener): SocketAddrV4 {
  let pk: i64 = 0;
  unsafe {
    pk = net_tcp_local_addr_c(listener.fd);
  }
  if (pk < 0) { return SocketAddrV4 { addr: packed_to_ipv4(0 as u32), port: 0 as u32 }; }
  let addr_u32: u32 = (((pk >> 32) & 4294967295) as u32);
  let port_u32: u32 = ((pk & 65535) as u32);
  return SocketAddrV4 { addr: packed_to_ipv4(addr_u32), port: port_u32 };
}
// ——— UDP ———
export struct UdpSocket {
  fd: i32
}
/** Exported function `udp_bind`.
 * Implements `udp_bind`.
 * @param addr Ipv4Addr
 * @param port u32
 * @return UdpSocket
 */
export function udp_bind(addr: Ipv4Addr, port: u32): UdpSocket {
  let fd: i32 = 0;
  unsafe {
    fd = net_udp_bind_c(addr_to_packed(addr), port);
  }
  return UdpSocket { fd: fd };
}
/** Exported function `send_to`.
 * Implements `send_to`.
 * @param sock UdpSocket
 * @param addr Ipv4Addr
 * @param port u32
 * @param buf *u8
 * @param len usize
 * @return i32
 */
export function send_to(sock: UdpSocket, addr: Ipv4Addr, port: u32, buf: *u8, len: usize): i32 {
  unsafe { return net_udp_send_to_c(sock.fd, addr_to_packed(addr), port, buf, len); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `recv_from`.
 * Implements `recv_from`.
 * @param sock UdpSocket
 * @param buf *u8
 * @param len usize
 * @param timeout_ms u32
 * @param out_addr *u32
 * @param out_port *u32
 * @return i32
 */
export function recv_from(sock: UdpSocket, buf: *u8, len: usize, timeout_ms: u32, out_addr: *u32, out_port: *u32): i32 {
  unsafe { return net_udp_recv_from_c(sock.fd, buf, len, timeout_ms, out_addr, out_port); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `udp_recv_many`.
 * Implements `udp_recv_many`.
 * @param sock UdpSocket
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @param n i32
 * @param timeout_ms u32
 * @param out_sizes *i32
 * @param out_addrs *u32
 * @param out_ports *u32
 * @return i32
 */
export function udp_recv_many(sock: UdpSocket, p0: *u8, l0: usize, p1: *u8, l1: usize, n: i32, timeout_ms: u32, out_sizes: *i32, out_addrs: *u32, out_ports: *u32): i32 {
  unsafe { return net_udp_recv_many_c(sock.fd, p0, l0, p1, l1, n, timeout_ms, out_sizes, out_addrs, out_ports); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `udp_send_many`.
 * Implements `udp_send_many`.
 * @param sock UdpSocket
 * @param a0 u32
 * @param port0 u32
 * @param p0 *u8
 * @param l0 usize
 * @param a1 u32
 * @param port1 u32
 * @param p1 *u8
 * @param l1 usize
 * @param n i32
 * @return i32
 */
export function udp_send_many(sock: UdpSocket, a0: u32, port0: u32, p0: *u8, l0: usize, a1: u32, port1: u32, p1: *u8, l1: usize, n: i32): i32 {
  unsafe { return net_udp_send_many_c(sock.fd, a0, port0, p0, l0, a1, port1, p1, l1, n); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `udp_recv_many_buf`.
 * Implements `udp_recv_many_buf`.
 * @param sock UdpSocket
 * @param bufs *Buffer
 * @param n i32
 * @param timeout_ms u32
 * @param out_sizes *i32
 * @param out_addrs *u32
 * @param out_ports *u32
 * @return i32
 */
export function udp_recv_many_buf(sock: UdpSocket, bufs: *Buffer, n: i32, timeout_ms: u32, out_sizes: *i32, out_addrs: *u32, out_ports: *u32): i32 {
  unsafe { return net_udp_recv_many_buf_c(sock.fd, bufs, n, timeout_ms, out_sizes, out_addrs, out_ports); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `udp_send_many_buf`.
 * Implements `udp_send_many_buf`.
 * @param sock UdpSocket
 * @param addrs *u32
 * @param ports *u32
 * @param bufs *Buffer
 * @param n i32
 * @return i32
 */
export function udp_send_many_buf(sock: UdpSocket, addrs: *u32, ports: *u32, bufs: *Buffer, n: i32): i32 {
  unsafe { return net_udp_send_many_buf_c(sock.fd, addrs, ports, bufs, n); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `close_udp`.
 * Implements `close_udp`.
 * @param sock UdpSocket
 * @return i32
 */
export function close_udp(sock: UdpSocket): i32 {
  unsafe { return net_close_socket_c(sock.fd); }
  return 0; // unreachable — typeck workaround
}
// ——— IPv6 ———
export struct Ipv6Addr {
  b0: u8
  b1: u8
  b2: u8
  b3: u8
  b4: u8
  b5: u8
  b6: u8
  b7: u8
  b8: u8
  b9: u8
  b10: u8
  b11: u8
  b12: u8
  b13: u8
  b14: u8
  b15: u8
}
/** Exported function `ipv6_loopback`.
 * Implements `ipv6_loopback`.
 * @return Ipv6Addr
 */
export function ipv6_loopback(): Ipv6Addr {
  return Ipv6Addr {
    b0: 0, b1: 0, b2: 0, b3: 0, b4: 0, b5: 0, b6: 0, b7: 0,
    b8: 0, b9: 0, b10: 0, b11: 0, b12: 0, b13: 0, b14: 0, b15: 1
  };
}
/** Exported function `connect_ipv6`.
 * Implements `connect_ipv6`.
 * @param addr Ipv6Addr
 * @param port u32
 * @param timeout_ms u32
 * @return TcpStream
 */
export function connect_ipv6(addr: Ipv6Addr, port: u32, timeout_ms: u32): TcpStream {
  let fd: i32 = 0;
  unsafe {
    fd = net_tcp_connect_ipv6_c(&addr.b0, port, timeout_ms);
  }
  return TcpStream { fd: fd };
}
/** Exported function `listen_ipv6`.
 * Implements `listen_ipv6`.
 * @param addr Ipv6Addr
 * @param port u32
 * @return TcpListener
 */
export function listen_ipv6(addr: Ipv6Addr, port: u32): TcpListener {
  let fd: i32 = 0;
  unsafe {
    fd = net_tcp_listen_ipv6_c(&addr.b0, port);
  }
  return TcpListener { fd: fd };
}
// See implementation.
/** Exported function `resolve`.
 * Implements `resolve`.
 * @param hostname *u8
 * @return Ipv4Addr
 */
export function resolve(hostname: *u8): Ipv4Addr {
  let u: u32 = 0 as u32;
  unsafe {
    u = net_resolve_ipv4_c(hostname);
  }
  return packed_to_ipv4(u);
}

/** Exported function `resolve_err_ok`.
 * Implements `resolve_err_ok`.
 * @return i32
 */
export function resolve_err_ok(): i32 { return 0; }
/** Exported function `resolve_err_host_not_found`.
 * Implements `resolve_err_host_not_found`.
 * @return i32
 */
export function resolve_err_host_not_found(): i32 { return 1; }
/** Exported function `resolve_err_no_data`.
 * Implements `resolve_err_no_data`.
 * @return i32
 */
export function resolve_err_no_data(): i32 { return 2; }
/** Exported function `resolve_err_try_again`.
 * Implements `resolve_err_try_again`.
 * @return i32
 */
export function resolve_err_try_again(): i32 { return 3; }
/** Exported function `resolve_err_system`.
 * Implements `resolve_err_system`.
 * @return i32
 */
export function resolve_err_system(): i32 { return 4; }

/**
 * See implementation.
 */
export function resolve_ex(hostname: *u8, out_addr: *u32, out_err: *i32): i32 {
  unsafe { return net_resolve_ipv4_ex_c(hostname, out_addr, out_err); }
  return 0; // unreachable — typeck workaround
}

/**
 * See implementation.
 */
export function resolve_ipv6(hostname: *u8, out_addr_16: *u8, out_err: *i32): i32 {
  unsafe { return net_resolve_ipv6_ex_c(hostname, out_addr_16, out_err); }
  return 0; // unreachable — typeck workaround
}
// batch_max: see function docblock below.
/** Exported function `batch_max`.
 * Implements `batch_max`.
 * @return i32
 */
export function batch_max(): i32 { return 64; }
// accept_many: see function docblock below.
/** Exported function `accept_many`.
 * Implements `accept_many`.
 * @param listener TcpListener
 * @param out TcpStream[]
 * @param timeout_ms u32
 * @return u32
 */
export function accept_many(listener: TcpListener, out: TcpStream[], timeout_ms: u32): u32 {
  if (out.length == 0) { return 0 as u32; }
  let fd_buf: i32[64];
  let n_req: i32 = (if (out.length > 64) { 64 } else { out.length }) as i32;
  let count: i32 = 0;
  unsafe {
    count = net_accept_many_c(listener.fd, &fd_buf[0], n_req, timeout_ms);
  }
  let i: u32 = 0 as u32;
  while (i < (count as u32)) {
    out[i] = (TcpStream { fd: fd_buf[i as i32] });
    i = (i + 1 as u32) as u32;
  }
  return count as u32;
}
// connect_many: see function docblock below.
/** Exported function `connect_many`.
 * Implements `connect_many`.
 * @param addr Ipv4Addr
 * @param port u32
 * @param out TcpStream[]
 * @param timeout_ms u32
 * @return u32
 */
export function connect_many(addr: Ipv4Addr, port: u32, out: TcpStream[], timeout_ms: u32): u32 {
  if (out.length == 0) { return 0 as u32; }
  let fd_buf: i32[64];
  let n_req: i32 = (if (out.length > 64) { 64 } else { out.length }) as i32;
  let count: i32 = 0;
  unsafe {
    count = net_connect_many_c(addr_to_packed(addr), port, &fd_buf[0], n_req, timeout_ms);
  }
  let i: u32 = 0 as u32;
  while (i < (count as u32)) {
    out[i] = (TcpStream { fd: fd_buf[i as i32] });
    i = (i + 1 as u32) as u32;
  }
  return count as u32;
}
// See implementation.
/** Exported function `timeout_ms_from_ctx`.
 * Implements `timeout_ms_from_ctx`.
 * @param ctx Context
 * @return i32
 */
export function timeout_ms_from_ctx(ctx: context.Context): i32 {
  if (context.is_cancelled(ctx) != 0) {
    return err.net_err_cancelled();
  }
  let rem: i64 = context.remaining_ns(ctx);
  let dl: i64 = context.deadline_ns(ctx);
  if (dl > 0 && rem <= 0) {
    return err.net_err_timeout();
  }
  if (rem <= 0) {
    return 0;
  }
  let ms: i64 = rem / 1000000;
  if (ms <= 0) {
    return 1;
  }
  if (ms > 2147483647) {
    return 2147483647;
  }
  return ms as i32;
}
/** Exported function `connect_ctx_fd`.
 * Implements `connect_ctx_fd`.
 * @param addr Ipv4Addr
 * @param port u32
 * @param ctx Context
 * @return i32
 */
export function connect_ctx_fd(addr: Ipv4Addr, port: u32, ctx: context.Context): i32 {
  let tm: i32 = timeout_ms_from_ctx(ctx);
  if (tm < 0) {
    return tm;
  }
  unsafe { return net_tcp_connect_c(addr_to_packed(addr), port, tm as u32); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `connect_ipv6_ctx_fd`.
 * Implements `connect_ipv6_ctx_fd`.
 * @param addr Ipv6Addr
 * @param port u32
 * @param ctx Context
 * @return i32
 */
export function connect_ipv6_ctx_fd(addr: Ipv6Addr, port: u32, ctx: context.Context): i32 {
  let tm: i32 = timeout_ms_from_ctx(ctx);
  if (tm < 0) {
    return tm;
  }
  unsafe { return net_tcp_connect_ipv6_c(&addr.b0, port, tm as u32); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `accept_ctx_fd`.
 * Implements `accept_ctx_fd`.
 * @param listener TcpListener
 * @param ctx Context
 * @return i32
 */
export function accept_ctx_fd(listener: TcpListener, ctx: context.Context): i32 {
  let tm: i32 = timeout_ms_from_ctx(ctx);
  if (tm < 0) {
    return tm;
  }
  unsafe { return net_accept_c(listener.fd, tm as u32); }
  return 0; // unreachable — typeck workaround
}
/** Exported function `read_ctx`.
 * Read path helper `read_ctx`.
 * @param stream TcpStream
 * @param ptr *u8
 * @param len usize
 * @param ctx Context
 * @return i32
 */
export function read_ctx(stream: TcpStream, ptr: *u8, len: usize, ctx: context.Context): i32 {
  let tm: i32 = timeout_ms_from_ctx(ctx);
  if (tm < 0) {
    return tm;
  }
  let buf: Buffer = Buffer { ptr: ptr, length: len, handle: io_backend.handle_from_fd(stream.fd, 0) };
  return driver.submit_read(buf, tm as u32);
}
/** Exported function `write_ctx`.
 * Write path helper `write_ctx`.
 * @param stream TcpStream
 * @param ptr *u8
 * @param len usize
 * @param ctx Context
 * @return i32
 */
export function write_ctx(stream: TcpStream, ptr: *u8, len: usize, ctx: context.Context): i32 {
  let tm: i32 = timeout_ms_from_ctx(ctx);
  if (tm < 0) {
    return tm;
  }
  let buf: Buffer = Buffer { ptr: ptr, length: len, handle: io_backend.handle_from_fd(stream.fd, 0) };
  return driver.submit_write(buf, tm as u32);
}
// See implementation.
/** Exported function `TLS_NOT_IMPL`.
 * Implements `TLS_NOT_IMPL`.
 * @return i32
 */
export function TLS_NOT_IMPL(): i32 { return -9; }

/* See implementation. */
allow(padding) struct TlsStream {
  fd: i32
  ctx_handle: i64
}

/** Exported function `tls_is_available`.
 * Implements `tls_is_available`.
 * @return bool
 */
export function tls_is_available(): bool {
  let ok: i32 = 0;
  unsafe {
    ok = tls_plat.net_tls_is_available_c();
  }
  if (ok != 0) { return true; }
  return false;
}

/** Exported function `tls_backend_name`.
 * Implements `tls_backend_name`.
 * @return *u8
 */
export function tls_backend_name(): *u8 {
  unsafe { return tls_plat.net_tls_backend_name_c(); }
  return 0 as *u8; // unreachable — typeck workaround
}

/** Exported function `tls_connect_client`.
 * Implements `tls_connect_client`.
 * @param stream TcpStream
 * @param sni *u8
 * @return TlsStream
 */
export function tls_connect_client(stream: TcpStream, sni: *u8): TlsStream {
  let h: i64 = 0;
  unsafe {
    h = tls_plat.net_tls_connect_client_c(stream.fd, sni);
  }
  return TlsStream { fd: stream.fd, ctx_handle: h };
}

/** Exported function `tls_alpn_h2_http1_wire`.
 * Implements `tls_alpn_h2_http1_wire`.
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function tls_alpn_h2_http1_wire(out: *u8, out_cap: i32): i32 {
  unsafe { return net_tls_alpn_h2_http1_wire_c(out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `tls_connect_client_alpn`.
 * Implements `tls_connect_client_alpn`.
 * @param stream TcpStream
 * @param sni *u8
 * @param alpn_wire *u8
 * @param alpn_wire_len i32
 * @return TlsStream
 */
export function tls_connect_client_alpn(stream: TcpStream, sni: *u8, alpn_wire: *u8, alpn_wire_len: i32): TlsStream {
  let h: i64 = 0;
  unsafe {
    h = tls_plat.net_tls_connect_client_alpn_c(stream.fd, sni, alpn_wire, alpn_wire_len);
  }
  return TlsStream { fd: stream.fd, ctx_handle: h };
}

/** Exported function `tls_alpn_selected`.
 * Implements `tls_alpn_selected`.
 * @param tls TlsStream
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function tls_alpn_selected(tls: TlsStream, out: *u8, out_cap: i32): i32 {
  unsafe { return tls_plat.net_tls_alpn_selected_c(tls.ctx_handle, out, out_cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `tls_alpn_is_h2`.
 * Implements `tls_alpn_is_h2`.
 * @param tls TlsStream
 * @return bool
 */
export function tls_alpn_is_h2(tls: TlsStream): bool {
  let ok: i32 = 0;
  unsafe {
    ok = tls_plat.net_tls_alpn_is_h2_c(tls.ctx_handle);
  }
  if (ok != 0) { return true; }
  return false;
}

/** Exported function `tls_read`.
 * Read path helper `tls_read`.
 * @param tls TlsStream
 * @param buf *u8
 * @param cap i32
 * @return i32
 */
export function tls_read(tls: TlsStream, buf: *u8, cap: i32): i32 {
  unsafe { return tls_plat.net_tls_read_c(tls.ctx_handle, buf, cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `tls_write`.
 * Write path helper `tls_write`.
 * @param tls TlsStream
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function tls_write(tls: TlsStream, buf: *u8, len: i32): i32 {
  unsafe { return tls_plat.net_tls_write_c(tls.ctx_handle, buf, len); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `tls_close`.
 * Implements `tls_close`.
 * @param tls TlsStream
 * @return i32
 */
export function tls_close(tls: TlsStream): i32 {
  unsafe { return tls_plat.net_tls_close_c(tls.ctx_handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `tls_last_error`.
 * Implements `tls_last_error`.
 * @return i32
 */
export function tls_last_error(): i32 {
  unsafe { return tls_plat.net_tls_last_error_c(); }
  return 0; // unreachable — typeck workaround
}

/* See implementation. */
export struct TcpConnPool {
  handle: i64;
}

/** Exported function `tcp_pool_new`.
 * Implements `tcp_pool_new`.
 * @param host u32
 * @param port u32
 * @param max_idle i32
 * @return TcpConnPool
 */
export function tcp_pool_new(host: u32, port: u32, max_idle: i32): TcpConnPool {
  let _rc: TcpConnPool = 0;
  unsafe { _rc = TcpConnPool { handle: tcp_pool_plat.net_tcp_pool_create_c(host, port, max_idle) }; }
  return _rc;
}

/** Exported function `tcp_pool_acquire`.
 * Implements `tcp_pool_acquire`.
 * @param pool *TcpConnPool
 * @param timeout_ms u32
 * @return i32
 */
export function tcp_pool_acquire(pool: *TcpConnPool, timeout_ms: u32): i32 {
  unsafe { return tcp_pool_plat.net_tcp_pool_acquire_c(pool.handle, timeout_ms); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `tcp_pool_release`.
 * Implements `tcp_pool_release`.
 * @param pool *TcpConnPool
 * @param fd i32
 * @return i32
 */
export function tcp_pool_release(pool: *TcpConnPool, fd: i32): i32 {
  unsafe { return tcp_pool_plat.net_tcp_pool_release_c(pool.handle, fd); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `tcp_pool_drain`.
 * Implements `tcp_pool_drain`.
 * @param pool *TcpConnPool
 * @return void
 */
export function tcp_pool_drain(pool: *TcpConnPool): void {
  unsafe {
    tcp_pool_plat.net_tcp_pool_drain_c(pool.handle);
  }
}

/** Exported function `tcp_pool_destroy`.
 * Implements `tcp_pool_destroy`.
 * @param pool *TcpConnPool
 * @return void
 */
export function tcp_pool_destroy(pool: *TcpConnPool): void {
  unsafe {
    tcp_pool_plat.net_tcp_pool_destroy_c(pool.handle);
  }
  let zero: i64 = 0;
  pool.handle = zero;
}

/** Exported function `tcp_pool_connect_count`.
 * Implements `tcp_pool_connect_count`.
 * @param pool *TcpConnPool
 * @return i32
 */
export function tcp_pool_connect_count(pool: *TcpConnPool): i32 {
  unsafe { return tcp_pool_plat.net_tcp_pool_connect_count_c(pool.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `tcp_pool_idle_count`.
 * Implements `tcp_pool_idle_count`.
 * @param pool *TcpConnPool
 * @return i32
 */
export function tcp_pool_idle_count(pool: *TcpConnPool): i32 {
  unsafe { return tcp_pool_plat.net_tcp_pool_idle_count_c(pool.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `tcp_pool_smoke`.
 * Implements `tcp_pool_smoke`.
 * @return i32
 */
export function tcp_pool_smoke(): i32 {
  unsafe { return tcp_pool_plat.net_tcp_pool_smoke_c(); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `net_module_anchor_c`.
 * Implements `net_module_anchor_c`.
 * @return i32
 */
export function net_module_anchor_c(): i32 { return 0; }
