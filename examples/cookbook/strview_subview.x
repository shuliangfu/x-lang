/**
 * Cookbook STR-01：StrView 零拷贝 subview（STD-016 / ZC-4）。
 */
const string = import("std.string");

function main(): i32 {
  let buf: u8[8] = [97, 98, 99, 100, 101, 102, 103, 0];
  let full: StrView = string.view(&buf[0], 7);
  let mid: StrView = string.string_view_subview(full, 2, 3);
  if (string.len(mid) != 3) { return 1; }
  if (string.string_view_get(mid, 0) != 99) { return 2; }
  let expect: u8[3] = [99, 100, 101];
  let exp_v: StrView = string.view(&expect[0], 3);
  if (string.string_view_eq(mid, exp_v) != 1) { return 3; }
  return 0;
}
