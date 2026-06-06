// io_mmap_throughput.zig — I/O 基线：大文件 mmap 顺序扫描（Zig -O2 对照）
const std = @import("std");

pub fn main() !void {
    const path = "tests/bench/.io_mmap_bench_tmp";
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const len = try file.getEndPos();
    if (len == 0) std.process.exit(1);
    const map = try std.os.mmap(null, len, std.os.PROT.READ, std.os.MAP.PRIVATE, file.handle, 0);
    defer std.os.munmap(map);
    var sum: i32 = 0;
    for (map) |b| {
        sum +%= @as(i32, @intCast(b));
    }
    std.process.exit(@intCast(sum & 255));
}
