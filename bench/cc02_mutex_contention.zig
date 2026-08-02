// cc02_mutex_contention.zig — 并发基准：互斥锁争用（Zig -O2 对照）
// M=4 线程各在共享互斥锁下对 counter 自增 N_ITERS=1e7 次，终值 = M*N。
const std = @import("std");

const N_THREADS: usize = 4;
const N_ITERS: i64 = 10_000_000;

fn worker(mtx: *std.atomic.Mutex, counter: *i64, iters: i64) void {
    var i: i64 = 0;
    while (i < iters) : (i += 1) {
        while (!mtx.tryLock()) {}
        counter.* += 1;
        mtx.unlock();
    }
}

pub fn main() !void {
    var mtx: std.atomic.Mutex = .unlocked;
    var counter: i64 = 0;
    var threads: [N_THREADS]std.Thread = undefined;
    var t: usize = 0;
    while (t < N_THREADS) : (t += 1) {
        threads[t] = try std.Thread.spawn(.{}, worker, .{ &mtx, &counter, N_ITERS });
    }
    t = 0;
    while (t < N_THREADS) : (t += 1) {
        threads[t].join();
    }
    asm volatile ("" : [counter] "+r" (counter) : : .{ .memory = true });
    std.process.exit(@intCast(counter & 255));
}
