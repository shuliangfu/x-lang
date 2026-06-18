/**
 * STD-030 烟测：TLS 桩后端 — tls_is_available 为 false，握手返回 TLS_NOT_IMPL。
 */
const debug = import("core.debug");
const net = import("std.net");

function main(): i32 {
  if (net.tls_is_available()) { return 1; }
  let name: *u8 = net.tls_backend_name();
  if (name == 0 as *u8) { return 2; }
  if (*name != 115) { return 3; }
  debug.assert_eq_i32(tls_last_error(), 0);
  let bad: TcpStream = TcpStream { fd: -1 };
  let tls: TlsStream = tls_connect_client(bad, 0 as *u8);
  if (tls.ctx_handle != 0) { return 4; }
  debug.assert_eq_i32(tls_last_error(), -2);
  let plain: TcpStream = TcpStream { fd: 0 };
  let tls2: TlsStream = tls_connect_client(plain, 0 as *u8);
  if (tls2.ctx_handle != 0) { return 5; }
  debug.assert_eq_i32(tls_last_error(), -9);
  let ign: i32 = tls_close(tls2);
  if (ign != 0) { return 6; }
  return 0;
}
