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
  let pool: TcpConnPool = net.tcp_pool_new(0x7f000001, 9, 1);
  let zero: i64 = 0;
  if (pool.handle == zero) { return 1; }
  if (net.tcp_pool_connect_count(&pool) != 0) { return 2; }
  if (net.tcp_pool_idle_count(&pool) != 0) { return 3; }
  net.tcp_pool_drain(&pool);
  net.tcp_pool_destroy(&pool);
  return 0;
}
