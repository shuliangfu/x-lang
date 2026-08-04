// s05_release_safe_vs_fast.zig — mixed workload benchmark
// Matches bench/s05_release_safe_vs_fast.c / .x algorithm.
// This file is compiled with -OReleaseSafe and -OReleaseFast separately
// by the aggregation script to compare the two build modes.
// Mixed: array access + integer arithmetic + byte string scan.
const std = @import("std");

const N: i32 = 100_000_000;
const M: usize = 10_000;
const M_I32: i32 = 10_000;

pub fn main() !void {
    var arr: [M]i32 = undefined;
    var str_data: [M]u8 = undefined;

    var i: usize = 0;
    while (i < M) : (i += 1) {
        arr[i] = @intCast(i);
        str_data[i] = @truncate((i * 31 + 17) & 0xFF);
    }

    var sum: i32 = 0;
    var str_count: i32 = 0;
    var ii: i32 = 0;
    while (ii < N) : (ii += 1) {
        const j: usize = @intCast(@rem(ii, M_I32));
        sum +%= arr[j] *% ii;
        if (str_data[j] > 127) {
            str_count +%= 1;
        }
    }

    const result: i32 = sum + str_count;
    std.process.exit(@intCast(result & 0xFF));
}
