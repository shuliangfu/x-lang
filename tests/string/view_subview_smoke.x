/**
 * ZC-4 smoke：StrView 零拷贝 subview（string_view_subview）。
 * 栈上 buf → 全视图 → 子视图 eq/compare；exit 0。
 */
const string = import("std.string");

function main(): i32 {
  let buf: u8[8] = [97, 98, 99, 100, 101, 102, 103, 0];
  let full: StrView = string.view(&buf[0], 7);
  let mid: StrView = string.string_view_subview(full, 2, 3);
  if (string.len(mid) != 3) { return 1; }
  if (string.string_view_get(mid, 0) != 99) { return 2; }
  if (string.string_view_get(mid, 2) != 101) { return 3; }
  let tail: StrView = string.string_view_subview(full, 5, 10);
  if (string.len(tail) != 2) { return 4; }
  if (string.string_view_get(tail, 0) != 102) { return 5; }
  let empty: StrView = string.string_view_subview(full, 20, 1);
  if (string.is_empty(empty) != 1) { return 6; }
  let expect: u8[3] = [99, 100, 101];
  let exp_v: StrView = string.view(&expect[0], 3);
  if (string.string_view_eq(mid, exp_v) != 1) { return 7; }
  if (string.string_view_compare(mid, exp_v) != 0) { return 8; }
  return 0;
}
