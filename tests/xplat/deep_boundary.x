// STD-138 aggregate deep-boundary smoke (time / env / path).
// Gate counts `// case N` markers (min_smoke_cases in TSV).
const time = import("std.time");
const env = import("std.env");
const path = import("std.path");

/** Program entry: six must-green cross-platform probes.
 * @return i32 0 on success; 1..6 identify the failing case
 */
function main(): i32 {
  // case 1: wall-clock RFC3339 format fills >= 20 bytes
  let buf: u8[32] = [];
  if (time.format_wall_rfc3339(&buf[0], 32) < 20) { return 1; }
  // case 2: local UTC offset within +/-14h
  let off: i32 = time.wall_local_offset_min();
  if (off < -840 || off > 840) { return 2; }
  // case 3: temp_dir yields a non-empty path
  let tmp: u8[64] = [];
  if (env.temp_dir(&tmp[0], 64) < 1) { return 3; }
  // case 4: monotonic clock is non-decreasing
  let t0: i64 = time.now_monotonic_ns();
  let t1: i64 = time.now_monotonic_ns();
  if (t1 < t0) { return 4; }
  // case 5: path.join("/tmp", "foo") produces >= 4 bytes
  let a: u8[4] = [47, 116, 109, 112];
  let b: u8[4] = [102, 111, 111, 0];
  let out: u8[16] = [];
  if (path.join(&out[0], 16, &a[0], 4, &b[0], 3) < 4) { return 5; }
  // case 6: Timer + sleep_ms reports elapsed >= 5ms
  let tm: Timer = time.start();
  time.sleep_ms(10);
  if (time.elapsed_ms(tm) < 5) { return 6; }
  return 0;
}
