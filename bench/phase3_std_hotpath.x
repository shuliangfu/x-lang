/**
 * See implementation.
 * See implementation.
 */
const datetime = import("std.datetime");
const compress = import("std.compress");
const net = import("std.net");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let utc_name: u8[4] = [85, 84, 67, 0];
  let tz: TimeZone = TimeZone { offset_min: 0, iana_id: -1 };
  let zero: i64 = 0;
  let i: i32 = 0;
  while (i < 50000) {
    datetime.timezone_iana(&utc_name[0], 3, &tz);
    let _: i32 = compress.format_brotli();
    let _: i32 = compress.compress_state_bytes_for(compress.format_zstd());
    let pool: TcpConnPool = net.tcp_pool_new(0x7f000001, 9, 1);
    if (pool.handle != zero) {
      net.tcp_pool_drain(&pool);
      net.tcp_pool_destroy(&pool);
    }
    i = i + 1;
  }
  return 0;
}
