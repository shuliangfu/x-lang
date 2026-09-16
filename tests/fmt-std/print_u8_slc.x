// Regression: fmt.println(u8[]) uses TYPE_SLICE mid std_fmt_println_u8_slc.
// Product ABI: slice formals are fat-pointer addresses (not by-value dual-GP).
// u8[N] still goes JSON schema; this file covers the slice overload path.
const fmt = import("std.fmt");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32 — 0 on success
 */
function main(): i32 {
  let msg: u8[5] = [72, 101, 108, 108, 111];
  let s: u8[] = msg;
  let n: i32 = fmt.println(s);
  if (n != 0) { return 1; }
  let m: i32 = fmt.print(s);
  if (m != 0) { return 2; }
  return 0;
}
