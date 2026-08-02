// cc04_parallel_reduce.zig — 并发基准：多线程分治规约（Zig -O2 对照）
// M=4 线程各对分片 [start,end) 计算 sum of squares of (i & 0x3FF)，主线程合并。
const std = @import("std");

const N_THREADS: usize = 4;
const SLICE: i64 = 10_000_000;
const N_TOTAL: i64 = N_THREADS * SLICE; // 40_000_000

fn worker(start: i64, end: i64, out: *i64) void {
    var sum: i64 = 0;
    var i: i64 = start;
    while (i < end) : (i += 1) {
        const v: i64 = i & 0x3FF;
        sum += v * v;
    }
    asm volatile ("" : [sum] "+r" (sum) : : .{ .memory = true });
    out.* = sum;
}

pub fn main() !void {
    var threads: [N_THREADS]std.Thread = undefined;
    var results: [N_THREADS]i64 = [_]i64{0} ** N_THREADS;
    var t: usize = 0;
    while (t < N_THREADS) : (t += 1) {
        const start: i64 = @as(i64, @intCast(t)) * SLICE;
        threads[t] = try std.Thread.spawn(.{}, worker, .{ start, start + SLICE, &results[t] });
    }
    var total: i64 = 0;
    t = 0;
    while (t < N_THREADS) : (t += 1) {
        threads[t].join();
        total += results[t];
    }
    asm volatile ("" : [total] "+r" (total) : : .{ .memory = true });
    std.process.exit(@intCast(total & 255));
}
