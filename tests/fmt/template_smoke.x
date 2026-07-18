// See implementation.
const fmt = import("std.fmt");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let pat: u8[5] = [120, 123, 125, 121, 0];
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.format_template(&buf[0], 32, &pat[0], 4, 42);
  if (n < 3) { return 1; }
  if (buf[0] != 120 || buf[1] != 52 || buf[2] != 50) { return 2; }
  return 0;
}
