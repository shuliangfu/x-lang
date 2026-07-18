// See implementation.
const http = import("std.http");
const net = import("std.net");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (http.network_smoke() != 0) { return 1; }

  let wire: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  if (net.tls_alpn_h2_http1_wire(&wire[0], 16) != 12) { return 2; }
  if (wire[0] != 2 || wire[1] != 104 || wire[2] != 50) { return 3; }

  if (http.err_network_h2() != -1231) { return 4; }

  // See implementation.
  let _avail: bool = http.network_is_available();

  return 0;
}
