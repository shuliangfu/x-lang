// 测试 std.string：StrView 零拷贝只读、string_view_*、string_data_ptr、string_eq_view
//
// 【文件职责】验证 (ptr, len) 通过 StrView 做只读操作无拷贝；String 通过
// string_data_ptr + string_len 零拷贝输出。
const string = import("std.string");

function main(): i32 {
  // StrView 零拷贝：直接对缓冲区做 view 操作，不 string_from_slice
  let buf: u8[8] = [97, 98, 99, 100, 101, 0, 0, 0];
  let v: StrView = string.view(&buf[0], 5);
  if (string.len(v) != 5) { return 1; }
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
  // string_eq_view：String 与 view 比较，不把 view 拷入 String
  let s: String = string.string_from_slice(&buf[0], 5);
  if (string.string_eq_view(s, v) != 1) { return 11; }
  if (string.string_compare_view(s, v) != 0) { return 12; }
  // string_data_ptr：零拷贝输出，ptr 与 String 内部一致
  let p: *u8 = string.string_data_ptr(&s);
  if (p == 0) { return 13; }
  if (string.len(s) != 5) { return 14; }
  if (p[0] != 97 || p[1] != 98) { return 15; }
  if (string.string_len_ptr(&s) != 5) { return 16; }
  return 0;
}
