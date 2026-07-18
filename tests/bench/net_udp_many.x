// See implementation.
// See implementation.
const net = import("std.net");
const driver = import("std.io.driver");
const process = import("std.process");

/** Internal function `bench_parse_port`.
 * Implements `bench_parse_port`.
 * @param s *u8
 * @param default_port u32
 * @return u32
 */
function bench_parse_port(s: *u8, default_port: u32): u32 {
  if (s == 0 as *u8) { return default_port; }
  let n: u32 = 0;
  let i: i32 = 0;
  while (true) {
    let c: u8 = s[i];
    if (c == 0) { break; }
    if (c < 48 || c > 57) { return default_port; }
    n = n * 10 + ((c - 48) as u32);
    i = i + 1;
  }
  if (i <= 0) { return default_port; }
  return n;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /* See implementation. */
  let udp_port: u32 = 38458;
  if (process.args_count() >= 2) {
    udp_port = bench_parse_port(process.arg(1), udp_port);
  }
  let udp_pkts: i32 = 4096;
  let batch: i32 = 8;
  let pkt_len: usize = 64;
  let addr: Ipv4Addr = Ipv4Addr { a: 127, b: 0, c: 0, d: 1 };
  let sock: UdpSocket = net.udp_bind(addr, udp_port);
  if (sock.fd < 0) { return 1; }
  let b0: u8[64] = 0;
  let b1: u8[64] = 0;
  let b2: u8[64] = 0;
  let b3: u8[64] = 0;
  let b4: u8[64] = 0;
  let b5: u8[64] = 0;
  let b6: u8[64] = 0;
  let b7: u8[64] = 0;
  let bufs: Buffer[8] = [
    Buffer { ptr: &b0[0], len: pkt_len, handle: 0 },
    Buffer { ptr: &b1[0], len: pkt_len, handle: 0 },
    Buffer { ptr: &b2[0], len: pkt_len, handle: 0 },
    Buffer { ptr: &b3[0], len: pkt_len, handle: 0 },
    Buffer { ptr: &b4[0], len: pkt_len, handle: 0 },
    Buffer { ptr: &b5[0], len: pkt_len, handle: 0 },
    Buffer { ptr: &b6[0], len: pkt_len, handle: 0 },
    Buffer { ptr: &b7[0], len: pkt_len, handle: 0 }
  ];
  let out_sizes: i32[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let out_addrs: u32[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let out_ports: u32[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let total: i32 = 0;
  let sum: i32 = 0;
  /* See implementation. */
  while (total < udp_pkts) {
    let n: i32 = net.udp_recv_many_buf(sock, &bufs[0], batch, 5000, &out_sizes[0], &out_addrs[0], &out_ports[0]);
    if (n <= 0) {
      net.close_udp(sock);
      return 2;
    }
    let j: i32 = 0;
    while (j < n) {
      sum = sum + out_sizes[j];
      j = j + 1;
    }
    total = total + n;
  }
  if (net.close_udp(sock) != 0) { return 3; }
  if (total != udp_pkts) { return 4; }
  return sum & 255;
}
