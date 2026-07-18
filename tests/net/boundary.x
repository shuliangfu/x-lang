// See implementation.
//
// See implementation.
// See implementation.
const net = import("std.net");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let loopback: Ipv4Addr = Ipv4Addr { a: 127, b: 0, c: 0, d: 1 };
  // See implementation.
  let u: u32 = net.addr_to_packed(loopback);
  if (u != 0x7f000001) { return 1; }
  // See implementation.
  let back: Ipv4Addr = net.packed_to_ipv4(u);
  if (back.a != 127 || back.d != 1) { return 2; }
  // case 3：0.0.0.0
  let zero: Ipv4Addr = Ipv4Addr { a: 0, b: 0, c: 0, d: 0 };
  if (net.addr_to_packed(zero) != 0) { return 3; }
  // case 4：net_batch_max
  if (net.batch_max() < 8) { return 4; }
  // See implementation.
  let sock: UdpSocket = net.udp_bind(loopback, 0);
  if (sock.fd < 0) { return 5; }
  // See implementation.
  let listener: TcpListener = net.listen(loopback, 0);
  if (listener.fd < 0) { return 6; }
  // See implementation.
  let la: SocketAddrV4 = net.listener_local_addr(listener);
  if (la.port == 0) { return 7; }
  // See implementation.
  let bcast: Ipv4Addr = Ipv4Addr { a: 255, b: 255, c: 255, d: 255 };
  if (net.addr_to_packed(bcast) != 0xffffffff) { return 8; }
  // See implementation.
  if (net.close_udp(sock) != 0) { return 9; }
  // See implementation.
  if (net.close_listener(listener) != 0) { return 10; }
  return 0;
}
