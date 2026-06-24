// STD-131：BytesView 查找 / 分割烟测（无 BytesView 局部变量，避免 macOS struct ABI SIGTRAP）
const str = import("core.str");

function main(): i32 {
  let buf: u8[11] = [104, 101, 108, 108, 111, 44, 119, 111, 114, 108, 100];
  let ptr: *u8 = &buf[0];
  let len: i32 = 11;
  let idx: i32 = str.bytes_view_index_of_byte(str.bytes_view(ptr, len), 44);
  if (idx != 5) { return 1; }
  let needle: u8[5] = [119, 111, 114, 108, 100];
  if (str.bytes_view_index_of(str.bytes_view(ptr, len), &needle[0], 5) != 6) { return 2; }
  if (str.bytes_view_contains_byte(str.bytes_view(ptr, len), 44) != 1) { return 3; }
  if (str.bytes_view_len(str.bytes_view_subview(str.bytes_view(ptr, len), 0, 5)) != 5) { return 4; }
  if (str.bytes_view_len(str.bytes_view_subview(str.bytes_view(ptr, len), 6, 5)) != 5) { return 5; }
  if (str.bytes_view_get(str.bytes_view(ptr, len), 0) != 104) { return 6; }
  if (str.bytes_view_get(str.bytes_view(ptr, len), 6) != 119) { return 7; }
  if (str.bytes_view_get(str.bytes_view(ptr, len), 10) != 100) { return 12; }
  let hi: u8[2] = [104, 101];
  if (str.bytes_view_starts_with(str.bytes_view(ptr, len), &hi[0], 2) != 1) { return 8; }
  if (str.bytes_view_starts_with(str.bytes_view(ptr, len), &hi[0], 3) != 0) { return 9; }
  if (str.bytes_view_contains_byte(str.bytes_view(ptr, 5), 44) != 0) { return 10; }
  if (str.bytes_view_index_of_byte(str.bytes_view(ptr, 5), 44) != -1) { return 11; }
  return 0;
}
