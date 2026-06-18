// 测试 std.mem.Buffer：ABI 24 字节（ptr, len, handle）、register_buffer 占位
const mem = import("std.mem");

function main(): i32 {
  let b: Buffer = Buffer { ptr: 0, len: 0, handle: 0 }
  return mem.register_buffer(b);
}
