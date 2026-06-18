// io_random_pread.zig — I/O 基线：随机 offset pread（Zig -O2 对照，PERF-002）
const std = @import("std");

const SEG: usize = 4096;
const PAGES: u32 = 4096;
const ROUNDS: i32 = 1024;

pub fn main() !void {
    const path = "tests/bench/.io_mmap_bench_tmp";
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    var buf: [SEG]u8 = undefined;
    var sum: i32 = 0;
    var seed: u32 = 12345;
    var r: i32 = 0;
    while (r < ROUNDS) : (r += 1) {
        seed = seed *% 1103515245 +% 12345;
        const page: u32 = seed % PAGES;
        const off: u64 = @as(u64, page) * SEG;
        const nr = try file.preadAll(&buf, off);
        if (nr != SEG) std.process.exit(2);
        for (buf) |b| sum +%= @as(i32, @intCast(b));
    }
    std.process.exit(@intCast(sum & 255));
}
