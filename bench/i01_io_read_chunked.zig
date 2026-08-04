// io_read_chunked.zig — I/O 基线：4KiB 块顺序读 4096 轮（16 MiB）（Zig 0.16 -OReleaseFast 对照）
//
// Mirrors bench/i01_io_read_chunked.x: open a 16 MiB file, read 4 KiB chunks
// for 4096 rounds, accumulate byte sum, exit with sum & 255.
const std = @import("std");

const PATH = "bench/.io_mmap_bench_tmp";
const CHUNK: usize = 4096;
const ROUNDS: i32 = 4096;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const file = try std.Io.Dir.cwd().openFile(io, PATH, .{});
    defer file.close(io);
    var buf: [CHUNK]u8 = undefined;
    var sum: i32 = 0;
    var rounds: i32 = 0;
    while (rounds < ROUNDS) : (rounds += 1) {
        var reader = file.reader(io, &buf);
        try reader.interface.readSliceAll(&buf);
        for (buf) |b| sum +%= @as(i32, @intCast(b));
    }
    std.process.exit(@intCast(sum & 255));
}
