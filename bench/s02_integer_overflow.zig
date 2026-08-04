// s02_integer_overflow.zig — integer overflow check on/off overhead
// Compares "with overflow check" vs "without overflow check" (wrapping) i32 mul.
// Matches bench/s02_integer_overflow.c / .x algorithm.
// N=100000000 iterations, a = i*7919, b = i*6151.
// With check uses manual pre-check (a > maxInt(i32) / b); without uses *% wrapping.
const std = @import("std");

const N: i32 = 100_000_000;
var g_overflow: i32 = 0;

fn bench_with_check() i32 {
    var sum: i32 = 0;
    g_overflow = 0;
    var i: i32 = 0;
    while (i < N) : (i += 1) {
        const a = i *% 7919;
        const b = i *% 6151;
        if (b != 0 and a > @divTrunc(std.math.maxInt(i32), b)) {
            g_overflow +%= 1;
        } else {
            sum +%= a *% b;
        }
    }
    return sum;
}

fn bench_without_check() i32 {
    var sum: i32 = 0;
    var i: i32 = 0;
    while (i < N) : (i += 1) {
        const a = i *% 7919;
        const b = i *% 6151;
        sum +%= a *% b;
    }
    return sum;
}

pub fn main(init: std.process.Init) !void {
    const ts0 = std.Io.Timestamp.now(init.io, .awake);
    const s1 = bench_with_check();
    const ts1 = std.Io.Timestamp.now(init.io, .awake);
    const s2 = bench_without_check();
    const ts2 = std.Io.Timestamp.now(init.io, .awake);

    const ns1: i64 = @intCast(ts0.durationTo(ts1).nanoseconds);
    const ns2: i64 = @intCast(ts1.durationTo(ts2).nanoseconds);

    const ms1 = @as(f64, @floatFromInt(ns1)) / 1_000_000.0;
    const ms2 = @as(f64, @floatFromInt(ns2)) / 1_000_000.0;

    std.debug.print("with_check:     {d:.2} ms  sum={d}  overflow={d}\n", .{ ms1, s1, g_overflow });
    std.debug.print("without_check:  {d:.2} ms  sum={d}\n", .{ ms2, s2 });
}
