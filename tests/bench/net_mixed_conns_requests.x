// See implementation.
// See implementation.
const net = import("std.net");
const process = import("std.process");
const time = import("std.time");
const io = import("std.io");

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

/** Internal function `bench_swap_i64`.
 * Implements `bench_swap_i64`.
 * @param a *i64
 * @param b *i64
 * @return void
 */
function bench_swap_i64(a: *i64, b: *i64): void {
  let t: i64 = a[0];
  a[0] = b[0];
  b[0] = t;
}

/** Internal function `bench_sort_latencies`.
 * Implements `bench_sort_latencies`.
 * @param lat *i64
 * @param n i32
 * @return void
 */
function bench_sort_latencies(lat: *i64, n: i32): void {
  let i: i32 = 0;
  while (i < n) {
    let j: i32 = 0;
    while (j + 1 < n) {
      if (lat[j] > lat[j + 1]) {
        bench_swap_i64(lat + j, lat + (j + 1));
      }
      j = j + 1;
    }
    i = i + 1;
  }
}

/** Internal function `bench_p99_us`.
 * Implements `bench_p99_us`.
 * @param lat *i64
 * @param n i32
 * @return i64
 */
function bench_p99_us(lat: *i64, n: i32): i64 {
  if (n <= 0) { return 0; }
  bench_sort_latencies(lat, n);
  let idx: i32 = (n * 99) / 100;
  if (idx >= n) { idx = n - 1; }
  return lat[idx];
}

/** Internal function `mixed_write_512`.
 * Write path helper `mixed_write_512`.
 * @param stream TcpStream
 * @param buf *u8
 * @return i32
 */
function mixed_write_512(stream: TcpStream, buf: *u8): i32 {
  let need: i32 = 512;
  let nw: i32 = net.write_batch(stream, buf, 512, 0 as *u8, 0, 0 as *u8, 0, 0 as *u8, 0, 1, 0);
  if (nw != need) { return -1; }
  return nw;
}

/** Internal function `mixed_read_512`.
 * Read path helper `mixed_read_512`.
 * @param stream TcpStream
 * @param buf *u8
 * @return i32
 */
function mixed_read_512(stream: TcpStream, buf: *u8): i32 {
  let need: i32 = 512;
  let nr: i32 = net.read_batch(stream, buf, 512, 0 as *u8, 0, 0 as *u8, 0, 0 as *u8, 0, 1, 0);
  if (nr != need) { return -1; }
  return nr;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let mixed_port: u32 = 38459;
  if (process.args_count() >= 2) {
    mixed_port = bench_parse_port(process.arg(1), mixed_port);
  }
  let mixed_conns: i32 = 256;
  let mixed_rounds: i32 = 16;
  let payload: i32 = 512;
  let addr: Ipv4Addr = Ipv4Addr { a: 127, b: 0, c: 0, d: 1 };
  let lat_buf: i64[4096] = 0;
  let lat: *i64 = lat_buf;
  let n_samples: i32 = 0;
  let sum: i32 = 0;
  let ci: i32 = 0;
  while (ci < mixed_conns) {
    let stream: TcpStream = net.connect_blocking(addr, mixed_port, 0);
    if (stream.fd < 0) { return 1; }
    let round: i32 = 0;
    while (round < mixed_rounds) {
      let buf: u8[512] = [];
      let bi: i32 = 0;
      while (bi < payload) {
        buf[bi] = ((ci + round + bi) & 255) as u8;
        bi = bi + 1;
      }
      let t0: i64 = time.now_monotonic_us();
      if (mixed_write_512(stream, &buf[0]) < 0) {
        net.close_stream(stream);
        return 2;
      }
      if (mixed_read_512(stream, &buf[0]) < 0) {
        net.close_stream(stream);
        return 3;
      }
      let t1: i64 = time.now_monotonic_us();
      if (n_samples < 4096) {
        let d: i64 = t1 - t0;
        if (d <= 0) { d = 1; }
        lat[n_samples] = d;
        n_samples = n_samples + 1;
      }
      bi = 0;
      while (bi < payload) {
        sum = sum + (buf[bi] as i32);
        bi = bi + 1;
      }
      round = round + 1;
    }
    if (net.close_stream(stream) != 0) { return 4; }
    ci = ci + 1;
  }
  /* See implementation. */
  let p99: i64 = bench_p99_us(lat, n_samples);
  bench_write_p99_line(p99);
  return sum & 255;
}

/** Internal function `bench_u64_len`.
 * Query helper `bench_u64_len`.
 * @param v i64
 * @return i32
 */
function bench_u64_len(v: i64): i32 {
  if (v <= 0) { return 1; }
  let n: i32 = 0;
  let x: i64 = v;
  while (x > 0) {
    n = n + 1;
    x = x / 10;
  }
  return n;
}

/** Internal function `bench_u64_fill`.
 * Implements `bench_u64_fill`.
 * @param buf *u8
 * @param len i32
 * @param v i64
 * @return void
 */
function bench_u64_fill(buf: *u8, len: i32, v: i64): void {
  let x: i64 = v;
  if (x <= 0) {
    buf[0] = 48;
    return;
  }
  let pos: i32 = len - 1;
  while (x > 0 && pos >= 0) {
    let d: i32 = (x % 10) as i32;
    buf[pos] = (48 + d) as u8;
    x = x / 10;
    pos = pos - 1;
  }
}

/** Internal function `bench_write_p99_line`.
 * Write path helper `bench_write_p99_line`.
 * @param p99 i64
 * @return void
 */
function bench_write_p99_line(p99: i64): void {
  let hdr: u8[13] = [66, 69, 78, 67, 72, 95, 80, 57, 57, 95, 85, 83, 61];
  let dig: u8[24] = 0;
  let dlen: i32 = bench_u64_len(p99);
  bench_u64_fill(&dig[0], dlen, p99);
  io.write_stderr(&hdr[0], 13, 0);
  io.write_stderr(&dig[0], dlen as usize, 0);
  let nl: u8 = 10;
  io.write_stderr(&nl, 1, 0);
}
