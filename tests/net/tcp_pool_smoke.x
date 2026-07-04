// STD-164：TCP 连接池 idle 复用烟测
const net = import("std.net");

function main(): i32 {
  if (net.tcp_pool_smoke() != 0) { return 1; }

  let pool: TcpConnPool = net.tcp_pool_new(0x7f000001, 9, 1);
  let zero: i64 = 0;
  if (pool.handle == zero) { return 2; }
  if (net.tcp_pool_connect_count(&pool) != 0) { return 3; }
  net.tcp_pool_destroy(&pool);
  if (pool.handle != zero) { return 4; }
  return 0;
}
