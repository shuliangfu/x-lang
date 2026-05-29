// mem_copy.zig — 与 tests/bench/mem_copy.su / mem_copy.c 等价的 Zig 参照
const std = @import("std");

pub fn main() !void {
    const n: usize = 4096;
    var buf: [4096]u8 = undefined;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        buf[i] = @truncate(i);
    }
    var j: usize = 0;
    var sum: i32 = 0;
    while (j < n) : (j += 1) {
        sum += @intCast(buf[j]);
    }
    std.process.exit(@intCast(sum));
}
