// io_write_throughput.zig — I/O 基线：大文件顺序 write（Zig -O2 对照）
const std = @import("std");

const CHUNK: usize = 4096;
const NUM_CHUNKS: i32 = 4096;

pub fn main() !void {
    const path = "tests/bench/.io_write_bench_tmp";
    const file = try std.fs.cwd().createFile(path, .{ .truncate = true });
    defer file.close();
    var buf: [CHUNK]u8 = undefined;
    var sum: i32 = 0;
    var ci: i32 = 0;
    while (ci < NUM_CHUNKS) : (ci += 1) {
        var bi: i32 = 0;
        while (bi < CHUNK) : (bi += 1) {
            const b: u8 = @intCast((ci + bi) & 255);
            buf[@intCast(bi)] = b;
            sum +%= @as(i32, @intCast(b));
        }
        try file.writeAll(&buf);
    }
    std.process.exit(@intCast(sum & 255));
}
