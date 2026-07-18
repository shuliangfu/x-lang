// See implementation.
//
// See implementation.
// See implementation.
const string = import("std.string");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let buf: u8[8] = [97, 98, 99, 100, 101, 102, 103, 0];
  let full: StrView = string.view(&buf[0], 7);
  // See implementation.
  if (string.is_empty(string.view(&buf[0], 0)) != 1) { return 1; }
  // See implementation.
  let mid: StrView = string.string_view_subview(full, 2, 3);
  if (string.len(mid) != 3) { return 2; }
  // See implementation.
  let empty: StrView = string.string_view_subview(full, 99, 1);
  if (string.is_empty(empty) != 1) { return 3; }
  // See implementation.
  let tail: StrView = string.string_view_subview(full, 5, 99);
  if (string.len(tail) != 2) { return 4; }
  // case 5：string_capacity
  if (string.string_capacity() != 256) { return 5; }
  // See implementation.
  let s: String = string.new();
  if (string.len(s) != 0) { return 6; }
  // See implementation.
  let s2: String = s;
  if (string.string_append_char(&s2, 120) != 0) { return 7; }
  let xb: u8[1] = [120];
  let xs: String = string.string_from_slice(&xb[0], 1);
  if (string.string_compare(s2, xs) != 0) { return 8; }
  // See implementation.
  let yz: u8[2] = [121, 122];
  if (string.string_starts_with(s2, &yz[0], 2) != 0) { return 9; }
  // See implementation.
  if (string.string_find_char(s2, 121) != -1) { return 10; }
  // case 10：string_view_eq
  let v1: StrView = string.view(&buf[0], 2);
  let ab: u8[2] = [97, 98];
  let v2: StrView = string.view(&ab[0], 2);
  if (string.string_view_eq(v1, v2) != 1) { return 11; }
  return 0;
}
