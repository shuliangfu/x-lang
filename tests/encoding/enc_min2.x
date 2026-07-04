// 最小：let + if 内 import 调用
const encoding = import("std.encoding");

function main(): i32 {
  let ok: u8[4] = [97, 98, 99, 0];
  if (encoding.utf8_valid(&ok[0], 3) != 1) { return 1; }
  return 0;
}
