// Hello World：程序正常输出走 std.fmt（stdout）
const fmt = import("std.fmt");

function main(): i32 {
  let msg: *u8 = "Hello World\n";
  let n: i32 = fmt.print(msg, 12);
  return if (n >= 0) { 0 } else { 1 };
}
