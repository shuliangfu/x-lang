// s01_bounds_check.zig — bounds check on/off overhead
// Compares "with bounds check" vs "without bounds check" array access.
// Matches bench/s01_bounds_check.c / .x algorithm.
// N=10000000 elements, R=10 rounds.
const std = @import("std");

const N: usize = 10_000_000;
const R: i32 = 10;
const N_I32: i32 = 10_000_000;

var arr: [N]i32 = undefined;
var idx: [N]i32 = undefined;

fn bench_with_check() i32 {
    var sum: i32 = 0;
    var r: i32 = 0;
    while (r < R) : (r += 1) {
        var i: usize = 0;
        while (i < N) : (i += 1) {
            const ii = idx[i];
            if (ii >= 0 and ii < N_I32) {
                sum +%= arr[@intCast(ii)];
            }
        }
    }
    return sum;
}

fn bench_without_check() i32 {
    var sum: i32 = 0;
    var r: i32 = 0;
    while (r < R) : (r += 1) {
        var i: usize = 0;
        while (i < N) : (i += 1) {
            sum +%= arr[@intCast(idx[i])];
        }
    }
    return sum;
}

pub fn main(init: std.process.Init) !void {
    var i: usize = 0;
    while (i < N) : (i += 1) {
        arr[i] = @intCast(i);
        const idx_val = @as(i32, @intCast(i)) *% 1103515245 +% 12345;
        idx[i] = @mod(idx_val, N_I32);
    }

    const ts0 = std.Io.Timestamp.now(init.io, .awake);
    const s1 = bench_with_check();
    const ts1 = std.Io.Timestamp.now(init.io, .awake);
    const s2 = bench_without_check();
    const ts2 = std.Io.Timestamp.now(init.io, .awake);

    const ns1: i64 = @intCast(ts0.durationTo(ts1).nanoseconds);
    const ns2: i64 = @intCast(ts1.durationTo(ts2).nanoseconds);

    const ms1 = @as(f64, @floatFromInt(ns1)) / 1_000_000.0;
    const ms2 = @as(f64, @floatFromInt(ns2)) / 1_000_000.0;

    std.debug.print("with_check:     {d:.2} ms  sum={d}\n", .{ ms1, s1 });
    std.debug.print("without_check:  {d:.2} ms  sum={d}\n", .{ ms2, s2 });
}
