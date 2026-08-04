// s03_optional_result.zig — Optional/Result hot-path overhead
// Compares "direct return" vs "optional (?i32)" function call overhead.
// Matches bench/s03_optional_result.c / .x algorithm.
// N=100000000 calls. compute(x) = x * 42 + 7.
// Optional variant uses ?i32 with null on failure (x > 1000000).
const std = @import("std");

const N: i32 = 100_000_000;

fn compute_direct(x: i32) i32 {
    return x *% 42 +% 7;
}

fn compute_optional(x: i32) ?i32 {
    if (x > 1_000_000) return null;
    return x *% 42 +% 7;
}

fn bench_direct() i32 {
    var sum: i32 = 0;
    var i: i32 = 0;
    while (i < N) : (i += 1) {
        sum +%= compute_direct(i);
    }
    return sum;
}

fn bench_optional() i32 {
    var sum: i32 = 0;
    var i: i32 = 0;
    while (i < N) : (i += 1) {
        if (compute_optional(i)) |v| {
            sum +%= v;
        }
    }
    return sum;
}

pub fn main(init: std.process.Init) !void {
    const ts0 = std.Io.Timestamp.now(init.io, .awake);
    const s1 = bench_direct();
    const ts1 = std.Io.Timestamp.now(init.io, .awake);
    const s2 = bench_optional();
    const ts2 = std.Io.Timestamp.now(init.io, .awake);

    const ns1: i64 = @intCast(ts0.durationTo(ts1).nanoseconds);
    const ns2: i64 = @intCast(ts1.durationTo(ts2).nanoseconds);

    const ms1 = @as(f64, @floatFromInt(ns1)) / 1_000_000.0;
    const ms2 = @as(f64, @floatFromInt(ns2)) / 1_000_000.0;

    std.debug.print("direct:    {d:.2} ms  sum={d}\n", .{ ms1, s1 });
    std.debug.print("optional:  {d:.2} ms  sum={d}\n", .{ ms2, s2 });
}
