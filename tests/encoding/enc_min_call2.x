const encoding = import("std.encoding");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let ok: u8[4] = [97, 98, 99, 0];
  let v: i32 = encoding.utf8_valid(&ok[0], 3);
  return 0;
}
