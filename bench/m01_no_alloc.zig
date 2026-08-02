// m01_no_alloc.zig — 与 bench/m01_no_alloc.x / .c 等价的 Zig 参照
// 纯栈上计算 sum of squares 1..N, N=100000000，无分配。
// 使用 wrapping 算术（*% / +%）以匹配 C/xlang 的 i32 溢出回绕语义。
const std = @import("std");

pub fn main() !void {
    const n: i32 = 100_000_000;
    var sum: i32 = 0;
    var i: i32 = 1;
    while (i <= n) : (i += 1) {
        sum +%= i *% i;
    }
    std.process.exit(@intCast(sum & 0xFF));
}
