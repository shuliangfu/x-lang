// cc01_thread_create.zig — 并发基准：线程创建/加入（Zig -O2 对照）
// 顺序 create+join N=10000 线程，每线程 WORK=64 步 base+i 累加。
const std = @import("std");

const N_THREADS: i32 = 10000;
const WORK: i32 = 64;

fn worker(base: i32, out: *i32) void {
    var sum: i32 = 0;
    var i: i32 = 0;
    while (i < WORK) : (i += 1) {
        sum += base + i;
    }
    asm volatile ("" : [sum] "+r" (sum) : : .{ .memory = true });
    out.* = sum;
}

pub fn main() !void {
    var total: i64 = 0;
    var t: i32 = 0;
    while (t < N_THREADS) : (t += 1) {
        var sum: i32 = 0;
        const thread = try std.Thread.spawn(.{}, worker, .{ t, &sum });
        thread.join();
        total += @as(i64, @intCast(sum));
    }
    asm volatile ("" : [total] "+r" (total) : : .{ .memory = true });
    std.process.exit(@intCast(total & 255));
}
