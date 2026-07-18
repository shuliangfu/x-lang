// See implementation.
const encoding = import("std.encoding");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let ok: u8[4] = [97, 98, 99, 0];
  if (encoding.utf8_valid(&ok[0], 3) != 1) { return 1; }
  return 0;
}
