// io_batch_readv.zig — I/O 基线：4 段 readv 顺序读满 16MiB（Zig -O2 对照）
const std = @import("std");

const SEG: usize = 4096;
const ROUNDS: i32 = 1024;

pub fn main() !void {
    const path = "tests/bench/.io_mmap_bench_tmp";
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    var b0: [SEG]u8 = undefined;
    var b1: [SEG]u8 = undefined;
    var b2: [SEG]u8 = undefined;
    var b3: [SEG]u8 = undefined;
    var sum: i32 = 0;
    var r: i32 = 0;
    while (r < ROUNDS) : (r += 1) {
        const iovecs = [_]std.os.iovec{
            .{ .iov_base = &b0, .iov_len = SEG },
            .{ .iov_base = &b1, .iov_len = SEG },
            .{ .iov_base = &b2, .iov_len = SEG },
            .{ .iov_base = &b3, .iov_len = SEG },
        };
        const nr = try std.os.readv(file.handle, &iovecs);
        if (nr != SEG * 4) std.process.exit(2);
        for (b0) |b| sum +%= @as(i32, @intCast(b));
        for (b1) |b| sum +%= @as(i32, @intCast(b));
        for (b2) |b| sum +%= @as(i32, @intCast(b));
        for (b3) |b| sum +%= @as(i32, @intCast(b));
    }
    std.process.exit(@intCast(sum & 255));
}
