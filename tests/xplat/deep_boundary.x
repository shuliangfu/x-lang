// See implementation.
const time = import("std.time");
const env = import("std.env");
const path = import("std.path");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  let buf: u8[32] = [];
  if (time.format_wall_rfc3339(&buf[0], 32) < 20) { return 1; }
  // See implementation.
  let off: i32 = time.wall_local_offset_min();
  if (off < -840 || off > 840) { return 2; }
  // See implementation.
  let tmp: u8[64] = [];
  if (env.temp_dir(&tmp[0], 64) < 1) { return 3; }
  // See implementation.
  let t0: i64 = time.now_monotonic_ns();
  let t1: i64 = time.now_monotonic_ns();
  if (t1 < t0) { return 4; }
  // See implementation.
  let a: u8[4] = [47, 116, 109, 112];
  let b: u8[4] = [102, 111, 111, 0];
  let out: u8[16] = [];
  if (path.join(&out[0], 16, &a[0], 4, &b[0], 3) < 4) { return 5; }
  // See implementation.
  let tm: Timer = time.start();
  time.sleep_ms(10);
  if (time.elapsed_ms(tm) < 5) { return 6; }
  return 0;
}
