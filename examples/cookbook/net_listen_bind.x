/**
 * Cookbook NET-01：TcpListener 绑定本地端口（阻塞 accept 烟测见 NET-02）。
 */
const net = import("std.net");

function main(): i32 {
  let addr: Ipv4Addr = Ipv4Addr { a: 127, b: 0, c: 0, d: 1 };
  let listener: TcpListener = net.listen(addr, 38555);
  if (listener.fd < 0) { return 1; }
  if (net.close_listener(listener) != 0) { return 2; }
  return 0;
}
