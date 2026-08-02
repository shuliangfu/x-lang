// r02_float_accum.zig — FP accumulation benchmark (matches r02_float_accum.c / .x)
const std = @import("std");

pub fn main() !void {
    const n: i32 = 100_000_000;
    var sum: f64 = 0.0;
    var i: i32 = 0;
    while (i < n) : (i += 1) {
        sum += @as(f64, @floatFromInt(i)) * 0.5;
    }
    const sum_i: i64 = @intFromFloat(sum);
    std.process.exit(@intCast(sum_i & 0xFF));
}
