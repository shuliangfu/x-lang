// cc05_thread_affinity.zig — 线程亲和/绑核测方差（Zig -O2 对照）
// 5 轮：每轮 spawn 1 线程做 N=100000000 LCG 累加，join，记录 wall-clock
// 时间，报告 median + 方差。
// Note: Zig 无可移植的 CPU-affinity API，不绑核（unpinned）。
const std = @import("std");

const N: i32 = 100_000_000;
const ROUNDS: usize = 5;

fn worker(out: *i32) void {
    var s: i32 = 0;
    var i: i32 = 0;
    while (i < N) : (i += 1) {
        const t: i32 = i *% 1103515245 +% 12345;
        s ^= t;
    }
    asm volatile ("" : [s] "+r" (s) : : .{ .memory = true });
    out.* = s;
}

pub fn main(init: std.process.Init) !void {
    var samples: [ROUNDS]f64 = undefined;
    var sink: i32 = 0;
    var r: usize = 0;
    while (r < ROUNDS) : (r += 1) {
        var result: i32 = 0;
        const ts0 = std.Io.Timestamp.now(init.io, .awake);
        const thread = try std.Thread.spawn(.{}, worker, .{ &result });
        thread.join();
        const ts1 = std.Io.Timestamp.now(init.io, .awake);
        const elapsed_ns: i64 = @intCast(ts0.durationTo(ts1).nanoseconds);
        samples[r] = @as(f64, @floatFromInt(elapsed_ns)) / 1e9;
        sink ^= result;
    }

    // Insertion sort (5 elements — avoids std.sort API version differences).
    var i: usize = 1;
    while (i < ROUNDS) : (i += 1) {
        var j: usize = i;
        while (j > 0 and samples[j] < samples[j - 1]) {
            const tmp: f64 = samples[j];
            samples[j] = samples[j - 1];
            samples[j - 1] = tmp;
            j -= 1;
        }
    }
    const median: f64 = samples[ROUNDS / 2];

    // Population variance.
    var mean: f64 = 0;
    for (samples) |x| mean += x;
    mean /= @as(f64, @floatFromInt(ROUNDS));
    var variance: f64 = 0;
    for (samples) |x| {
        const d: f64 = x - mean;
        variance += d * d;
    }
    variance /= @as(f64, @floatFromInt(ROUNDS));

    std.debug.print("cc05: rounds={d} N={d} pin=0 median={d}s variance={e} mean={d}s\n",
        .{ ROUNDS, N, median, variance, mean });

    asm volatile ("" : [sink] "+r" (sink) : : .{ .memory = true });
    std.process.exit(@intCast(sink & 255));
}
