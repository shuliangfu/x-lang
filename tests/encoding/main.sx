// 测试 std.encoding：utf8_valid、utf8_len_chars、utf8_encode_rune、utf8_decode_rune、ascii_*
const encoding = import("std.encoding");

function main(): i32 {
  let ok: u8[4] = [97, 98, 99, 0];
  if (encoding.utf8_valid(&ok[0], 3) != 1) { return 1; }
  if (encoding.utf8_len_chars(&ok[0], 3) != 3) { return 2; }
  let out_r: u32 = 0;
  let n: i32 = encoding.utf8_decode_rune(&ok[0], 3, &out_r);
  if (n != 1 || out_r != 97) { return 3; }
  let buf: u8[8] = [];
  if (encoding.utf8_encode_rune(97, &buf[0]) != 1) { return 4; }
  if (encoding.ascii_is_alpha(97) != 1) { return 5; }
  if (encoding.ascii_to_upper(97) != 65) { return 6; }
  return 0;
}
