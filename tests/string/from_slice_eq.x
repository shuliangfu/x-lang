// See implementation.
const string = import("std.string");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let buf: u8[4] = [97, 98, 99, 0];
  let s: String = string.string_from_slice(&buf[0], 3);
  if (string.length(s) != 3) { return 1; }
  if (string.is_empty(s) != 0) { return 2; }
  let t: String = string.string_from_slice(&buf[0], 3);
  if (string.string_eq(s, t) != 1) { return 3; }
  let u: String = string.new();
  if (string.is_empty(u) != 1) { return 4; }
  if (string.string_eq(s, u) != 0) { return 5; }
  return 0;
}
