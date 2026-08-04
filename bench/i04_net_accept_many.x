// See implementation.
// See implementation.
const net = import("std.net");
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
  let net_bench_port: u32 = 38456;
  if (process.args_count() >= 2) {
    net_bench_port = bench_parse_port(process.arg(1), net_bench_port);
  }
  let net_bench_conns: i32 = 4096;
  let addr: Ipv4Addr = Ipv4Addr { a: 127, b: 0, c: 0, d: 1 };
  let listener: TcpListener = net.listen(addr, net_bench_port);
  if (listener.fd < 0) { return 1; }
  let out_buf: TcpStream[64] = 0;
  let out: TcpStream[] = out_buf;
  let total: i32 = 0;
  /* See implementation. */
  while (total < net_bench_conns) {
    let n: u32 = net.accept_many(listener, out, 5000);
    if (n == 0) {
      net.close_listener(listener);
      return 2;
    }
    let j: u32 = 0;
    while (j < n) {
      net.close_stream(out[j]);
      j = j + 1;
    }
    total = total + (n as i32);
  }
  if (net.close_listener(listener) != 0) { return 3; }
  if (total != net_bench_conns) { return 4; }
  return 0;
}
