/**
 * See implementation.
 */
const net = import("std.net");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let addr: Ipv4Addr = Ipv4Addr { a: 127, b: 0, c: 0, d: 1 };
  let sock: UdpSocket = net.udp_bind(addr, 38556);
  if (sock.fd < 0) { return 1; }
  if (net.close_udp(sock) != 0) { return 2; }
  return 0;
}
