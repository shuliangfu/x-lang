/**
 * Stage9 Cap residual 9.1.7 slice1 probe: Linux sendmmsg/recvmmsg without libc
 * (std.net udp_batch → runtime_net_udp_batch Cap xlang_net_cap.h).
 *
 * Contract: bind two UDP sockets; send_many 2 datagrams; recv_many 2; payloads match.
 * PLATFORM: LINUX|x86_64 gold.
 */
const net = import("std.net");

extern function net_udp_bind_c(addr_u32: u32, port_u32: u32): i32;
extern function net_udp_send_many_c(fd: i32, a0: u32, port0: u32, p0: *u8, l0: usize, a1: u32, port1: u32, p1: *u8, l1: usize, n: i32): i32;
extern function net_udp_recv_many_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, n: i32, timeout_ms: u32, out_sizes: *i32, out_addrs: *u32, out_ports: *u32): i32;
extern function net_close_socket_c(fd: i32): i32;

/**
 * Probe entry for Cap residual 9.1.7 slice1 mmsg face.
 * @return i32 — 0 ok; 1 bind fail; 2 send fail; 3 recv fail; 4 payload mismatch; 5 close fail
 */
export function main(): i32 {
  /* Host-order 127.0.0.1; bind applies htonl inside Cap/set_addr_port. */
  let loopback: u32 = 0x7f000001;
  let rx_port: u32 = 39837;
  let tx_port: u32 = 39838;
  let rx: i32 = 0;
  let tx: i32 = 0;
  let ns: i32 = 0;
  let nr: i32 = 0;
  let c0: i32 = 0;
  let c1: i32 = 0;
  let p0: u8[4] = [0x41, 0x42, 0x43, 0x44];
  let p1: u8[4] = [0x31, 0x32, 0x33, 0x34];
  let r0: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let r1: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let sizes: i32[2] = [0, 0];
  let addrs: u32[2] = [0, 0];
  let ports: u32[2] = [0, 0];

  unsafe {
    rx = net_udp_bind_c(loopback, rx_port);
    tx = net_udp_bind_c(loopback, tx_port);
  }
  if (rx < 0 || tx < 0) {
    return 1;
  }

  /* sendmmsg Cap path: two datagrams to rx_port. */
  unsafe {
    ns = net_udp_send_many_c(tx, loopback, rx_port, &p0[0], 4, loopback, rx_port, &p1[0], 4, 2);
  }
  if (ns != 2) {
    unsafe {
      net_close_socket_c(rx);
      net_close_socket_c(tx);
    }
    return 2;
  }

  /* recvmmsg Cap path: poll+recv with short timeout after send. */
  unsafe {
    nr = net_udp_recv_many_c(rx, &r0[0], 8, &r1[0], 8, 2, 500, &sizes[0], &addrs[0], &ports[0]);
  }
  if (nr != 2 || sizes[0] != 4 || sizes[1] != 4) {
    unsafe {
      net_close_socket_c(rx);
      net_close_socket_c(tx);
    }
    return 3;
  }
  if (r0[0] != 0x41 || r0[1] != 0x42 || r0[2] != 0x43 || r0[3] != 0x44) {
    unsafe {
      net_close_socket_c(rx);
      net_close_socket_c(tx);
    }
    return 4;
  }
  if (r1[0] != 0x31 || r1[1] != 0x32 || r1[2] != 0x33 || r1[3] != 0x34) {
    unsafe {
      net_close_socket_c(rx);
      net_close_socket_c(tx);
    }
    return 4;
  }

  unsafe {
    c0 = net_close_socket_c(rx);
    c1 = net_close_socket_c(tx);
  }
  if (c0 != 0 || c1 != 0) {
    return 5;
  }
  return 0;
}
