// 烟测：std.debug println 字符串字面量（stderr）+ assert 重导出
const dbg = import("std.debug");

function main(): i32 {
  let a: i32 = dbg.println("debug line");
  let b: i32 = dbg.assert(true);
  return if (a == 0 && b == 0) { 0 } else { 1 };
}
