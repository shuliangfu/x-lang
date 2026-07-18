// See implementation.
const sqlite = import("std.db.sqlite");
const net = import("std.net");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let sa: i32 = sqlite.is_available();
  if (sa != 0 && sa != 1) { return 1; }
  let tn: bool = net.tls_is_available();
  if (tn) {
    let _: *u8 = net.tls_backend_name();
  }
  return 0;
}
