/**
 * See implementation.
 * See implementation.
 */
const net = import("std.net");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let addr: Ipv4Addr = Ipv4Addr { a: 127, b: 0, c: 0, d: 1 };
  /* See implementation. */
  let stream: TcpStream = net.connect_blocking(addr, 39999, 100);
  if (stream.fd < 0) { return 2; }
  let buf: u8[4] = [1, 2, 3, 4];
  let nw: i32 = net.write_batch(stream, &buf[0], 4, 0 as *u8, 0, 0 as *u8, 0, 0 as *u8, 0, 1, 0);
  if (net.close_stream(stream) != 0) { return 3; }
  if (nw != 4) { return 4; }
  return 0;
}
