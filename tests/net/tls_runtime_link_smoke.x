// See implementation.
const net = import("std.net");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /* tls_is_available is bool. Backend name bytes are u8. */
  if (!net.tls_is_available()) {
    return 1;
  }
  let name: *u8 = net.tls_backend_name();
  if (name == 0 as *u8) {
    return 2;
  }
  if (name[0] != (111 as u8) || name[1] != (112 as u8)) {
    return 3;
  }
  return 0;
}
