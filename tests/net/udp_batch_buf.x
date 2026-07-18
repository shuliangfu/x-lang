// See implementation.
// See implementation.
const net = import("std.net");
// See implementation.
const driver = import("std.io.driver");

/* See implementation. */
extern function net_udp_bind_c(addr_u32: u32, port: u32): i32;
extern function net_udp_recv_many_buf_c(fd: i32, bufs: *Buffer, n: i32, timeout_ms: u32, out_sizes: *i32, out_addrs: *u32, out_ports: *u32): i32;
extern function net_udp_send_many_buf_c(fd: i32, addrs: *u32, ports: *u32, bufs: *Buffer, n: i32): i32;
extern function net_close_socket_c(fd: i32): i32;

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /* See implementation. */
  let loopback: u32 = 0x7f000001;
  let sock_fd: i32 = unsafe { net_udp_bind_c(loopback, 0) };
  if (sock_fd < 0) { return 1; }
  let recv_buf: u8[64] = 0;
  let recv_io: Buffer = Buffer { ptr: &recv_buf[0], len: 64, handle: 0 };
  let out_size0: i32 = 0;
  let out_addr0: u32 = 0;
  let out_port0: u32 = 0;
  let _recv: i32 = unsafe { net_udp_recv_many_buf_c(sock_fd, &recv_io, 1, 1, &out_size0, &out_addr0, &out_port0) };
  let send_addr0: u32 = loopback;
  let send_port0: u32 = 9;
  let payload: u8[4] = [1, 2, 3, 4];
  /* See implementation. */
  let send_io: Buffer = Buffer { ptr: &payload[0], len: 4, handle: 0 };
  let n_send: i32 = unsafe { net_udp_send_many_buf_c(sock_fd, &send_addr0, &send_port0, &send_io, 1) };
  let c: i32 = unsafe { net_close_socket_c(sock_fd) };
  if (c != 0) { return 2; }
  /* See implementation. */
  if (n_send < 0) { return 0; }
  if (n_send != 1) { return 3; }
  return 0;
}
