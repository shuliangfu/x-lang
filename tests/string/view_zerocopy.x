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
  // See implementation.
  let buf: u8[8] = [97, 98, 99, 100, 101, 0, 0, 0];
  let v: StrView = string.view(&buf[0], 5);
  if (string.length(v) != 5) { return 1; }
  if (string.is_empty(v) != 0) { return 2; }
  if (string.string_view_get(v, 0) != 97) { return 3; }
  let v2: StrView = string.view(&buf[0], 5);
  if (string.string_view_eq(v, v2) != 1) { return 4; }
  if (string.string_view_compare(v, v2) != 0) { return 5; }
  if (string.string_view_find_char(v, 99) != 2) { return 6; }
  let pre: u8[2] = [97, 98];
  if (string.string_view_starts_with(v, &pre[0], 2) != 1) { return 7; }
  let suf: u8[2] = [100, 101];
  if (string.string_view_ends_with(v, &suf[0], 2) != 1) { return 8; }
  if (string.string_view_contains(v, &pre[0], 2) != 1) { return 9; }
  if (string.string_view_find_slice(v, &pre[0], 2) != 0) { return 10; }
  // See implementation.
  let s: String = string.string_from_slice(&buf[0], 5);
  if (string.string_eq_view(s, v) != 1) { return 11; }
  if (string.string_compare_view(s, v) != 0) { return 12; }
  // See implementation.
  let p: *u8 = string.string_data_ptr(&s);
  if (p == 0) { return 13; }
  if (string.length(s) != 5) { return 14; }
  if (p[0] != 97 || p[1] != 98) { return 15; }
  if (string.string_len_ptr(&s) != 5) { return 16; }
  return 0;
}
