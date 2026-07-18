// See implementation.
// See implementation.
const net = import("std.net");

/* See implementation. */
extern function net_tcp_listen_c(addr_u32: u32, port: u32): i32;

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /* See implementation. */
  let probe: u32 = ((127 as u32) << 24) | ((0 as u32) << 16) | ((0 as u32) << 8) | (1 as u32);
  let listener_fd: i32 = unsafe { net_tcp_listen_c(probe, 8080) };
  if (listener_fd < 0) { return 1; }
  // See implementation.
  return 0;
}
