/**
 * Cookbook NET-02：UdpSocket 绑定本地端口并收一单包（自发自收需同进程双 fd，此处仅 bind）。
 */
const net = import("std.net");

function main(): i32 {
  let addr: Ipv4Addr = Ipv4Addr { a: 127, b: 0, c: 0, d: 1 };
  let sock: UdpSocket = net.udp_bind(addr, 38556);
  if (sock.fd < 0) { return 1; }
  if (net.close_udp(sock) != 0) { return 2; }
  return 0;
}
