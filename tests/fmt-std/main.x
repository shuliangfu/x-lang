// See implementation.
const fmt = import("std.fmt");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let buf: u8[32] = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  ];
  let total: i32 = fmt.format(buf, 32, 10, 20);
  return if (total == 4) { 0 } else { 1 };
}
