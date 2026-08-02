// i02_multi_file_read.zig — 多文件并发读吞吐（Zig 0.16 -OReleaseFast 对照）
//
// Mirrors bench/i02_multi_file_read.x: write F=8 × 1 MiB temp files under /tmp,
// run T=4 worker threads that each read per=F/T files in 64 KiB chunks,
// print total GB/s, then clean up. Uses std.posix + libc close/write so each
// worker thread holds its own fd without needing a per-thread Io instance.
const std = @import("std");

const F: usize = 8;
const T: usize = 4;
const FILE_BYTES: usize = 1024 * 1024;
const CHUNK: usize = 64 * 1024;

extern "c" fn close(fd: c_int) c_int;
extern "c" fn write(fd: c_int, buf: [*]const u8, n: usize) isize;

fn pathFor(buf: *[32]u8, idx: usize) [:0]u8 {
    const base = "/tmp/i02_bench_file_";
    @memcpy(buf[0..base.len], base);
    buf[base.len] = '0' + @as(u8, @intCast(idx));
    const suffix = ".dat";
    @memcpy(buf[base.len + 1 ..][0..suffix.len], suffix);
    buf[base.len + 1 + suffix.len] = 0;
    return buf[0 .. base.len + 1 + suffix.len :0];
}

fn reader(file_start: usize, file_count: usize, out: *u64) void {
    var total: u64 = 0;
    var buf: [CHUNK]u8 = undefined;
    var fi: usize = file_start;
    while (fi < file_start + file_count) : (fi += 1) {
        var path_buf: [32]u8 = undefined;
        const path = pathFor(&path_buf, fi);
        const fd = std.posix.openat(std.posix.AT.FDCWD, path, .{ .ACCMODE = .RDONLY }, 0) catch {
            out.* = total;
            return;
        };
        var remaining: usize = FILE_BYTES;
        while (remaining > 0) {
            const to_read: usize = @min(CHUNK, remaining);
            const nr = std.posix.read(fd, buf[0..to_read]) catch break;
            if (nr == 0) break;
            total += @as(u64, @intCast(nr));
            remaining -= @intCast(nr);
        }
        _ = close(fd);
    }
    asm volatile ("" : [total] "+r" (total) : : .{ .memory = true });
    out.* = total;
}

pub fn main(init: std.process.Init) !void {
    // ---- Phase 1: write F x 1 MiB temp files (single thread, main Io) ----
    var wbuf: [CHUNK]u8 = undefined;
    for (&wbuf, 0..) |*b, i| b.* = @intCast(i & 255);

    var f: usize = 0;
    while (f < F) : (f += 1) {
        var path_buf: [32]u8 = undefined;
        const path = pathFor(&path_buf, f);
        const fd = try std.posix.openat(std.posix.AT.FDCWD, path, .{
            .ACCMODE = .WRONLY,
            .CREAT = true,
            .TRUNC = true,
        }, 0o644);
        var remaining: usize = FILE_BYTES;
        while (remaining > 0) {
            const nw = write(fd, &wbuf, @min(CHUNK, remaining));
            if (nw <= 0) {
                _ = close(fd);
                return error.WriteFail;
            }
            remaining -= @intCast(nw);
        }
        _ = close(fd);
    }

    // ---- Phase 2: timed parallel read with T threads ----
    const t0 = std.Io.Timestamp.now(init.io, .awake);

    var threads: [T]std.Thread = undefined;
    var results: [T]u64 = [_]u64{0} ** T;
    const per: usize = F / T;
    var ti: usize = 0;
    while (ti < T) : (ti += 1) {
        threads[ti] = try std.Thread.spawn(.{}, reader, .{ ti * per, per, &results[ti] });
    }
    ti = 0;
    while (ti < T) : (ti += 1) threads[ti].join();

    const t1 = std.Io.Timestamp.now(init.io, .awake);
    const elapsed_ns: i128 = @intCast(t0.durationTo(t1).nanoseconds);

    var total_bytes: u64 = 0;
    for (results) |x| total_bytes += x;
    const secs: f64 = @as(f64, @floatFromInt(elapsed_ns)) / 1e9;
    const gbps: f64 = (@as(f64, @floatFromInt(total_bytes)) / (1024.0 * 1024.0 * 1024.0)) / secs;

    var stderr_buf: [256]u8 = undefined;
    var stderr = std.Io.File.stderr().writer(init.io, &stderr_buf);
    try stderr.interface.print("i02: files={d} threads={d} bytes={d} in {d:.6}s = {d:.3} GB/s\n",
        .{ F, T, total_bytes, secs, gbps });
    try stderr.interface.flush();

    // ---- Phase 3: cleanup ----
    f = 0;
    while (f < F) : (f += 1) {
        var path_buf: [32]u8 = undefined;
        const path = pathFor(&path_buf, f);
        std.Io.Dir.cwd().deleteFile(init.io, path[0..path.len]) catch {};
    }

    asm volatile ("" : [total_bytes] "+r" (total_bytes) : : .{ .memory = true });
    std.process.exit(@intCast(total_bytes & 255));
}
