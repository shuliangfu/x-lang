// 测试绑定 import + 跨模块 struct 类型
const driver = import("std.io.driver");

function main(): i32 {
  let buf: Buffer = Buffer { ptr: 0, len: 0, handle: 0 };
  return if (buf.handle == 0) { 0 } else { 1 };
}
