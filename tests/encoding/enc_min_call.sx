// 最小：顶层 import 调用（无 if）
const encoding = import("std.encoding");

function main(): i32 {
  let ok: u8[4] = [97, 98, 99, 0];
  let v: i32 = encoding.utf8_valid(&ok[0], 3);
  return v;
}
