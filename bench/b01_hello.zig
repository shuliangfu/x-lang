// b01_hello.zig — 与 bench/b01_hello.x / .c 等价的 Zig 参照
// 最小 hello world 程序，用于二进制体积对比。
// 使用 pub fn main() void（非 !void）+ std.process.exit 绕过默认错误处理
// 运行时初始化开销，最小化二进制体积。
const std = @import("std");

pub fn main() void {
    std.process.exit(42);
}
