// See implementation.
//
// See implementation.
const net = import("std.net");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let err: i32 = 0;
  let addr_u32: u32 = 0;

  // See implementation.
  let bad: u8[16] = [105, 110, 118, 97, 108, 105, 100, 46, 105, 110, 118, 97, 108, 105, 100, 0];
  if (net.resolve_ex(&bad[0], &addr_u32, &err) == 0) {
    return 1;
  }
  if (err != net.resolve_err_host_not_found() && err != net.resolve_err_no_data()) {
    return 2;
  }

  // "localhost" IPv4
  let host: u8[10] = [108, 111, 99, 97, 108, 104, 111, 115, 116, 0];
  err = 0;
  addr_u32 = 0 as u32;
  if (net.resolve_ex(&host[0], &addr_u32, &err) != 0) {
    return 0;
  }
  if (err != net.resolve_err_ok()) {
    return 3;
  }
  let v4: Ipv4Addr = net.packed_to_ipv4(addr_u32);
  if (v4.a != 127) {
    return 4;
  }

  // See implementation.
  let out6: u8[16] = [];
  err = 0;
  if (resolve_ipv6(&host[0], &out6[0], &err) != 0) {
    return 0;
  }
  if (err != net.resolve_err_ok()) {
    return 5;
  }
  if (out6[15] != 1) {
    return 6;
  }

  // listen_ipv6 on ::1
  let lb: Ipv6Addr = net.ipv6_loopback();
  let ln: TcpListener = net.listen_ipv6(lb, 0);
  if (ln.fd < 0) {
    return 7;
  }
  if (net.close_listener(ln) != 0) {
    return 8;
  }
  return 0;
}
